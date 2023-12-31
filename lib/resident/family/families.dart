import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:smart_community/components/manage.dart';
import 'package:smart_community/resident/family/family.dart';
import 'package:smart_community/utils.dart';

class ResidentFamilies extends StatelessWidget {
  const ResidentFamilies({
    required this.communityId,
    super.key,
  });

  final String communityId;

  @override
  Widget build(final BuildContext context) => Manage(
        title: const Text('家人管理'),
        fetchRecords: fetchRecords,
        filter: keyFilter('name'),
        toElement: toElement,
        onAddPressed: onAddPressed,
      );

  Future<List<RecordModel>> fetchRecords() {
    final String filter =
        'communityId = "$communityId" && userId = "${pb.authStore.model!.id}"';
    return pb
        .collection('families')
        .getFullList(filter: filter, sort: '-created');
  }

  void onAddPressed(
    final BuildContext context,
    final void Function() refreshRecords,
  ) {
    navPush(
      context,
      ResidentFamily(communityId: communityId),
    ).then((final value) => refreshRecords());
  }

  Widget toElement(
    final BuildContext context,
    final void Function() refreshRecords,
    final RecordModel record,
  ) =>
      ListTile(
        title: Text(record.getStringValue('name')),
        subtitle: Text(record.getStringValue('relation')),
        trailing: _recordState(record),
        onTap: () {
          navPush(
            context,
            ResidentFamily(communityId: communityId, recordId: record.id),
          ).then((final value) => refreshRecords());
        },
      );

  Widget _recordState(final RecordModel record) {
    final String state = record.getStringValue('state');
    const double fontSize = 16;

    if (state == 'reviewing') {
      return const Text(
        '审核中',
        style: TextStyle(
          color: Colors.purple,
          fontSize: fontSize,
        ),
      );
    } else if (state == 'verified') {
      return const Text(
        '审核通过',
        style: TextStyle(
          color: Colors.green,
          fontSize: fontSize,
        ),
      );
    } else if (state == 'rejected') {
      return const Text(
        '审核未通过',
        style: TextStyle(
          color: Colors.red,
          fontSize: fontSize,
        ),
      );
    }
    return const Text(
      '未知状态',
      style: TextStyle(
        color: Colors.grey,
        fontSize: fontSize,
      ),
    );
  }
}
