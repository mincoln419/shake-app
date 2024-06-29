abstract class ICalculatorLocalDataSource {
  String get key;

  Future<void> setString(String value);

  Future<String?> getString();
}

