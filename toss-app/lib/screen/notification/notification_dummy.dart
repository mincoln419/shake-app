import 'package:fast_app_base/common/cli_common.dart';
import 'package:fast_app_base/screen/notification/vo/notification_type.dart';
import 'package:fast_app_base/screen/notification/vo/v_toss_notification.dart';

final notificationDummies = <TossNotification>[
  TossNotification(
      NotificationType.tossPay,
      "이번 주에 영화 한편 어떠세요? \n CGV에서 영화티켓 할인 쿠폰이 도착했어요",
      DateTime.now().subtract(27.minutes)),
  TossNotification(
      NotificationType.walk,
      "금일 3000보 달성하셨어요. 앞으로도 화이팅!",
      DateTime.now().subtract(180.minutes)),
  TossNotification(
      NotificationType.stock,
      "코스피 2700선 돌파!!!! ",
      DateTime.now().subtract(247.minutes)),
  TossNotification(
      NotificationType.luck,
      "행운의 룰렛 이벤트 참가! 선착순 10000명에게 10000원 지급!",
      DateTime.now().subtract(90.minutes)),
  TossNotification(
      NotificationType.people,
      "이번 주 공동구매 물픔! 최신형 ☺ 다이슨 헤어 드라이기 ",
      DateTime.now().subtract(21.minutes)),
  TossNotification(
      NotificationType.tossPay,
      "이번 달 토스로 받은 혜택 금액을 확인해보세요!",
      DateTime.now().subtract(36.minutes)),
  TossNotification(
      NotificationType.tossPay,
      "경성 크리처 & 토스 페이 콜라보레이션 공개!! 🥰🥰🥰🥰",
      DateTime.now().subtract(443.minutes)),
  TossNotification(
      NotificationType.walk,
      "만보기 첼린지 이벤트가 곧 마감됩니다. D-2",
      DateTime.now().subtract(55.minutes)),
  TossNotification(
      NotificationType.moneyTip,
      "오늘의 머니팁! 확인해보시겠어요?",
      DateTime.now().subtract(1.minutes)),
];
