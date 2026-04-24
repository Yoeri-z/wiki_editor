import 'package:flutter/material.dart';

/// A standalone text editor widget with support for a custom [TextEditingController].
/// Usually used with [MarkdownTextEditingController] for syntax highlighting.
class WikiTextEditor extends StatelessWidget {
  /// The controller for the text field.
  final TextEditingController controller;

  /// Whether the editor should be multiline.
  final bool isMultiline;

  /// Decoration of the text field.
  final InputDecoration? decoration;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  const WikiTextEditor({
    super.key,
    required this.controller,
    this.isMultiline = true,
    this.decoration,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: isMultiline ? null : 1,
      decoration: decoration,
      textAlignVertical: TextAlignVertical.top,
    );
  }
}
