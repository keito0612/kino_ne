import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/views/pages/editor_page.dart';
import 'package:kino_ne/views/pages/home_page.dart';
import 'package:kino_ne/views/pages/tree_detail_page.dart';
import 'models/page.dart' as model; // 名前の衝突を避けるためにここでも as model を使用

void main() {
  // アプリ全体で Riverpod を使用可能にする
  runApp(const ProviderScope(child: MyForestApp()));
}

class MyForestApp extends StatelessWidget {
  const MyForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '言葉の森',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green.shade700,
          secondary: Colors.amber.shade700,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // 最初の画面
      home: const HomePage(),
    );
  }
}
