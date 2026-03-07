import 'package:flutter/widgets.dart';
import 'package:wiki_editor/src/document/wiki_document.dart';
import 'package:wiki_editor/src/editor/wiki_default_styles.dart';
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
      for (final segment in document.getSegments(i)) {
        allLineSpans.add(switch (segment) {
          TokenSegment seg => TextSpan(
            text: seg.text,
            style: style?.copyWith(
              color: _getThemeColor(context, seg.type),
              fontWeight: seg.type == TokenType.bold || seg.type == TokenType.h1
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          TextSegment seg => TextSpan(text: seg.text, style: style),
        });
      }

      if (i < lines.length - 1) {
        allLineSpans.add(TextSpan(text: '\n', style: style));
      }
    }

    return TextSpan(children: allLineSpans, style: style);
  }

  Color _getThemeColor(BuildContext context, TokenType type) {
    final theme = WikiEditorTheme.of(context);
    return switch (type) {
      .bold => theme.boldColor,
      .italic => theme.italicColor,
      .wikiOpen => theme.linkColor,
      .latexInline || .latexDisplay => theme.latexColor,
      .h1 || .ul || .ol => theme.headerColor,
      _ => theme.tokenColor,
    };
  }

  void resetCache() => document.clear();
}
