import 'package:calculator_modularization_domain/src/util/formatter.dart';

class CalculatorEntity {
  String _result;

  String get result => _result;

  CalculatorEntity({
    String? result,
  }) : _result = result ?? '0';

  String _num1 = '0';
  String _num2 = '0';

  String _operator = '';

  String get operator => _operator;

  void calculate(String buttonText) {
    switch (buttonText) {
      case 'AC':
        _performClear();
      case '+/-':
        _performConvert();
      case '<':
        _performBackspace();
      case '+':
      case '-':
      case 'x':
      case '/':
        _performOperator(buttonText);
      case '=':
        _performCalculator();
      case '.':
        _performDecimalPoint();
      default:
        _performInputNumber(buttonText);
    }
  }

  void _performClear() {
    _result = '0';
    _num1 = '0';
    _num2 = '0';
    _operator = '';
  }

  void _performConvert() {
    if (_result == '0') return;
    if (_result.startsWith('-')) {
      _result = _result.replaceFirst('-', '');
    } else {
      _result = '-$_result';
    }
  }

  void _performBackspace() {
    if (_result.length > 2) {
      _result = _result.substring(0, _result.length - 1);
      return;
    }

    if (_result.startsWith('-')) {
      _result = '0';
      return;
    }

    if (_result.length > 1) {
      _result = _result.substring(0, _result.length - 1);
    } else {
      _result = '0';
    }
  }

  void _performOperator(String operator) {
    if (_operator.isEmpty) {
      _num1 = _result;
      _result = '0';
    }

    _operator = operator;
  }

  void _performCalculator() {
    final double number;
    switch (_operator) {
      case '+':
        number = double.parse(_num1) + double.parse(_num2);
      case '-':
        number = double.parse(_num1) - double.parse(_num2);
      case 'x':
        number = double.parse(_num1) * double.parse(_num2);
      case '/':
        number = double.parse(_num1) / double.parse(_num2);
      default:
        number = double.parse(_result);
    }

    final String result = IFormatter.normalize(number);
    _result = result;
    _num1 = result;
    _num2 = '0';
    _operator = '';
  }

  void _performDecimalPoint() {
    if (_result.contains('.')) return;
    _result = '$_result.';
  }

  void _performInputNumber(String number) {
    final String result = _result == '0' ? number : _result + number;

    if (_operator.isNotEmpty) {
      _num2 = result;
    }

    _result = result;
  }
}