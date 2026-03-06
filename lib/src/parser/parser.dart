import 'dart:convert';
import 'dart:typed_data';

import 'package:petitparser/petitparser.dart';

import 'grammar.dart';
import 'nodes.dart';

/// Non Constructable class that gives access to parsing static methods.
final class WikiParser {
  WikiParser._();

  static final _i = WikiParser._();

  late final parser = const WikiGrammarDefinition().build();

  late final inlineParser = const WikiInlineGrammarDefinition().build();

  /// Prases a string into [BlockNode] nodes.
  static List<BlockNode> parse(String input) {
    var result = _i.parser.parse(input);

    if (result is Failure) {
      throw ParserException(result);
    }

    return List<BlockNode>.from(result.value);
  }

  /// Parses a blob of bytes into [BlockNode] nodes.
  static List<BlockNode> parseBytes(Uint8List bytes) {
    final input = utf8.decode(bytes);

    return parse(input);
  }

  /// Parse a singular line into [InlineNode] nodes.
  static List<InlineNode> parseLine(String line) {
    final result = _i.inlineParser.parse(line);

    if (result is Failure) {
      throw ParserException(result);
    }

    return List<InlineNode>.from(result.value);
  }

  static String unparse(List<WikiNode> nodes) {
    final buffer = StringBuffer();

    for (var node in nodes) {
      node.writeWikiTextToBuffer(buffer);
      if (node != nodes.last && node is BlockNode) {
        buffer.writeln();
      }
    }

    return buffer.toString();
  }
}
