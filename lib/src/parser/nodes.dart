import 'package:wiki_editor/src/utils/extensions.dart';

import 'grammar.dart';

enum HeaderLevel { h1, h2 }

sealed class WikiNode {
  /// Write the node's content to a [buffer] as wiki text.
  void writeWikiTextToBuffer(StringBuffer buffer);

  /// Convert the notes content to a wiki text string.
  String toWikiText() {
    final buffer = StringBuffer();
    writeWikiTextToBuffer(buffer);
    return buffer.toString();
  }
}

sealed class BlockNode extends WikiNode {}

sealed class InlineNode extends WikiNode {}

final class HeaderNode extends BlockNode {
  HeaderNode(this.level, this.children);

  final HeaderLevel level;
  final List<InlineNode> children;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    final header = switch (level) {
      .h1 => WikiToken.h1,
      .h2 => WikiToken.h2,
    };

    buffer.write(header);
    buffer.writeSpace();

    for (final child in children) {
      child.writeWikiTextToBuffer(buffer);
    }
  }

  @override
  String toString() => 'HeaderNode($level, $children)';
}

final class ParagraphNode extends BlockNode {
  ParagraphNode(this.children);

  final List<InlineNode> children;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    for (final child in children) {
      child.writeWikiTextToBuffer(buffer);
    }
  }

  @override
  String toString() => 'ParagraphNode($children)';
}

final class UnorderedListNode extends BlockNode {
  UnorderedListNode(this.children);

  final List<InlineNode> children;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.ul);

    for (final child in children) {
      child.writeWikiTextToBuffer(buffer);
    }
  }

  @override
  String toString() => 'ListItemNode($children)';
}

final class OrderedListNode extends BlockNode {
  OrderedListNode(this.position, this.children);

  final int position;
  final List<InlineNode> children;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(' $position. ');

    for (final child in children) {
      child.writeWikiTextToBuffer(buffer);
    }
  }

  @override
  String toString() => 'ListItemNode($position, $children)';
}

final class TextNode extends InlineNode {
  TextNode(this.text);

  final String text;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(text);
  }

  @override
  String toString() => 'Text("$text")';
}

final class BoldNode extends InlineNode {
  BoldNode(this.text);

  final String text;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.bold);
    buffer.write(text);
    buffer.write(WikiToken.bold);
  }

  @override
  String toString() => 'Bold("$text")';
}

final class ItalicNode extends InlineNode {
  ItalicNode(this.text);

  final String text;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.italic);
    buffer.write(text);
    buffer.write(WikiToken.italic);
  }

  @override
  String toString() => 'Italic("$text")';
}

final class InlineLatexNode extends InlineNode {
  InlineLatexNode(this.latex);

  final String latex;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.latexInline);
    buffer.write(latex);
    buffer.write(WikiToken.latexInline);
  }

  @override
  String toString() => 'InlineLatex("$latex")';
}

final class DisplayLatexNode extends InlineNode {
  DisplayLatexNode(this.latex);

  final String latex;

  @override
  void writeWikiTextToBuffer(StringBuffer buffer) {
    buffer.write(WikiToken.latexBloc);
    buffer.write(latex);
    buffer.write(WikiToken.latexBloc);
  }

  @override
  String toString() => 'DisplayLatex("$latex")';
}

final class WikiLinkNode extends InlineNode {
  WikiLinkNode({required this.page, required this.alias});

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
  String toString() => 'Link(page: $page, alias: $alias)';
}
