import 'package:flutter/material.dart';

import 'package:smart_community/utils.dart';

class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('修改信息')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              _InformationForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InformationForm extends StatefulWidget {
  const _InformationForm();

  @override
  State<_InformationForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_InformationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _fields = ['name', 'phone', 'identity'];
  Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    _controllers = {
      for (final i in _fields) i: TextEditingController(),
    };

    for (final i in _controllers.entries) {
      i.value.text = pb.authStore.model.getStringValue(i.key);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var element in _controllers.values) {
      element.dispose();
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
            controller: _controllers['identity'],
            decoration: const InputDecoration(
              labelText: '身份证号',
              hintText: '请输入身份证号',
            ),
            validator: notNullValidator('身份证号不能为空'),
          ),
          TextFormField(
            controller: _controllers['phone'],
            decoration: const InputDecoration(
              labelText: '手机号',
              hintText: '请输入手机号',
            ),
            validator: notNullValidator('手机号不能为空'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _onSubmitPressed(context),
            child: const Text('确认修改'),
          ),
        ],
      ),
    );
  }

  void _onSubmitPressed(context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final body = {for (final i in _controllers.entries) i.key: i.value.text};
    pb
        .collection('users')
        .update(pb.authStore.model.id, body: body)
        .then((value) => navPop(context))
        .catchError((error) => showException(context, error));
  }
}
