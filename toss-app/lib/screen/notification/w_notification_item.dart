import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/notification/vo/v_toss_notification.dart';
import 'package:flutter/material.dart';

class NotificationItemWidget extends StatefulWidget {
  const NotificationItemWidget({super.key, required this.tossNotification});

  final TossNotification tossNotification;

  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<NotificationItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [

          ],
        ),
        widget.tossNotification.description.text.make()
      ],
    );
  }
}
