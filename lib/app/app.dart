import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';

class BuzzStringApp extends ConsumerWidget {
  const BuzzStringApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BuzzString App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF003057),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0xFFB3A369),
          cursorColor: Color(0xFFB3A369),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF003057),
        ),
      ),
      routerConfig: router,
    );
  }
}
