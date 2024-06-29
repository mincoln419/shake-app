import 'package:fast_app_base/common/common.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FireWidget extends StatefulWidget {
    const FireWidget({super.key});

  @override
  State<FireWidget> createState() => _FireWidgetState();
}

class _FireWidgetState extends State<FireWidget> {

  late StateMachineController controller;
  late SMIBool smiOn;
  late SMIBool smiHover;

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      "$baseRivPath/fire_button.riv",
      stateMachines: const ['State Machine 1'],
      onInit: (Artboard art){
        controller = StateMachineController.fromArtboard(art, 'State Machine 1')!;
        controller.isActive = true;
        art.addController(controller);
        smiOn = controller.findInput<bool>('ON') as SMIBool;
        smiHover = controller.findInput<bool>('Hover') as SMIBool;
        smiOn.value = true;
      },
    );
  }
}
