import 'package:flutter/widgets.dart';
import 'package:wiki_editor/src/document/wiki_document.dart';
import 'package:wiki_editor/src/editor/wiki_editor_theme.dart';
import 'package:wiki_editor/src/parser/lexer.dart';

class WikiController extends TextEditingController {
  WikiController() : document = WikiDocument();

  WikiDocument document;

  void _diffCache(List<String> newLines) {
    final delta = newLines.length - document.lineCount;

    if (delta != 0) {
      final splitPoint = _getLineAtOffset(text, selection.baseOffset);
      document.shiftLines(splitPoint, delta);
      document.cutLines(newLines.length);
    }

    int linesDiffed = 0;

    for (int i = 0; i < newLines.length; i++) {
      if (document.getRawText(i) != newLines[i]) {
        document.updateLine(i, newLines[i]);
        linesDiffed++;
      }
    }

    debugPrint('Diffing summary');
    debugPrint(' - Lines hit: $linesDiffed');
    debugPrint(' - Delta: $delta');
  }

  int _getLineAtOffset(String text, int offset) {
    if (offset <= 0) return 0;
    if (offset > text.length) offset = text.length;
    return '\n'.allMatches(text.substring(0, offset)).length;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final lines = text.split('\n');

    if (lines.length != document.lineCount) {
      _diffCache(lines);
    } else {
      final index = _getLineAtOffset(text, selection.baseOffset);
      document.updateLine(index, lines[index]);
    }

    final List<TextSpan> allLineSpans = [];

    for (int i = 0; i < lines.length; i++) {
      final isCode = document.isCodeBlock(i);
      final isLatex = document.isLatexBlock(i);
      final segments = document.getSegments(i);

      for (final segment in segments) {
        allLineSpans.add(switch (segment) {
          TokenSegment seg => TextSpan(
            text: seg.text,
            style: style?.merge(
              _getThemeStyle(context, seg.type, isCode, isLatex),
            ),
          ),
          TextSegment seg => TextSpan(
            text: seg.text,
            style: style?.merge(
              _getThemeStyle(context, TokenType.text, isCode, isLatex),
            ),
          ),
        });
      }

      if (i < lines.length - 1) {
        allLineSpans.add(TextSpan(text: '\n', style: style));
      }
    }

    return TextSpan(children: allLineSpans, style: style);
  }

  TextStyle _getThemeStyle(
    BuildContext context,
    TokenType type,
    bool isCodeBlock,
    bool isLatexBlock,
  ) {
    final theme = WikiEditorTheme.of(context);

    if (isCodeBlock) {
      return theme.inlineCodeStyle;
    }

    if (isLatexBlock) {
      return theme.latexStyle;
    }

    return switch (type) {
      TokenType.bold => theme.boldStyle,
      TokenType.italic => theme.italicStyle,
      TokenType.strikethrough => theme.strikethroughStyle,
      TokenType.inlineCode || TokenType.codeBlock => theme.inlineCodeStyle,
      TokenType.wikiOpen => theme.linkStyle,
      TokenType.latexInline ||
      TokenType.latexDisplay ||
      TokenType.latexBlock => theme.latexStyle,
      TokenType.h1 ||
      TokenType.h2 ||
      TokenType.h3 ||
      TokenType.h4 ||
      TokenType.h5 ||
      TokenType.h6 ||
      TokenType.ul ||
      TokenType.ol ||
      TokenType.blockquote ||
      TokenType.hr => theme.headerStyle,
      _ => theme.textStyle,
    };
  }

  void resetCache() => document.clear();
}
