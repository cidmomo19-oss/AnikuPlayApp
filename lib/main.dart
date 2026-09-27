import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/main_shell.dart';
import 'app/theme.dart';

void main() {
  runApp(const ProviderScope(child: AnikuPlayApp()));
}

class AnikuPlayApp extends StatelessWidget {
  const AnikuPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnikuPlay',
      debugShowCheckedModeBanner: false,
      scrollBehavior: AppScrollBehavior(),
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}
