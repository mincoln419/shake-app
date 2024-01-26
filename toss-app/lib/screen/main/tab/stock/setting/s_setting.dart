import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/dart/extension/datetime_extension.dart';
import 'package:fast_app_base/common/data/preference/app_preferences.dart';
import 'package:fast_app_base/common/data/preference/prefs.dart';
import 'package:fast_app_base/common/widget/w_big_button.dart';
import 'package:fast_app_base/screen/main/tab/stock/setting/d_number.dart';
import 'package:fast_app_base/screen/main/tab/stock/setting/w_switch_menu.dart';
import 'package:fast_app_base/screen/opensource/s_opensource.dart';
import 'package:flutter/material.dart';
import 'package:quiver/testing/src/time/time.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: '설정'.text.make(),
        ),
        body: ListView(
          children: [
            Obx(
              () => SwitchMenu(
                '푸시 설정',
                Prefs.isPushedOnRx.get(),
                onTap: (isOn) {
                  Prefs.isPushedOnRx.set(isOn);
                },
              ),
            ),
            Obx(() => Slider(
                value: Prefs.slidePosition.get(),
                onChanged: (value) => {Prefs.slidePosition.set(value)})),
            Obx(
              () => BigButton(
                  '날짜(${Prefs.birthDay.get() != null ? Prefs.birthDay.get()?.formattedDate : ''})',
                  onTap: () async {
                final datep = await showDatePicker(
                    context: context,
                    initialDate: Prefs.birthDay.get(),
                    firstDate: DateTime.now().subtract(90.days),
                    lastDate: DateTime.now().add(30.days));
                if (datep != null) {
                  Prefs.birthDay.set(datep);
                }
              }),
            ),
            Obx(
                  () => BigButton(
                  '저장된 숫자(${Prefs.number.get()})',
                  onTap: () async {
                    final number = await NumberDialog().show();

                    if(number != null){
                      Prefs.number.set(number!);
                    }
                  }),
            ),
            BigButton('오픈소스화면', onTap: () async {
              Nav.push(OpensourceScreen());
            }),
          ],
        ));
  }
}
