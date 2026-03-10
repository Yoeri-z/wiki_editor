# wiki_editor

A lightweight, responsive material themed Markdown editor for Flutter with real-time syntax highlighting and LaTeX support.

## Features

- **Real-time Syntax Highlighting**: Highlight Markdown and LaTeX patterns directly in the text field as you type.
- **Responsive Layout**: Automatically switches between a side-by-side (editor and preview) view on wide screens and a toggleable mode on narrow screens.
- **LaTeX Support**: Full support for inline (`$ ... $`, `\( ... \)`) and block (`$$ ... $$`, `\[ ... \]`) LaTeX math expressions in both the editor and preview.
- **Modular Components**: Use the comprehensive workspace or build your own with standalone editor and preview widgets.
- **Lightweight**: Optimized for performance on small to medium documents.

## Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  wiki_editor:
    path: ./ # Or the appropriate path/version once published
```

## Usage

### Complete Workspace

The `WikiEditorWorkspace` is the easiest way to get started. It handles the editor state, layout, and preview toggling.

```dart
import 'package:flutter/material.dart';
import 'package:wiki_editor/wiki_editor.dart';

class MyEditorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wiki Editor')),
      body: WikiEditorWorkspace(
        initialValue: '# Hello Wiki\nThis is **Markdown** with $E=mc^2$.',
        onChanged: (value) {
          print('Content updated: $value');
        },
      ),
    );
  }
}
```

### Standalone Preview

If you just need to display Markdown with LaTeX support without an editor:

```dart
WikiPreview(
  data: '# Result\nThe solution is $x=42$',
)
```

### Standalone Text Editor

If you want to use the syntax-highlighted editor without the workspace logic:

```dart
final controller = MarkdownTextEditingController(
  text: 'Initial text',
  highlighter: MarkdownHighlighter.material(context),
);

WikiTextEditor(
  controller: controller,
);
```

## How it Works

1. **`MarkdownHighlighter`**: A utility that uses regex to parse text into styled `TextSpan`s.
2. **`MarkdownTextEditingController`**: An extension of `TextEditingController` that applies the highlighter to the editor's text.
3. **`WikiTextEditor`**: The core text field widget.
4. **`WikiPreview`**: The markdown/LaTeX renderer.
5. **`WikiEditorWorkspace`**: A composite widget that orchestrates the editor and preview.

## Customization

You can provide a custom `MarkdownHighlighter` to change the appearance of the syntax highlighting:

```dart
final customHighlighter = MarkdownHighlighter(
  headingStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
  boldStyle: TextStyle(color: Colors.green),
  latexStyle: TextStyle(backgroundColor: Colors.yellow[100]),
);
```

## Caveats

This project is made specifically for another app, this app does not require complex code block or table syntax. These syntax are left out of the regex parser to save a lot on performance. This project is also not intended to be used for large markdown documents, performance will degrade when many lines are present since it uses a regular flutter text field.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
