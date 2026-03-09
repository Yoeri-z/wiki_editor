import 'package:petitparser/petitparser.dart';

import 'nodes.dart';

sealed class WikiToken {
  static const wikiOpen = r'[[';
  static const wikiClose = r']]';
  static const wikiPipe = r'|';
  static const bold = r'**';
  static const italic = r'*';
  static const strikethrough = r'~~';
  static const inlineCode = r'`';
  static const blockCode = r'```';

  static const latexInline = r'$';
  static const latexBloc = r'$$';

  static const ul = r'- ';
  static const h1 = r'#';
  static const h2 = r'##';
  static const h3 = r'###';
  static const h4 = r'####';
  static const h5 = r'#####';
  static const h6 = r'######';
  static const blockquote = r'> ';
  static const horizontalRule = r'---';
}

class WikiInlineGrammarDefinition extends GrammarDefinition {
  const WikiInlineGrammarDefinition();
  // INLINE TOKENS
  Parser wikiOpen() => string(WikiToken.wikiOpen);
  Parser wikiClose() => string(WikiToken.wikiClose);
  Parser wikiPipe() => char(WikiToken.wikiPipe);

  Parser boldMarker() => string(WikiToken.bold);
  Parser italicMarker() => char(WikiToken.italic);
  Parser strikethroughMarker() => string(WikiToken.strikethrough);
  Parser inlineCodeMarker() => char(WikiToken.inlineCode);

  Parser latexInlineMarker() => char(WikiToken.latexInline);

  ///ETRYPOINT
  @override
  Parser start() => ref0(inline).star().end();

  /// RULES
  Parser inline() =>
      ref0(inlineLatex) |
      ref0(link) |
      ref0(bold) |
      ref0(italic) |
      ref0(strikethrough) |
      ref0(inlineCode) |
      ref0(text);

  Parser inlineLatex() =>
      (ref0(latexInlineMarker) &
              any().starLazy(ref0(latexInlineMarker)).flatten() &
              ref0(latexInlineMarker))
          .map((v) => InlineLatexNode(v[1].trim()));

  Parser link() =>
      (ref0(wikiOpen) &
              any().starLazy(ref0(wikiPipe) | ref0(wikiClose)).flatten() &
              (ref0(wikiPipe) & any().starLazy(ref0(wikiClose)).flatten())
                  .optional() &
              ref0(wikiClose))
          .map((v) {
            final page = (v[1] as String);
            final alias = v[2] != null ? (v[2][1] as String) : page;
            return WikiLinkNode(page: page, alias: alias);
          });

  Parser bold() =>
      (ref0(boldMarker) &
              any().starLazy(ref0(boldMarker)).flatten() &
              ref0(boldMarker))
          .map((v) => BoldNode(v[1]));

  Parser italic() =>
      (ref0(italicMarker) &
              any().starLazy(ref0(italicMarker)).flatten() &
              ref0(italicMarker))
          .map((v) => ItalicNode(v[1]));

  Parser strikethrough() =>
      (ref0(strikethroughMarker) &
              any().starLazy(ref0(strikethroughMarker)).flatten() &
              ref0(strikethroughMarker))
          .map((v) => StrikethroughNode(v[1]));

  Parser inlineCode() =>
      (ref0(inlineCodeMarker) &
              any().starLazy(ref0(inlineCodeMarker)).flatten() &
              ref0(inlineCodeMarker))
          .map((v) => InlineCodeNode(v[1]));

  Parser text() => ref0(textChar).plus().flatten().map((v) => TextNode(v));

  Parser textChar() => ref0(special).not() & ref0(newline).not() & any();

  Parser special() =>
      ref0(wikiOpen) |
      ref0(boldMarker) |
      ref0(italicMarker) |
      ref0(strikethroughMarker) |
      ref0(inlineCodeMarker) |
      ref0(latexInlineMarker);

  Parser newline() => Token.newlineParser();
}

class WikiGrammarDefinition extends WikiInlineGrammarDefinition {
  const WikiGrammarDefinition();
  // BLOCK TOKENS
  Parser newlineOrEnd() => newline() | endOfInput();

  Parser h6() => string(WikiToken.h6) & char(' ');
  Parser h5() => string(WikiToken.h5) & char(' ');
  Parser h4() => string(WikiToken.h4) & char(' ');
  Parser h3() => string(WikiToken.h3) & char(' ');
  Parser h2() => string(WikiToken.h2) & char(' ');
  Parser h1() => string(WikiToken.h1) & char(' ');

  Parser indent() => char(' ').star().flatten();
  Parser bullet() => anyOf('-*+').flatten() & char(' ');
  Parser ordered() => digit().plus().flatten() & string('. ');

  Parser blockquoteMarker() => string(WikiToken.blockquote);
  Parser latexBlockMarker() => string(WikiToken.latexBloc);
  Parser horizontalRuleMarker() => string(WikiToken.horizontalRule);
  Parser codeBlockMarker() => string(WikiToken.blockCode);

  //ENTRY
  @override
  Parser start() => ref0(block).star().end();

  //RULES
  Parser block() =>
      ref0(header6) |
      ref0(header5) |
      ref0(header4) |
      ref0(header3) |
      ref0(header2) |
      ref0(header1) |
      ref0(list) |
      ref0(latexBlock) |
      ref0(blockquote) |
      ref0(codeBlock) |
      ref0(horizontalRule) |
      ref0(emptyLine) |
      ref0(paragraph);

  Parser header6() =>
      (ref0(h6) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h6, List<InlineNode>.from(v[1]));
      });

  Parser header5() =>
      (ref0(h5) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h5, List<InlineNode>.from(v[1]));
      });

  Parser header4() =>
      (ref0(h4) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h4, List<InlineNode>.from(v[1]));
      });

  Parser header3() =>
      (ref0(h3) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h3, List<InlineNode>.from(v[1]));
      });

  Parser header2() =>
      (ref0(h2) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h2, List<InlineNode>.from(v[1]));
      });

  Parser header1() =>
      (ref0(h1) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h1, List<InlineNode>.from(v[1]));
      });

  Parser list() =>
      (ref0(unorderedListItem) | ref0(orderedListItem)).plus().map((v) {
        final items = List<_ListItemData>.from(v);
        return _buildList(items);
      });

  Parser latexBlock() =>
      (ref0(latexBlockMarker) &
              any().starLazy(ref0(latexBlockMarker)).flatten() &
              ref0(latexBlockMarker) &
              ref0(newlineOrEnd))
          .map((v) => DisplayLatexNode((v[1] as String).trim()));

  Parser unorderedListItem() =>
      (ref0(indent) & ref0(bullet) & ref0(inline).star() & ref0(newlineOrEnd))
          .map((v) {
            final indentation = v[0] as String;
            return _ListItemData(
              indentation.length,
              ListItemNode([
                ParagraphNode(List<InlineNode>.from(v[2])),
              ], indentation: indentation),
              isOrdered: false,
            );
          });

  Parser orderedListItem() =>
      (ref0(indent) & ref0(ordered) & ref0(inline).star() & ref0(newlineOrEnd))
          .map((v) {
            final indentation = v[0] as String;
            return _ListItemData(
              indentation.length,
              ListItemNode([
                ParagraphNode(List<InlineNode>.from(v[2])),
              ], indentation: indentation),
              isOrdered: true,
              start: int.parse(v[1][0]),
            );
          });

  Parser blockquote() =>
      (ref0(blockquoteMarker) & ref0(inline).star() & ref0(newlineOrEnd))
          .plus()
          .map((v) {
            final items = (v as List).map((line) {
              return ParagraphNode(List<InlineNode>.from(line[1]));
            }).toList();
            return BlockquoteNode(List<BlockNode>.from(items));
          });

  Parser codeBlock() =>
      (ref0(codeBlockMarker) &
              any().starLazy(ref0(newline)).flatten() &
              ref0(newline) &
              any().starLazy(ref0(codeBlockMarker)).flatten() &
              ref0(codeBlockMarker) &
              ref0(newlineOrEnd))
          .map((v) => CodeBlockNode(v[1].trim(), v[3]));

  Parser horizontalRule() => (ref0(horizontalRuleMarker) & ref0(newlineOrEnd))
      .map((v) => const HorizontalRuleNode());

  Parser paragraph() =>
      (ref0(inline).plus() &
              (ref0(newline) & ref0(blockStart).not() & ref0(inline).plus())
                  .star() &
              ref0(newlineOrEnd))
          .map((v) {
            final first = List<InlineNode>.from(v[0]);
            final rest = (v[1] as List)
                .map((e) {
                  return [const TextNode('\n'), ...List<InlineNode>.from(e[2])];
                })
                .expand((i) => i)
                .toList();
            return ParagraphNode([...first, ...rest]);
          });

  Parser blockStart() =>
      ref0(h6) |
      ref0(h5) |
      ref0(h4) |
      ref0(h3) |
      ref0(h2) |
      ref0(h1) |
      ref0(latexBlockMarker) |
      ref0(indent) & ref0(bullet) |
      ref0(indent) & ref0(ordered) |
      ref0(blockquoteMarker) |
      ref0(horizontalRuleMarker) |
      ref0(codeBlockMarker);

  Parser emptyLine() => ref0(newline).map((_) => const EmptyBlockNode());

  BlockNode _buildList(List<_ListItemData> items) {
    if (items.isEmpty) return const EmptyBlockNode();

    // Group items by root level indentation
    final rootIndent = items[0].indent;
    final groups = <List<_ListItemData>>[];
    for (final item in items) {
      if (groups.isEmpty || item.indent == rootIndent) {
        groups.add([item]);
      } else if (item.indent > rootIndent) {
        groups.last.add(item);
      } else {
        // Lower indentation ends the current list grouping logic
        // but PetitParser's plus() already handled adjacency.
        groups.add([item]);
      }
    }

    final isOrdered = items[0].isOrdered;
    final start = items[0].start;

    final listItems = <ListItemNode>[];
    for (final group in groups) {
      final rootItem = group[0];
      if (group.length > 1) {
        // We have nested items
        final nestedBlocks = _buildList(group.sublist(1));
        listItems.add(ListItemNode([...rootItem.node.children, nestedBlocks]));
      } else {
        listItems.add(rootItem.node);
      }
    }

    if (isOrdered) {
      return OrderedListNode(start, listItems);
    } else {
      return UnorderedListNode(listItems);
    }
  }
}

class _ListItemData {
  final int indent;
  final ListItemNode node;
  final bool isOrdered;
  final int start;

  _ListItemData(
    this.indent,
    this.node, {
    required this.isOrdered,
    this.start = 1,
  });
}
