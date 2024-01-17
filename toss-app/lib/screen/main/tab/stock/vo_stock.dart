import 'dart:ui';

import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/main/tab/stock/vo_popular_stock.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

class Stock extends PopularStock {
  final String stockImagePath;

  Stock(
      {required super.yesterdayClosePrice,
      required super.currentPrice,
      required super.stockName,
      required this.stockImagePath});


}
