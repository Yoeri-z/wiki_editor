import 'package:flutter/material.dart';

import 'package:wiki_editor/src/document/wiki_document.dart';
import 'package:wiki_editor/src/editor/wiki_default_styles.dart';
import 'package:wiki_editor/src/parser/lexer.dart';

class WikiController extends TextEditingController {
  WikiController() : document = WikiDocument();

  WikiController.fromDocument(this.document);

  WikiDocument document;

  final lexer = WikiLexer();

  Object? error;

  bool get hasParseError => error != null;

  void _syncDocument() {
    try {
      document = WikiDocument.fromContent(text);
      error = null;
    } catch (e) {
      error = e;
    }
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    _syncDocument();

    final segments = WikiLexer.split(text);

    return TextSpan(
      children: [
        for (final segment in segments)
          switch (segment) {
            TokenSegment seg => TextSpan(
              text: seg.text,
              style: style?.copyWith(
                color: WikiEditorTheme.of(context).tokenColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSegment seg => TextSpan(text: seg.text, style: style),
          },
      ],
    );
  }
}
