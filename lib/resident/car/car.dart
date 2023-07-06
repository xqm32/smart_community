import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:smart_community/utils.dart';

class ResidentCar extends StatefulWidget {
  const ResidentCar({
    super.key,
    required this.communityId,
    this.recordId,
  });

  final String communityId;
  final String? recordId;

  @override
  State<ResidentCar> createState() => _ResidentCarState();
}

class _ResidentCarState extends State<ResidentCar> {
  List<GlobalKey<FormState>> _formKeys = [];

  final List<String> _fields = ['name', 'plate'];
  Map<String, TextEditingController> _controllers = {};

  final List<String> _steps = ['填写信息', '物业审核', '审核通过'];
  final Map<String, int> _stateIndex = {
    'reviewing': 1,
    'rejected': 1,
    'verified': 2,
  };
  int _index = 0;

  Map<String, dynamic>? _struct;
  String? _area;
  String? _zone;
  String? _position;

  final List<String> _fileFields = ['photo'];
  Map<String, Uint8List?> _files = {};
  Map<String, String?> _filenames = {};

  final service = pb.collection('cars');

  RecordModel? _record;

  @override
  void initState() {
    _formKeys = List.generate(_steps.length, (index) => GlobalKey<FormState>());
    _controllers = {
      for (final i in _fields) i: TextEditingController(),
    };
    _files = {
      for (final i in _fileFields) i: null,
    };
    _filenames = {
      for (final i in _fileFields) i: null,
    };

    pb.collection('communities').getOne(widget.communityId).then((value) {
      final struct = value.getStringValue('parking');

      setState(() {
        _struct = struct.isNotEmpty
            ? jsonDecode(struct) as Map<String, dynamic>
            : null;
      });

      if (widget.recordId != null) {
        service.getOne(widget.recordId!).then(_setRecord);
      }
    });

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
        title: const Text('车辆管理'),
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

  void _setRecord(RecordModel record) async {
    final state = record.getStringValue('state');
    for (final i in _controllers.entries) {
      i.value.text = record.getStringValue(i.key);
    }
    final images = {};
    for (final i in _fileFields) {
      final filename = record.getStringValue(i);
      if (filename.isNotEmpty) {
        final resp = await get(pb.getFileUrl(record, record.getStringValue(i)));
        images[i] = resp.bodyBytes;
      }
    }
    String? area = record.getStringValue('area');
    String? zone = record.getStringValue('zone');
    String? position = record.getStringValue('position');
    if (_struct == null || !_struct!.containsKey(area)) {
      area = null;
      zone = null;
      position = null;
    } else if (!_struct![area]!.containsKey(zone)) {
      zone = null;
      position = null;
    } else if (!_struct![area]![zone]!.contains(position)) {
      position = null;
    }
    setState(() {
      _record = record;
      for (final i in images.keys) {
        _files[i] = images[i];
      }
      _index = _stateIndex[state] ?? 0;
      _area = area;
      _zone = zone;
      _position = position;
    });
  }

  Map<String, dynamic> _getBody() {
    final Map<String, dynamic> body = {
      for (final i in _controllers.entries) i.key: i.value.text
    };
    body.addAll({
      'userId': pb.authStore.model!.id,
      'communityId': widget.communityId,
      'state': 'reviewing',
      'area': _area,
      'zone': _zone,
      'position': _position,
    });

    return body;
  }

  void _onSubmitPressed() {
    if (!_formKeys[_index].currentState!.validate()) {
      return;
    }

    final files = [
      for (final i in _files.entries)
        if (i.value != null && _filenames[i.key] != null)
          MultipartFile.fromBytes(i.key, i.value!, filename: _filenames[i.key])
    ];

    if (_index == 0) {
      service
          .create(body: _getBody(), files: files)
          .then(_setRecord)
          .catchError((error) => showException(context, error));
    } else {
      service
          .update(_record!.id, body: _getBody(), files: files)
          .then(_setRecord)
          .catchError((error) => showException(context, error));
    }
  }

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

  Widget _imageForm(
    String field,
    String labelText,
    String hintText,
    void Function(String filename, Uint8List bytes) update,
  ) {
    return Column(
      children: [
        Container(
          decoration: _files[field] != null
              ? null
              : BoxDecoration(border: Border.all(color: Colors.grey)),
          height: 160,
          child: _files[field] != null
              ? Image.memory(
                  _files[field]!,
                )
              : Center(child: Text(labelText)),
        ),
        TextButton(
          onPressed: () {
            pickImage(update: update);
          },
          child: Text(hintText),
        ),
      ],
    );
  }

  Widget _form({required int index}) {
    return Form(
      key: _formKeys[index],
      child: Column(
        children: [
          TextFormField(
            controller: _controllers['name'],
            decoration: const InputDecoration(
              labelText: '名称',
              hintText: '请填写车辆名称',
            ),
            validator: notNullValidator('名称不能为空'),
          ),
          TextFormField(
            controller: _controllers['plate'],
            decoration: const InputDecoration(
              labelText: '车牌号',
              hintText: '请填写车牌号',
            ),
            validator: notNullValidator('车牌号不能为空'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: '区域'),
                  value: _area,
                  items: _struct?.keys
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _area = value;
                      _zone = null;
                      _position = null;
                    });
                  },
                  validator: notNullValidator('区域不能为空'),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: '分区'),
                  value: _zone,
                  items: (_struct?[_area] as Map<String, dynamic>?)
                      ?.keys
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _zone = value;
                      _position = null;
                    });
                  },
                  validator: notNullValidator('分区不能为空'),
                ),
              ),
            ],
          ),
          DropdownButtonFormField(
            decoration: const InputDecoration(labelText: '车位'),
            value: _position,
            items: (_struct?[_area]?[_zone] as List?)
                ?.map((e) => DropdownMenuItem(
                      value: e as String,
                      child: Text(e),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _position = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _imageForm('photo', '请上传车辆照片', '选择车辆照片', (filename, bytes) {
            setState(() {
              _files['photo'] = bytes;
              _filenames['photo'] = filename;
            });
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _onSubmitPressed,
            child: Text(['提交', '修改信息', '修改信息'].elementAt(_index)),
          )
        ],
      ),
    );
  }
}
