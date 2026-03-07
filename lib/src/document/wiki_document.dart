import 'package:wiki_editor/src/parser/lexer.dart';
import '../parser/nodes.dart';
import '../parser/parser.dart';

class _DocumentLine {
  const _DocumentLine(this.rawText, this.segments, this.block);
  final String rawText;
  final List<WikiSegment> segments;
  final BlockNode block;
}

class WikiDocument {
  WikiDocument();

  factory WikiDocument.fromContent(String content) {
    final document = WikiDocument();
    final lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      document.updateLine(i, lines[i]);
    }
    return document;
  }

  final _lines = <int, _DocumentLine>{};

  int get lineCount => _lines.length;

  ///Get the segments in the line at [index], returns an empty list if this line was not registered.
  List<WikiSegment> getSegments(int index) => _lines[index]?.segments ?? [];

  ///Get the block in the line at [index], returns an [EmptyBlockNode] if this line was not registered.
  BlockNode getBlock(int index) => _lines[index]?.block ?? EmptyBlockNode();

  ///Get the rawtext in the line at [index], returns null if this line was not registered.
  String? getRawText(int index) => _lines[index]?.rawText;

  List<BlockNode> get blocks {
    if (_lines.isEmpty) return [];
    final maxIndex = _lines.keys.reduce((a, b) => a > b ? a : b);
    return List.generate(maxIndex + 1, (i) => getBlock(i));
  }

  void updateLine(int index, String text) {
    BlockNode block;
    try {
      block = WikiParser.parse(text).firstOrNull ?? EmptyBlockNode();
    } catch (e) {
      block = _lines[index]?.block ?? EmptyBlockNode();
    }

    _lines[index] = _DocumentLine(text, WikiLexer.split(text), block);
  }

  void shiftLines(int fromIndex, int delta) {
    if (delta == 0) return;

    final shifted = <int, _DocumentLine>{};
    for (final entry in _lines.entries) {
      if (entry.key < fromIndex) {
        shifted[entry.key] = entry.value;
      } else {
        final newKey = entry.key + delta;
        if (newKey >= 0) shifted[newKey] = entry.value;
      }
    }

    _lines
      ..clear()
      ..addAll(shifted);
  }

  void cutLines(int totalLineCount) {
    _lines.removeWhere((key, _) => key >= totalLineCount);
  }

  String toWikiText() => WikiParser.unparse(blocks);

  void clear() => _lines.clear();
}
