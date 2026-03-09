enum TokenType {
  bold,
  italic,
  strikethrough,
  inlineCode,
  wikiOpen, // Using this for the whole [[link]]
  latexDisplay,
  latexInline,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  blockquote,
  codeBlock,
  latexBlock,
  hr,
  text,
  ul,
  ol,
}

sealed class WikiSegment {
  final String text;
  final int start;
  final int end;

  WikiSegment(this.text, this.start, this.end);
}

class TokenSegment extends WikiSegment {
  final TokenType type;
  TokenSegment(this.type, super.text, super.start, super.end);
}

class TextSegment extends WikiSegment {
  TextSegment(super.text, super.start, super.end);
}

class WikiLexer {
  static List<WikiSegment> split(String text) {
    if (text.isEmpty) return [];

    // Note: Use 'r' for raw strings to avoid escaping backslashes manually
    final regEx = RegExp(
      r'(?<bold>\*\*.*?\*\*)|'
      r'(?<italic>\*.*?\*)|'
      r'(?<strikethrough>~~.*?~~)|'
      r'(?<codeBlock>^```.*$)|'
      r'(?<latexBlock>^\$\$.*$)|'
      r'(?<inlineCode>`.*?`)|'
      r'(?<wiki>\[\[.*?\]\])|'
      r'(?<latexDisplay>\$\$.*?\$\$)|'
      r'(?<latex>\$.*?\$)|'
      r'(?<h6>^###### .*$)|'
      r'(?<h5>^##### .*$)|'
      r'(?<h4>^#### .*$)|'
      r'(?<h3>^### .*$)|'
      r'(?<h2>^## .*$)|'
      r'(?<h1>^# .*$)|'
      r'(?<blockquote>^ *> .*$)|'
      r'(?<hr>^ *---$)|'
      r'(?<unorderedList>^ *[-*+] )|'
      r'(?<orderedList>^ *\d+\. )',
      multiLine: true,
    );

    final List<WikiSegment> segments = [];
    int lastIndex = 0;

    for (final match in regEx.allMatches(text)) {
      // 1. Add leading plain text as a TextSegment
      if (match.start > lastIndex) {
        final content = text.substring(lastIndex, match.start);
        segments.add(TextSegment(content, lastIndex, match.start));
      }

      // 2. Identify the match
      final matchText = match.group(0)!;
      TokenType type = TokenType.text;

      // Check named groups to assign the correct type
      if (match.namedGroup('bold') != null) {
        type = TokenType.bold;
      } else if (match.namedGroup('italic') != null) {
        type = TokenType.italic;
      } else if (match.namedGroup('strikethrough') != null) {
        type = TokenType.strikethrough;
      } else if (match.namedGroup('inlineCode') != null) {
        type = TokenType.inlineCode;
      } else if (match.namedGroup('wiki') != null) {
        type = TokenType.wikiOpen;
      } else if (match.namedGroup('latexDisplay') != null) {
        type = TokenType.latexDisplay;
      } else if (match.namedGroup('latex') != null) {
        type = TokenType.latexInline;
      } else if (match.namedGroup('h6') != null) {
        type = TokenType.h6;
      } else if (match.namedGroup('h5') != null) {
        type = TokenType.h5;
      } else if (match.namedGroup('h4') != null) {
        type = TokenType.h4;
      } else if (match.namedGroup('h3') != null) {
        type = TokenType.h3;
      } else if (match.namedGroup('h2') != null) {
        type = TokenType.h2;
      } else if (match.namedGroup('h1') != null) {
        type = TokenType.h1;
      } else if (match.namedGroup('blockquote') != null) {
        type = TokenType.blockquote;
      } else if (match.namedGroup('hr') != null) {
        type = TokenType.hr;
      } else if (match.namedGroup('codeBlock') != null) {
        type = TokenType.codeBlock;
      } else if (match.namedGroup('latexBlock') != null) {
        type = TokenType.latexBlock;
      } else if (match.namedGroup('unorderedList') != null) {
        type = TokenType.ul;
      } else if (match.namedGroup('orderedList') != null) {
        type = TokenType.ol;
      }

      segments.add(TokenSegment(type, matchText, match.start, match.end));
      lastIndex = match.end;
    }

    // 3. Catch any trailing text
    if (lastIndex < text.length) {
      final content = text.substring(lastIndex);
      segments.add(TextSegment(content, lastIndex, text.length));
    }

    return segments;
  }
}
