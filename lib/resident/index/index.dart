import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

// 居民端首页组件
class ResidentIndex extends StatefulWidget {
  const ResidentIndex({
    super.key,
    required this.communityId,
    required this.notifications,
  });

  final String communityId;
  final List<RecordModel> notifications;

  @override
  State<ResidentIndex> createState() => _ResidentIndexState();
}

class _ResidentIndexState extends State<ResidentIndex> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ResidentIndexNotification(notifications: widget.notifications),
            const SizedBox(height: 8),
            const ResidentIndexService(),
            const SizedBox(height: 8),
            ResidentIndexNews(notifications: widget.notifications),
          ],
        ),
      ),
    );
  }
}

// 居民端通知组件
class ResidentIndexNotification extends StatelessWidget {
  const ResidentIndexNotification({
    super.key,
    required this.notifications,
  });

  final List<RecordModel> notifications;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications),
        title: Row(
          children: [
            Text(notifications.first.getStringValue('title')),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('查看'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// 居民端服务组件
class ResidentIndexService extends StatelessWidget {
  const ResidentIndexService({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
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
                onPressed: () {},
                icon: Icons.home,
                text: '房屋管理',
                color: Colors.green,
              ),
              ResidentIndexServiceIcon(
                onPressed: () {},
                icon: Icons.car_rental,
                text: '车辆管理',
                color: Colors.blue,
              ),
              ResidentIndexServiceIcon(
                onPressed: () {},
                icon: Icons.people,
                text: '家人管理',
                color: Colors.purple,
              ),
            ],
          ),
          Row(
            children: [
              ResidentIndexServiceIcon(
                onPressed: () {},
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
          // 卡片底部留 8 像素的空，不然会跟上面的组件贴合太近
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// 居民端服务图标组件
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

// 居民端新闻组件
class ResidentIndexNews extends StatelessWidget {
  const ResidentIndexNews({
    super.key,
    required this.notifications,
  });

  final List<RecordModel> notifications;

  @override
  Widget build(BuildContext context) {
    // 参见 https://stackoverflow.com/questions/45669202/how-to-add-a-listview-to-a-column-in-flutter
    // ListView 在 Column 中需要有确定的高度
    return Expanded(
      child: Card(
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
                        onPressed: () {},
                        child: const Text('更多'),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(notifications[index].getStringValue('title')),
                    subtitle: Text(notifications[index].updated.split(' ')[0]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}