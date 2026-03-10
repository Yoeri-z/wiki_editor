import 'package:flutter/material.dart';
import 'package:wiki_editor/src/markdown_highlighter.dart';
import 'markdown_text_editing_controller.dart';
import 'wiki_preview_widget.dart';
import 'wiki_text_editor.dart';

/// A comprehensive workspace widget that provides both a Markdown editor and a live preview.
///
/// It supports responsive layouts, automatically switching to side-by-side mode on wide screens
/// unless [useAdaptiveLayout] is set to false.
class WikiEditorWorkspace extends StatefulWidget {
  const WikiEditorWorkspace({
    super.key,
    this.initialValue,
    this.highlighter,
    this.onChanged,
    this.isMultiline = true,
    this.label = 'Markdown Editor',
    this.showPreview = false,
    this.useAdaptiveLayout = true,
  });

  /// The initial text value for the editor.
  final String? initialValue;

  /// Optional highlighter configuration for syntax highlighting.
  final MarkdownHighlighter? highlighter;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Whether the editor should support multiple lines.
  final bool isMultiline;

  /// The label for the text field.
  final String label;

  /// Whether to show the preview widget in non-adaptive or narrow modes.
  final bool showPreview;

  /// If this is true, the preview widget will be displayed alongside the editor
  /// when screen width is sufficient (>= 800).
  final bool useAdaptiveLayout;

  @override
  State<WikiEditorWorkspace> createState() => _WikiEditorWorkspaceState();
}

class _WikiEditorWorkspaceState extends State<WikiEditorWorkspace> {
  late MarkdownTextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MarkdownTextEditingController(
      text: widget.initialValue,
      highlighter: widget.highlighter,
    );
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant WikiEditorWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.highlighter != widget.highlighter) {
      final newController = MarkdownTextEditingController(
        text: _controller.text,
        highlighter: widget.highlighter,
      );

      _controller.dispose();
      _controller = newController;
    }
  }

  void _handleTextChange() {
    widget.onChanged?.call(_controller.text);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = widget.useAdaptiveLayout &&
            constraints.maxWidth > 800 &&
            widget.isMultiline;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: WikiTextEditor(
                  controller: _controller,
                  isMultiline: true,
                  label: widget.label,
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: WikiPreview(data: _controller.text),
              ),
            ],
          );
        }

        return widget.showPreview && widget.isMultiline
            ? WikiPreview(data: _controller.text)
            : WikiTextEditor(
                controller: _controller,
                isMultiline: widget.isMultiline,
                label: widget.label,
              );
      },
    );
  }
}
