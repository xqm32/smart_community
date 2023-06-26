import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:smart_community/register.dart';
import 'package:smart_community/utils.dart';

// 登陆页面组件
class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // 使用 Center 将内容居中
      body: Center(
        // 外侧加入边距，这样显得好看些😊
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

// 登陆表单组件
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // 参见 https://api.flutter.dev/flutter/widgets/Form-class.html#widgets.Form.1
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 参见 https://docs.flutter.dev/cookbook/forms/text-field-changes#2-use-a-texteditingcontroller
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 角色属性定义在这里，传递到下级组件
  String role = 'resident';
  String getRole() => role;
  void setRole(Set<dynamic> selection) {
    setState(() => role = selection.first);
  }

  @override
  void dispose() {
    // 参见 https://docs.flutter.dev/cookbook/forms/text-field-changes#create-a-texteditingcontroller 中的 Note
    // 释放 controller 的资源
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 完善这里的页面导航
    void authThen(RecordAuth value) {
      final authRole = value.record?.getStringValue('role');
      if (authRole == role) {
        navGoto(context, const Text('登陆成功'));
      } else {
        navGoto(context, const Text('角色不匹配'));
      }
    }

    // 参见 https://github.com/pocketbase/dart-sdk#error-handling
    // TODO: 完善这里的页面导航
    void onLoginPressed() {
      pb
          .collection('users')
          .authWithPassword(_usernameController.text, _passwordController.text)
          .then(authThen)
          .catchError((error) => navGoto(context, Text('$error')));
    }

    // TODO: 表单验证
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RoleChoice(
            getRole: getRole,
            setRole: setRole,
          ),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: '用户名',
              hintText: '请输入手机号',
            ),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
            ),
            // 隐藏密码
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onLoginPressed,
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
}

// 参见 https://api.flutter.dev/flutter/material/SegmentedButton-class.html
// 角色选择组件
class RoleChoice extends StatelessWidget {
  // 非常暴力的获取上级属性方式......但很有效🥺
  final String Function() getRole;
  final void Function(Set<dynamic>) setRole;

  const RoleChoice({
    super.key,
    required this.getRole,
    required this.setRole,
  });

  @override
  Widget build(BuildContext context) {
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
      selected: {getRole()},
      onSelectionChanged: setRole,
    );
  }
}
