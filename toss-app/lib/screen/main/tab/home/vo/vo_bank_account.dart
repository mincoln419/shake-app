import 'package:fast_app_base/screen/main/tab/home/vo/vo_bank.dart';

class BankAccount {
  final Bank bank;
  final String accountName;
  final String accountHolderName;
  int balance;
  final String? accountTypeName;

  BankAccount(
    this.bank,
    this.accountName,
    this.accountHolderName,
    this.balance, {
    this.accountTypeName,
  });
}
