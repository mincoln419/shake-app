import 'package:fast_app_base/common/common.dart';
import 'package:flutter/material.dart';

class RoundedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadiusGeometry? radius;
  final double radiusValue;

  const RoundedContainer({
    super.key,
    required this.child,
    this.radiusValue = 10.0,
    this.padding,
    this.margin,
    this.color,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: child,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius ?? BorderRadius.circular(radiusValue),
      ),
    );
  }
}
