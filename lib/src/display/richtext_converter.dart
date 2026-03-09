import 'package:flutter/widgets.dart';
import '../parser/nodes.dart';

class WikiRichTextConverter {
  static InlineSpan convertToSpan(BuildContext context, List<BlockNode> nodes) {
    final List<InlineSpan> children = [];

    for (var i = 0; i < nodes.length; i++) {
      children.add(nodes[i].build(context));
      if (i < nodes.length - 1) {
        children.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: children);
  }
}
