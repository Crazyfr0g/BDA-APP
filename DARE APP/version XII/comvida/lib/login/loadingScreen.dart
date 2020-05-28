import 'package:comvida/login/loginChoice.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class loadingScreen extends StatefulWidget {
  @override
  _loadingScreenState createState() => _loadingScreenState();
}

class _loadingScreenState extends State<loadingScreen> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        seconds: 5,
        navigateAfterSeconds: loginChoice(),
        image: new Image.asset('assets/BDA2.png'),
        backgroundColor: Color(0xFF121A21),
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.white);
  }
}
