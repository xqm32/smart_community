import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:smart_community/components/search.dart';
import 'package:smart_community/utils.dart';

// 物业端
class Property extends StatefulWidget {
  const Property({super.key});

  @override
  State<Property> createState() => _PropertyState();
}

class _PropertyState extends State<Property> {
  // 小区列表
  late Future<List<RecordModel>> communities;
  // 当前选择的小区
  late Future<RecordModel> community;

  // 当前选择的小区 ID
  String? communityId;
  // 底部导航栏索引
  int _index = 0;

  @override
  void initState() {
    communities = pb.collection('communities').getFullList();
    // TODO: 从缓存中读取 communityId
    if (communityId != null) {
      community = pb.collection('communities').getOne(communityId!);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('物业端'), actions: [
        // 右上角选择小区按钮
        FutureBuilder(
          future: communities,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SearchAction(
                builder: _searchActionBuilder,
                records: snapshot.data!,
                test: (element, input) =>
                    element.getStringValue('name').contains(input),
                toElement: (element) => ListTile(
                  title: Text(element.getStringValue('name')),
                  onTap: () {
                    fetchCommunity(element.id);
                    navPop(context);
                  },
                ),
              );
            }
            return Container();
          },
        )
      ]),
      body: [
        // 物业端首页
        communityId != null
            ? const LinearProgressIndicator()
            : FutureBuilder(
                future: communities,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RecordList(
                      records: snapshot.data!,
                      itemBuilder: (context, index) {
                        final element = snapshot.data!.elementAt(index);
                        return ListTile(
                          title: Text(element.getStringValue('name')),
                          onTap: () => fetchCommunity(element.id),
                        );
                      },
                    );
                  }
                  return Container();
                },
              ),

        // 物业端我的
        const LinearProgressIndicator(),
      ].elementAt(_index),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        currentIndex: _index,
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
      ),
    );
  }

  // 选择小区
  void fetchCommunity(String id) {
    setState(
      () {
        communityId = id;
        community = pb.collection('communities').getOne(communityId!);
      },
    );
  }

  // 右上角选择小区按钮
  Widget _searchActionBuilder(context, controller) {
    return TextButton(
      onPressed: () => controller.openView(),
      // 没有选择小区时显示「请选择小区」，有小区时显示小区名
      child: communityId != null
          ? FutureBuilder(
              future: community,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!.getStringValue('name'));
                }
                return Container();
              },
            )
          : const Text('请选择小区'),
    );
  }
}
