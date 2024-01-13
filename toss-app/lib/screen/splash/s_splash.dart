import 'package:after_layout/after_layout.dart';
import 'package:fast_app_base/common/cli_common.dart';
import 'package:fast_app_base/common/common.dart';
import 'package:flutter/cupertino.dart';

import '../main/s_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with AfterLayoutMixin {

  @override
  void initState() {

    // delay((){
    //   Nav.push(const MainScreen());
    // }, 1500.ms);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/image/splash/splash.png",
        width: 192,
        height: 192,
      ),
    );
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    delay((){
      Nav.clearAllAndPush(const MainScreen());
    }, 1500.ms);

  }
}
