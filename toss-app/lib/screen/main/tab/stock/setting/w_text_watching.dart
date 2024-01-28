import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/screen/main/tab/home/w_rive_like_button.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../home/w_rive_like_button.dart';

class TextWatchingBearWidget extends StatefulWidget {
  final bool check;
  final bool handsUP;
  final double look;

  const TextWatchingBearWidget(
      {super.key,
      required this.check,
      required this.handsUP,
      required this.look});

  @override
  State<TextWatchingBearWidget> createState() => _TextWatchingBearWidget();
}

class _TextWatchingBearWidget extends State<TextWatchingBearWidget> {
  late StateMachineController controller;
  late SMIBool smiCheck;
  late SMIBool smiHandsUp;
  late SMINumber smiLook;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextWatchingBearWidget oldWidget) {
    if (widget.check != oldWidget.check) {
      smiCheck.value = widget.check;
    }

    if (widget.handsUP != oldWidget.handsUP) {
      smiHandsUp.value = widget.handsUP;
    }

    if (widget.look != oldWidget.look) {
      smiLook.value = widget.look;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      "$baseRivePath/login_screen_character.riv",
      stateMachines: ["State Machine 1"],
      onInit: (Artboard art) {
        controller =
            StateMachineController.fromArtboard(art, "State Machine 1")!;
        controller.isActive = true;
        art.addController(controller);
        smiCheck = controller.findInput<bool>("Check") as SMIBool;
        smiHandsUp = controller.findInput<bool>("hands_up") as SMIBool;
        smiLook = controller.findInput<double>("Look") as SMINumber;
      },
    );
  }
}
