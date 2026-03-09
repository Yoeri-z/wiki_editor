import 'package:flutter/material.dart';
import 'package:wiki_editor/wiki_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          final primary = theme.primaryColor;
          final textTheme = theme.textTheme;

          return WikiEditorTheme(
            themeData: WikiEditorThemeData(
              boldStyle: textTheme.bodyMedium!.copyWith(
                color: primary,
                fontWeight: .w700,
              ),
              italicStyle: textTheme.bodyMedium!.copyWith(
                color: primary,
                fontStyle: .italic,
              ),
              strikethroughStyle: textTheme.bodyMedium!.copyWith(
                color: primary,
                decoration: .lineThrough,
              ),
              linkStyle: textTheme.bodyMedium!.copyWith(color: primary),
              latexStyle: textTheme.bodyMedium!.copyWith(color: primary),
              headerStyle: textTheme.bodyMedium!.copyWith(
                color: primary,
                fontWeight: .w700,
              ),
            ),
            child: const MyHomePage(title: 'Flutter Demo Home Page'),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final WikiController controller = WikiController();
  void _rebuilder() => setState(() {});

  @override
  void initState() {
    super.initState();
    controller.addListener(_rebuilder);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            spacing: 20,
            mainAxisAlignment: .center,
            children: [
              SizedBox(
                width: 400,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: WikiCodeEditor(controller: controller),
                  ),
                ),
              ),
              SizedBox(
                width: 400,
                child: DisplayWidget(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
