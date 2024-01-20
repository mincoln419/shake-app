import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/widget/w_round_button.dart';
import 'package:fast_app_base/screen/notification/vo/v_toss_notification.dart';
import 'package:fast_app_base/screen/notification/w_notification_item.dart';
import 'package:flutter/material.dart';
import 'package:nav/dialog/dialog.dart';

class NumberDialog extends DialogWidget<int> {

  NumberDialog({super.key, super.animation = NavAni.Fade, super.barrierDismissible = false});

  @override
  State<NumberDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends DialogState<NumberDialog> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          '숫자를 입력해주세요 : '.text.make(),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
          ),
          RoundButton(text: '완료', onTap: (){
            final fieldText = controller.text;
            widget.hide(int.parse(fieldText));
          })
        ],
      ),
    );
  }
}
