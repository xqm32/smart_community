import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

// PocketBaser 实例
final pb = PocketBase('http://127.0.0.1:8090');

// 导航 push 方法的缩写，原来的方法太长了
void navPush(context, widget) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => widget,
  ));
}

// 导航 pop 方法的缩写
void navPop(context) {
  Navigator.of(context).pop();
}

// 跳转至组件并移除导航栈
void navGoto(context, widget) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => widget),
    (route) => false,
  );
}

// 使用 SnackBar 显示错误信息的缩写
void showError(context, error) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
}
