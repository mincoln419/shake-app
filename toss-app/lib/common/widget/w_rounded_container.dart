import 'package:fast_app_base/common/common.dart';
import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  const RoundedContainer(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      this.radius = 20,
      this.backgroundColor});

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    var title;
    return Container(
        padding: padding,
        decoration: BoxDecoration(
            color: backgroundColor ?? context.appColors.roundedLayoutBackground,
            borderRadius: BorderRadius.circular(radius)),
        child: child);
  }
}
