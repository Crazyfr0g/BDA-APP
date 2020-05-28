import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/home_page.dart';
import 'package:comvida/navs/DisasterFeed.dart';
import 'package:comvida/navs/OrgAndNews.dart';
import 'package:comvida/navs/OrgProfile.dart';
import 'package:comvida/navs/Profile.dart';
import 'package:comvida/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:comvida/login/create_account.dart';
import 'package:comvida/login/provider.dart';
import 'package:provider/provider.dart';
import 'account_create.dart';
import 'colors.dart';
import 'login/loadingScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override

  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Providers(
      auth: AuthService(),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData  (
            scaffoldBackgroundColor: Colors.transparent
          ),
       home: ChangeNotifierProvider<BottomNavigationBarProvider>(
        child: HomeController(),
        create: (BuildContext context) => BottomNavigationBarProvider(),
      ),
        routes: <String, WidgetBuilder>{
          '/signUp': (BuildContext context) => CreateAccountPage(authFormType: AuthFormType.signUp),
          '/signIn': (BuildContext context) => CreateAccountPage(authFormType: AuthFormType.signIn),
          '/home': (BuildContext context) => MyApp(),
          '/Profile': (context) => normalUser(),
        },
      ),
    );
  }
}

class HomeController extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    final AuthService auth = Providers.of(context).auth;
    return StreamBuilder(
        stream: auth.onAuthStateChanged,
        builder: (context, AsyncSnapshot <String> snapshot){
          if(snapshot.connectionState == ConnectionState.active){
            final bool signedIn = snapshot.hasData;
            return signedIn ? MyHomePage() :loadingScreen();
          }
          return CircularProgressIndicator();
         },
     );
  }
}

