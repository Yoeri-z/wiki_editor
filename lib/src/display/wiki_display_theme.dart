import 'package:flutter/material.dart';

@immutable
class WikiDisplayThemeData {
  const WikiDisplayThemeData({
    this.textStyle = const TextStyle(color: Colors.black),
    this.boldStyle = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.italicStyle = const TextStyle(
      color: Colors.black,
      fontStyle: FontStyle.italic,
    ),
    this.strikethroughStyle = const TextStyle(
      color: Colors.black,
      decoration: TextDecoration.lineThrough,
    ),
    this.inlineCodeStyle = const TextStyle(
      color: Colors.black,
      fontFamily: 'monospace',
      backgroundColor: Color.fromARGB(20, 0, 0, 0),
    ),
    this.linkStyle = const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
    this.inlineLatexStyle = const TextStyle(color: Colors.black),
    this.displayLatexStyle = const TextStyle(color: Colors.black, fontSize: 24),

    this.h1Style = const TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    this.h2Style = const TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    this.h3Style = const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.h4Style = const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    this.h5Style = const TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    this.h6Style = const TextStyle(
      color: Colors.black,
      fontSize: 11,
      fontWeight: FontWeight.bold,
    ),
  });

  final TextStyle textStyle;
  final TextStyle boldStyle;
  final TextStyle italicStyle;
  final TextStyle strikethroughStyle;
  final TextStyle inlineCodeStyle;
  final TextStyle linkStyle;
  final TextStyle inlineLatexStyle;
  final TextStyle displayLatexStyle;
  final TextStyle h1Style;
  final TextStyle h2Style;
  final TextStyle h3Style;
  final TextStyle h4Style;
  final TextStyle h5Style;
  final TextStyle h6Style;

  @override
  int get hashCode => Object.hashAll([
    textStyle,
    boldStyle,
    italicStyle,
    strikethroughStyle,
    inlineCodeStyle,
    linkStyle,
    inlineLatexStyle,
    displayLatexStyle,
    h1Style,
    h2Style,
    h3Style,
    h4Style,
    h5Style,
    h6Style,
  ]);

  @override
  bool operator ==(Object other) {
    return other is WikiDisplayThemeData &&
        other.textStyle == textStyle &&
        other.boldStyle == boldStyle &&
        other.italicStyle == italicStyle &&
        other.strikethroughStyle == strikethroughStyle &&
        other.inlineCodeStyle == inlineCodeStyle &&
        other.displayLatexStyle == displayLatexStyle &&
        other.linkStyle == linkStyle &&
        other.inlineLatexStyle == inlineLatexStyle &&
        other.h1Style == h1Style &&
        other.h2Style == h2Style &&
        other.h3Style == h3Style &&
        other.h4Style == h4Style &&
        other.h5Style == h5Style &&
        other.h6Style == h6Style;
  }
}

class WikiDisplayTheme extends InheritedWidget {
  const WikiDisplayTheme({
    super.key,
    required this.themeData,
    required super.child,
  });

  final WikiDisplayThemeData themeData;

  @override
  bool updateShouldNotify(WikiDisplayTheme oldWidget) =>
      oldWidget.themeData != themeData;

  static WikiDisplayThemeData of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<WikiDisplayTheme>();

    return widget?.themeData ?? const WikiDisplayThemeData();
  }
}
