import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/widget/w_round_button.dart';
import 'package:fast_app_base/screen/main/tab/stock/setting/w_text_watching.dart';
import 'package:fast_app_base/screen/notification/vo/v_toss_notification.dart';
import 'package:fast_app_base/screen/notification/w_notification_item.dart';
import 'package:flutter/material.dart';
import 'package:nav/dialog/dialog.dart';

class NumberDialog extends DialogWidget<int> {
  NumberDialog(
      {super.key,
      super.animation = NavAni.Fade,
      super.barrierDismissible = false});

  @override
  State<NumberDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends DialogState<NumberDialog> {
  final textController = TextEditingController();
  final passwordController = TextEditingController();
  final numberFocus = new FocusNode();
  final passwordFocus = new FocusNode();

  bool check = false;
  bool handsUp = false;
  double look = 0.0;

  @override
  void initState() {
    textController.addListener(() {
      setState(() {
        look = textController.text.length.toDouble() * 1.5;
      });
    });

    numberFocus.addListener(() {
      setState(() {
        check = numberFocus.hasFocus;
      });

    });

    passwordFocus.addListener(() {
      setState(() {
        handsUp = passwordFocus.hasFocus;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          '숫자를 입력해주세요 : '.text.make(),
          SizedBox(
            width: 200,
            height: 200,
            child: TextWatchingBearWidget(
              check: check,
              handsUP: handsUp,
              look: look,
            ),
          ),
          TextField(
            focusNode: numberFocus,
            controller: textController,
            keyboardType: TextInputType.number,
          ),
          TextField(
            focusNode: passwordFocus,
            obscureText: true,
            controller: passwordController,
            keyboardType: TextInputType.number,
          ),
          RoundButton(
              text: '완료',
              onTap: () {
                final fieldText = textController.text;
                widget.hide(int.parse(fieldText));
              })
        ],
      ),
    );
  }
}
