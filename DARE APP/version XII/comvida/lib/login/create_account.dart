import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthFormType { signIn, signUp }

class CreateAccountPage extends StatefulWidget {
  final AuthFormType authFormType;
  CreateAccountPage({@required this.authFormType});

  @override
  _CreateAccountPageState createState() =>
      _CreateAccountPageState(authFormType: this.authFormType);
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  @override

  _CreateAccountPageState({this.authFormType});

  AuthFormType authFormType;

  final formkey = GlobalKey<FormState>();
  String _email, _password, _name, _value;
  bool _obscureText = true;
  bool _autoValidate = false;

  Flushbar flush;

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  void createUserAccountInDatabase() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;
    final key = formkey.currentState;
    key.save();

    String _choiceOfName;

    if (_value == "Organization") {
      _choiceOfName = "Name of Organization";
    } else if (_value == "Normal User") {
      _choiceOfName = "Name of User";
    }

    DocumentReference ref = await db.collection('USERS').document(user.uid);

    if(_value == "Organization"){
      return ref.setData({
        'Email': '${_email}',
        'Password': '${_password}',
        _choiceOfName: '${_name}',
        'Type of User': '${_value}',
        'Total_RequestCount': 0,
        'Total_GoalReachedCount': 0,
        'Profile_Information': "",
        'Profile_Picture': "",
        'User_ID': user.uid,
        'Contact_Number': "",
        'Date_Joined': time,
        'Address': "",
        'Org_status': "Not verified",
      });
    }
    else if(_value == "Normal User"){
      return ref.setData({
        'Email': '${_email}',
        'Password': '${_password}',
        _choiceOfName: '${_name}',
        'Type of User': '${_value}',
        'Interested_Helpcount': 0,
        'Confirmed_Helpcount': 0,
        'Profile_Information': "",
        'Profile_Picture': "",
        'User_ID': user.uid,
        'Contact_Number': "",
        'Date_Joined': time,
        'Birth_Date': "",
        'Address': "",
      });
    }
  }

   submit() async {
    final key = formkey.currentState;
    key.save();
    try {
      final auth = Providers.of(context).auth;
      if (authFormType == AuthFormType.signIn) {
        try{
          String uid = await auth.signInWithEmailAndPassword(_email, _password);
          print(uid);
          CircularProgressIndicator();
          Navigator.pushReplacementNamed(context, '/home');
        }
        catch(signUperror){
          print(signUperror);

          if (signUperror is PlatformException){
            if(signUperror.code == 'ERROR_USER_NOT_FOUND'){
              return Flushbar(
                margin: EdgeInsets.all(8),
                borderRadius: 8,
                title: "Warning!",
                message: "User doesn't exist.",
                duration:  Duration(seconds: 3),
              )..show(context);
            }
          }
          if (signUperror is PlatformException){
            if(signUperror.code == 'ERROR_WRONG_PASSWORD'){
              return Flushbar(
                margin: EdgeInsets.all(8),
                borderRadius: 8,
                title: "Warning!",
                message: "You have inputted a wrong password.",
                duration:  Duration(seconds: 3),
              )..show(context);
            }
          }
        }
      }
      else
        {
          try{
            String uid =
            await auth.createUserWithEmailAndPassword(_email, _password, _name);
            print("Signed Up with new ID ${uid}");
            Navigator.pushReplacementNamed(context, '/home');
            createUserAccountInDatabase();
          }
          catch(signUperror){
            print(signUperror);
            if(signUperror is PlatformException){
              if(signUperror.code == 'ERROR_EMAIL_ALREADY_IN_USE'){
                return Flushbar(
                  margin: EdgeInsets.all(8),
                  borderRadius: 8,
                  title: "Warning!",
                  message: "Email already in use.",
                  duration:  Duration(seconds: 3),
                )..show(context);
          }
        }
      }
      }
    } catch (e) {
      print(e);
    }
  }

  void switchFormState(String state) {
    formkey.currentState.reset();
    if (state == "signUp") {
      setState(() {
        authFormType = AuthFormType.signUp;
      });
    } else {
      setState(() {
        authFormType = AuthFormType.signIn;
      });
    }
  }


  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final _bottom = MediaQuery.of(context).viewInsets.bottom;
    ScreenUtil.instance = ScreenUtil(width: 1920, height: 1080)..init(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: Material(
          child: SingleChildScrollView(
            reverse: true,
            child: Padding(
              padding: EdgeInsets.only(bottom: _bottom),
              child: Center(
                child: Container(
                  color: Color(0xFFFFFFFF),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 80,
                            backgroundImage: AssetImage('assets/BDA2.png'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: _height * 0.01,
                      ),
                      Form(
                        key: formkey,
                        autovalidate: _autoValidate,
                        child: Column(
                          children: buildInputs() + buildButtons(),
                        ),
                      ),
                      SizedBox(
                        height: _height * 0.02,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    height: _height * 0.05,
                    width: _width * 0.50,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Forgot Password? ',
                              style: TextStyle(
                                  color: Color(0xFF2b527f),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            TextSpan(
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF2b527f),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              text: 'Click here.',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) => ForgotPassword()
                                      )
                                  );
                                },
                            ),
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  List<Widget> buildInputs() {
    List<Widget> textFields = [];

    String _switchAccountTypeText;

    if (_value == "Organization") {
      _switchAccountTypeText = "Enter organization name:";

    } else {
      _switchAccountTypeText = "Enter name:";
    }

    if (authFormType == AuthFormType.signUp) {
      textFields.add(
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .90,
            ),
            child: new Theme(
                data: new ThemeData(
                  primaryColor: Color(0xFF2b527f),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .90,
                      ),
                      child: new Theme(
                        data: new ThemeData(
                          primaryColor: Color(0xFF2b527f),
                        ),
                        child: TextFormField(
                          onSaved: (value) => _name = value,
                          decoration: inputDecorationFields(
                              iconData: FontAwesomeIcons.signature,
                              label: _switchAccountTypeText),
                          validator: (String value) {
                            if (value.length < 1)
                              return '${_switchAccountTypeText}, field is empty';
                            else
                              return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          style: textStyleFiles(),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ),
      );
    }
    textFields.add(
      SizedBox(
        height: 10,
      ),
    );
    textFields.add(
      Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .90,
        ),
        child: new Theme(
          data: new ThemeData(
            primaryColor: Color(0xFF2b527f),
          ),
          child: TextFormField(
            onSaved: (value) => _email = value,
            decoration: inputDecorationFields(
                iconData: FontAwesomeIcons.solidEnvelope,
                label: "Enter Email:"),
            validator: (String value) {
              Pattern pattern =
                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
              RegExp regex = new RegExp(pattern);
              if (!regex.hasMatch(value))
                return 'Enter Valid Email';
              else
                return null;
            },
            keyboardType: TextInputType.emailAddress,
            style: textStyleFiles(),
          ),
        ),
      ),
    );
    textFields.add(
      SizedBox(
        height: 10,
      ),
    );
    textFields.add(
      Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .90,
        ),
        child: new Theme(
          data: new ThemeData(
            primaryColor: Color(0xFF2b527f),
          ),
          child: TextFormField(
            obscureText: _obscureText,
            onSaved: (value) => _password = value,
            decoration: inputDecorationFields(
                iconData: FontAwesomeIcons.key, label: "Enter Password:",
              suffxIcon: GestureDetector(
                onTap: (){
                  _toggle();
                },
                  child: Icon(FontAwesomeIcons.eye)
              )
            ),
            validator: (String value) {
              if (value.length < 1)
                return 'Password, field is empty';
              else if (value.length < 6)
                return 'Password too short.';
              else
                return null;
            },
            textInputAction: TextInputAction.done,
            style: textStyleFiles(),
          ),
        ),
      ),
    );
    textFields.add(
      SizedBox(
        height: 15,
      ),
    );
    return textFields;
  }

  List<Widget> buildButtons() {
    String _switchButtonText, _newFormState, _submitButtonText;

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    if (authFormType == AuthFormType.signIn) {
      _switchButtonText = "Create new account";
      _newFormState = "signUp";
      _submitButtonText = "Sign In";
    }
    else {
      _switchButtonText = "Have an account? Sign in.";
      _newFormState = "signIn";
      _submitButtonText = "Sign Up";
    }

    if (authFormType == AuthFormType.signIn) {
      return [
        Container(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: _height * 0.05,
              width: _width * 0.50,
              child: ProgressButton(
                  defaultWidget: const Text('Sign In',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12
                    ),
                  ),
                  progressWidget: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  width: _width * 0.30,
                  height: 40,
                  borderRadius: 20.0,
                  color: Color(0xFF2b527f),
                  onPressed: () async {
                    try{
                      final key = formkey.currentState;
                      if (key.validate()){
                        submit();
                      }
                      else{
                        setState(() {
                          _autoValidate = true;
                        });
                      }
                    }
                    catch(e){
                      print(e);
                    }
                    await Future.delayed(
                        const Duration(seconds: 10), () => 42);
                  }
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        new SignUpButtons(
          text: _switchButtonText,
          color: Color(0xFF2b527f),
          onPressed: () {
            switchFormState(_newFormState);
          },
        ),
      ];
    }
    else {
      return [
        Container(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: _height * 0.05,
              width: _width * 0.50,
              child: ProgressButton(
                  defaultWidget: const Text('Sign Up',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12
                    ),
                  ),
                  progressWidget: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  width: _width * 0.30,
                  height: 40,
                  borderRadius: 20.0,
                  color: Color(0xFF2b527f),
                  onPressed: () async {
                    final key = formkey.currentState;
                    await Future.delayed(
                        const Duration(milliseconds: 8000), () => 42);
                    return () async {
                      final key = formkey.currentState;
                      if (key.validate()){

                        _value = "Normal User";
                        submit();
                        createUserAccountInDatabase();

                        flush = Flushbar<bool>(
                          duration: Duration(seconds: 3),
                          blockBackgroundInteraction: true,
                          isDismissible: false,
                          routeBlur: 30,
                          routeColor: Colors.white.withOpacity(0.30),
                          margin: EdgeInsets.all(8),
                          borderRadius: 8,
                          title: "Message",
                          message: "Successfully created an account. It will log in automatically after creating.",
                        )
                          ..show(context).then((result) {
                            setState(() {
                            });
                          });
                      }
                      else{
                        setState(() {
                          _autoValidate = true;
                        });
                      }
                    };
                  }
              ),
            ),
          ),
        ),
        new SignUpButtons(
          text: _switchButtonText,
          color: Color(0xFF2b527f),
          onPressed: () {
            switchFormState(_newFormState);
          },
        ),
      ];
    }
  }

  InputDecoration inputDecorationFields(
      {@required String label, @required IconData iconData, suffxIcon}) {
    return new InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      icon: Icon(
        iconData,
        color: Color(0xFF2b527f),
        size: 30,
      ),
        labelText: label,
        fillColor: Color(0xFF2b527f),
        border: outlineInputBorderFields(),
        suffixIcon: suffxIcon,
    );
  }


}

class SignUpButtons extends StatelessWidget {

  SignUpButtons({@required this.text, @required this.color, this.onPressed});

  final String text;
  final Color color;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return ButtonTheme(
      minWidth: MediaQuery.of(context).size.width * 0.45,
      height: ScreenUtil.getInstance().setHeight(60),
      child: OutlineButton(
        color: color,
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        borderSide: BorderSide(
          color: Color(0xFF2b527f),//Color of the border
          style: BorderStyle.solid, //Style of the border
          width: 0.12, //width of the border
        ),
        onPressed: onPressed,
        child: AutoSizeText(
          text,
          style: TextStyle(
            color: Color(0xFF2b527f),
            fontSize: ScreenUtil.getInstance().setSp(60),
          ),
        ),
      ),
    );
  }
}


OutlineInputBorder outlineInputBorderFields() {
  return new OutlineInputBorder(
    borderRadius: new BorderRadius.circular(30.0),
    borderSide: new BorderSide(),
  );
}

TextStyle textStyleFiles() {
  return new TextStyle(
    fontSize: ScreenUtil.getInstance().setSp(60),
    fontFamily: "Poppins",
    color: Color(0xFF2b527f),
  );
}

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override

  final _formkeyResetPassword = GlobalKey<FormState>();

  String resetPassword;

  Future<void> resetPasswordAccount(String email) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.white,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF2b527f),
            title: Text(
              'Forgot Password',
            ),
          ),
          body: Container(
            color: Colors.white,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints){
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          'Reset Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2b527f),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formkeyResetPassword,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: _width * .80,
                                ),
                                child: TextFormField(
                                  maxLines: 1,
                                  keyboardType: TextInputType.text,
                                  onSaved: (value) => resetPassword = value,
                                  validator: (String value) {
                                    if (value.length < 1)
                                      return 'Field is empty.';
                                    else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Enter Email:',
                                    labelStyle: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.30,
                        child: ProgressButton(
                            defaultWidget: const Text('Confirm',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12
                              ),
                            ),
                            progressWidget: SizedBox(
                              height: 20.0,
                              width: 20.0,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            width: _width * 0.30,
                            height: 40,
                            borderRadius: 20.0,
                            color: Color(0xFF2b527f),
                            onPressed: () async {


                              final key = _formkeyResetPassword.currentState;
                              key.save();
                              print(resetPassword);

                              resetPasswordAccount(resetPassword);

                              await Future.delayed(
                                  const Duration(milliseconds: 2000), () => 42);
                              return () async {


                                Flushbar(
                                  margin: EdgeInsets.all(8),
                                  borderRadius: 8,
                                  title: "Message",
                                  message: "Please check the email you provided for messages.",
                                  duration: Duration(seconds: 2),
                                )
                                  ..show(context).then((result) {
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  });
                              };
                            }
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          )
      ),
    );
  }
}
