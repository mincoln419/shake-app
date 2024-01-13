import 'package:fast_app_base/screen/notification/vo/notification_type.dart';

class TossNotification {
  final NotificationType notificationType;
  final String description;
  final DateTime time;
  bool isRead;

  TossNotification(
    this.notificationType,
    this.description,
    this.time, {
    this.isRead = false,
  });
}
