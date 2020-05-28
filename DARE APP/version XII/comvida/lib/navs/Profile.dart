import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/login/provider.dart';
import 'package:comvida/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override

  Widget build(BuildContext context) {
//    return Scaffold(
//      body: SingleChildScrollView(
//        child: Center(
//          child: Column(
//            children: <Widget>[
//              normalUser(),
//            ],
//          ),
//        )
//      ),
//    );
    return Scaffold(
      body: SingleChildScrollView(
          child: normalUser()
      ),
    );
  }
}

class normalUser extends StatefulWidget {
  @override
  _normalUserState createState() => _normalUserState();
}

class _normalUserState extends State<normalUser> {
  @override

  void initState() {
    super.initState();
    _loadCurrentUser();
    _knowTypeofUser();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String name;
  String email;
  String typeOfUser;
  String userID;

  final db = Firestore.instance;

  _knowTypeofUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    db.collection('USERS').document(user.uid).get().then((DocumentSnapshot ds) {
      setState(() {
        if (typeOfUser == 'Normal User') {
          return this.name = ds['Name of User'];
        } else {
          return this.name = ds['Name of Organization'];
        }
      });
    });
  }

  _loadCurrentUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    db.collection('USERS').document(user.uid).get().then((DocumentSnapshot ds) {
      setState(() {
        this.userID = user.uid;
        this.email = ds['Email'];
        this.typeOfUser = ds['Type of User'];
      });
    });
  }

  String _name() {
    if (name != null) {
      return name;
    } else {
      return "no current user";
    }
  }

  String _email() {
    if (email != null) {
      return email;
    } else {
      return "no current user";
    }
  }

  _viewingRequest (BuildContext) async {
    return showDialog(
        barrierDismissible: false,
        context: _scaffoldKey.currentContext,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return Center(
            child: AlertDialog(
              contentPadding: EdgeInsets.only(left: 20, right: 20),
              title: Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Information"),
                    GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.of(context).pop();
                          });
                        },
                        child: Icon(
                          FontAwesomeIcons.times,
                          size: 17,
                        )),
                  ],
                ),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Container(
                height: _height * 0.50,
                width: _width * 0.80,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Requestors name:'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                             'Name_ofUser',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Description:',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Help_Description',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Help needed:',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                         'Help_TypeNeeded',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: _width * 0.25,
                      child: RaisedButton(
                        child: new Text(
                          'Respond',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(0xFF121A21),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        onPressed: () {
                        },
                      ),
                    ),
                    SizedBox(
                      width: _width * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: _width * 0.25,
                        child: RaisedButton(
                          child: new Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Color(0xFF121A21),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: _height * 0.02,
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: Colors.blueAccent,
      ),
    );

//    return Container(
//      color: Colors.white,
//      child: ListView(
//        padding: EdgeInsets.zero,
//        children: <Widget>[
//          SizedBox(
//            height: _height * 0.040,
//          ),
//          Column(
//            children: <Widget>[
//              Container(
//                child: CircleAvatar(
//                  radius: 60,
//                  backgroundColor: Color(0xFF121A21),
//                  child: CircleAvatar(
//                    radius: 55,
//                    backgroundColor: Colors.greenAccent,
//                    child: CircleAvatar(
//                      radius: 48,
//                      backgroundImage: AssetImage('assets/Monkey.jpg'),
//                    ),
//                  ),
//                ),
//              ),
//              SizedBox(
//                height: _height * 0.020,
//              ),
//              Container(
//                child: Text(
//                  _name(),
//                  style: TextStyle(color: Color(0xFF121A21)),
//                ),
//              ),
//              SizedBox(
//                height: _height * 0.005,
//              ),
//              Container(
//                child: Text(
//                  _email(),
//                  style: TextStyle(color: Color(0xFF121A21)),
//                ),
//              ),
//            ],
//          ),
//          SizedBox(
//            height: _height * 0.010,
//          ),
//          Divider(
//            color: Colors.black,
//          ),
//          Container(
//            margin: EdgeInsets.only(top: 10),
//            width: double.infinity,
//            child: Align(
//              alignment: Alignment.center,
//              child: FlatButton.icon(
//                color: Color(0xFFFFFFFF),
//                label: Text('Update Donate Info'),
//                icon: Icon(
//                  FontAwesomeIcons.user,
//                  color: Color(0xff045135),
//                ),
//                textColor: Color(0xFF121A21),
//                onPressed: (){
////                  setState(() {
////                    Navigator.push(
////                        context,
////                        MaterialPageRoute(
////                          builder: (BuildContext context) =>  UpdateDonateInfo(),
////                        )
////                    );
////                  });
//                },
//              ),
//            ),
//          ),
//          Container(
//            alignment: Alignment.bottomLeft,
//            padding: const EdgeInsets.only(left: 15),
//            height: MediaQuery.of(context).size.height * 0.53,
//            child: FlatButton(
//              onPressed: () async {
//                try {
//                  AuthService auth = Providers.of(context).auth;
//                  await auth.signOut();
//                  print("Signed Out");
//                } catch (e) {
//                  print(e);
//                }
//              },
//              padding: const EdgeInsets.all(0),
//              child: Row(
//                children: <Widget>[
//                  Align(
//                    alignment: Alignment.bottomLeft,
//                    child: Icon(
//                      FontAwesomeIcons.signOutAlt,
//                      color: Color(0xff045135),
//                      size: 25,
//                    ),
//                  ),
//                  SizedBox(
//                    width: 10,
//                  ),
//                  Align(
//                    alignment: Alignment.bottomLeft,
//                    child: Text(
//                      "Log out",
//                      style: TextStyle(
//                        fontWeight: FontWeight.w500,
//                        fontSize: 16,
//                        color: Color(0xFF121A21),
//                      ),
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          ),
//        ],
//      ),
//    );

//      return Container(
//        child: Column(
//          children: <Widget>[
//            Row(
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(top: 10.0, right: 10.0),
//                  child: Icon(FontAwesomeIcons.edit),
//                ),
//              ],
//            ),
//            CircleAvatar(
//              radius: 70,
//            ),
//            Padding(
//              padding: const EdgeInsets.only(top: 20),
//              child: Column(
//                children: <Widget>[
//                  Container(
//                    child: Text(_name()),
//                  ),
//                  Container(
//                    child: Text(_email()),
//                  )
//                ],
//              ),
//            ),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: Divider(
//                color: Colors.black,
//              ),
//            ),
//
//          Card(
//            child: Column(
//              children: <Widget>[
//                FlatButton(
//                    onPressed: (){
//                      _viewingRequest(BuildContext);
//                      },
//                    child: Text(
//                  'Press Me',
//                )),
//              ],
//            ),
//          ),
//          ],
//        ),
//      );
  }
}


class SubPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sub Page'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Click button to back to Main Page'),
            RaisedButton(
              textColor: Colors.white,
              color: Colors.redAccent,
              child: Text('Back to Main Page'),
              onPressed: () {
                Navigator.popAndPushNamed(context, '/Profile');
              },
            )
          ],
        ),
      ),
    );
  }
}

//Container(
//child: Row(
//mainAxisAlignment: MainAxisAlignment.center,
//children: <Widget>[
//Column(
//children: <Widget>[
//Padding(
//padding: const EdgeInsets.only(top: 25.0),
//child: CircleAvatar(
//radius: 70,
//),
//),
//
////                  StreamBuilder<QuerySnapshot>(
////                      stream: db
////                          .collection('USERS')
////                          .where('Name of Organization', isEqualTo: 'DSWD')
////                          .snapshots(),
////                      builder: (context, snapshot) {
////                        if (snapshot.hasData) {
////                          return Column(
////                              children: snapshot.data.documents
////                                  .map((doc) => buildItem(doc))
////                                  .toList()
////                          );
////                        } else {
//////                      return SizedBox();
////                          return Container(
////                            color: Colors.redAccent,
////                          );
////                        }
////                      })
//],
//)
//],
//),
//),