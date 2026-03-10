import 'package:flutter/material.dart';

/// A standalone text editor widget with support for a custom [TextEditingController].
/// Usually used with [MarkdownTextEditingController] for syntax highlighting.
class WikiTextEditor extends StatelessWidget {
  /// The controller for the text field.
  final TextEditingController controller;

  /// Whether the editor should be multiline.
  final bool isMultiline;

  /// The label for the text field.
  final String label;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Optional padding around the editor.
  final EdgeInsetsGeometry padding;

  const WikiTextEditor({
    super.key,
    required this.controller,
    this.isMultiline = true,
    this.label = 'Markdown Editor',
    this.onChanged,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: isMultiline ? null : 1,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }
}
