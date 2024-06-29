
import 'package:calculator_modularization_data/src/model/calculator.dart';
import 'package:calculator_modularization_data/src/source/source.dart';
import 'package:calculator_modularization_domain/domain.dart';

class CalculatorRepository extends ICalculatorRepository{
  final CalculatorDataSource _calculatorDataSource;

  CalculatorRepository(this._calculatorDataSource);

  @override
  Future<CalculatorEntity> fetch() async {
    final CalculatorModel model = await _calculatorDataSource.fetch();
    return model.toEntity();
  }

  @override
  Future<void> save(CalculatorEntity entity) {
    return _calculatorDataSource.save(entity.toModel());
  }
}

extension on CalculatorModel {
  CalculatorEntity toEntity() {
    return CalculatorEntity(
      result: result,
    );
  }
}

extension on CalculatorEntity {
  CalculatorModel toModel() {
    return CalculatorModel(
      result: result,
    );
  }
}

