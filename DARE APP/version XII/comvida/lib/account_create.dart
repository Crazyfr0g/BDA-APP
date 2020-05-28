import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'login/create_account.dart';
import 'login/provider.dart';

class AccountCreate extends StatefulWidget {
  @override
  _AccountCreateState createState() => _AccountCreateState();
}

class _AccountCreateState extends State<AccountCreate> {
  String _email;
  final formkey = GlobalKey<FormState>();


//  void submit() async {
//    final key = formkey.currentState;
//    key.save();
//    final auth = Providers.of(context).auth;
//          String uid =
//          await auth.createUserWithEmailAndPassword(_email);
//          print("Signed Up with new ID ${uid}");
//          Navigator.pushReplacementNamed(context, '/home');
//
//  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Material(
          child: Form(
            key: formkey,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Container(
                        width: _width * 0.80,
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          onSaved: (value) => _email = value,
                          validator: (String value) {
                            if (value.length < 1)
                              return 'How many families are affected field, is empty';
                            else
                              return null;
                          },
                          decoration: InputDecoration(
                            icon: Icon(FontAwesomeIcons.featherAlt),
                            labelText: 'Email:',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlatButton(
                    child: Text('Sign Up',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800
                      ),
                    ),
                    onPressed: () async {
//                      submit();
                    },
                  ),
                  InkWell(
                    onTap: (){

                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RichText(
                        text: TextSpan(
                          text: 'Existing Account? ',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'LOG IN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline
                              )
                            )
                          ]
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
