import 'package:flutter/widgets.dart';
import 'package:wiki_editor/wiki_editor.dart';

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key, required WikiController controller})
    : _controller = controller,
      _wikiText = null;

  DisplayWidget.fromText(String text) : _wikiText = text, _controller = null;

  final WikiController? _controller;
  final String? _wikiText;

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  late WikiController _controller;

  @override
  void initState() {
    super.initState();
    if (widget._controller != null) {
      _controller = widget._controller!;
    } else if (widget._wikiText != null) {
      _controller = WikiController();
      _controller.text = widget._wikiText!;
    } else {
      _controller = WikiController();
    }

    _controller.addListener(_rebuild);
  }

  _rebuild() => setState(() {});

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget._controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_rebuild);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: WikiRichTextConverter.convertToSpan(
        context,
        _controller.document.blocks,
      ),
    );
  }
}
