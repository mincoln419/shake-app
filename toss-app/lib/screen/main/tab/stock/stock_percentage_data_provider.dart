import 'dart:ui';

import 'package:fast_app_base/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract mixin class StockPercentageDataProvider{

  int get yesterdayClosePrice;
  int get currentPrice;

  double get todayPercentage =>
      ((currentPrice - yesterdayClosePrice) / yesterdayClosePrice * 100)
          .toPrecision(2);

  String get todayPercentageToString => "$symbol$todayPercentage";

  bool get isPlus => currentPrice > yesterdayClosePrice;

  bool get isSame => currentPrice == yesterdayClosePrice;

  String get symbol => isSame
      ? ""
      : isPlus
      ? "+"
      : "-";

  Color getPriceColor(BuildContext context) => isSame
      ? context.appColors.lessImportantText
      : isPlus
      ? context.appColors.plus
      : context.appColors.minus;
}