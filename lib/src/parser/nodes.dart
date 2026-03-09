import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:wiki_editor/src/display/wiki_display_theme.dart';
import 'package:wiki_editor/src/utils/extensions.dart';

import 'grammar.dart';

enum HeaderLevel { h1, h2, h3, h4, h5, h6 }

sealed class WikiNode {
  const WikiNode();

  /// Write the node's content to a [buffer] as wiki text.
  void writeWikiTextToBuffer(StringBuffer buffer);

  /// Convert the notes content to a wiki text string.
  String toWikiText() {
    final buffer = StringBuffer();
    writeWikiTextToBuffer(buffer);
    return buffer.toString();
  }

  /// Build a [InlineSpan] representation of this node.
  InlineSpan build(BuildContext context);
}

sealed class BlockNode extends WikiNode {
  const BlockNode();
}

sealed class InlineNode extends WikiNode {
  const InlineNode();
}

final class HeaderNode extends BlockNode {
  const HeaderNode(this.level, this.children);

  final HeaderLevel level;
  final List<InlineNode> children;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    final header = switch (level) {
      HeaderLevel.h1 => WikiToken.h1,
      HeaderLevel.h2 => WikiToken.h2,
      HeaderLevel.h3 => WikiToken.h3,
      HeaderLevel.h4 => WikiToken.h4,
      HeaderLevel.h5 => WikiToken.h5,
      HeaderLevel.h6 => WikiToken.h6,
    };

    buffer.write(header);
    buffer.writeSpace();

    for (final child in children) {
      child.writeWikiTextToBuffer(buffer);
    }
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);
    final style = switch (level) {
      HeaderLevel.h1 => theme.h1Style,
      HeaderLevel.h2 => theme.h2Style,
      HeaderLevel.h3 => theme.h3Style,
      HeaderLevel.h4 => theme.h4Style,
      HeaderLevel.h5 => theme.h5Style,
      HeaderLevel.h6 => theme.h6Style,
    };

    return TextSpan(
      children: children.map((c) => c.build(context)).toList(),
      style: style,
    );
  }

  @override
  String toString() => 'HeaderNode($level, $children)';
}

final class ParagraphNode extends BlockNode {
  const ParagraphNode(this.children);

  final List<InlineNode> children;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    for (final child in children) {
      child.writeWikiTextToBuffer(buffer);
    }
  }

  @override
  InlineSpan build(BuildContext context) {
    return TextSpan(children: children.map((c) => c.build(context)).toList());
  }

  @override
  String toString() => 'ParagraphNode($children)';
}

final class EmptyBlockNode extends BlockNode {
  const EmptyBlockNode();

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    //empty block is empty so it does not write
  }

  @override
  InlineSpan build(BuildContext context) {
    return const TextSpan(text: '');
  }

  @override
  String toString() => 'EmptyBlockNode()';
}

final class ListItemNode extends WikiNode {
  const ListItemNode(this.children, {this.indentation = ''});

  final List<BlockNode> children;
  final String indentation;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    for (var i = 0; i < children.length; i++) {
      if (i > 0) buffer.write(indentation);
      children[i].writeWikiTextToBuffer(buffer);
      if (i < children.length - 1) {
        buffer.writeln();
      }
    }
  }

  @override
  InlineSpan build(BuildContext context) {
    final List<InlineSpan> spans = [];
    for (var i = 0; i < children.length; i++) {
      spans.add(children[i].build(context));
      if (i < children.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    return TextSpan(children: spans);
  }

  @override
  String toString() => 'ListItemNode($children, indent: $indentation)';
}

final class UnorderedListNode extends BlockNode {
  const UnorderedListNode(this.items);

  final List<ListItemNode> items;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    for (var i = 0; i < items.length; i++) {
      buffer.write(items[i].indentation);
      buffer.write('- ');
      items[i].writeWikiTextToBuffer(buffer);
      if (i < items.length - 1) buffer.writeln();
    }
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);

    final List<InlineSpan> spans = [];
    for (var i = 0; i < items.length; i++) {
      spans.add(TextSpan(text: '• ', style: theme.textStyle));
      spans.add(items[i].build(context));
      if (i < items.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    return TextSpan(children: spans);
  }

  @override
  String toString() => 'UnorderedListNode($items)';
}

final class OrderedListNode extends BlockNode {
  const OrderedListNode(this.start, this.items);

  final int start;
  final List<ListItemNode> items;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    for (var i = 0; i < items.length; i++) {
      buffer.write(items[i].indentation);
      buffer.write('${start + i}. ');
      items[i].writeWikiTextToBuffer(buffer);
      if (i < items.length - 1) buffer.writeln();
    }
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);

    final List<InlineSpan> spans = [];
    for (var i = 0; i < items.length; i++) {
      spans.add(TextSpan(text: '${start + i}. ', style: theme.textStyle));
      spans.add(items[i].build(context));
      if (i < items.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    return TextSpan(children: spans);
  }

  @override
  String toString() => 'OrderedListNode($start, $items)';
}

final class BlockquoteNode extends BlockNode {
  const BlockquoteNode(this.children);

  final List<BlockNode> children;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    for (var i = 0; i < children.length; i++) {
      buffer.write(WikiToken.blockquote);
      children[i].writeWikiTextToBuffer(buffer);
      if (i < children.length - 1) buffer.writeln();
    }
  }

  @override
  InlineSpan build(BuildContext context) {
    final List<InlineSpan> spans = [];
    for (var i = 0; i < children.length; i++) {
      spans.add(children[i].build(context));
      if (i < children.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }
    return TextSpan(
      children: spans,
      style: const TextStyle(
        fontStyle: FontStyle.italic,
        color: Color.fromARGB(255, 100, 100, 100),
      ),
    );
  }

  @override
  String toString() => 'BlockquoteNode($children)';
}

final class CodeBlockNode extends BlockNode {
  const CodeBlockNode(this.language, this.content);

  final String language;
  final String content;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write('```');
    buffer.write(language);
    buffer.writeln();
    buffer.write(content);
    if (!content.endsWith('\n')) buffer.writeln();
    buffer.write('```');
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);
    return TextSpan(text: content, style: theme.inlineCodeStyle);
  }

  @override
  String toString() => 'CodeBlockNode($language, $content)';
}

final class HorizontalRuleNode extends BlockNode {
  const HorizontalRuleNode();

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.horizontalRule);
  }

  @override
  InlineSpan build(BuildContext context) {
    // RichText doesn't support dividers well, using a dash string for now
    return const TextSpan(
      text: '--------------------------------\n',
      style: TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
    );
  }

  @override
  String toString() => 'HorizontalRuleNode()';
}

final class TextNode extends InlineNode {
  const TextNode(this.text);

  final String text;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(text);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);

    return TextSpan(text: text, style: theme.textStyle);
  }

  @override
  String toString() => 'Text("$text")';
}

final class BoldNode extends InlineNode {
  const BoldNode(this.text);

  final String text;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.bold);
    buffer.write(text);
    buffer.write(WikiToken.bold);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);

    return TextSpan(text: text, style: theme.boldStyle);
  }

  @override
  String toString() => 'Bold("$text")';
}

final class ItalicNode extends InlineNode {
  const ItalicNode(this.text);

  final String text;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.italic);
    buffer.write(text);
    buffer.write(WikiToken.italic);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);
    return TextSpan(text: text, style: theme.italicStyle);
  }

  @override
  String toString() => 'Italic("$text")';
}

final class StrikethroughNode extends InlineNode {
  const StrikethroughNode(this.text);

  final String text;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.strikethrough);
    buffer.write(text);
    buffer.write(WikiToken.strikethrough);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);
    return TextSpan(text: text, style: theme.strikethroughStyle);
  }

  @override
  String toString() => 'Strikethrough("$text")';
}

final class InlineCodeNode extends InlineNode {
  const InlineCodeNode(this.code);

  final String code;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.inlineCode);
    buffer.write(code);
    buffer.write(WikiToken.inlineCode);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);
    return TextSpan(text: code, style: theme.inlineCodeStyle);
  }

  @override
  String toString() => 'InlineCode("$code")';
}

final class InlineLatexNode extends InlineNode {
  const InlineLatexNode(this.latex);

  final String latex;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.latexInline);
    buffer.write(latex);
    buffer.write(WikiToken.latexInline);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);

    return WidgetSpan(
      alignment: .middle,
      baseline: .alphabetic,
      child: Math.tex(
        latex,
        mathStyle: .text,
        textStyle: theme.inlineLatexStyle,
      ),
    );
  }

  @override
  String toString() => 'InlineLatex("$latex")';
}

final class DisplayLatexNode extends BlockNode {
  const DisplayLatexNode(this.latex);

  final String latex;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.latexBloc);
    buffer.write(latex);
    buffer.write(WikiToken.latexBloc);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);

    return WidgetSpan(
      child: Center(
        child: Math.tex(
          latex,
          mathStyle: MathStyle.display,
          textStyle: theme.displayLatexStyle,
        ),
      ),
    );
  }

  @override
  String toString() => 'DisplayLatex("$latex")';
}

final class WikiLinkNode extends InlineNode {
  const WikiLinkNode({required this.page, required this.alias});

  final String page;
  final String alias;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.wikiOpen);
    buffer.write(page);
    if (alias != page) {
      buffer.write(WikiToken.wikiPipe);
      buffer.write(alias);
    }

    buffer.write(WikiToken.wikiClose);
  }

  @override
  InlineSpan build(BuildContext context) {
    final theme = WikiDisplayTheme.of(context);
    return TextSpan(text: alias, style: theme.linkStyle);
  }

  @override
  String toString() => 'Link(page: $page, alias: $alias)';
}
