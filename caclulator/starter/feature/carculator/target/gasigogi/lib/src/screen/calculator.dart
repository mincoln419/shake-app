
import 'package:calculator_modularization_domain/domain.dart';
import 'package:calculator_modularization_presentation/presentation.dart';
import 'package:feature_calculator/gasigogi.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CalculatorViewModel>().load();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Calculator'),
      ),
      body: ValueListenableBuilder<CalculatorEntity>(
          valueListenable: context.read<CalculatorViewModel>(),
          builder: (context, calculator, child) {
            return Column(
              children: [
                CalculatorBoard(
                  number: calculator.result,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CalculatorButton.complex(
                        text: 'AC',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.complex(
                        text: '+/-',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.complex(
                        text: '<',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.operator(
                        text: '/',
                        operator: calculator.operator,
                        onTap: (buttonText) => _perform(buttonText, save: true),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '7',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '8',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '9',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.operator(
                        text: 'x',
                        operator: calculator.operator,
                        onTap: (buttonText) => _perform(buttonText, save: true),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '4',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '5',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '6',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.operator(
                        text: '+',
                        operator: calculator.operator,
                        onTap: (buttonText) => _perform(buttonText, save: true),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '1',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '2',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '3',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.operator(
                        text: '-',
                        operator: calculator.operator,
                        onTap: (buttonText) => _perform(buttonText, save: true),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: CalculatorButton.simple(
                        text: '0',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.simple(
                        text: '.',
                        onTap: (buttonText) => _perform(buttonText),
                      ),
                    ),
                    Expanded(
                      child: CalculatorButton.operator(
                        text: '=',
                        operator: calculator.operator,
                        onTap: (buttonText) => _perform(buttonText, save: true),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
    );
  }

  Future<void> _perform(String buttonText, {
    bool save = false,
  }) async {
    context.read<CalculatorViewModel>().calculate(buttonText);

    if(save){
      await context.read<CalculatorViewModel>().save();
    }
  }
}
