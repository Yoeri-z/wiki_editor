import 'package:flutter/material.dart';

class MarkdownHighlighter {
  MarkdownHighlighter({
    TextStyle? headingStyle,
    TextStyle? boldStyle,
    TextStyle? italicStyle,
    TextStyle? codeStyle,
    TextStyle? linkStyle,
    TextStyle? latexStyle,
    TextStyle? listStyle,
  }) : _patterns = {
         // Headings
         RegExp(r'^#+.*$', multiLine: true):
             headingStyle ??
             const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
         // Lists (Unordered and Ordered) - matches only the marker
         RegExp(r'^ *([-*+]|\d+\.)(?= )', multiLine: true):
             listStyle ??
             const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
         // Bold
         RegExp(r'\*\*.*?\*\*|__.*?__'):
             boldStyle ?? const TextStyle(fontWeight: FontWeight.bold),
         // Italic
         RegExp(r'\*.*?\*|_.*?_'):
             italicStyle ?? const TextStyle(fontStyle: FontStyle.italic),
         // Code
         RegExp(r'`.*?`'):
             codeStyle ??
             TextStyle(
               fontFamily: 'monospace',
               backgroundColor: Colors.grey[200],
             ),
         // Links
         RegExp(r'\[.*?\]\(.*?\)'):
             linkStyle ??
             const TextStyle(
               color: Colors.blue,
               decoration: TextDecoration.underline,
             ),
         // LaTeX
         RegExp(r'\$\$.*?\$\$|\$.*?\$|\\\(.*?\\\)|\\\[.*?\\\]', dotAll: true):
             latexStyle ??
             const TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
       };

  factory MarkdownHighlighter.material(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MarkdownHighlighter(
      headingStyle: TextStyle(fontWeight: .bold, color: colorScheme.primary),
      listStyle: TextStyle(fontWeight: .bold, color: colorScheme.primary),
      boldStyle: TextStyle(fontWeight: .bold),
      italicStyle: TextStyle(fontStyle: .italic),
      codeStyle: TextStyle(
        fontFamily: 'monospace',
        backgroundColor: Colors.grey[200],
      ),
      linkStyle: TextStyle(color: colorScheme.primary),
      latexStyle: TextStyle(color: colorScheme.tertiary),
    );
  }

  final Map<RegExp, TextStyle> _patterns;

  TextSpan buildTextSpan(String text, TextStyle? baseStyle) {
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    // We need to find all matches and sort them by start index
    final List<_MatchRange> allMatches = [];
    for (final pattern in _patterns.keys) {
      for (final match in pattern.allMatches(text)) {
        allMatches.add(
          _MatchRange(match.start, match.end, _patterns[pattern]!),
        );
      }
    }

    // Sort matches by start index, and then by length (descending) to handle nested patterns if any
    // Note: Simple regex approach might struggle with complex nesting, but for a lightweight editor it's usually fine.
    allMatches.sort((a, b) {
      final res = a.start.compareTo(b.start);
      if (res != 0) return res;
      return b.end.compareTo(a.end);
    });

    // Remove overlapping matches
    final List<_MatchRange> nonOverlappingMatches = [];
    if (allMatches.isNotEmpty) {
      _MatchRange current = allMatches[0];
      nonOverlappingMatches.add(current);
      for (int i = 1; i < allMatches.length; i++) {
        if (allMatches[i].start >= current.end) {
          current = allMatches[i];
          nonOverlappingMatches.add(current);
        }
      }
    }

    for (final match in nonOverlappingMatches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: match.style,
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(style: baseStyle, children: spans);
  }
}

class _MatchRange {
  final int start;
  final int end;
  final TextStyle style;

  _MatchRange(this.start, this.end, this.style);
}
