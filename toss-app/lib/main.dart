import 'package:easy_localization/easy_localization.dart';
import 'package:fast_app_base/common/data/preference/item/app_shared_preference.dart';
import 'package:fast_app_base/data/local/local_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app.dart';
import 'common/data/preference/app_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  final bindings = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: bindings);
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await AppPreferences.init();
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  AppSharedPreference.setCount(10);

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ko')],
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('ko'),
      path: 'assets/translations',
      useOnlyLangCode: true,
      child: const App()));
}
