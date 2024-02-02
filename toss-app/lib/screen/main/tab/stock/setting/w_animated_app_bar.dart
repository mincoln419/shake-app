import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/widget/w_arrow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../../common/widget/w_tap.dart';

class AnimatedAppBar extends StatefulWidget {
  final String title;
  final ScrollController scrollController;
  final AnimationController animationController;

  const AnimatedAppBar(
    this.title, {
    super.key,
    required this.scrollController, required this.animationController,
  });

  @override
  State<AnimatedAppBar> createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  Duration duration = 10.ms;
  double scrollPosition = 0;
  late Animation<double> animation = CurvedAnimation(parent: widget.animationController, curve: Curves.bounceInOut);

  @override
  void initState() {

    widget.animationController.addListener(() {
      setState(() {

      });
    });

    widget.scrollController.addListener(() {
      setState(() {
        scrollPosition = widget.scrollController.position.pixels;
      });
    });

    super.initState();
  }

  bool get isTriggered => scrollPosition > 80;

  double getValue(double initial, double target) {
    if (isTriggered) {
      return target;
    }
    double fraction = scrollPosition / 80;
    return initial + (target - initial) * fraction;
  }

  @override
  Widget build(BuildContext context) {
    duration = 250.ms;
    return Container(
      width: double.infinity,
      color: context.backgroundColor,
      child: SafeArea(
        child: Stack(
          children: [
            Tap(
              onTap: () {
                Nav.pop(context);
              },
              child: Arrow(
                direction: AxisDirection.left,
              ),
            ).p20(),
            Positioned(
              left: animation.value * 200,
                          child: TweenAnimationBuilder<Color?>(
            duration: 1000.ms,
            tween: ColorTween(
              begin: Colors.green,
              end: isTriggered ? Colors.orange : Colors.green,
            ),
            builder: (context, value, child) => ColorFiltered(
              colorFilter: ColorFilter.mode(
                  value ?? Colors.green, BlendMode.modulate),
              child: child,
            ),
            child: Image.asset(
              "$basePath/icon/map_point.png",
              height: 60,
            ),
                          ),
                        ),
            AnimatedContainer(
              duration: duration,
              padding: EdgeInsets.only(
                  left: getValue(20, 50), top: getValue(50, 15)),
              child: AnimatedDefaultTextStyle(
                child: widget.title.text.make(),
                duration: duration,
                style: TextStyle(
                    fontSize: getValue(30, 18), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
