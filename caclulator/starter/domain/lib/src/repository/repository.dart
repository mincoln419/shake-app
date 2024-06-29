import 'package:calculator_modularization_domain/domain.dart';

abstract class ICalculatorRepository {

  Future<CalculatorEntity> fetch();

  Future<void> save(CalculatorEntity entity);
}