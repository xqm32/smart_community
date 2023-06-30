import 'package:flutter/material.dart';

import 'package:smart_community/utils.dart';
import 'package:smart_community/login.dart';

// 注册
class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// 注册/表单
class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _fields = [
    'name',
    'username',
    'password',
    'passwordConfirm'
  ];
  Map<String, TextEditingController> _controllers = {};

  String? _usernameErrorText;

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final Map<String, dynamic> body = {
      for (final i in _controllers.entries) i.key: i.value.text
    };
    body.addAll({
      'role': ['resident']
    });

    pb.collection('users').create(body: body).then((value) {
      navGoto(context, const Login());
    }).catchError((error) {
      if (error.statusCode == 400) {
        setState(() {
          _usernameErrorText = '用户名已存在';
        });
      } else if (error.statusCode == 0) {
        showError(context, '网络错误');
      } else {
        showException(context, error);
      }
    });
  }

  @override
  void initState() {
    _controllers = {
      for (final i in _fields) i: TextEditingController(),
    };

    super.initState();
  }

  @override
  void dispose() {
    for (var i in _controllers.values) {
      i.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _controllers['name'],
            decoration: const InputDecoration(
              labelText: '姓名',
              hintText: '请输入姓名',
            ),
            validator: notNullValidator('姓名不能为空'),
          ),
          TextFormField(
            controller: _controllers['username'],
            decoration: InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
              errorText: _usernameErrorText,
            ),
            validator: usernameValidator,
          ),
          TextFormField(
            controller: _controllers['password'],
            decoration: const InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
            ),
            validator: passwordValidator,
            obscureText: true,
          ),
          TextFormField(
            controller: _controllers['passwordConfirm'],
            decoration: const InputDecoration(
              labelText: '确认密码',
              hintText: '请再次输入密码',
            ),
            validator: (value) {
              final result = passwordValidator(value);
              if (result != null) {
                return result;
              }
              if (value != _controllers['password']!.text) {
                return '两次输入密码不一致';
              }
              return null;
            },
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onRegisterPressed,
            child: const Text('注册'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => navGoto(context, const Login()),
            child: const Text('登陆'),
          )
        ],
      ),
    );
  }
}
