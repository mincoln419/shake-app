import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/notification/s_notification.dart';
import 'package:flutter/material.dart';

class TossBar extends StatefulWidget {
  static const double appBarHeight = 60;
  const TossBar({super.key});

  @override
  State<TossBar> createState() => _TossBarState();
}

class _TossBarState extends State<TossBar> {

  bool _showRedDot = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TossBar.appBarHeight,
      color: context.appColors.appBarBackground,
      child: Row(
        children: [
          width10,
          Image.asset(
            "$basePath/icon/toss.png",
            height: 30,
          ),
          emptyExpanded,
          Image.asset(
            "$basePath/icon/map_point.png",
            height: 30,
          ),
          width10,
          Tap(
            onTap: () => setState(() {
              _showRedDot = !_showRedDot;
              Nav.push(NotificationScreen());
            }),
            child: Stack(
              children: [
                Image.asset(
                  "$basePath/icon/notification.png",
                  height: 30,
                ),
                if(_showRedDot)Positioned.fill(
                    child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration:
                        const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                  ),
                ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
