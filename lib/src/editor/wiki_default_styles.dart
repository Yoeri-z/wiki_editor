import 'package:flutter/material.dart';

@immutable
class WikiEditorThemeData {
  const WikiEditorThemeData({
    this.tokenColor = const Color.fromARGB(255, 0, 89, 255),
    this.boldColor = const Color.fromARGB(255, 21, 101, 192),
    this.italicColor = const Color.fromARGB(255, 0, 150, 136),
    this.linkColor = const Color.fromARGB(255, 255, 111, 0),
    this.latexColor = const Color.fromARGB(255, 76, 175, 80),
    this.headerColor = const Color.fromARGB(255, 198, 40, 40),
  });

  final Color tokenColor;
  final Color boldColor;
  final Color italicColor;
  final Color linkColor;
  final Color latexColor;
  final Color headerColor;

  @override
  int get hashCode => Object.hashAll([
    tokenColor,
    boldColor,
    italicColor,
    linkColor,
    latexColor,
    headerColor,
  ]);

  @override
  bool operator ==(Object other) {
    return other is WikiEditorThemeData &&
        other.tokenColor == tokenColor &&
        other.boldColor == boldColor &&
        other.italicColor == italicColor &&
        other.linkColor == linkColor &&
        other.latexColor == latexColor &&
        other.headerColor == headerColor;
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

    return widget?.themeData ?? WikiEditorThemeData();
  }
}
