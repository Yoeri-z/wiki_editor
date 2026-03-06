import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wiki_editor/src/document/wiki_controller.dart';

class _EditorSelectionGestureDetectorBuilder
    extends TextSelectionGestureDetectorBuilder {
  _EditorSelectionGestureDetectorBuilder({required _WikiCodeEditorState state})
    : super(delegate: state);
}

class WikiCodeEditor extends StatefulWidget {
  const WikiCodeEditor({
    super.key,
    this.textStyle,
    this.cursorColor,
    this.readOnly = false,
    this.selectionControls,
    this.selectionEnabled = true,
    required this.controller,
  });

  final TextStyle? textStyle;
  final TextSelectionControls? selectionControls;
  final Color? cursorColor;
  final bool readOnly;
  final bool selectionEnabled;
  final WikiController controller;

  @override
  State<WikiCodeEditor> createState() => _WikiCodeEditorState();
}

class _WikiCodeEditorState extends State<WikiCodeEditor>
    implements TextSelectionGestureDetectorBuilderDelegate {
  final focusNode = FocusNode();

  @override
  GlobalKey<EditableTextState> editableTextKey = GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.selectionEnabled;

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style;
    final selectionStyle = DefaultSelectionStyle.of(context);
    TextSelectionControls? selectionControls = widget.selectionControls;

    if (selectionControls == null) {
      if (defaultTargetPlatform == .iOS || defaultTargetPlatform == .macOS) {
        selectionControls = cupertinoTextSelectionControls;
      }
      if (defaultTargetPlatform == .android ||
          defaultTargetPlatform == .fuchsia) {
        selectionControls = materialTextSelectionControls;
      } else {
        selectionControls = desktopTextSelectionControls;
      }
    }

    return _EditorSelectionGestureDetectorBuilder(
      state: this,
    ).buildGestureDetector(
      child: RepaintBoundary(
        child: EditableText(
          key: editableTextKey,
          controller: widget.controller,
          focusNode: focusNode,
          style: textStyle,
          readOnly: widget.readOnly,
          selectionControls: selectionControls,
          selectionColor: selectionStyle.selectionColor,
          enableInteractiveSelection: true,
          cursorColor: selectionStyle.cursorColor ?? Colors.blueGrey,
          backgroundCursorColor: selectionStyle.cursorColor ?? Colors.blueGrey,
          maxLines: null,
        ),
      ),
    );
  }
}
