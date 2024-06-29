
import 'package:calculator_modularization_presentation_starter/domain/domain.dart';

class SaveCalculatorUseCase extends IUseCase {
  final ICalculatorRepository _iCalculatorRepository;

  SaveCalculatorUseCase(this._iCalculatorRepository);

  @override
  Future execute([params]) async {
    if (params == null) return;
    _iCalculatorRepository.save(params.entity);
  }
}
