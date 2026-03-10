import 'package:flutter/material.dart';
import 'package:wiki_editor/wiki_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wiki Editor Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Light Markdown Editor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _markdownText = r"""# Welcome to Wiki Editor

This is a **lightweight** markdown editor with syntax highlighting and LaTeX support.

## LaTeX Example
Inline: $E = mc^2$

Block:
$$
\int_0^\infty e^{-x^2} dx = \frac{\sqrt{\pi}}{2}
$$

## Markdown Features
- [x] Syntax highlighting in editor
- [x] Responsive preview
- [x] LaTeX support
""";

  bool _showPreview = false;
  bool _useAdaptiveLayout = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(
              _useAdaptiveLayout ? Icons.devices : Icons.phonelink_lock,
            ),
            tooltip: 'Toggle Adaptive Layout',
            onPressed: () =>
                setState(() => _useAdaptiveLayout = !_useAdaptiveLayout),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _showPreview = !_showPreview),
            icon: Icon(_showPreview ? Icons.edit : Icons.remove_red_eye),
            label: Text(_showPreview ? 'Edit' : 'Preview'),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WikiEditorWorkspace(
          initialValue: _markdownText,
          showPreview: _showPreview,
          useAdaptiveLayout: _useAdaptiveLayout,
          highlighter: MarkdownHighlighter.material(context),
          onChanged: (value) {
            setState(() {
              _markdownText = value;
            });
          },
        ),
      ),
    );
  }
}
