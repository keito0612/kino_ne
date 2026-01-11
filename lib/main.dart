import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kino_ne/services/local_storage_service.dart';
import 'package:kino_ne/view_models/passcode/passcode_view_model.dart';
import 'package:kino_ne/views/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // .envファイルを読み込む
  await dotenv.load(fileName: ".env");
  // アプリ全体で Riverpod を使用可能にする
  runApp(
    ProviderScope(
      overrides: [
        // 2. localStorageServiceProvider を実際のインスタンスで上書き
        localStorageServiceProvider.overrideWithValue(
          LocalStorageService(prefs),
        ),
      ],
      child: const ProviderScope(child: MyForestApp()),
    ),
  );
}

class MyForestApp extends StatelessWidget {
  const MyForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: const [Locale('ja', 'JP')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('ja', 'JP'),
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
      home: const MainPage(),
    );
  }
}
