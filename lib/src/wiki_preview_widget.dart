import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:markdown/markdown.dart' as md;

/// A standalone widget to display Markdown with LaTeX support.
class WikiPreview extends StatelessWidget {
  const WikiPreview({super.key, required this.data, this.selectable = true});

  /// The markdown text to display.
  final String data;

  /// Whether the text should be selectable.
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: selectable,
      extensionSet: md.ExtensionSet(
        [...md.ExtensionSet.gitHubFlavored.blockSyntaxes, LatexBlockSyntax()],
        [...md.ExtensionSet.gitHubFlavored.inlineSyntaxes, LatexInlineSyntax()],
      ),
      builders: {'latex': LatexElementBuilder()},
    );
  }
}
