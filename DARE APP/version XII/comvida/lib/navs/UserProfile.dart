import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/login/provider.dart';
import 'package:comvida/services/auth_services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as Path;
import 'package:uuid/uuid.dart';


class UserProfile extends StatefulWidget {
  UserProfile(
      this.UidUser,
      this._nameOfUser,
      this._emailOfUser,
      this._typeOfUser,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount,
      this._userProfile) : super();

  final String UidUser;
  final String _nameOfUser;
  final String _emailOfUser;
  final String _typeOfUser;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;
  final String _userProfile;


  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override

  void initState() {
    super.initState();
    print(widget._userProfile);
  }

  Widget _buildDroughtRequest() {
    if (widget._typeOfUser == "Barangay") {
      return _UserProfileBeneficiary(widget.UidUser, widget._nameOfUser, widget._emailOfUser, widget.totalInterestedCount, widget.totalConfirmedHelpCount, widget._userProfile);
    }
    else if (widget._typeOfUser == "Normal User")  {
      return _UserProfileBenefactor(widget.UidUser, widget._nameOfUser, widget._emailOfUser, widget.totalInterestedCount, widget.totalConfirmedHelpCount, widget._userProfile);
    }
    else if (widget._typeOfUser == "Admin")  {
      return UserProfileAdmin(widget.UidUser, widget._nameOfUser, widget._emailOfUser, widget.totalInterestedCount, widget.totalConfirmedHelpCount, widget._userProfile);
    }
  }

  _logoutSettting () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                        child: Text("Settings",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)
                )
            ),
            content: Container(
              height: _height * 0.08,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: ProgressButton(
                            defaultWidget: const Text('Log out',
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
                            color: Color(0xFF3F6492),
                            onPressed: () async {
                              await Future.delayed(
                                  const Duration(milliseconds: 2000), () => 42);
                              return () async {
                                try {
                                  AuthService auth = Providers.of(context).auth;
                                  await auth.signOut();
                                  Navigator.pop(context);
                                  print("Signed Out");
                                } catch (e) {
                                  print(e);
                                }
                              };
                            }
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }


  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: [0.3, 0.7],
          colors: [
            Color(0xFFE5E7EF),
            Color(0xFF2b527f),
          ],
        ),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: AppBar(
            backgroundColor: Color(0xFF2b527f),
            title: Text(
                'B-DA',
                style: GoogleFonts.raleway(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFFFFF),
                  ),
                )
            ),
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(
                      FontAwesomeIcons.signOutAlt
                  ),
                  onPressed: (){
                    _logoutSettting();
                  }
                  ),
            ],
          ),
        ),
        body: _buildDroughtRequest(),
      ),
    );
  }
}


class ShowUserProfileBenefactor extends StatefulWidget {
  ShowUserProfileBenefactor(
      this.UidUser,
      this._nameOfUser,
      this._emailOfUser,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount) : super();

  final String UidUser;
  final String _nameOfUser;
  final String _emailOfUser;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;

  @override
  _ShowUserProfileBenefactorState createState() => _ShowUserProfileBenefactorState();
}

class _ShowUserProfileBenefactorState extends State<ShowUserProfileBenefactor> {
  String _donateUpdate;

  @override

  void initState() {
    super.initState();
    _loadCurrentUser();
    _knowTypeofUser();
    loadImage();
  }
  var url;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formkeyResponse = GlobalKey<FormState>();


  void loadImage() async {
    final ref = FirebaseStorage.instance.ref().child('chats/image_picker372109322.jpg}');
   url = await ref.getDownloadURL();
    Image.network(url);
  }

  String name;
  String email;
  String typeOfUser;
  String userID;
  String _helpdesc,
      _helpneeded,
      _helplocation,
      _nameofuser,
      _helpdescResponse,
      _helpneededResponse,
      _helptitleResponse,
      _helpamountResponse;
  bool _autoValidate = false;


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

  _displaySettting () async {
    return showDialog(
        barrierDismissible: false,
        context: _scaffoldKey.currentContext,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                        child: Text("Settings",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.21,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF121A21),
                          onPressed: ()  {
                          },
                          child: Text(
                            'Update Information',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF121A21),
                          onPressed: ()  {
                          },
                          child: Text(
                            'Reset Information',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF121A21),
                          onPressed: ()  {
                          },
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          _displaySettting();
                        });
                      },
                      child: InkWell(
                          child: Icon(
                              FontAwesomeIcons.cog
                          )
                      ),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 70,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text (widget._nameOfUser,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                      ),
                    ),
                    Container(
                      child: Text(widget._emailOfUser,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                              child: Text('Personal Information:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                              child: Text('Name',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                widget._nameOfUser,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Email',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                  widget._emailOfUser,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Contact Number',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(widget.totalConfirmedHelpCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                              child: Text('Account Information:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                             Padding(
                               padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                               child: Text('Total Interested Help Count',
                                 style: TextStyle(
                                     color: Colors.black,
                                     fontSize: 13
                                 ),
                               ),
                             ),
                           Padding(
                             padding: const EdgeInsets.only(right: 10.0),
                             child: Text(
                               widget.totalInterestedCount.toString(),
                               style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 15
                               ),
                             ),
                           )
                         ],
                       ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Total Confirmed Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(widget.totalConfirmedHelpCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                              child: Text('Account Information:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                              child: Text('Total Interested Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                widget.totalInterestedCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Total Confirmed Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(widget.totalConfirmedHelpCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _UserProfileBenefactor extends StatefulWidget {
  _UserProfileBenefactor(
      this.UidUser,
      this._nameOfUser,
      this._emailOfUser,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount,
      this._userProfile) : super();

  final String UidUser;
  final String _nameOfUser;
  final String _emailOfUser;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;
  final String _userProfile;

  @override
  _UserProfileBenefactorState createState() => _UserProfileBenefactorState();
}

class _UserProfileBenefactorState extends State<_UserProfileBenefactor> {
  String _donateUpdate;

  String _helpfamiliesaffected;

  @override

  void initState() {
    super.initState();
    _loadCurrentUser();
    _knowTypeofUser();
    loadImage();
    print(widget.UidUser);
  }
  var url;

  final _formkeyName = GlobalKey<FormState>();
  final _formkeyContactNumber = GlobalKey<FormState>();
  final _formkeyAddress = GlobalKey<FormState>();
  final _formkeyBirthdate = GlobalKey<FormState>();
  final _formkeyResponse = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");


  void loadImage() async {
    final ref = FirebaseStorage.instance.ref().child('chats/image_picker372109322.jpg}');
    url = await ref.getDownloadURL();
    Image.network(url);
  }

  String name;
  String email;
  String typeOfUser;
  String userID;
  String _helpdesc,
      _helpneeded,
      _helplocation,
      _helpdescResponse,
      _helpneededResponse,
      _helptitleResponse,
      _helpamountResponse;

  String _nameofUser;
  String _contactNumber;
  String _city;
  String _barangy;
  String _street;
  String _uploadedFileURLFood;
  String imageS;


  var uuid = Uuid();
  var _birthdate;

  File _imageFood;

  bool _autoValidate = false;
  Flushbar flush;
  AssetImage imageType;

  final db = Firestore.instance;


  uploadFileFood() async {

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${widget.UidUser}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskFood = storageReferenceFood.putFile(_imageFood);
    await uploadTaskFood.onComplete;
    print('File Uploaded');

    storageReferenceFood.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLFood = fileURL;
        print(_uploadedFileURLFood);
      });
    });

  }

  _updateProfile() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Upload Profile",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.userAlt,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.45,
              width: _width * 0.80,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: RaisedButton(
                          child: Text("Choose Image:",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          onPressed: (){
                            getImageFood();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: _imageFood == null
                              ?
                          Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No image selected.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),),
                              )
                          )
                              :
                          Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.file(_imageFood),
                              )
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            uploadFileFood();
                            await Future.delayed(
                                const Duration(milliseconds: 5000), () => 42);
                            return () async {
                              _saveConfirmedCountToBeneficiaryRespondents();
                              Navigator.pop(context);
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _saveConfirmedCountToBeneficiaryRespondents() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Profile_Picture': _uploadedFileURLFood,
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Profile_Picture': _uploadedFileURLFood,
          });
        });
      }
    });
  }

  Future getImageFood() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    setState(() {
      _imageFood = image;
    });
  }

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

  void _userDonationsCanGive() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Donations_ICanGive': '${_donateUpdate}'});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Donations_ICanGive': '${_donateUpdate}'});
          user.reload();
        });
      }
    });

  }

  _personalInfoSettting () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Details",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.listOl,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.27,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateName();
                          },
                          child: Text(
                            'Name',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: ()  {
                            Navigator.pop(context);
                            _updateContactNumber();
                          },
                          child: Text(
                            'Contact number',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: () async {
                            Navigator.pop(context);
                            _updateAddress();
                          },
                          child: Text(
                            'Address',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateBirthdate();
                          },
                          child: Text(
                            'Birthdate',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _updateName() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update name",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.signature,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyName,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLength: 100,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _nameofUser = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Name:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()){
                                saveName();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateContactNumber() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Number",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.addressBook,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyContactNumber,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLength: 11,
                                keyboardType: TextInputType.number,
                                onSaved: (value) =>  _contactNumber = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Contact Number:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyContactNumber.currentState;
                              if (key.validate()){
                                saveContactNumber();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateAddress() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Address",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.addressBook,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.30,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyAddress,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _city = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'City:',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _barangy = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Barangay:',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _street = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Street:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyAddress.currentState;
                              if (key.validate()){
                                saveAddress();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateBirthdate() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Birthdate",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.calendarAlt,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyBirthdate,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child:  DateTimeField (
                                format: dateFormat,
                                onShowPicker: (context, currentValue) async {
                                  final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  return(currentValue);
                                },
                                decoration: InputDecoration(
                                  labelText: 'Choose date:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyBirthdate.currentState;
                              if (key.validate()){
                                saveBirthdate();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  saveName() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Name of User': _nameofUser});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Name of User': _nameofUser});
          user.reload();
        });
      }
    });
  }

  saveContactNumber() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final contactnumberKey = _formkeyContactNumber.currentState;
    contactnumberKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Contact_Number': _contactNumber});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Contact_Number': _contactNumber});
          user.reload();
        });
      }
    });
  }

  saveBirthdate() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final birthdateKey = _formkeyBirthdate.currentState;
    birthdateKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Birth_Date': _birthdate});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Birth_Date': _birthdate});
          user.reload();
        });
      }
    });
  }

  saveAddress() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final addressKey = _formkeyAddress.currentState;
    addressKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Address': "${_street} Street, ${_barangy}. ${_city} City."});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Address': "${_street} Street, ${_barangy}.${_city} City."});
          user.reload();
        });
      }
    });
  }

  Container buildItem(DocumentSnapshot doc) {

    Widget picture(){
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
        return InkWell(
          onTap: (){
            setState(() {
              _updateProfile();
            });
          },
          child: CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage('assets/no-image.png'),
          ),
        );
      }
      else{
        return InkWell(
          onTap: (){
            setState(() {
              _updateProfile();
            });
          },
          child: CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(doc.data['Profile_Picture']),
          ),
        );
      }
    }

   String dateJoined (){
      if(doc.data['Date_Joined'] == "" || doc.data['Date_Joined'] == null){
         return "";
      }
      else{
        return doc.data['Date_Joined'];
      }
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            picture(),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text (doc.data['Name of User'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white
                      ),
                    ),
                  ),
                  Container(
                    child: Text(doc.data['Email'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white

                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 5),
                            child: Text('Personal Information',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, right: 5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _personalInfoSettting();
                                });
                              },
                              child: InkWell(
                                  child: Icon(
                                    FontAwesomeIcons.cog,
                                    size: 15,
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                         Expanded(
                           flex: 1,
                           child: Padding(
                             padding: const EdgeInsets.only(left: 10.0),
                             child: Text('Name:',
                               style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 13
                               ),
                             ),
                           ),
                         ),
                         Expanded(
                           flex: 3,
                           child: Padding(
                             padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                             child: Text(
                               doc.data['Name of User'],
                               textAlign: TextAlign.right,
                               style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 13,
                                   fontWeight: FontWeight.w800
                               ),
                             ),
                           ),
                         )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                              flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Email:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Email'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Contact Number:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Contact_Number'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Birthdate:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Birth_Date'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text('Address:',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(
                                  doc.data['Address'],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                            child: Text('Coins Earned',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),

                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, bottom: 0, top: 10),
                                child: Text(doc.data['Confirmed_Helpcount'].toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
                                child: InkWell(
                                    child: Icon(
                                      FontAwesomeIcons.coins,
                                      size: 15,
                                    )
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 15),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 5),
                            child: Text('Activities',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                         Expanded(
                           flex: 1,
                           child: Padding(
                             padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                             child: Text('Date joined:',
                               style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 13
                               ),
                             ),
                           ),
                         ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                dateJoined(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Total Confirmed Help',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13
                              ),
                            ),
                          ),
                        ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Confirmed_Helpcount'].toString(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container (
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.020,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                            stream: db.collection('USERS').where('User_ID', isEqualTo: '${widget.UidUser}').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                    children: snapshot.data.documents
                                        .map((doc) => buildItem(doc))
                                        .toList());
                              } else {
                                return Container(
                                    child: Center(
                                        child: CircularProgressIndicator()
                                    )
                                );
                              }
                            })
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}


class _UserProfileBeneficiary extends StatefulWidget {
  _UserProfileBeneficiary(
      this.UidUser,
      this._nameOfUser,
      this._emailOfUser,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount,
      this._userProfile) : super();

  final String UidUser;
  final String _nameOfUser;
  final String _emailOfUser;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;
  final String _userProfile;

  @override
  _UserProfileBeneficiaryState createState() => _UserProfileBeneficiaryState();
}

class _UserProfileBeneficiaryState extends State<_UserProfileBeneficiary> {
  String _donateUpdate;

  String _helpfamiliesaffected;


  @override

  void initState() {
    super.initState();
    _loadCurrentUser();
    _knowTypeofUser();
    print(widget.UidUser);
  }

  var url;

  final _formkeyName = GlobalKey<FormState>();
  final _formkeyContactNumber = GlobalKey<FormState>();
  final _formkeyAddress = GlobalKey<FormState>();
  final _formkeyBirthdate = GlobalKey<FormState>();
  final _formkeyResponse = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");

  final Dformat = new DateFormat.yMMMMd("en_US").add_jm();


  String name;
  String email;
  String typeOfUser;
  String userID;

  String _profileInfo;
  String _nameofUser;
  String _contactNumber;
  String _city;
  String _barangy;
  String _street;
  String _uploadedFileURLFood;
  String imageS;


  var uuid = Uuid();
  var _birthdate;

  File _imageFood;
  bool _autoValidate = false;
  Flushbar flush;
  AssetImage imageType;

  final db = Firestore.instance;

  _updateProfile() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Upload Profile",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.userAlt,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.40,
              width: _width * 0.70,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: RaisedButton(
                          child: Text("Choose Image:",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          onPressed: (){
                            getImageProfile();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: _imageFood == null
                              ?
                          Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No image selected.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),),
                              )
                          )
                              :
                          Container(
                            child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(_imageFood),
                                )
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                          color: Color(0xFF121A21),
                          onPressed: () async {
                            uploadFileProfile();
                            await Future.delayed(
                                const Duration(milliseconds: 5000), () => 42);
                            return () async {
                              _saveConfirmedCountToBeneficiaryRespondents();
                              Navigator.pop(context);
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  uploadFileProfile() async {

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${widget.UidUser}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskFood = storageReferenceFood.putFile(_imageFood);
    await uploadTaskFood.onComplete;
    print('File Uploaded');

    storageReferenceFood.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLFood = fileURL;
        print(_uploadedFileURLFood);
      });
    });

  }

  _saveConfirmedCountToBeneficiaryRespondents() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Profile_Picture': _uploadedFileURLFood,
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Profile_Picture': _uploadedFileURLFood,
          });
        });
      }
    });
  }

  Future getImageProfile() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    setState(() {
      _imageFood = image;
    });
  }

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

  _personalInfoSettting () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Details",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.listOl,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.21,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateName();
                          },
                          child: Text(
                            'Name',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: ()  {
                            Navigator.pop(context);
                            _updateContactNumber();
                          },
                          child: Text(
                            'Contact number',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: () async {
                            Navigator.pop(context);
                            _updateAddress();
                          },
                          child: Text(
                            'Address',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _ProfileInfoSettting () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Prof.Info",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.listOl,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.08,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF2b527f),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateInfo();
                          },
                          child: Text(
                            'Update Info',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _updateName() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update name",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.signature,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyName,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLength: 100,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _nameofUser = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Name:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()){
                                saveName();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateInfo() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Info",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.signature,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyName,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLines: 3,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _profileInfo = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Profile Info:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()){
                                saveInfo();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateContactNumber() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Number",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.addressBook,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyContactNumber,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLength: 11,
                                keyboardType: TextInputType.number,
                                onSaved: (value) =>  _contactNumber = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Contact Number:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyContactNumber.currentState;
                              if (key.validate()){
                                saveContactNumber();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateAddress() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Address",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.addressBook,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.30,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyAddress,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _city = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'City:',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _barangy = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Barangay:',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _street = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Street:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyAddress.currentState;
                              if (key.validate()){
                                saveAddress();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  saveName() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Name of Barangay': _nameofUser});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Name of Barangay': _nameofUser});
          user.reload();
        });
      }
    });
  }

  saveInfo() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Profile_Information': _profileInfo});
          user.reload();
        });
      }
      else {
        setState(() async {
          await ref
              .setData({'Profile_Information': _profileInfo});
          user.reload();
        });
      }
    });
  }

  saveContactNumber() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final contactnumberKey = _formkeyContactNumber.currentState;
    contactnumberKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Contact_Number': _contactNumber});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Contact_Number': _contactNumber});
          user.reload();
        });
      }
    });
  }

  saveAddress() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final addressKey = _formkeyAddress.currentState;
    addressKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Address': "${_street} Street, ${_barangy}. ${_city} City."});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Address': "${_street} Street, ${_barangy}.${_city} City."});
          user.reload();
        });
      }
    });
  }

  Container buildItem(DocumentSnapshot doc) {

    Widget picture(){
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == "" ){
        return InkWell(
          onTap: (){
            setState(() {
              _updateProfile();
            });
          },
          child: CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage('assets/no-image.png'),
          ),
        );
      }
      else{
        return InkWell(
          onTap: (){
            setState(() {
              _updateProfile();
            });
          },
          child: CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(doc.data['Profile_Picture']),
          ),
        );
      }
    }

    String _profInfo (){
      if (doc.data['Profile_Information'] == ""){
        return 'Please update profile information.';
      }
      else{
        return doc.data['Profile_Information'];
      }
    }

    Color _statusColor (){
      if (doc.data['Barangay_Status'] == "Not verified"){
        return Colors.red;
      }
      else if (doc.data['Barangay_Status'] == "Verified"){
        return Colors.green;
      }
    }

    String _orgStatus (){
      if (doc.data['Barangay_Status'] == "Not verified"){
        return "Not verified";
      }
      else if (doc.data['Barangay_Status'] == "Verified"){
        return "Verified";
      }
    }


    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            picture(),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text (doc.data['Name of Barangay'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white
                      ),
                    ),
                  ),
                  Container(
                    child: Text(doc.data['Email'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white

                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 5),
                            child: Text('Barangay Details',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, right: 5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _personalInfoSettting();
                                });
                              },
                              child: InkWell(
                                  child: Icon(
                                    FontAwesomeIcons.cog,
                                    size: 15,
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                         Expanded(
                           flex: 2,
                           child:  Padding(
                             padding: const EdgeInsets.only(left: 10.0),
                             child: Text('Barangay status:',
                               style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 13
                               ),
                             ),
                           ),
                         ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                _orgStatus(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: _statusColor(),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Barangay name:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Name of Barangay'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Email:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child:  Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Email'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child:   Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Contact Number:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Contact_Number'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                           Expanded(
                             flex: 1,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 10.0),
                               child: Text('Address:',
                                 style: TextStyle(
                                     color: Colors.black,
                                     fontSize: 13
                                 ),
                               ),
                             ),
                           ),
                           Expanded(
                             flex: 4,
                             child:  Padding(
                               padding: const EdgeInsets.only(right: 10.0),
                               child: Text(
                                 doc.data['Address'],
                                 textAlign: TextAlign.right,
                                 style: TextStyle(
                                     color: Colors.black,
                                     fontSize: 12.5,
                                     fontWeight: FontWeight.w800
                                 ),
                               ),
                             ),
                           )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                            child: Text('Profile Information',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, right: 5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _ProfileInfoSettting();
                                });
                              },
                              child: InkWell(
                                  child: Icon(
                                    FontAwesomeIcons.cog,
                                    size: 15,
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_profInfo(),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                            child: Text('Coins Earned',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),

                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0, bottom: 0, top: 10),
                                child: Text(
                                  doc.data['Total_GoalReachedCount'].toString(),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0, right: 10.0, left: 10.0),
                                child: InkWell(
                                    child: Icon(
                                      FontAwesomeIcons.coins,
                                      size: 15,
                                    )
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 30.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 5),
                            child: Text('Activities',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child:    Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                              child: Text('Date joined',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child:  Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                Dformat.format(doc.data['Date_Joined'].toDate()),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                              child: Text(
                                'Total Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child:  Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Total_ConfirmedHelp'].toString(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text('Total Goal Reached',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(
                                  doc.data['Total_GoalReachedCount'].toString(),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container (
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.020,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                            stream: db.collection('USERS').where('User_ID', isEqualTo: '${widget.UidUser}').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                    children: snapshot.data.documents
                                        .map((doc) => buildItem(doc))
                                        .toList());
                              } else {
                                return Container(
                                    child: Center(
                                        child: CircularProgressIndicator()
                                    )
                                );
                              }
                            })
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}


class UserProfileAdmin extends StatefulWidget {
  UserProfileAdmin(
      this.UidUser,
      this._nameOfUser,
      this._emailOfUser,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount,
      this._userProfile) : super();

  final String UidUser;
  final String _nameOfUser;
  final String _emailOfUser;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;
  final String _userProfile;


  @override
  _UserProfileAdminState createState() => _UserProfileAdminState();
}

class _UserProfileAdminState extends State<UserProfileAdmin> {
  String _donateUpdate;

  String _helpfamiliesaffected;


  @override

  void initState() {
    super.initState();
    _loadCurrentUser();
    _knowTypeofUser();
    loadImage();
    print(widget.UidUser);
  }

  var url;

  final _formkeyName = GlobalKey<FormState>();
  final _formkeyContactNumber = GlobalKey<FormState>();
  final _formkeyAddress = GlobalKey<FormState>();
  final _formkeyBirthdate = GlobalKey<FormState>();
  final _formkeyResponse = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final dateFormat = DateFormat("EEEE, MMMM d, yyyy");


  void loadImage() async {
    final ref = FirebaseStorage.instance.ref().child('chats/image_picker372109322.jpg}');
    url = await ref.getDownloadURL();
    Image.network(url);
  }

  String name;
  String email;
  String typeOfUser;
  String userID;

  String _profileInfo;
  String _nameofUser;
  String _contactNumber;
  String _city;
  String _barangy;
  String _street;
  String _uploadedFileURLFood;
  String imageS;


  var uuid = Uuid();
  var _birthdate;

  File _imageFood;
  bool _autoValidate = false;
  Flushbar flush;
  AssetImage imageType;

  final db = Firestore.instance;

  _updateProfile() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Upload Profile",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.userAlt,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.40,
              width: _width * 0.70,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: RaisedButton(
                          child: Text("Choose Image:",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          onPressed: (){
                            getImageProfile();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: _imageFood == null
                              ?
                          Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No image selected.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),),
                              )
                          )
                              :
                          Container(
                            child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(_imageFood),
                                )
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                          color: Color(0xFF121A21),
                          onPressed: () async {
                            uploadFileProfile();
                            await Future.delayed(
                                const Duration(milliseconds: 5000), () => 42);
                            return () async {
                              _saveConfirmedCountToBeneficiaryRespondents();
                              Navigator.pop(context);
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  uploadFileProfile() async {

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${widget.UidUser}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskFood = storageReferenceFood.putFile(_imageFood);
    await uploadTaskFood.onComplete;
    print('File Uploaded');

    storageReferenceFood.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLFood = fileURL;
        print(_uploadedFileURLFood);
      });
    });

  }

  _saveConfirmedCountToBeneficiaryRespondents() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Profile_Picture': _uploadedFileURLFood,
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Profile_Picture': _uploadedFileURLFood,
          });
        });
      }
    });
  }

  Future getImageProfile() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    setState(() {
      _imageFood = image;
    });
  }

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

  _personalInfoSettting () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Details",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.listOl,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.21,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF121A21),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateName();
                          },
                          child: Text(
                            'Name',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF121A21),
                          onPressed: ()  {
                            Navigator.pop(context);
                            _updateContactNumber();
                          },
                          child: Text(
                            'Contact number',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF121A21),
                          onPressed: () async {
                            Navigator.pop(context);
                            _updateAddress();
                          },
                          child: Text(
                            'Address',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _ProfileInfoSettting () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Prof.Info",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.listOl,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.08,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.50,
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                          color: Color(0xFF121A21),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateInfo();
                          },
                          child: Text(
                            'Update Info',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _updateName() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update name",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.signature,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyName,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLength: 100,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _nameofUser = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Name:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                          color: Color(0xFF121A21),
                          onPressed: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()){
                                saveName();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateInfo() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Info",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.signature,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyName,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLines: 3,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _profileInfo = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Profile Info:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                          color: Color(0xFF121A21),
                          onPressed: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()){
                                saveInfo();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateContactNumber() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Number",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.addressBook,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.13,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyContactNumber,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                maxLength: 11,
                                keyboardType: TextInputType.number,
                                onSaved: (value) =>  _contactNumber = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Contact Number:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                          color: Color(0xFF121A21),
                          onPressed: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyContactNumber.currentState;
                              if (key.validate()){
                                saveContactNumber();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _updateAddress() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Center(
                            child: Text("Update Address",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 3),
                            child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.pop(context);
                                  });
                                },
                                child: Icon(
                                  FontAwesomeIcons.addressBook,
                                  size: 20,
                                )),
                          ),
                        ],
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Container(
              height: _height * 0.30,
              width: _width * 0.40,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Form(
                      key: _formkeyAddress,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _city = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'City:',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _barangy = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Barangay:',
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: _width * .80,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                onSaved: (value) =>  _street = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Street:',
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
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0, bottom: 3),
                    child: Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
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
                          color: Color(0xFF121A21),
                          onPressed: () async {
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () async {
                              final key = _formkeyAddress.currentState;
                              if (key.validate()){
                                saveAddress();
                                Navigator.pop(context);
                              }else{
                                setState(() {
                                  _autoValidate = true;
                                });
                              }
                            };
                          }
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  saveName() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Name of Admin': _nameofUser});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Name of Admin': _nameofUser});
          user.reload();
        });
      }
    });
  }

  saveInfo() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Profile_Information': _profileInfo});
          user.reload();
        });
      }
      else {
        setState(() async {
          await ref
              .setData({'Profile_Information': _profileInfo});
          user.reload();
        });
      }
    });
  }

  saveContactNumber() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final contactnumberKey = _formkeyContactNumber.currentState;
    contactnumberKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Contact_Number': _contactNumber});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Contact_Number': _contactNumber});
          user.reload();
        });
      }
    });
  }

  saveAddress() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final addressKey = _formkeyAddress.currentState;
    addressKey.save();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Address': "${_street} Street, ${_barangy}. ${_city} City."});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Address': "${_street} Street, ${_barangy}.${_city} City."});
          user.reload();
        });
      }
    });
  }

  Container buildItem(DocumentSnapshot doc) {

    Widget picture(){
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
        return InkWell(
          onTap: (){
            setState(() {
              _updateProfile();
            });
          },
          child: CircleAvatar(
            radius: 70,
            backgroundImage: AssetImage('assets/no-image.png'),
          ),
        );
      }
      else{
        return InkWell(
          onTap: (){
            setState(() {
              _updateProfile();
            });
          },
          child: CircleAvatar(
            radius: 70,
            backgroundImage: NetworkImage(doc.data['Profile_Picture']),
          ),
        );
      }
    }

    String _profInfo (){
      if (doc.data['Profile_Information'] == ""){
        return 'Please update profile information.';
      }
      else{
        return doc.data['Profile_Information'];
      }
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            picture(),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Text (doc.data['Name of Admin'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white
                      ),
                    ),
                  ),
                  Container(
                    child: Text(doc.data['Email'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white

                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 5),
                            child: Text('Admin Details',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, right: 5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _personalInfoSettting();
                                });
                              },
                              child: InkWell(
                                  child: Icon(
                                    FontAwesomeIcons.cog,
                                    size: 15,
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Admin name:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Text(
                                doc.data['Name of Admin'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child:  Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Email:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                         Expanded(
                           flex: 4,
                           child:  Padding(
                             padding: const EdgeInsets.only(right: 10.0)  ,
                             child: Text(
                               doc.data['Email'],
                               textAlign: TextAlign.right,
                               style: TextStyle(
                                   color: Colors.black,
                                   fontSize: 13,
                                   fontWeight: FontWeight.w800
                               ),
                             ),
                           ),
                         )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Contact Number:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Contact_Number'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child:  Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Text('Address:',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(
                                  doc.data['Address'],
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                            child: Text('Admin Information',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, right: 5),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {
                                  _ProfileInfoSettting();
                                });
                              },
                              child: InkWell(
                                  child: Icon(
                                    FontAwesomeIcons.cog,
                                    size: 15,
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _profInfo(),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container (
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.020,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                            stream: db.collection('USERS').where('User_ID', isEqualTo: widget.UidUser).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                    children: snapshot.data.documents
                                        .map((doc) => buildItem(doc))
                                        .toList());
                              } else {
                                return Container(
                                    child: Center(
                                        child: CircularProgressIndicator()
                                    )
                                );
                              }
                            })
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}


























class _UserProfileBeneficiaryUpdatePersonalInfo extends StatefulWidget {

  _UserProfileBeneficiaryUpdatePersonalInfo(
      this.UidUser,
      this._nameOfUser,
      this._emailOfUser,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount) : super();

  final String UidUser;
  final String _nameOfUser;
  final String _emailOfUser;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;

  @override
  __UserProfileBeneficiaryUpdatePersonalInfoState createState() => __UserProfileBeneficiaryUpdatePersonalInfoState();
}

class __UserProfileBeneficiaryUpdatePersonalInfoState extends State<_UserProfileBeneficiaryUpdatePersonalInfo> {

  final _formkey = GlobalKey<FormState>();
  bool _autoValidate = false;
  final db = Firestore.instance;

  var uuid = Uuid();

  File _imageFood;

  String _helpfamiliesaffected;
  String _helplocation;
  String _dropoffLocation;
  String _helpInquiry;
  String _uploadedFileURLFood;


  Future getImageFood() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    setState(() {
      _imageFood = image;
    });
  }

  uploadFileFood() async {

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${widget.UidUser}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskFood = storageReferenceFood.putFile(_imageFood);
    await uploadTaskFood.onComplete;
    print('File Uploaded');

    storageReferenceFood.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLFood = fileURL;
        print(_uploadedFileURLFood);
      });
    });

  }

  Flushbar flush;

  _saveConfirmedCountToBeneficiaryRespondents() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    final key = _formkey.currentState;
    key.save();

    DocumentReference ref = db.collection('USERS').document(widget.UidUser);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Profile_Picture': _uploadedFileURLFood,
            'Profile_Information': _helpfamiliesaffected
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Profile_Picture': _uploadedFileURLFood,
            'Profile_Information': _helpfamiliesaffected
          });
        });
      }
    });
  }

  @override

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Personal Information"),
      ),
      body: Container(
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Card(
                  elevation: 5,
                  child: Column(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text('Upload profile picture:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: RaisedButton(
                                    child: Text("Choose Image:",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800
                                      ),
                                    ),
                                    onPressed: (){
                                      getImageFood();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                child: _imageFood == null
                                    ?
                                Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('No image selected.',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800
                                        ),),
                                    )
                                )
                                    :
                                Container(
                                  child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Image.file(_imageFood),
                                      )
                                  ),
                                )
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Divider(
                            color: Colors.black,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: _formkey,
                              autovalidate: _autoValidate,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
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
                                          keyboardType: TextInputType.number,
                                          onSaved: (value) => _helpfamiliesaffected = value,
                                          validator: (String value) {
                                            if (value.length < 1)
                                              return 'How many families are affected field is empty';
                                            else
                                              return null;
                                          },
                                          decoration: InputDecoration(
                                            icon: Icon(FontAwesomeIcons.listOl),
                                            labelText: 'Name:',
                                            labelStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5.0),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: _width * .80,
                                        ),
                                        child: TextFormField(
                                          onSaved: (value) => _helplocation = value,
                                          validator: (String value) {
                                            if (value.length < 1)
                                              return 'Affected field is empty';
                                            else
                                              return null;
                                          },
                                          decoration: InputDecoration(
                                            icon: Icon(FontAwesomeIcons.locationArrow),
                                            labelText: 'Affected area:',
                                            labelStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5.0),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: _width * .80,
                                        ),
                                        child: TextFormField(
                                          onSaved: (value) => _dropoffLocation = value,
                                          validator: (String value) {
                                            if (value.length < 1)
                                              return 'Drop off location field is empty';
                                            else
                                              return null;
                                          },
                                          decoration: InputDecoration(
                                            icon: Icon(FontAwesomeIcons.searchLocation),
                                            labelText: 'Contact number:',
                                            labelStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 5.0),
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth: _width * .80,
                                        ),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          onSaved: (value) => _helpInquiry = value,
                                          validator: (String value) {
                                            if (value.length < 1)
                                              return 'Contact number field is empty';
                                            else
                                              return null;
                                          },
                                          decoration: InputDecoration(
                                            icon: Icon(FontAwesomeIcons.solidAddressBook),
                                            labelText: 'Age:',
                                            labelStyle: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800
                                            ),
                                          ),
                                        ),
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
                        ],
                      ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0, right: 8.0),
                          child: Container(
                              height: _height * 0.05,
                              child: ProgressButton(
                                  defaultWidget: const Text('Confirm',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12
                                    ),
                                  ),
                                  progressWidget: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white
                                      )
                                  ),
                                  width: _width * 0.30,
                                  height: 40,
                                  borderRadius: 20.0,
                                  color: Color(0xFF121A21),
                                  onPressed: () async {
                                    uploadFileFood();
                                    await Future.delayed(
                                        const Duration(milliseconds: 5000), () => 42);
                                    return () {
                                      _saveConfirmedCountToBeneficiaryRespondents();
                                        flush = Flushbar<bool>(
                                          isDismissible: false,
                                          routeBlur: 50,
                                          routeColor: Colors.white.withOpacity(0.50),
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Thank you",
                                          message: "Your response is a big help for , You have chosen to donate",
                                          mainButton: FlatButton(
                                            onPressed: () async {
                                              flush.dismiss(true);
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: TextStyle(color: Colors.amber),
                                            ),
                                          ),
                                        )
                                          ..show(context).then((result) {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          });
                                    };
                                  }
                              )
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }
}

class ShowUserProfileBeneficiary extends StatefulWidget {

  ShowUserProfileBeneficiary(
      this.UidUser,
      this._nameOfUser,
      this._emailOfUser,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount) : super();

  final String UidUser;
  final String _nameOfUser;
  final String _emailOfUser;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;

  @override
  _ShowUserProfileBeneficiary createState() => _ShowUserProfileBeneficiary();
}

class _ShowUserProfileBeneficiary extends State<ShowUserProfileBenefactor> {
  String _donateUpdate;

  @override

  void initState() {
    super.initState();
    _loadCurrentUser();
    _knowTypeofUser();
    loadImage();
  }
  var url;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formkeyResponse = GlobalKey<FormState>();


  void loadImage() async {
    final ref = FirebaseStorage.instance.ref().child('chats/image_picker372109322.jpg}');
    url = await ref.getDownloadURL();
    Image.network(url);
  }

  String name;
  String email;
  String typeOfUser;
  String userID;
  String _helpdesc,
      _helpneeded,
      _helplocation,
      _nameofuser,
      _helpdescResponse,
      _helpneededResponse,
      _helptitleResponse,
      _helpamountResponse;
  bool _autoValidate = false;


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

  void _userDonationsCanGive() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({'Donations_ICanGive': '${_donateUpdate}'});
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({'Donations_ICanGive': '${_donateUpdate}'});
          user.reload();
        });
      }
    });

  }

  _displayResponse () async {
    return showDialog(
        barrierDismissible: false,
        context: _scaffoldKey.currentContext,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                        child: Text("Personal Information",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Form(
              key: _formkeyResponse,
              autovalidate: _autoValidate,
              child: Container(
                height: _height * 0.50,
                width: _width * 0.80,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        onSaved: (value) => _helptitleResponse = value,
                        validator: (String value) {
                          if (value.length < 1)
                            return 'Activity title, field is empty';
                          else
                            return null;
                        },
                        decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.featherAlt),
                          labelText: 'Name',
                        ),
                      ),
                      TextFormField(
                        maxLines: 3,
                        onSaved: (value) => _helpneededResponse = value,
                        validator: (String value) {
                          if (value.length < 1)
                            return 'Description of activity, field is empty';
                          else
                            return null;
                        },
                        decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.info),
                          labelText: 'Description of activity',
                        ),
                      ),
                      TextFormField(
                        maxLines: 3,
                        onSaved: (value) => _helpamountResponse = value,
                        validator: (String value) {
                          if (value.length < 1)
                            return 'Amount to give, field is empty';
                          else
                            return null;
                        },
                        decoration: InputDecoration(
                          icon: Icon(FontAwesomeIcons.moneyBillWaveAlt),
                          labelText: 'Amount to give',
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
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: _width * 0.25,
                    child: RaisedButton(
                      child: new Text(
                        'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color(0xFF121A21),
                      shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0),
                      ),
                      onPressed: () {
                        final key = _formkeyResponse.currentState;
                        if (key.validate()){
                          Navigator.pop(context);
                        }
                        else{
                          setState(() {
//                            _autoValidate = true;
                          });
                        }
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
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  _viewingRequest ()  {
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
                    Text("Donation Info"),
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
                width: _width * 0.80,
                height: _height * 0.40,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'What can you donate now?', style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500
                            ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CheckboxGroup(
                          orientation: GroupedButtonsOrientation.VERTICAL,
                          labels: <String>[
                            "Clothes",
                            "Food and Water",
                            "Money",
                            "Materials",
                          ],
                          onSelected: (List<String> checked){
                            _donateUpdate = checked.toString();
                            print(_donateUpdate);
                          },
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

                      child: RaisedButton(
                        child: new Text(
                          'Update',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color(0xFF121A21),
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        onPressed: () {
                          _userDonationsCanGive();
                          Navigator.pop(context);
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

//  _viewingRequest ()  {
//    return showDialog(
//        barrierDismissible: false,
//        context: _scaffoldKey.currentContext,
//        builder: (context) {
//          final _width = MediaQuery.of(context).size.width;
//          final _height = MediaQuery.of(context).size.height;
//          return Center(
//            child: AlertDialog(
//              contentPadding: EdgeInsets.only(left: 20, right: 20),
//              title: Padding(
//                padding: const EdgeInsets.only(bottom: 15.0),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Text("Donation Info"),
//                    GestureDetector(
//                        onTap: () {
//                          setState(() {
//                            Navigator.of(context).pop();
//                          });
//                        },
//                        child: Icon(
//                          FontAwesomeIcons.times,
//                          size: 17,
//                        )),
//                  ],
//                ),
//              ),
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
//              content: Container(
//                width: _width * 0.80,
//                height: _height * 0.40,
//                child: SingleChildScrollView(
//                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    crossAxisAlignment: CrossAxisAlignment.center,
//                    children: <Widget>[
//                      Padding(
//                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: <Widget>[
//                            Text(
//                              'What can you donate now?', style: TextStyle(
//                                fontSize: 16, fontWeight: FontWeight.w500
//                            ),
//                            ),
//                          ],
//                        ),
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: CheckboxGroup(
//                          orientation: GroupedButtonsOrientation.VERTICAL,
//                          labels: <String>[
//                            "Clothes",
//                            "Food and Water",
//                            "Money",
//                            "Materials",
//                          ],
//                          onSelected: (List<String> checked){
//                            _donateUpdate = checked.toString();
//                            print(_donateUpdate);
//                          },
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//              actions: <Widget>[
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.center,
//                  children: <Widget>[
//                    Container(
//
//                      child: RaisedButton(
//                        child: new Text(
//                          'Update',
//                          style: TextStyle(color: Colors.white),
//                        ),
//                        color: Color(0xFF121A21),
//                        shape: new RoundedRectangleBorder(
//                          borderRadius: new BorderRadius.circular(30.0),
//                        ),
//                        onPressed: () {
//                          _userDonationsCanGive();
//                          Navigator.pop(context);
//                        },
//                      ),
//                    ),
//                    SizedBox(
//                      width: _width * 0.01,
//                    ),
//                    Padding(
//                      padding: const EdgeInsets.only(right: 8.0),
//                      child: Container(
//                        width: _width * 0.25,
//                        child: RaisedButton(
//                          child: new Text(
//                            'Cancel',
//                            style: TextStyle(color: Colors.white),
//                          ),
//                          color: Color(0xFF121A21),
//                          shape: new RoundedRectangleBorder(
//                            borderRadius: new BorderRadius.circular(30.0),
//                          ),
//                          onPressed: () {
//                            Navigator.of(context).pop();
//                          },
//                        ),
//                      ),
//                    ),
//                    SizedBox(
//                      height: _height * 0.02,
//                    ),
//                  ],
//                )
//              ],
//            ),
//          );
//        });
//  }


  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, right: 10.0),
                    child: GestureDetector(
                      onTap: (){
                        setState(() {
                          _displayResponse();
                        });
                      },
                      child: InkWell(
                          child: Icon(
                              FontAwesomeIcons.edit
                          )
                      ),
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 70,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text (widget._nameOfUser,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(widget._emailOfUser,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                              child: Text('Personal Information:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                              child: Text('Name',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                widget._nameOfUser,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Email',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                widget._emailOfUser,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Contact Number',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(widget.totalConfirmedHelpCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                              child: Text('Account Information:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                              child: Text('Total Interested Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                widget.totalInterestedCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Total Confirmed Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(widget.totalConfirmedHelpCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 10, top: 10),
                              child: Text('Account Information:',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                              child: Text('Total Interested Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                widget.totalInterestedCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Total Confirmed Help Count',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(widget.totalConfirmedHelpCount.toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
//                  Container(
//                    width: _width * 0.60,
//                    child: Card(
//                      child: Column(
//                        children: <Widget>[
//                          FlatButton.icon(
//                              icon: Icon(FontAwesomeIcons.user),
//                              onPressed: (){
//                                _viewingRequest();
//                              },
//                              label: Text(
//                                'Update Donate Info',
//                              )),
//                        ],
//                      ),
//                    ),
//                  ),
            ],
          ),
        ),
      ),
    );
  }
}
