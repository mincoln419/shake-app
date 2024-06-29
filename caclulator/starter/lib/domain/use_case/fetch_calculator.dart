
import 'package:calculator_modularization_presentation_starter/domain/domain.dart';

class FetchCalculatorUseCase extends IUseCase<void, SaveCalculatorParams>{
  final ICalculatorRepository _iCalculatorRepository;

  FetchCalculatorUseCase(this._iCalculatorRepository);

  @override
  Future<CalculatorEntity> execute([SaveCalculatorParams? params]) async{
    return _iCalculatorRepository.fetch();
  }
}

class SaveCalculatorParams {
  final CalculatorEntity entity;

  SaveCalculatorParams({required this.entity});
}