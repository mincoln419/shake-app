import 'package:fast_app_base/screen/main/tab/search/search_stock_data.dart';
import 'package:fast_app_base/screen/main/tab/search/w_popular_search_stock_list.dart';
import 'package:fast_app_base/screen/main/tab/search/w_saerch_history_stock.dart';
import 'package:fast_app_base/screen/main/tab/search/w_search_auto_complete_list.dart';
import 'package:fast_app_base/screen/main/tab/search/w_stock_search_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SearchStockScreen extends StatefulWidget {
  const SearchStockScreen({super.key});

  @override
  State<SearchStockScreen> createState() => _SearchStockScreenState();
}

class _SearchStockScreenState extends State<SearchStockScreen> with SearchStockDataProvider {

  final controller = TextEditingController();

  @override
  void initState() {

    Get.put(SearchStockData());
    controller.addListener(() {
      late String keyword = controller.text;
      searchData.search(keyword);
    });

    super.initState();
  }

  @override
  void dispose() {
    Get.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StockSearchAppBar(controller: controller),
      body:
      Obx(() =>  searchData.autoCompleteList.isEmpty?
        ListView(children: const [
          SearchHistoryStockList(),
          PopularSearchStockList()
        ],):
            SearchAutoCompleteList(controller),
      ),

    );
  }
}
