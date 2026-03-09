import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wiki_editor/wiki_editor.dart';

void main() {
  group('WikiParser.parse & unparse', () {
    test('empty input returns empty list', () {
      expect(WikiParser.parse(''), isEmpty);
    });

    test('parseBytes decodes UTF-8', () {
      final bytes = [72, 101, 108, 108, 111]; // 'Hello' in UTF-8
      final nodes = WikiParser.parseBytes(Uint8List.fromList(bytes));
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<ParagraphNode>());
    });

    // Core property: idempotence - parsing -> unparsing -> parsing should yield
    // semantically equivalent nodes
    test('idempotence for all valid wiki texts', () {
      const inputs = [
        'Hello world',
        '**bold**',
        '*italic*',
        '~~strikethrough~~',
        '`inline code`',
        '\$latex\$',
        '\$\$latex\$\$',
        '[[page]]',
        '[[page|alias]]',
        ' - item',
        ' 1. item',
        '# Header 1',
        '## Header 2',
        '### Header 3',
        '#### Header 4',
        '##### Header 5',
        '###### Header 6',
        '> blockquote',
        '---',
        '```dart\nvoid main() {}\n```',
        '# Header with **bold**',
        ' - item with *italic*',
        ' 1. item with \$latex\$',
        'Multiple\nlines\nof text',
      ];

      for (final input in inputs) {
        final nodes = WikiParser.parse(input);
        final output = WikiParser.unparse(nodes);

        expect(output, input, reason: 'Idempotence failed for input: "$input"');
      }
    });

    test('header levels h1 through h6', () {
      final headers = {
        '# H1': HeaderLevel.h1,
        '## H2': HeaderLevel.h2,
        '### H3': HeaderLevel.h3,
        '#### H4': HeaderLevel.h4,
        '##### H5': HeaderLevel.h5,
        '###### H6': HeaderLevel.h6,
      };

      for (final entry in headers.entries) {
        final nodes = WikiParser.parse(entry.key);
        expect(nodes.first, isA<HeaderNode>());
        expect((nodes.first as HeaderNode).level, entry.value);
      }
    });

    test('unordered list marker creates UnorderedListNode', () {
      final nodes = WikiParser.parse(' - item');
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<UnorderedListNode>());
      expect((nodes.first as UnorderedListNode).items, hasLength(1));
    });

    test(
      'ordered list marker creates OrderedListNode with correct start',
      () {
        final nodes = WikiParser.parse(' 1. item');
        expect(nodes, hasLength(1));
        expect(nodes.first, isA<OrderedListNode>());
        expect((nodes.first as OrderedListNode).start, 1);
      },
    );

    test('blockquote marker creates BlockquoteNode', () {
      final nodes = WikiParser.parse('> item');
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<BlockquoteNode>());
    });

    test('horizontal rule marker creates HorizontalRuleNode', () {
      final nodes = WikiParser.parse('---');
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<HorizontalRuleNode>());
    });

    test('code block marker creates CodeBlockNode', () {
      final nodes = WikiParser.parse('```dart\ncode\n```');
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<CodeBlockNode>());
      expect((nodes.first as CodeBlockNode).language, 'dart');
      expect((nodes.first as CodeBlockNode).content, 'code\n');
    });

    test('latex display block', () {
      const input = '\$\$\nE = mc^2\n\$\$';
      final nodes = WikiParser.parse(input);
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<DisplayLatexNode>());
      expect((nodes.first as DisplayLatexNode).latex, 'E = mc^2');
    });

    test('bold markers create BoldNode', () {
      final nodes = WikiParser.parse('**bold**');
      final paragraph = nodes.first as ParagraphNode;
      expect(paragraph.children.first, isA<BoldNode>());
      expect((paragraph.children.first as BoldNode).text, 'bold');
    });

    test('italic markers create ItalicNode', () {
      final nodes = WikiParser.parse('*italic*');
      final paragraph = nodes.first as ParagraphNode;
      expect(paragraph.children.first, isA<ItalicNode>());
      expect((paragraph.children.first as ItalicNode).text, 'italic');
    });

    test('strikethrough markers create StrikethroughNode', () {
      final nodes = WikiParser.parse('~~strike~~');
      final paragraph = nodes.first as ParagraphNode;
      expect(paragraph.children.first, isA<StrikethroughNode>());
      expect((paragraph.children.first as StrikethroughNode).text, 'strike');
    });

    test('inline code markers create InlineCodeNode', () {
      final nodes = WikiParser.parse('`code`');
      final paragraph = nodes.first as ParagraphNode;
      expect(paragraph.children.first, isA<InlineCodeNode>());
      expect((paragraph.children.first as InlineCodeNode).code, 'code');
    });

    test('multiple blocks are parsed in correct order', () {
      const input = '# Header\nParagraph\n - list';
      final nodes = WikiParser.parse(input);
      expect(nodes, hasLength(3));
      expect(nodes[0], isA<HeaderNode>());
      expect(nodes[1], isA<ParagraphNode>());
      expect(nodes[2], isA<UnorderedListNode>());
    });

    test('multiline paragraph', () {
      const input = 'Line 1\nLine 2';
      final nodes = WikiParser.parse(input);
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<ParagraphNode>());
      expect((nodes.first as ParagraphNode).children, hasLength(3)); // Line 1, \n, Line 2
    });

    test('nested list structure', () {
      const input = '''
 - This is a list.
  1. With an ordered sublist.
  2. Of two items.
 - And it also continues after.''';
      final nodes = WikiParser.parse(input);
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<UnorderedListNode>());
      final ul = nodes.first as UnorderedListNode;
      expect(ul.items, hasLength(2));
      
      // Check first item has nested ordered list
      expect(ul.items[0].children, hasLength(2));
      expect(ul.items[0].children[0], isA<ParagraphNode>());
      expect(ul.items[0].children[1], isA<OrderedListNode>());
      
      final ol = ul.items[0].children[1] as OrderedListNode;
      expect(ol.items, hasLength(2));
    });
  });

  group('WikiParser.parseLine & unparse', () {
    test('idempotence for all valid inline texts', () {
      const inputs = [
        'Hello world',
        '**bold**',
        '*italic*',
        '~~strike~~',
        '`code`',
        '\$latex\$',
        '\$\$latex\$\$',
        '[[page]]',
        '[[page|alias]]',
      ];

      for (final input in inputs) {
        final nodes = WikiParser.parseLine(input);
        final output = WikiParser.unparse(nodes);

        expect(output, input, reason: 'Idempotence failed for input: "$input"');
      }
    });
  });
}
