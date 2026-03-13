import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../color.dart';

class StyledDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;

  const StyledDialog({Key? key, required this.title, required this.content, this.actions, this.maxWidth = 520}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(gradient: LinearGradient(colors: [primaryblue, primaryblue]), borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(children: [
              Expanded(child: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              IconButton(onPressed: () => Get.back(), icon: Icon(Icons.close, color: Colors.white))
            ]),
          ),
          Padding(padding: const EdgeInsets.all(14.0), child: content),
          if (actions != null && actions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
            ),
        ]),
      ),
    );
  }
}

Future<T?> showStyledDialog<T>(BuildContext context, {required String title, required Widget content, List<Widget>? actions, bool barrierDismissible = true, double maxWidth = 520}) {
  return Get.dialog<T>(StyledDialog(title: title, content: content, actions: actions, maxWidth: maxWidth), barrierDismissible: barrierDismissible);
}
