import 'package:doaya_ui/doaya_ui.dart';
import 'package:flutter/material.dart';

/// Wraps [child] in an RTL MaterialApp with the given Doaya theme.
Widget harness(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? DoayaTheme.glass(),
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: DoayaBackground(
        child: Scaffold(
          body: Center(child: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}
