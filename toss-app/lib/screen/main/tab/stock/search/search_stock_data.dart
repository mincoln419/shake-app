import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/util/local_json.dart';
import 'package:fast_app_base/screen/main/tab/stock/vo_simple_stock.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

abstract mixin class SearchStockDataProvider {
  late final searchData = Get.find<SearchStockData>();
}

class SearchStockData extends GetxController {
  List<SimpleStock> stocks = [];
  RxList<SimpleStock> autoCompleteList = <SimpleStock>[].obs;
  RxList<String> searchHistoryList = <String>[].obs;

  @override
  void onInit() {
    searchHistoryList.addAll(['삼성전자', 'LG전자', '현대차', '넷플릭스', '애플']);
    loadLocalStockJson();

    super.onInit();
  }

  Future<void> loadLocalStockJson() async {
    final jsonList =
        await LocalJson.getObjectList<SimpleStock>("json/stock_list.json");
    stocks.addAll(jsonList);
  }

  void search(String keyword) {
    if (keyword.isEmpty) {
      autoCompleteList.clear();
      return;
    }

    autoCompleteList.value =
        stocks.where((element) => element.stockName.contains(keyword)).toList();
  }

  void addHistory(SimpleStock stock) {
    searchHistoryList.add(stock.stockName);
  }

  void removeHistory(String stockName) {
    searchHistoryList.remove(stockName);
  }
}
