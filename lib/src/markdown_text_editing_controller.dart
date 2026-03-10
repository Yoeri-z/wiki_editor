import 'package:flutter/material.dart';
import 'markdown_highlighter.dart';

class MarkdownTextEditingController extends TextEditingController {
  MarkdownTextEditingController({super.text, MarkdownHighlighter? highlighter})
    : highlighter = highlighter ?? MarkdownHighlighter();

  final MarkdownHighlighter highlighter;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    return highlighter.buildTextSpan(text, style);
  }
}
