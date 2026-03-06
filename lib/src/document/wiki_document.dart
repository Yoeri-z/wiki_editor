import '../parser/parser.dart';
import '../parser/nodes.dart';

class WikiDocument {
  WikiDocument();

  factory WikiDocument.fromContent(String content) {
    final document = WikiDocument();

    final nodes = WikiParser.parse(content);

    document._blocks.addAll(nodes);

    return document;
  }

  final List<BlockNode> _blocks = [];

  List<BlockNode> get blocks => List.unmodifiable(_blocks);
  int get blockLength => _blocks.length;

  /// Add a new character to this document
  void addBlock(int index, String newLine) {
    final block = WikiParser.parse(newLine).firstOrNull;

    if (block != null) {
      _blocks[index] = block;
    }
  }

  void removeLine(int index) {
    _blocks.removeAt(index);
  }

  void addLine(int index, String line) {
    final block = WikiParser.parse(line).firstOrNull;

    if (block != null) {
      _blocks.insert(index, block);
    }
  }

  String toWikiText() {
    return WikiParser.unparse(_blocks);
  }

  void clear() {
    _blocks.clear();
  }
}
