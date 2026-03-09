import 'package:collection/collection.dart';
import 'package:wiki_editor/src/parser/lexer.dart';
import '../parser/nodes.dart';
import '../parser/parser.dart';

class _DocumentLine {
  _DocumentLine(this.rawText, this.segments)
      : hasCodeFence = segments
            .any((s) => s is TokenSegment && s.type == TokenType.codeBlock),
        hasLatexFence = segments
            .any((s) => s is TokenSegment && s.type == TokenType.latexBlock);

  final String rawText;
  final List<WikiSegment> segments;
  final bool hasCodeFence;
  final bool hasLatexFence;
}

class BlockInfo {
  BlockInfo(this.node, this.startLine, this.endLine);

  final BlockNode node;
  final int startLine;
  final int endLine;

  @override
  String toString() => 'BlockInfo($node, lines: $startLine-$endLine)';
}

class WikiDocument {
  WikiDocument();

  factory WikiDocument.fromContent(String content) {
    final document = WikiDocument();
    final lines = content.split('\n');
    document._lines.addAll(
      lines.map((line) => _DocumentLine(line, WikiLexer.split(line))),
    );
    document._firstDirtyLine = 0;
    document._recalculateBlockMarkers();
    return document;
  }

  final List<_DocumentLine> _lines = [];
  List<BlockInfo> _blockInfos = [];
  int? _firstDirtyLine;

  // O(1) lookup cache for block states per line
  final List<bool> _lineInCodeBlock = [];
  final List<bool> _lineInLatexBlock = [];

  int get lineCount => _lines.length;

  /// Get the segments in the line at [index], returns an empty list if this line was not registered.
  List<WikiSegment> getSegments(int index) {
    if (index < 0 || index >= _lines.length) return [];
    return _lines[index].segments;
  }

  /// Get the block in the line at [index].
  BlockNode? getBlock(int index) {
    if (_firstDirtyLine != null) {
      _reparse();
    }

    if (index >= _lines.length) return null;

    for (final block in _blockInfos) {
      if (block.startLine <= index && block.endLine >= index) {
        if (block.startLine == index) return block.node;
      }
    }
    return null;
  }

  /// Get the rawtext in the line at [index], returns null if this line was not registered.
  String? getRawText(int index) {
    if (index < 0 || index >= _lines.length) return null;
    return _lines[index].rawText;
  }

  /// O(1) check if a line is part of a code block.
  bool isCodeBlock(int line) {
    if (line < 0 || line >= _lineInCodeBlock.length) return false;
    return _lineInCodeBlock[line];
  }

  /// O(1) check if a line is part of a latex display block.
  bool isLatexBlock(int line) {
    if (line < 0 || line >= _lineInLatexBlock.length) return false;
    return _lineInLatexBlock[line];
  }

  void _recalculateBlockMarkers() {
    _lineInCodeBlock.clear();
    _lineInLatexBlock.clear();
    bool insideCode = false;
    bool insideLatex = false;
    for (int i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      
      _lineInCodeBlock.add(insideCode || line.hasCodeFence);
      if (line.hasCodeFence) insideCode = !insideCode;

      _lineInLatexBlock.add(insideLatex || line.hasLatexFence);
      if (line.hasLatexFence) insideLatex = !insideLatex;
    }
  }

  List<BlockNode> get blocks {
    if (_firstDirtyLine != null) {
      _reparse();
    }
    return _blockInfos.map((i) => i.node).toList();
  }

  List<BlockInfo> get blockInfos {
    if (_firstDirtyLine != null) {
      _reparse();
    }
    return _blockInfos;
  }

  void updateLine(int index, String text) {
    bool oldHasCodeFence = false;
    bool oldHasLatexFence = false;
    if (index >= 0 && index < _lines.length) {
      oldHasCodeFence = _lines[index].hasCodeFence;
      oldHasLatexFence = _lines[index].hasLatexFence;
    }

    final newLine = _DocumentLine(text, WikiLexer.split(text));
    final sizeChanged = index >= _lines.length;

    if (index >= 0 && index < _lines.length) {
      _lines[index] = newLine;
    } else if (index == _lines.length) {
      _lines.add(newLine);
    } else {
      while (_lines.length < index) {
        _lines.add(_DocumentLine('', []));
      }
      _lines.add(newLine);
    }

    // Only recalculate if fence state changed or document size changed
    if (sizeChanged || 
        oldHasCodeFence != newLine.hasCodeFence || 
        oldHasLatexFence != newLine.hasLatexFence) {
      _recalculateBlockMarkers();
    } else {
      if (_lineInCodeBlock.length <= index || _lineInLatexBlock.length <= index) {
        _recalculateBlockMarkers();
      }
    }

    _markDirty(index);
  }

  void _markDirty(int index) {
    if (_firstDirtyLine == null || index < _firstDirtyLine!) {
      _firstDirtyLine = index;
    }
  }

  void _reparse() {
    if (_firstDirtyLine == null) return;

    int reparseStartLine = 0;
    int blockIdxToReplace = 0;

    for (int i = 0; i < _blockInfos.length; i++) {
      final info = _blockInfos[i];
      if (info.startLine <= _firstDirtyLine! &&
          info.endLine >= _firstDirtyLine!) {
        reparseStartLine = info.startLine;
        blockIdxToReplace = i;
        break;
      }

      if (info.startLine > _firstDirtyLine!) {
        reparseStartLine = _firstDirtyLine!;
        blockIdxToReplace = i;
        break;
      }

      if (i == _blockInfos.length - 1) {
        reparseStartLine = info.endLine + 1;
        if (reparseStartLine > _firstDirtyLine!)
          reparseStartLine = info.startLine;
        blockIdxToReplace = _blockInfos.length;
      }
    }

    if (_blockInfos.isEmpty) {
      reparseStartLine = 0;
      blockIdxToReplace = 0;
    }

    final reparseText = _getRawTextFrom(reparseStartLine);

    try {
      final parsedBlocks = WikiParser.parseWithOffsets(reparseText);

      final List<int> relativeLineStartOffsets = [];
      int currentOffset = 0;
      for (int i = reparseStartLine; i < _lines.length; i++) {
        relativeLineStartOffsets.add(currentOffset);
        currentOffset += _lines[i].rawText.length + 1;
      }

      final newBlockInfos = parsedBlocks.map((pb) {
        final relStartLine = _findLineForOffset(
          relativeLineStartOffsets,
          pb.startOffset,
          isEnd: false,
        );
        final relEndLine = _findLineForOffset(
          relativeLineStartOffsets,
          pb.endOffset,
          isEnd: true,
        );
        return BlockInfo(
          pb.node,
          reparseStartLine + relStartLine,
          reparseStartLine + relEndLine,
        );
      }).toList();

      _blockInfos.removeRange(blockIdxToReplace, _blockInfos.length);
      _blockInfos.addAll(newBlockInfos);

      _firstDirtyLine = null;
    } catch (e) {
      _firstDirtyLine = null;
    }
  }

  int _findLineForOffset(
    List<int> lineStartOffsets,
    int offset, {
    required bool isEnd,
  }) {
    if (lineStartOffsets.isEmpty) return 0;
    final index = lowerBound(lineStartOffsets, offset);

    if (index < lineStartOffsets.length && lineStartOffsets[index] == offset) {
      return (isEnd && index > 0) ? index - 1 : index;
    }

    return (index > 0) ? index - 1 : 0;
  }

  String _getRawTextFrom(int startLine) {
    if (startLine >= _lines.length) return '';
    return _lines.sublist(startLine).map((l) => l.rawText).join('\n');
  }

  String _getRawFullText() {
    if (_lines.isEmpty) return '';
    return _lines.map((l) => l.rawText).join('\n');
  }

  void shiftLines(int fromIndex, int delta) {
    if (delta == 0) return;

    if (delta > 0) {
      for (var i = 0; i < delta; i++) {
        if (fromIndex <= _lines.length) {
          _lines.insert(fromIndex, _DocumentLine('', []));
        } else {
          _lines.add(_DocumentLine('', []));
        }
      }
    } else {
      final countToRemove = -delta;
      for (var i = 0; i < countToRemove; i++) {
        if (fromIndex < _lines.length) {
          _lines.removeAt(fromIndex);
        }
      }
    }
    _recalculateBlockMarkers();
    _markDirty(fromIndex);
  }

  void cutLines(int totalLineCount) {
    if (_lines.length > totalLineCount) {
      _lines.removeRange(totalLineCount, _lines.length);
      _recalculateBlockMarkers();
      _markDirty(totalLineCount);
    }
  }

  String toWikiText() => _getRawFullText();

  void clear() {
    _lines.clear();
    _blockInfos = [];
    _lineInCodeBlock.clear();
    _lineInLatexBlock.clear();
    _firstDirtyLine = null;
  }
}
