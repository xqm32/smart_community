import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:smart_community/resident/announcement/Announcement.dart';
import 'package:smart_community/resident/announcement/announcements.dart';

import 'package:smart_community/resident/car/cars.dart';
import 'package:smart_community/resident/family/families.dart';
import 'package:smart_community/resident/house/houses.dart';
import 'package:smart_community/resident/problem/problems.dart';
import 'package:smart_community/utils.dart';

// 居民端/首页
class ResidentIndex extends StatefulWidget {
  const ResidentIndex({
    super.key,
    required this.communityId,
  });

  final String communityId;

  @override
  State<ResidentIndex> createState() => _ResidentIndexState();
}

class _ResidentIndexState extends State<ResidentIndex> {
  late Future<List<RecordModel>> announcements;

  @override
  void initState() {
    announcements = pb.collection('announcements').getFullList(
        filter: 'communityId = "${widget.communityId}"', sort: '-created');
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResidentIndex oldWidget) {
    announcements = pb.collection('announcements').getFullList(
        filter: 'communityId = "${widget.communityId}"', sort: '-created');
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder(
              future: announcements,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ResidentIndexAnnouncement(
                    announcements: snapshot.data!,
                  );
                }
                return const ResidentIndexAnnouncement(announcements: []);
              },
            ),
            const Divider(height: 8),
            ResidentIndexService(
              communityId: widget.communityId,
            ),
            const Divider(height: 8),
            FutureBuilder(
              future: announcements,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ResidentIndexAnnouncements(
                    communityId: widget.communityId,
                    announcements: snapshot.data!,
                  );
                }
                return ResidentIndexAnnouncements(
                  communityId: widget.communityId,
                  announcements: const [],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 居民端/首页/通知
class ResidentIndexAnnouncement extends StatelessWidget {
  const ResidentIndexAnnouncement({
    super.key,
    required this.announcements,
  });

  final List<RecordModel> announcements;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: Row(
        children: [
          announcements.isEmpty
              ? const Text('暂无通知')
              : Text(announcements.first.getStringValue('title')),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => navPush(
                  context,
                  ResidentAnnouncement(recordId: announcements.first.id),
                ),
                child: const Text('查看'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 居民端/首页/服务
class ResidentIndexService extends StatelessWidget {
  const ResidentIndexService({
    super.key,
    required this.communityId,
  });

  final String communityId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ResidentIndexServiceIcon(
              onPressed: () {},
              icon: Icons.person,
              text: '实名认证',
              color: Colors.orange,
            ),
            ResidentIndexServiceIcon(
              onPressed: () =>
                  navPush(context, ResidentHouses(communityId: communityId)),
              icon: Icons.home,
              text: '房屋管理',
              color: Colors.green,
            ),
            ResidentIndexServiceIcon(
              onPressed: () =>
                  navPush(context, ResidentCars(communityId: communityId)),
              icon: Icons.car_rental,
              text: '车辆管理',
              color: Colors.blue,
            ),
            ResidentIndexServiceIcon(
              onPressed: () =>
                  navPush(context, ResidentFamilies(communityId: communityId)),
              icon: Icons.people,
              text: '家人管理',
              color: Colors.purple,
            ),
          ],
        ),
        Row(
          children: [
            ResidentIndexServiceIcon(
              onPressed: () =>
                  navPush(context, ResidentProblems(communityId: communityId)),
              icon: Icons.question_mark,
              text: '问题上报',
              color: Colors.cyan,
            ),
            ResidentIndexServiceIcon(
              onPressed: () {},
              icon: Icons.how_to_vote,
              text: '预算支出投票',
              color: Colors.indigo,
            ),
            ResidentIndexServiceIcon(
              onPressed: () {},
              icon: Icons.phone,
              text: '联系物业',
              color: Colors.lightGreen,
            ),
            ResidentIndexServiceIcon(
              onPressed: () {},
              icon: Icons.more_horiz,
              text: '更多服务',
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// 居民端/首页/服务/图标
class ResidentIndexServiceIcon extends StatelessWidget {
  const ResidentIndexServiceIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.color,
  });

  final void Function() onPressed;
  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: 50,
            color: color,
          ),
          Text(text),
        ],
      ),
    );
  }
}

// 居民端/首页/新闻
class ResidentIndexAnnouncements extends StatelessWidget {
  const ResidentIndexAnnouncements({
    super.key,
    required this.communityId,
    required this.announcements,
  });

  final String communityId;
  final List<RecordModel> announcements;

  @override
  Widget build(BuildContext context) {
    // 参见 https://stackoverflow.com/questions/45669202/how-to-add-a-listview-to-a-column-in-flutter
    // ListView 在 Column 中需要有确定的高度
    return Expanded(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: Row(
              children: [
                const Text('通知公告'),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => navPush(
                        context,
                        ResidentAnnouncements(communityId: communityId),
                      ),
                      child: const Text('更多'),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(announcements[index].getStringValue('title')),
                  subtitle: Text(announcements[index].updated.split(' ')[0]),
                  onTap: () => navPush(
                    context,
                    ResidentAnnouncement(recordId: announcements.first.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
