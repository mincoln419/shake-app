import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/dart/extension/datetime_extension.dart';
import 'package:fast_app_base/screen/main/tab/search/popular_stock_dummy.dart';
import 'package:fast_app_base/screen/main/tab/search/w_popular_stock_item.dart';
import 'package:flutter/material.dart';

class PopularSearchStockList extends StatelessWidget {
  const PopularSearchStockList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            '인기 검색'.text.bold.make(),
            emptyExpanded,
            '오늘 ${DateTime.now().formattedDateTime}'.text.bold.make()
          ],
        ),
        height20,
        ...popularStockList.mapIndexed((element, index) => PopularStockItem(stock: element, number : index + 1)).toList(),
      ],

    ).pSymmetric(h: 20);
  }
}
