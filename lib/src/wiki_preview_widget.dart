import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:markdown/markdown.dart' as md;

/// A standalone widget to display Markdown with LaTeX support.
class WikiPreview extends StatelessWidget {
  const WikiPreview({
    super.key,
    required this.data,
    this.selectable = true,
    this.padding = const EdgeInsets.all(8.0),
    this.decoration,
  });

  /// The markdown text to display.
  final String data;

  /// Whether the text should be selectable.
  final bool selectable;

  /// Optional padding around the preview.
  final EdgeInsetsGeometry padding;

  /// Optional decoration for the preview container.
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration:
            decoration ??
            BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
        clipBehavior: Clip.antiAlias,
        child: MarkdownBody(
          data: data,
          selectable: selectable,
          extensionSet: md.ExtensionSet(
            [
              ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
              LatexBlockSyntax(),
            ],
            [
              ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
              LatexInlineSyntax(),
            ],
          ),
          builders: {'latex': LatexElementBuilder()},
        ),
      ),
    );
  }
}
