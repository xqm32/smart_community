import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:smart_community/utils.dart';

// 物业端/首页/车辆审核
class PropertyCar extends StatefulWidget {
  const PropertyCar({
    super.key,
    required this.communityId,
    this.recordId,
  });

  final String communityId;
  final String? recordId;

  @override
  State<PropertyCar> createState() => _PropertyCarState();
}

class _PropertyCarState extends State<PropertyCar> {
  List<GlobalKey<FormState>> _formKeys = [];

  final List<String> _fields = ['name', 'plate'];
  Map<String, TextEditingController> _controllers = {};

  final List<String> _steps = ['填写信息', '物业审核', '审核通过'];
  final Map<String, int> _stateIndex = {
    'reviewing': 1,
    'rejected': 1,
    'verified': 2
  };
  int _index = 1;

  final service = pb.collection('cars');

  RecordModel? _record;

  @override
  void initState() {
    _formKeys = List.generate(_steps.length, (index) => GlobalKey<FormState>());
    _controllers = {
      for (final i in _fields) i: TextEditingController(),
    };
    if (widget.recordId != null) {
      service.getOne(widget.recordId!).then(_setRecord);
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('车辆审核'),
        actions: _actionsBuilder(context),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _index,
        controlsBuilder: (context, details) => Container(),
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
  }

  void _setRecord(RecordModel value) {
    final state = value.getStringValue('state');
    for (final i in _controllers.entries) {
      i.value.text = value.getStringValue(i.key);
    }
    setState(() {
      _record = value;
      _index = _stateIndex[state] ?? 0;
    });
  }

  Map<String, dynamic> _getBody() {
    final Map<String, dynamic> body = {
      for (final i in _controllers.entries) i.key: i.value.text
    };
    body.addAll({
      'userId': pb.authStore.model!.id,
      'communityId': widget.communityId,
    });

    return body;
  }

  void _onSubmitPressed() {
    if (!_formKeys[_index].currentState!.validate()) {
      return;
    }

    final body = _getBody();
    body.addAll({'state': 'verified'});
    service
        .update(_record!.id, body: body)
        .then(_setRecord)
        .catchError((error) => showException(context, error));
  }

  void _onRejectPressed() {
    if (!_formKeys[_index].currentState!.validate()) {
      return;
    }

    final body = _getBody();
    body.addAll({'state': 'rejected'});
    service
        .update(_record!.id, body: body)
        .then(_setRecord)
        .catchError((error) => showException(context, error));
  }

  // 物业端/首页/车辆审核/填写信息
  Widget _form({required int index}) {
    return Form(
      key: _formKeys[index],
      child: Column(
        children: [
          TextFormField(
            enabled: false,
            controller: _controllers['name'],
            decoration: const InputDecoration(
              labelText: '名称',
              hintText: '请填写车辆名称',
            ),
            validator: notNullValidator('名称不能为空'),
          ),
          TextFormField(
            enabled: false,
            controller: _controllers['plate'],
            decoration: const InputDecoration(
              labelText: '车牌号',
              hintText: '请填写车牌号',
            ),
            validator: notNullValidator('车牌号不能为空'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onSubmitPressed,
            child: Text(['通过', '通过'].elementAt(_index - 1)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _onRejectPressed,
            child: Text(
              ['驳回', '驳回'].elementAt(_index - 1),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // 物业端/首页/车辆审核/删除车辆
  List<Widget>? _actionsBuilder(context) {
    if (_record == null) {
      return null;
    }

    return [
      IconButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              surfaceTintColor: Theme.of(context).colorScheme.background,
              title: const Text('删除车辆'),
              content: const Text('确定要删除该车辆吗？'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    navPop(context, 'Cancel');
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    service.delete(_record!.id).then((value) {
                      navPop(context, 'OK');
                      navPop(context);
                    });
                  },
                  child: const Text('确认'),
                ),
              ],
            );
          },
        ),
        icon: const Icon(
          Icons.delete_outline,
          color: Colors.red,
        ),
      )
    ];
  }
}
