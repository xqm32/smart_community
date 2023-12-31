import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:smart_community/utils.dart';

class ResidentFamily extends StatefulWidget {
  const ResidentFamily({
    required this.communityId,
    super.key,
    this.recordId,
  });

  final String communityId;
  final String? recordId;

  @override
  State<ResidentFamily> createState() => _ResidentFamilyState();
}

class _ResidentFamilyState extends State<ResidentFamily> {
  List<GlobalKey<FormState>> _formKeys = [];

  final List<String> _fields = ['name', 'identity', 'relation'];
  Map<String, TextEditingController> _controllers = {};

  final List<String> _steps = ['填写信息', '物业审核', '审核通过'];
  final Map<String, int> _stateIndex = {'reviewing': 1, 'verified': 2};
  int _index = 0;

  final RecordService service = pb.collection('families');

  RecordModel? _record;

  @override
  void initState() {
    _formKeys = List.generate(
      _steps.length,
      (final int index) => GlobalKey<FormState>(),
    );
    _controllers = {
      for (final String i in _fields) i: TextEditingController(),
    };
    if (widget.recordId != null) {
      service.getOne(widget.recordId!).then(_setRecord);
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final TextEditingController i in _controllers.values) {
      i.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('家人管理'),
          actions: _actionsBuilder(context),
        ),
        body: Stepper(
          type: StepperType.horizontal,
          currentStep: _index,
          controlsBuilder:
              (final BuildContext context, final ControlsDetails details) =>
                  Container(),
          steps: [
            for (int i = 0; i < _steps.length; ++i)
              Step(
                isActive: _index >= i,
                title: Text(_steps.elementAt(i)),
                content: _form(index: i),
              ),
          ],
        ),
      );

  void _setRecord(final RecordModel record) async {
    final String state = record.getStringValue('state');
    for (final MapEntry<String, TextEditingController> i
        in _controllers.entries) {
      i.value.text = record.getStringValue(i.key);
    }
    final test = await pb.collection('users').getFullList(
        filter: 'identity = "${record.getStringValue('identity')}"');
    RecordModel data;
    if (test.isEmpty) {
      data = await pb.collection('users').create(
        body: {
          'username': record.getStringValue('identity'),
          'password': record.getStringValue('identity').substring(10),
          'passwordConfirm': record.getStringValue('identity').substring(10),
          'name': record.getStringValue('name'),
          'phone': record.getStringValue('phone'),
          'identity': record.getStringValue('identity'),
          'role': 'resident',
        },
      );
    } else {
      data = test.first;
    }
    pb
        .collection('residents')
        .create(
          body: {
            'communityId': widget.communityId,
            'userId': data.id,
            'state': 'reviewing',
          },
        )
        .then((final value) {})
        .catchError((final error) {});

    setState(() {
      _record = record;
      _index = _stateIndex[state] ?? 0;
    });
  }

  Map<String, dynamic> _getBody() {
    final Map<String, dynamic> body = {
      for (final MapEntry<String, TextEditingController> i
          in _controllers.entries)
        i.key: i.value.text
    };
    body.addAll({
      'userId': pb.authStore.model!.id,
      'communityId': widget.communityId,
      'state': 'reviewing',
    });

    return body;
  }

  void _onSubmitPressed() {
    if (!_formKeys[_index].currentState!.validate()) {
      return;
    }

    if (_index == 0) {
      service
          .create(body: _getBody())
          .then(_setRecord)
          .catchError((final error) => showException(context, error));
      showSuccess(context, '提交成功');
    } else {
      service
          .update(_record!.id, body: _getBody())
          .then(_setRecord)
          .catchError((final error) => showException(context, error));
      showSuccess(context, '修改成功');
    }
  }

  Widget _form({required final int index}) => Form(
        key: _formKeys[index],
        child: Column(
          children: [
            TextFormField(
              controller: _controllers['name'],
              decoration: const InputDecoration(
                labelText: '姓名',
                hintText: '请填写家人姓名',
              ),
              validator: FormBuilderValidators.required(errorText: '姓名不能为空'),
            ),
            TextFormField(
              controller: _controllers['identity'],
              decoration: const InputDecoration(
                labelText: '身份证号',
                hintText: '请填写家人身份证号',
              ),
              validator: FormBuilderValidators.required(errorText: '身份证号不能为空'),
            ),
            TextFormField(
              controller: _controllers['relation'],
              decoration: const InputDecoration(
                labelText: '关系',
                hintText: '请填写关系',
              ),
              validator: FormBuilderValidators.required(errorText: '关系不能为空'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onSubmitPressed,
              child: Text(['提交', '修改信息', '修改信息'].elementAt(_index)),
            )
          ],
        ),
      );

  List<Widget>? _actionsBuilder(final context) {
    if (_record == null) {
      return null;
    }

    return [
      IconButton(
        onPressed: () => showDialog(
          context: context,
          builder: (final BuildContext context) => AlertDialog(
            surfaceTintColor: Theme.of(context).colorScheme.background,
            title: const Text('删除家人'),
            content: const Text('确定要删除该家人吗？'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  navPop(context, 'Cancel');
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  service.delete(_record!.id).then((final value) {
                    navPop(context, 'OK');
                    navPop(context);
                  });
                },
                child: const Text('确认'),
              ),
            ],
          ),
        ),
        icon: const Icon(
          Icons.delete_outline,
          color: Colors.red,
        ),
      )
    ];
  }
}
