import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/notification/vo/v_toss_notification.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationItemWidget extends StatefulWidget {
  const NotificationItemWidget({super.key, required this.tossNotification, required this.onTap});

  final TossNotification tossNotification;
  final VoidCallback onTap;


  @override
  State<NotificationItemWidget> createState() => _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<NotificationItemWidget> {
  static const leftPadding = 10.0;
  static const iconWidth = 25.0;

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: widget.tossNotification.isRead
            ? context.backgroundColor
            : context.appColors.unreadColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Width(leftPadding),
                Image.asset(
                  widget.tossNotification.notificationType.iconPath,
                  width: iconWidth,
                ),
                widget.tossNotification.notificationType.name.text
                    .color(context.appColors.lessImportantText)
                    .make(),
                emptyExpanded,
                timeago
                    .format(widget.tossNotification.time, locale: context.locale.languageCode)
                    .text
                    .size(13)
                    .color(context.appColors.lessImportantText)
                    .make(),
              ],
            ),
            widget.tossNotification.description.text
                .make()
                .pOnly(left: leftPadding + iconWidth)
          ],
        ),
      ),
    );
  }
}
