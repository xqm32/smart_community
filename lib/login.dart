import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:smart_community/property/property.dart';
import 'package:smart_community/register.dart';
import 'package:smart_community/resident/resident.dart';
import 'package:smart_community/utils.dart';

// 登陆
class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// 登陆/表单
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _fields = ['username', 'password'];
  Map<String, TextEditingController> _controllers = {};

  String role = 'resident';

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
          _roleChoice(),
          TextFormField(
            controller: _controllers['username'],
            decoration: const InputDecoration(
              labelText: '用户名',
              hintText: '请输入用户名',
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onLoginPressed,
            child: const Text('登陆'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => navGoto(context, const Register()),
            child: const Text('注册'),
          )
        ],
      ),
    );
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
  
    pb
        .collection('users')
        .authWithPassword(
            _controllers['username']!.text, _controllers['password']!.text)
        .then(_onValue)
        .catchError(_onError);
  }

  void _onValue(RecordAuth value) {
    final isResident = value.record?.getBoolValue('isResident');
    final isProperty = value.record?.getBoolValue('isProperty');

    if (role == 'resident' && isResident != null && isResident) {
      navGoto(context, const Resident());
    } else if (role == 'property' && isProperty != null && isProperty) {
      navGoto(context, const Property());
    } else {
      showError(context, '角色不匹配');
    }
  }

  void _onError(error) {
    if (error.statusCode == 400) {
      showError(context, '用户名或密码错误');
    } else if (error.statusCode == 0) {
      showError(context, '网络错误');
    } else {
      showException(context, error);
    }
  }

  Widget _roleChoice() {
    return SegmentedButton(
      segments: const [
        ButtonSegment(
          value: 'resident',
          label: Text('居民'),
        ),
        ButtonSegment(
          value: 'property',
          label: Text('物业'),
        ),
      ],
      selected: {role},
      onSelectionChanged: (value) => setState(() => role = value.first),
    );
  }
}
