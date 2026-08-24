import 'package:flutter/material.dart';

import 'screens/home_shell.dart';

/// 브랜드 컬러 — 앱 전체에서 이 상수만 참조한다.
const hornetYellow = Color(0xFFF7CE4C);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '말벌 아저씨',
      theme: ThemeData(
        useMaterial3: true,
        // ColorScheme: 앱의 "색 역할표". primary(주인공 색), onPrimary(그 위의
        // 글자색), surface(카드 같은 면) 역할별로 색을 정해두면
        // 버튼·카드·앱바가 알아서 가져다 쓴다.
        colorScheme: ColorScheme.fromSeed(
          seedColor: hornetYellow,
        ).copyWith(
          primary: hornetYellow,
          onPrimary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: hornetYellow,
        appBarTheme: const AppBarTheme(
          backgroundColor: hornetYellow,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: hornetYellow,
        ),
      ),
      home: const HomeShell(),
    );
  }
}
