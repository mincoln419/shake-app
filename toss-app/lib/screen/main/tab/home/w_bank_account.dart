import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/widget/w_rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';

import 'vo/vo_bank_account.dart';

class BankAccountWidget extends StatelessWidget {
  final BankAccount bankAccount;

  const BankAccountWidget(this.bankAccount, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              bankAccount.bank.logoImagePath,
              width: 40,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (bankAccount.accountTypeName ?? "${bankAccount.bank.name} 통장")
                    .text
                    .white
                    .size(12)
                    .make(),
                ("${bankAccount.balance} 원".text.white.bold.size(18).make())
              ],
            ).pSymmetric(h: 20, v: 10),
          ],
        ),
        RoundedContainer(
          backgroundColor: context.appColors.buttonBackground,
          child: "송금".text.white.bold.make(),
          radius: 10,
        ).pSymmetric(h: 5, v: 10)
      ],
    );
  }
}
