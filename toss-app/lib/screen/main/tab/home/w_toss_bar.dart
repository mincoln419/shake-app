import 'package:fast_app_base/common/common.dart';
import 'package:flutter/material.dart';

class TossBar extends StatefulWidget {
  const TossBar({super.key});

  @override
  State<TossBar> createState() => _TossBarState();
}

class _TossBarState extends State<TossBar> {

  bool _show_red_dot = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
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
              _show_red_dot = !_show_red_dot;
            }),
            child: Stack(
              children: [
                Image.asset(
                  "$basePath/icon/notification.png",
                  height: 30,
                ),
                if(_show_red_dot)Positioned.fill(
                    child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: Colors.red),
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
