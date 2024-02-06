import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pcfitment/screen/Dashboard.dart';
import 'package:pcfitment/screen/login.dart';
import 'package:pcfitment/utils/preference_utils.dart';
import 'package:pcfitment/widgets/navigation.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        if (PreferenceUtils.getIsLogin() == 'true') {
          Navigation.pushReplacement(context, const DashboardPage());
        } else {
          Navigation.pushReplacement(context, const LoginPage());
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white, // Change this to your desired color
      statusBarIconBrightness: Brightness.light, // Optional
    ));

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/images/ic_app_logo.gif',
            //height: MediaQuery.of(context).size.height,
            //width: MediaQuery.of(context).size.width,
            height: 100,
            width: 100,
            fit: BoxFit.contain,
          ),
        ),
        //child: FlutterLogo(size: MediaQuery.of(context).size.height),
      ),
    );
  }
}
