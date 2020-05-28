import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'create_account.dart';

class loginPage extends StatefulWidget {
  @override
  _loginPageState createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  @override
  bool _visible = true;
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    ScreenUtil.instance = ScreenUtil(width: 1920, height: 1080)..init(context);
    return MaterialApp(
      home: Material(
        child: Container(
          color: Color(0xFFFFFFFF),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: _height * 0.25,
              ),
              Container(
                child: AutoSizeText(
                  'Welcome',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color(0xFF121A21),
                    fontFamily: 'Pacifico',
                    fontSize: ScreenUtil.getInstance().setSp(200),
                  ),
                ),
              ),
              Container(
                child: AutoSizeText(
                  'to',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color(0xFF121A21),
                    fontFamily: 'Pacifico',
                    fontSize: ScreenUtil.getInstance().setSp(150),
                  ),
                ),
              ),
              Container(
                child: AutoSizeText(
                  'ComVida',
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: Color(0xFF121A21),
                    fontFamily: 'Pacifico',
                    fontSize: ScreenUtil.getInstance().setSp(200),
                  ),
                ),
              ),
//              SizedBox(
//                height: _height * 0.10,
//              ),
//              Container(
//               constraints: BoxConstraints(
////                 maxHeight: ScreenUtil.getInstance().setHeight(275),
////                 minHeight: ScreenUtil.getInstance().setHeight(100),
//                 maxWidth: ScreenUtil.getInstance().setWidth(1700),
//               ),
//               child: new Theme(
//                 data: new ThemeData(
//                   primaryColor: Color(0xFF121A21),
//                   ),
////                 child: TextFormField(
////                  decoration: new InputDecoration(
//////                  hintText: "Enter Email:",
////                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
////                    hintStyle: TextStyle(
////                      color: Colors.black,
////                    ),
////                    icon: Icon(FontAwesomeIcons.solidEnvelope,size: 35,color: Color(0xFF121A21),),
////                    labelText: "Enter Email:",
////                    fillColor: Color(0xFF121A21),
////                    border: new OutlineInputBorder(
////                      borderRadius: new BorderRadius.circular(25.0),
////                      borderSide: new BorderSide(
////                      ),
////                    ),
////                  ),
////                  validator: (val) {
////                  if(val.length==0) {
////                    return "Email cannot be empty";
////                      }else{
////                      return null;
////                    }
////                  },
////                  keyboardType: TextInputType.emailAddress,
////                  style: new TextStyle(
//////                  fontSize: 12,
////                    fontSize: ScreenUtil.getInstance().setSp(70),
////                    color: Color(0xFF121A21),
////                    fontFamily: "Poppins",
////                    ),
////                  ),
//               ),
//             ),
//              SizedBox(
//                height: _height * 0.02,
//              ),
//              Container(
//                constraints: BoxConstraints(
////                  maxHeight: ScreenUtil.getInstance().setHeight(275),
////                  minHeight: ScreenUtil.getInstance().setHeight(80),
//                  maxWidth: ScreenUtil.getInstance().setWidth(1700),
//                ),
//                child: new Theme(
//                  data: new ThemeData(
//                    primaryColor: Color(0xFF121A21),
//                  ),
////                  child: TextFormField(
////                    decoration: new InputDecoration(
////                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
////                        icon: Icon(FontAwesomeIcons.key,size: 35,color: Color(0xFF121A21),),
////                        labelText: "Enter Password:",
////                        fillColor: Colors.black,
////                        border: new OutlineInputBorder(
////                          borderRadius: new BorderRadius.circular(25.0),
////                          borderSide: new BorderSide(
////                          ),
////                        ),
////                      //fillColor: Colors.green
////                    ),
////                    validator: (val) {
////                      if(val.length==0) {
////                        return "Email cannot be empty";
////                      }else{
////                        return null;
////                      }
////                    },
////                    keyboardType: TextInputType.emailAddress,
////                    style: new TextStyle(
////                        fontSize: ScreenUtil.getInstance().setSp(70),
////                        fontFamily: "Poppins",
////                        color: Color(0xFF121A21),
////                    ),
////                  ),
//                ),
//              ),
              SizedBox(
              height: _height * 0.03,
              ),
              ButtonTheme(
                minWidth: ScreenUtil.getInstance().setWidth(700),
                height: ScreenUtil.getInstance().setHeight(60),
                child: RaisedButton(
                  color: Color(0xFF121A21),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/signIn');
                  },
                  child: AutoSizeText(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getInstance().setSp(60),
                    ),
                  ),
                ),
              ),
              ButtonTheme(
                minWidth: ScreenUtil.getInstance().setWidth(700),
                height: ScreenUtil.getInstance().setHeight(60),
                child: FlatButton(
                  color: Color(0xff045135),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0),
                  ),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/signUp');
                  },
                  child: AutoSizeText(
                    'Create Account',
                    style: TextStyle(
                        color: Color(0xFFFFFFFF),
                      fontSize: ScreenUtil.getInstance().setSp(60),
                    ),
                  ),
                ),
              ),
              Divider(
                height: ScreenUtil.getInstance().setHeight(40),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 20,
                    height: ScreenUtil.getInstance().setHeight(50),
                    child: RaisedButton(
                      color: Color(0xFF121A21),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(50.0),
                      ),
                      onPressed: (){
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Icon(
                          FontAwesomeIcons.google,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  ButtonTheme(
                    minWidth: 20,
                    height: ScreenUtil.getInstance().setHeight(50),
                    child: RaisedButton(
                      color: Color(0xFF121A21),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: (){
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      child: Icon(
                        FontAwesomeIcons.facebookF,
                        size: 15,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Container(
//child: AutoSizeText(
//'ComVida',
//style: TextStyle(
//decoration: TextDecoration.none,
//color: Color(0xFF121A21),
//fontFamily: 'Pacifico',
//fontSize: ScreenUtil.getInstance().setSp(200),
//),
//),
//),