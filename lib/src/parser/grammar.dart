import 'package:petitparser/petitparser.dart';

import 'nodes.dart';

sealed class WikiToken {
  static const wikiOpen = '[[';
  static const wikiClose = ']]';
  static const wikiPipe = '|';
  static const bold = '**';
  static const italic = '*';

  static const latexInline = '\$';
  static const latexBloc = '\$\$';

  static const ul = ' - ';
  static const h1 = '#';
  static const h2 = '##';
}

class WikiInlineGrammarDefinition extends GrammarDefinition {
  const WikiInlineGrammarDefinition();
  // INLINE TOKENS
  Parser wikiOpen() => string(WikiToken.wikiOpen);
  Parser wikiClose() => string(WikiToken.wikiClose);
  Parser wikiPipe() => char(WikiToken.wikiPipe);

  Parser boldMarker() => string(WikiToken.bold);
  Parser italicMarker() => char(WikiToken.italic);

  Parser latexInlineMarker() => char(WikiToken.latexInline);
  Parser latexBlockMarker() => string(WikiToken.latexBloc);

  ///ETRYPOINT
  @override
  Parser start() => ref0(inline).star().end();

  /// RULES
  Parser inline() =>
      ref0(displayLatex) |
      ref0(inlineLatex) |
      ref0(link) |
      ref0(bold) |
      ref0(italic) |
      ref0(text);

  Parser displayLatex() =>
      (ref0(latexBlockMarker) &
              any().starLazy(ref0(latexBlockMarker)).flatten() &
              ref0(latexBlockMarker))
          .map((v) => DisplayLatexNode(v[1].trim()));

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

  Parser text() => ref0(textChar).plus().flatten().map((v) => TextNode(v));

  Parser textChar() => ref0(special).not() & ref0(newline).not() & any();

  Parser special() =>
      ref0(wikiOpen) |
      ref0(boldMarker) |
      ref0(italicMarker) |
      ref0(latexInlineMarker) |
      ref0(latexBlockMarker);
}

class WikiGrammarDefinition extends WikiInlineGrammarDefinition {
  const WikiGrammarDefinition();
  // BLOCK TOKENS
  Parser newline() => Token.newlineParser();
  Parser newlineOrEnd() => newline() | endOfInput();

  Parser h2() => string(WikiToken.h2) & char(' ');
  Parser h1() => string(WikiToken.h1) & char(' ');
  Parser bullet() => string(WikiToken.ul);
  Parser ordered() => char(' ') & digit().plus().flatten() & string('. ');

  //ENTRY
  @override
  Parser start() => ref0(block).star().end();

  Parser inlineStart() => super.start();

  //RULES
  Parser block() =>
      ref0(header2) |
      ref0(header1) |
      ref0(unorderedList) |
      ref0(orderedList) |
      ref0(emptyLine) |
      ref0(paragraph);

  Parser header2() =>
      (ref0(h2) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h2, List<InlineNode>.from(v[1]));
      });

  Parser header1() =>
      (ref0(h1) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return HeaderNode(HeaderLevel.h1, List<InlineNode>.from(v[1]));
      });

  Parser unorderedList() =>
      (ref0(bullet) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return UnorderedListNode(List<InlineNode>.from(v[1]));
      });

  Parser orderedList() =>
      (ref0(ordered) & ref0(inline).star() & ref0(newlineOrEnd)).map((v) {
        return OrderedListNode(int.parse(v[0][1]), List<InlineNode>.from(v[1]));
      });

  Parser paragraph() => (ref0(inline).plus() & ref0(newlineOrEnd)).map((v) {
    return ParagraphNode(List<InlineNode>.from(v[0]));
  });

  Parser emptyLine() => ref0(newline).map((_) => EmptyBlockNode());
}
