import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/notification/notification_dummy.dart';
import 'package:fast_app_base/screen/notification/w_notification_item.dart';
import 'package:flutter/material.dart';

import 'd_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: context.appColors.appBarBackground,
            title: "알림".text.white.make(),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, idx) => NotificationItemWidget(
                tossNotification: notificationDummies[idx],
                onTap: () {
                  NotificationDialog([notificationDummies[0], notificationDummies[1]]).show();
                },
              ),
              childCount: notificationDummies.length,
            ),
          ),
        ],
      ),
    );
  }
}
