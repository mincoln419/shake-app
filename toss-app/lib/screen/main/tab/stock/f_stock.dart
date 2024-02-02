import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/widget/w_image_button.dart';
import 'package:fast_app_base/screen/main/tab/stock/search/s_search_stock_list.dart';
import 'package:fast_app_base/screen/main/tab/stock/setting/s_setting.dart';

import 'package:fast_app_base/screen/main/tab/stock/tab/f_my_stock.dart';
import 'package:fast_app_base/screen/main/tab/stock/tab/f_todays_discovery.dart';
import 'package:flutter/material.dart';

class StockFragment extends StatefulWidget {
  const StockFragment({super.key});

  @override
  State<StockFragment> createState() => _BenefitState();
}

class _BenefitState extends State<StockFragment> with SingleTickerProviderStateMixin{

  late final TabController tabController = TabController(length: 2, vsync: this);

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: context.appColors.roundedLayoutBackground,
          pinned: true,
          actions: [
            ImageButton(
                imagePath: "$basePath/icon/stock_search.png",
                onTap: () {
                  Nav.push(const SearchStockScreen());
                }),
            ImageButton(
                imagePath: "$basePath/icon/stock_calendar.png",
                onTap: () {
                  context.showSnackbar("달력");
                }),
            ImageButton(
                imagePath: "$basePath/icon/stock_settings.png",
                onTap: () {
                  Nav.push(SettingScreen());
                }),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              title,
              tabBar,
              currentIndex == 0? MyStockFragment() : TodaysDiscoveryFragment(),
              myAccount,
              height20,
              myStocks,
            ],
          ),
        )
      ],
    );
  }

  Widget get title => Container(
    color: context.appColors.roundedLayoutBackground,
    child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            '토스증권'.text.size(24).bold.make(),
            width20,
            'S&P 500'
                .text
                .size(13)
                .bold
                .color(context.appColors.lessImportantText)
                .make(),
            width10,
            3919.29
                .toComma()
                .toString()
                .text
                .size(13)
                .color(context.appColors.plus)
                .make(),
          ],
        ).pOnly(left: 20),
  );

  Widget get tabBar => Container(
    color: context.appColors.roundedLayoutBackground,
    child: Column(
          children: [
            TabBar(
              onTap: (index)=> setState(() => currentIndex = index),
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              indicatorColor: Colors.white,
              labelPadding: const EdgeInsets.symmetric(vertical: 20),
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
              controller: tabController,
              tabs: [
                '내 주식'.text.make(),
                '오늘의 발견'.text.make(),
              ],
            ),
            const Line(),
          ],
        ),
  );

  Widget get myAccount => Placeholder();

  Widget get myStocks => Placeholder();
}
