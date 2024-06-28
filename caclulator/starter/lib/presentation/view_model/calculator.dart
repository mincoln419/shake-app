
import 'package:calculator_basic_starter/data/repository/calculator.dart';
import 'package:calculator_basic_starter/data/soruce/local/local.dart';
import 'package:calculator_basic_starter/data/soruce/soruce.dart';
import 'package:calculator_basic_starter/ui/screen/calculator.dart';
import 'package:calculator_basic_starter/util/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalculatorViewModel extends ValueNotifier<CalculatorEntity> {

  final FetchCalculatorUseCase _fetchCalculatorUseCase;
  final SaveCalculatorUseCase _saveCalculatorUseCase;

  CalculatorViewModel(
      this._fetchCalculatorUseCase,
      this._saveCalculatorUseCase,
      super.calculator);

  Future<void> load() async {
    value = await _fetchCalculatorUseCase.execute();
  }

  Future<void> save() async {
    await _saveCalculatorUseCase.execute(value);
  }

  void calculate(String buttonText) {
    value.calculate(buttonText);
    notifyListeners();
  }
}

class FetchCalculatorUseCase {
  Future<CalculatorEntity> execute() {

    return CalculatorRepository(CalculatorDataSource(CalculatorLocalDataSource())).fetch();
  }
}

class SaveCalculatorUseCase {
  Future<void> execute(CalculatorEntity entity){
    return CalculatorRepository(CalculatorDataSource(CalculatorLocalDataSource())).save(entity);
  }
}

