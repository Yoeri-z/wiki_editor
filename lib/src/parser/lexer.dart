import 'package:wiki_editor/src/parser/grammar.dart';

sealed class WikiSegment {
  final String text;
  WikiSegment(this.text);
}

class TokenSegment extends WikiSegment {
  TokenSegment(super.text);
}

class TextSegment extends WikiSegment {
  TextSegment(super.text);
}

class WikiLexer {
  static final List<String> allTokens = [
    WikiToken.latexBloc, // '$$' (Check longer tokens first!)
    WikiToken.wikiOpen, // '[['
    WikiToken.wikiClose, // ']]'
    WikiToken.bold, // '**'
    WikiToken.ul, // ' - '
    WikiToken.h2, // '##'
    WikiToken.h1, // '#'
    WikiToken.italic, // '*'
    WikiToken.latexInline, // '$'
    WikiToken.wikiPipe, // '|'
  ];

  // Create a regex that matches any of the tokens.
  // We escape them to ensure characters like $ or [ don't break the regex.
  static final RegExp _tokenRegex = RegExp(
    '(${allTokens.map(RegExp.escape).join('|')})',
  );

  static List<WikiSegment> split(String input) {
    if (input.isEmpty) return [];

    final List<WikiSegment> segments = [];
    int lastMatchEnd = 0;

    for (final Match match in _tokenRegex.allMatches(input)) {
      // 1. Add the text BEFORE the token (if any)
      if (match.start > lastMatchEnd) {
        segments.add(TextSegment(input.substring(lastMatchEnd, match.start)));
      }

      // 2. Add the token itself
      segments.add(TokenSegment(match.group(0)!));

      lastMatchEnd = match.end;
    }

    // 3. Add any remaining text after the last token
    if (lastMatchEnd < input.length) {
      segments.add(TextSegment(input.substring(lastMatchEnd)));
    }

    return segments;
  }
}
