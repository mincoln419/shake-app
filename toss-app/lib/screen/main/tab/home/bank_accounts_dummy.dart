import 'package:fast_app_base/screen/main/tab/home/banks_dummy.dart';
import 'package:fast_app_base/screen/main/tab/home/vo/vo_bank_account.dart';

final bankAccountShinhan1 = BankAccount(bankShinhan, "111111111", "22222222", 1000000, accountTypeName: "신한주거래 우대통장");
final bankAccountShinhan2 = BankAccount(bankShinhan, "111111211", "32222222", 2000000, accountTypeName: "저축예금");
final bankAccountShinhan3 = BankAccount(bankShinhan, "111111311", "12222222", 3000000, accountTypeName: "저축예금");
final bankAccountShinhan4 = BankAccount(bankShinhan, "111111411", "52222222", 4000000, accountTypeName: "일반적금");

final bankAccountKakao1 = BankAccount(bankKakao, "111111411", "52222222", 4000000);
final bankAccountKakao2 = BankAccount(bankKakao, "111111411", "52222222", 4000000);
final bankAccountToss1 = BankAccount(bankToss, "111111411", "52222222", 4000000);

main(){
  for (BankAccount account in bankAccounts){
    print("${account.accountName}, ${account.bank.name}");
  }
}

final bankAccounts = [
  bankAccountShinhan1,
  bankAccountShinhan2,
  bankAccountShinhan3,
  bankAccountShinhan4,
  bankAccountKakao1,
  bankAccountKakao2,
  bankAccountToss1,
];