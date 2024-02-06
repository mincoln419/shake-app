import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreference {

  AppSharedPreference._();
  static AppSharedPreference instance = AppSharedPreference._();

  static const keyCount = 'count';
  static const keyLaunchCount = 'launch_count';

  late SharedPreferences _preferences;

  static init() async {
    instance._preferences = await SharedPreferences.getInstance();
  }

  static setCount(int count){
    instance._preferences.setInt(keyCount, count);
  }

  //null 인경우 디폴트 0 반환
  static int getCount(){
    return instance._preferences.getInt(keyCount) ?? 0;
  }
  static setLaunchCount(int count){
    instance._preferences.setInt(keyLaunchCount, count);
  }

  //null 인경우 디폴트 0 반환
  static int getLaunchCount(){
    return instance._preferences.getInt(keyLaunchCount) ?? 0;
  }



}