import 'package:flutter/material.dart';

import 'package:smart_community/login.dart';

void main() {
  runApp(const App());
}

// 应用组件
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 不显示 DEBUG 横幅
      debugShowCheckedModeBanner: false,
      title: 'Smart Community',
      theme: ThemeData(
        // 设置主题色
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
