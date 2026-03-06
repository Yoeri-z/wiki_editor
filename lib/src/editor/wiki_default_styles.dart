import 'package:flutter/material.dart';

@immutable
class WikiEditorThemeData {
  const WikiEditorThemeData({
    this.tokenColor = const Color.fromARGB(255, 0, 89, 255),
  });

  final Color tokenColor;

  @override
  int get hashCode => Object.hashAll([tokenColor]);

  @override
  bool operator ==(Object other) {
    return other is WikiEditorThemeData && other.tokenColor == tokenColor;
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
