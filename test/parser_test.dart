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
        '\$latex\$',
        '\$\$latex\$\$',
        '[[page]]',
        '[[page|alias]]',
        ' - item',
        ' 1. item',
        '# Header',
        '## Header',
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

    test('single hash (#) should create h1 header', () {
      final nodes = WikiParser.parse('# Header');
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<HeaderNode>());
      expect((nodes.first as HeaderNode).level, HeaderLevel.h1);
    });

    test('double hash (##) should create h2 header', () {
      final nodes = WikiParser.parse('## Header');
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<HeaderNode>());
      expect((nodes.first as HeaderNode).level, HeaderLevel.h2);
    });

    test('header unparse should preserve hash count', () {
      final nodes1 = WikiParser.parse('# Header');
      final output = WikiParser.unparse(nodes1);
      final nodes2 = WikiParser.parse(output);

      // After roundtrip, header level should still be h1
      expect((nodes2.first as HeaderNode).level, HeaderLevel.h1);
    });

    test('unordered list marker creates UnorderedListNode', () {
      final nodes = WikiParser.parse(' - item');
      expect(nodes, hasLength(1));
      expect(nodes.first, isA<UnorderedListNode>());
    });

    test(
      'ordered list marker creates OrderedListNode with correct position',
      () {
        final nodes = WikiParser.parse(' 1. item');
        expect(nodes, hasLength(1));
        expect(nodes.first, isA<OrderedListNode>());
        expect((nodes.first as OrderedListNode).position, 1);
      },
    );

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

    test('inline latex markers create InlineLatexNode', () {
      final nodes = WikiParser.parse('\$latex\$');
      final paragraph = nodes.first as ParagraphNode;
      expect(paragraph.children.first, isA<InlineLatexNode>());
      expect((paragraph.children.first as InlineLatexNode).latex, 'latex');
    });

    test('display latex markers create DisplayLatexNode', () {
      final nodes = WikiParser.parse('\$\$latex\$\$');
      final paragraph = nodes.first as ParagraphNode;
      expect(paragraph.children.first, isA<DisplayLatexNode>());
      expect((paragraph.children.first as DisplayLatexNode).latex, 'latex');
    });

    test('wiki link without alias has page == alias', () {
      final nodes = WikiParser.parse('[[page]]');
      final paragraph = nodes.first as ParagraphNode;
      final link = paragraph.children.first as WikiLinkNode;
      expect(link.page, 'page');
      expect(link.alias, 'page');
    });

    test('wiki link with alias preserves both values', () {
      final nodes = WikiParser.parse('[[page|alias]]');
      final paragraph = nodes.first as ParagraphNode;
      final link = paragraph.children.first as WikiLinkNode;
      expect(link.page, 'page');
      expect(link.alias, 'alias');
    });

    test('multiple blocks are parsed in correct order', () {
      const input = '# Header\nParagraph\n - list';
      final nodes = WikiParser.parse(input);
      expect(nodes, hasLength(3));
      expect(nodes[0], isA<HeaderNode>());
      expect(nodes[1], isA<ParagraphNode>());
      expect(nodes[2], isA<UnorderedListNode>());
    });

    test('nested formatting is parsed correctly', () {
      const input = 'Text **bold** and *italic*';
      final nodes = WikiParser.parse(input);
      final paragraph = nodes.first as ParagraphNode;

      // Should contain both bold and italic nodes
      expect(paragraph.children.any((n) => n is BoldNode), isTrue);
      expect(paragraph.children.any((n) => n is ItalicNode), isTrue);
    });
  });

  group('WikiParser.parseLine & unparse', () {
    test('idempotence for all valid inline texts', () {
      const inputs = [
        'Hello world',
        '**bold**',
        '*italic*',
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
