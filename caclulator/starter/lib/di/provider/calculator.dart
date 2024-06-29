
import 'package:calculator_modularization_data/data.dart';
import 'package:calculator_modularization_presentation/presentation.dart';
import 'package:calculator_modularization_presentation_starter/domain/domain.dart';
import 'package:calculator_modularization_presentation_starter/domain/use_case/fetch_calculator.dart';
import 'package:calculator_modularization_presentation_starter/domain/use_case/save_calculator.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalculatorProvider extends StatelessWidget {
  final Widget child;

  const CalculatorProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ICalculatorLocalDataSource>(
          create: (context) => CalculatorLocalDataSource(),
        ),
      ],
      child: MultiProvider(
        providers: [
          Provider<CalculatorDataSource>(
            create: (context) => CalculatorDataSource(context.read()),
          ),
        ],
        child: MultiProvider(
          providers: [
            Provider<ICalculatorRepository>(
              create: (context) => CalculatorRepository(context.read()),
            ),
          ],
          child: MultiProvider(
            providers: [
              Provider<FetchCalculatorUseCase>(
                create: (context) => FetchCalculatorUseCase(context.read()),
              ),
              Provider<SaveCalculatorUseCase>(
                create: (context) => SaveCalculatorUseCase(context.read()),
              ),
            ],
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<CalculatorViewModel>(
                  create: (context) => CalculatorViewModel(
                    context.read(),
                    context.read(),
                    CalculatorEntity(),
                  ),
                ),
              ],
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
