import 'package:flutter/material.dart';

@immutable
class WikiEditorThemeData {
  const WikiEditorThemeData({
    this.textStyle = const TextStyle(),
    this.boldStyle = const TextStyle(
      color: Color.fromARGB(255, 21, 101, 192),
      fontWeight: FontWeight.bold,
    ),
    this.italicStyle = const TextStyle(
      color: Color.fromARGB(255, 0, 150, 136),
      fontStyle: FontStyle.italic,
    ),
    this.strikethroughStyle = const TextStyle(
      color: Colors.grey,
      decoration: TextDecoration.lineThrough,
    ),
    this.inlineCodeStyle = const TextStyle(
      color: Colors.deepPurple,
      backgroundColor: Color.fromARGB(20, 0, 0, 0),
    ),
    this.linkStyle = const TextStyle(color: Color.fromARGB(255, 255, 111, 0)),
    this.latexStyle = const TextStyle(color: Color.fromARGB(255, 76, 175, 80)),
    this.headerStyle = const TextStyle(
      color: Color.fromARGB(255, 198, 40, 40),
      fontWeight: FontWeight.bold,
    ),
  });

  final TextStyle textStyle;
  final TextStyle boldStyle;
  final TextStyle italicStyle;
  final TextStyle strikethroughStyle;
  final TextStyle inlineCodeStyle;
  final TextStyle linkStyle;
  final TextStyle latexStyle;
  final TextStyle headerStyle;

  @override
  int get hashCode => Object.hashAll([
    textStyle,
    boldStyle,
    italicStyle,
    strikethroughStyle,
    inlineCodeStyle,
    linkStyle,
    latexStyle,
    headerStyle,
  ]);

  @override
  bool operator ==(Object other) {
    return other is WikiEditorThemeData &&
        other.textStyle == textStyle &&
        other.boldStyle == boldStyle &&
        other.italicStyle == italicStyle &&
        other.strikethroughStyle == strikethroughStyle &&
        other.inlineCodeStyle == inlineCodeStyle &&
        other.linkStyle == linkStyle &&
        other.latexStyle == latexStyle &&
        other.headerStyle == headerStyle;
  }
}

class WikiEditorTheme extends InheritedWidget {
  const WikiEditorTheme({
    super.key,
    required this.themeData,
    required super.child,
  });

  final WikiEditorThemeData themeData;

  @override
  bool updateShouldNotify(WikiEditorTheme oldWidget) =>
      oldWidget.themeData != themeData;

  static WikiEditorThemeData of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<WikiEditorTheme>();

    return widget?.themeData ?? const WikiEditorThemeData();
  }
}
