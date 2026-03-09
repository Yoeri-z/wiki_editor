import 'package:flutter_test/flutter_test.dart';
import 'package:wiki_editor/wiki_editor.dart';

void main() {
  group('WikiDocument', () {
    test('initial state is empty', () {
      final doc = WikiDocument();
      expect(doc.lineCount, 0);
      expect(doc.blocks, isEmpty);
      expect(doc.toWikiText(), '');
    });

    test('fromContent loads lines correctly', () {
      const content = 'Line 1\nLine 2\nLine 3';
      final doc = WikiDocument.fromContent(content);
      expect(doc.lineCount, 3);
      expect(doc.getRawText(0), 'Line 1');
      expect(doc.getRawText(1), 'Line 2');
      expect(doc.getRawText(2), 'Line 3');
      expect(doc.toWikiText(), content);
    });

    test('updateLine modifies existing line', () {
      final doc = WikiDocument.fromContent('Old');
      doc.updateLine(0, 'New');
      expect(doc.getRawText(0), 'New');
      expect(doc.toWikiText(), 'New');
    });

    test('updateLine at end adds new line', () {
      final doc = WikiDocument.fromContent('Line 1');
      doc.updateLine(1, 'Line 2');
      expect(doc.lineCount, 2);
      expect(doc.getRawText(1), 'Line 2');
    });

    test('updateLine beyond end pads with empty lines', () {
      final doc = WikiDocument();
      doc.updateLine(2, 'Line 3');
      expect(doc.lineCount, 3);
      expect(doc.getRawText(0), '');
      expect(doc.getRawText(1), '');
      expect(doc.getRawText(2), 'Line 3');
    });

    test('shiftLines positive delta inserts lines', () {
      final doc = WikiDocument.fromContent('A\nB');
      // Insert 1 line at index 1 (between A and B)
      doc.shiftLines(1, 1);
      expect(doc.lineCount, 3);
      expect(doc.getRawText(0), 'A');
      expect(doc.getRawText(1), '');
      expect(doc.getRawText(2), 'B');
    });

    test('shiftLines negative delta removes lines', () {
      final doc = WikiDocument.fromContent('A\nB\nC');
      // Remove 1 line at index 1 (remove B)
      doc.shiftLines(1, -1);
      expect(doc.lineCount, 2);
      expect(doc.getRawText(0), 'A');
      expect(doc.getRawText(1), 'C');
    });

    test('cutLines truncates document', () {
      final doc = WikiDocument.fromContent('A\nB\nC');
      doc.cutLines(1);
      expect(doc.lineCount, 1);
      expect(doc.getRawText(0), 'A');
      expect(doc.getRawText(1), isNull);
    });

    test('blocks trigger reparse of the whole document', () {
      final doc = WikiDocument.fromContent('# Header\nParagraph');
      final blocks = doc.blocks;
      expect(blocks, hasLength(2));
      expect(blocks[0], isA<HeaderNode>());
      expect(blocks[1], isA<ParagraphNode>());
    });

    test('multiline blocks are correctly grouped in blocks getter', () {
      final doc = WikiDocument.fromContent(' - Item 1\n - Item 2');
      final blocks = doc.blocks;
      // Should be 1 UnorderedListNode with 2 items
      expect(blocks, hasLength(1));
      expect(blocks[0], isA<UnorderedListNode>());
      expect((blocks[0] as UnorderedListNode).items, hasLength(2));
    });

    test('blockInfos tracks line ranges correctly', () {
      const content = '# Header\n\nParagraph line 1\nParagraph line 2';
      final doc = WikiDocument.fromContent(content);
      final infos = doc.blockInfos;
      
      expect(infos, hasLength(3)); // Header, Empty (newline), Paragraph
      
      expect(infos[0].startLine, 0);
      expect(infos[0].endLine, 0);
      expect(infos[0].node, isA<HeaderNode>());
      
      expect(infos[1].startLine, 1);
      expect(infos[1].endLine, 1);
      expect(infos[1].node, isA<EmptyBlockNode>());
      
      expect(infos[2].startLine, 2);
      expect(infos[2].endLine, 3);
      expect(infos[2].node, isA<ParagraphNode>());
    });

    test('isCodeBlock correctly identifies lines in code blocks', () {
      const content = 'Text\n```dart\ncode\n```\nMore text';
      final doc = WikiDocument.fromContent(content);
      
      expect(doc.isCodeBlock(0), isFalse); // Text
      expect(doc.isCodeBlock(1), isTrue);  // ```dart
      expect(doc.isCodeBlock(2), isTrue);  // code
      expect(doc.isCodeBlock(3), isTrue);  // ```
      expect(doc.isCodeBlock(4), isFalse); // More text
    });

    test('getSegments returns lexed segments', () {
      final doc = WikiDocument.fromContent('**bold** text');
      final segments = doc.getSegments(0);
      expect(segments.any((s) => s is TokenSegment && s.type == TokenType.bold), isTrue);
    });

    test('clear resets everything', () {
      final doc = WikiDocument.fromContent('Some content');
      doc.clear();
      expect(doc.lineCount, 0);
      expect(doc.blocks, isEmpty);
      expect(doc.toWikiText(), '');
    });

    test('getRawText returns null for out of bounds', () {
      final doc = WikiDocument.fromContent('A');
      expect(doc.getRawText(-1), isNull);
      expect(doc.getRawText(1), isNull);
    });

    test('getSegments returns empty list for out of bounds', () {
      final doc = WikiDocument.fromContent('A');
      expect(doc.getSegments(5), isEmpty);
    });
  });
}
