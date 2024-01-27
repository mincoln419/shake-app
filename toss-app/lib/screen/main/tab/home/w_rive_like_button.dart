import 'package:fast_app_base/common/common.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import '../../../../common/constants.dart';

class RiveLikeButtonWidget extends StatefulWidget {

  final bool isLiked;
  const RiveLikeButtonWidget(this.isLiked, {super.key, required this.onTapLike});
  final void Function(bool isLiked) onTapLike;

  @override
  State<RiveLikeButtonWidget> createState() => _RiveLikeButtonWidgetState();
}

class _RiveLikeButtonWidgetState extends State<RiveLikeButtonWidget> {

  late StateMachineController controller;
  late SMIBool smiPressed;
  late SMIBool smiHover;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RiveLikeButtonWidget oldWidget) {
    if(widget.isLiked != oldWidget.isLiked){
      smiPressed.value = widget.isLiked;
      smiHover.value = widget.isLiked;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: (){
        widget.onTapLike(!widget.isLiked);
      },
      child: RiveAnimation.asset(
        "$baseRivePath/light_like2.riv",
        stateMachines: ["State Machine 1"],
        onInit: (Artboard art){
          controller = StateMachineController.fromArtboard(art, "State Machine 1")!;
          controller.isActive = true;
          art.addController(controller);
          smiPressed = controller.findInput<bool>("Pressed") as SMIBool;
          smiHover = controller.findInput<bool>("Hover") as SMIBool;
        },
      ),
    );
  }
}
