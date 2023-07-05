import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_community/components/search.dart';
import 'package:smart_community/account/account.dart';
import 'package:smart_community/resident/index.dart';
import 'package:smart_community/utils.dart';

class Resident extends StatefulWidget {
  const Resident({super.key});

  @override
  State<Resident> createState() => _ResidentState();
}

class _ResidentState extends State<Resident> {
  late Future<List<RecordModel>> communities;

  late Future<RecordModel> community;

  String? communityId;

  int _index = 0;

  @override
  void initState() {
    communities = pb.collection('communities').getFullList();
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.containsKey('communityId')) {
        fetchCommunity(prefs.getString('communityId')!);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('居民端'), actions: [
        FutureBuilder(
          future: communities,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SearchAction(
                builder: _searchActionBuilder,
                records: snapshot.data!,
                filter: (element, input) =>
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
        communityId != null
            ? ResidentIndex(communityId: communityId!)
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
        const Account(),
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

  void fetchCommunity(String id) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('communityId', id);
      setState(
        () {
          communityId = id;
          community = pb.collection('communities').getOne(communityId!);
        },
      );
    });
  }

  Widget _searchActionBuilder(context, controller) {
    return TextButton(
      onPressed: () => controller.openView(),
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
