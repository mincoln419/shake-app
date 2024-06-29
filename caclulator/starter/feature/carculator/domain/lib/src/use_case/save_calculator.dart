
import 'package:calculator_modularization_domain/domain.dart';
import 'package:calculator_modularization_domain/src/util/use_case.dart';

class SaveCalculatorUseCase extends IUseCase {
  final ICalculatorRepository _iCalculatorRepository;

  SaveCalculatorUseCase(this._iCalculatorRepository);

  @override
  Future execute([params]) async {
    if (params == null) return;
    _iCalculatorRepository.save(params.entity);
  }
}
