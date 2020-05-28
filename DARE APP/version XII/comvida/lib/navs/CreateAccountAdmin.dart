import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/login/loadingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:grouped_checkbox/grouped_checkbox.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:comvida/login/provider.dart';


class MyActivityAdmin extends StatefulWidget {
  MyActivityAdmin(
      this.typeOfUser,
      this.UidUser,
      this.nameofUser,
      this.totalConfirmedHelpCount,
      this._userProfile,
      this.orgStatus) : super();

  final String typeOfUser;
  final String UidUser;
  final String nameofUser;
  final int totalConfirmedHelpCount;
  final String _userProfile;
  final String orgStatus;



  @override
  _MyActivityAdminState createState() => _MyActivityAdminState();
}

class _MyActivityAdminState extends State<MyActivityAdmin> {
  @override

  void initState() {
    super.initState();
    _knowNameOfUser();
  }

  Widget _buildUserRequest() {
    if (widget.typeOfUser == "Organization") {
      return ActivityFeedBeneficiaryController(widget.UidUser, widget.nameofUser, widget._userProfile, widget.orgStatus);
    }
    else if (widget.typeOfUser == "Normal User"){
      return ActivityFeedBenefactorController(widget.UidUser, widget.nameofUser, widget.totalConfirmedHelpCount);
    }
    else{
      return ActivityFeedAdminController(widget.UidUser, widget.nameofUser, widget.UidUser);

    }

  }

  final db = Firestore.instance;
  String _userID;

  void _knowNameOfUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    _userID = '${user.uid}';
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2b527f),
      body: _buildUserRequest(),
    );
  }
}


class ActivityFeedBenefactorController extends StatefulWidget {
  ActivityFeedBenefactorController(
      this.UidUser,
      this._nameOfUser,
      this.totalConfirmedHelpCount) : super();

  final String UidUser;
  final String _nameOfUser;
  final int totalConfirmedHelpCount;


  @override
  _ActivityFeedBenefactorControllerState createState() => _ActivityFeedBenefactorControllerState();
}

class _ActivityFeedBenefactorControllerState extends State<ActivityFeedBenefactorController> {
  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        color: Color(0xFF2b527f),
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60.0),
                  child: TabBar(
                    tabs: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Tab(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.running, color: Colors.white, size: 15),
                                SizedBox(
                                  height: _height * 0.01,
                                ),
                                Text(
                                  'Pending',
                                  style: TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Tab(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.inbox, color: Colors.white, size: 15),
                                SizedBox(
                                  height: _height * 0.01,
                                ),
                                Text(
                                  'Confirmed',
                                  style: TextStyle(fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
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
                body: Container(
                  color:   Colors.white,
//                decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                    begin: Alignment.bottomLeft,
//                    end: Alignment.topRight,
//                    stops: [0.2, 0.9],
//                    colors: [
//                      Color(0xFFE5E7EF),
//                      Color(0xFF2b527f),
//                    ],
//                  ),
//                ),
                  child: TabBarView(children: [
//                    ActivityFeedBenefactorNotification(widget.UidUser, widget._nameOfUser),
//                    ActivityFeedBenefactorInterestedList(widget.UidUser, widget._nameOfUser, widget.totalConfirmedHelpCount),
                    ActivityFeedBenefactorPendingList(widget.UidUser, widget._nameOfUser),
                    ActivityFeedBenefactorInterestedList(widget.UidUser, widget._nameOfUser, widget.totalConfirmedHelpCount),
                  ]
                  ),
                )
            )
        ),
      ),
    );
  }
}

class ActivityFeedBenefactorNotification extends StatefulWidget {
  ActivityFeedBenefactorNotification(
      this.UidUser,
      this.nameofUser) : super();

  final String UidUser;
  final String nameofUser;

  @override
  _ActivityFeedBenefactorNotificationState createState() => _ActivityFeedBenefactorNotificationState();
}

class _ActivityFeedBenefactorNotificationState extends State<ActivityFeedBenefactorNotification> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ActivityFeedBenefactorPendingList extends StatefulWidget {
  ActivityFeedBenefactorPendingList(this.UidUser, this._nameOfUser) : super();
  final String UidUser;
  final String _nameOfUser;

  @override
  _ActivityFeedBenefactorPendingListState createState() => _ActivityFeedBenefactorPendingListState();
}

class _ActivityFeedBenefactorPendingListState extends State<ActivityFeedBenefactorPendingList> {
  @override

  final db = Firestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Flushbar flush;

  String _scanBarcode = 'Unknown';

  Future scanBarcodeNormal (dynamic data) async {
    String barcodeScanRes;

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.QR);
    print(barcodeScanRes);

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Container buildItem(DocumentSnapshot doc) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: RichText(
                        text: TextSpan(
                            text: "Status: ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 11
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Pending",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800
                                ),
                              )
                            ]
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "You have confirmed that you will help ",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 13
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: '${doc['Requestors_Name']}. ',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          TextSpan(
                            text: "Please wait ",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: '${doc['Requestors_Name']} ',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          TextSpan(
                            text: "to confirm your help, as soon as they recieved it. Thank you!",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0, top: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: _height * 0.05,
                        child: RaisedButton(
                          child: new Text(
                            'QR Code',
                            style: TextStyle(color: Colors.white, fontSize: 12,
                            ),
                          ),
                          color: Color(0xFF2b527f),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
//                            _viewingRequest(doc.data);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => qrSample(doc.data['Confirmed_ID'], doc.data['Unique_ID'])
                                )
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 10,),
                      Container(
                        height: _height * 0.05,
                        child: RaisedButton(
                          child: new Text(
                            'View donation',
                            style: TextStyle(color: Colors.white, fontSize: 12,
                            ),
                          ),
                          color: Color(0xFF2b527f),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
                            _viewingRequest(doc.data);
                          },
                        ),
                      ),

                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _viewingRequest(dynamic data) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
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
                    Text
                      ("Donation Info", style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800,
                    ),
                    ),
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
                            child: Text(
                              'To:',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${data['Requestors_Name']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'From:',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${data['Respondents_Name']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Description:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${data['Request_Description']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Items given:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${data['Confirmed_Items_To_Give']}'.replaceAll(
                              new RegExp(r'[^\w\s\,]+'), ''),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Designated drop off location:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${data['Request_DropoffLocation']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
//                    Padding(
//                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
//                      child: Container(
//                        height: _height * 0.05,
//                        width: _width * 0.15,
//                        child: RaisedButton(
//                          child: new Text(
//                            'Scan',
//                            style: TextStyle(color: Colors.white, fontSize: 12),
//                          ),
//                          color: Color(0xFF2b527f),
//                          shape: new RoundedRectangleBorder(
//                            borderRadius: new BorderRadius.circular(30.0),
//                          ),
//                          onPressed: () {
//                            scanBarcodeNormal(data);
//                          },
//                        ),
//                      ),
//                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.25,
                        child: RaisedButton(
                          child: new Text(
                            'QR Code',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          color: Color(0xFF2b527f),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
//                              Navigator.of(context).pop();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => qrSample(data['Confirmed_ID'], data['Unique_ID'])
                                )
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.25,
                        child: RaisedButton(
                          child: new Text(
                            'Close',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          color: Color(0xFF2b527f),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  Widget build(BuildContext context) {
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
                            stream: db.collection('CONFIRMED INT BENEFAC').where('Confirmed_ID', isEqualTo: '${widget.UidUser}').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                    children: snapshot.data.documents
                                        .map((doc) => buildItem(doc))
                                        .toList());
                              } else {
                                return Center(child: CircularProgressIndicator());
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

class ActivityFeedBenefactorInterestedList extends StatefulWidget {
  ActivityFeedBenefactorInterestedList(
      this.UidUser,
      this._nameOfUser,
      this.totalConfirmedHelpCount) : super();

  final String UidUser;
  final String _nameOfUser;
  final int totalConfirmedHelpCount;

  @override
  _ActivityFeedBenefactorInterestedListState createState() => _ActivityFeedBenefactorInterestedListState();
}

class _ActivityFeedBenefactorInterestedListState extends State<ActivityFeedBenefactorInterestedList> {
  @override

  final db = Firestore.instance;

  Container buildItem(DocumentSnapshot doc) {


    void _deleteInterested() async {
      try {
        DocumentReference ref = db.collection('CONFIRMED HELP BENEFICIARY').document(doc.data['Unique_ID']);
        return ref.delete();
      } catch (e) {
        print(e);
      }
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
//                Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: <Widget>[
//                    Padding(
//                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
//                      child: RichText(
//                        text: TextSpan(
//                            text: "Status: ",
//                            style: TextStyle(
//                                color: Colors.black,
//                                fontSize: 11
//                            ),
//                            children: <TextSpan>[
//                              TextSpan(
//                                text: "Interested",
//                                style: TextStyle(
//                                    color: Colors.black,
//                                    fontWeight: FontWeight.w800
//                                ),
//                              )
//                            ]
//                        ),
//                      ),
//                    ),
//                    Padding(
//                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
//                      child: RichText(
//                        text: TextSpan(
//                            text: "Disaster: ",
//                            style: TextStyle(
//                                color: Colors.black,
//                                fontSize: 11
//                            ),
//                            children: <TextSpan>[
//                              TextSpan(
//                                text: '${doc['Type_of_Disaster']}'.replaceAll(new RegExp(r'[^\w\s\,]+'),''),
//                                style: TextStyle(
//                                    color: Colors.black,
//                                    fontWeight: FontWeight.w800
//                                ),
//                              )
//                            ]
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "Your donation to ${doc['Recieced_By']} has been recieved and confirmed. ",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 13
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "Thank you for helping and sharing. ",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                          TextSpan(
                            text: "Til next time.",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          )
                        ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        height: _height * 0.05,
                        child: RaisedButton(
                          child: new Text(
                            'Delete',
                            style: TextStyle(color: Colors.white, fontSize: 12,
                            ),
                          ),
                          color: Color(0xFF2b527f),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          onPressed: () {
                            _deleteInterested();
//                            Navigator.push(
//                                context,
//                                MaterialPageRoute(
//                                    builder: (BuildContext context) => ActivityFeedBenefactorConfirmInterested(
//                                        doc.data['Items_you_to_give'],
//                                        doc.data['Unique_ID'],
//                                        doc.data['Interested_ID'],
//                                        widget._nameOfUser,
//                                        doc.data['Requestors_Name'],
//                                        doc.data['Request_Description'],
//                                        doc.data['Request_DropoffLocation'],
//                                        doc.data['Request_ItemsNeeded'],
//                                        doc.data['Type_of_Disaster'],
//                                        widget.totalConfirmedHelpCount,
//                                        doc.data['Requestors_ID'],
//                                        doc.data['Requestors_HelpRequestUniqueID'],
//                                        doc.data['Requestors_RespondentCount']
//                                    )
//                                )
//                            );
                          },
                        ),
                      ),
//                      SizedBox(
//                        width: _width * 0.01,
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.only(right: 8.0),
//                        child: Container(
//                          height: _height * 0.05,
//                          child: OutlineButton(
//                            child: new Text(
//                              'Cancel Help',
//                              style: TextStyle(
//                                color: Colors.black,
//                                fontSize: 12,
//                              ),
//                            ),
//                            borderSide: BorderSide(
//                              color: Color(0xFF2b527f),//Color of the border
//                              style: BorderStyle.solid, //Style of the border
//                              width: 0.8, //width of the border
//                            ),
//                            shape: new RoundedRectangleBorder(
//                              borderRadius: new BorderRadius.circular(30.0),
//                            ),
//                            onPressed: () {
////                              _displayResponse(doc.data);
//                            },
//                          ),
//                        ),
//                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container NoData(DocumentSnapshot doc){
    return Container(
      height: 100,
      width: 100,
      child: Center(child: Card(child: Text("No Data"))),
    );
  }

  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
//        color: Colors.green,
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return Column(
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        StreamBuilder<QuerySnapshot>(
                            stream: db.collection('CONFIRMED HELP BENEFICIARY')
                                .where('Respondents_ID', isEqualTo: '${widget.UidUser}')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                    children: snapshot.data.documents
                                        .map((doc) => NoData(doc))
                                        .toList());
                              }
                              else if (snapshot.hasData == null){
                                return Container(
                                    child: Center(
                                        child: Text("No data")
                                    )
                                );
                              }
                              else {
                                print("No Data");
                                return Container(
                                    child: Text("No data")

//                                    child: Center(
//                                        child: Text("No data")
//                                    )
                                );
                              }
                            }

//                                return Column(
//                                    children: snapshot.data.documents
//                                        .map((doc) => buildItem(doc))
//                                        .toList());


                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

//    void _asyncMethod() {
//      Future.delayed(const Duration(seconds: 5), () {
//        setState(() {
//        });
//      });
//    }

//    return Scaffold(
//      body: Container (
//        child: new LayoutBuilder(
//          builder: (BuildContext context, BoxConstraints viewportConstraints) {
//            return Column(
//              children: <Widget>[
//                SizedBox(
//                  height: MediaQuery.of(context).size.height * 0.020,
//                ),
//                SingleChildScrollView(
//                  scrollDirection: Axis.vertical,
//                  child: Container(
//                    child: Column(
//                      children: <Widget>[
//                        StreamBuilder<QuerySnapshot>(
////                            stream: db.collection('INTERESTED BENEFACTOR').where('Interested_ID', isEqualTo: '${widget.UidUser}').snapshots(),
//                            stream: db.collection('CONFIRMED HELP BENEFICIARY').where('Respondents_ID', isEqualTo: '${widget.UidUser}').snapshots(),
//                            builder: (context, snapshot) {
//                              if (!snapshot.hasData) {
//                                return Column(
//                                    children: snapshot.data.documents
//                                        .map((doc) => buildItem(doc))
//                                        .toList());
//                              }
//                              else  {
//                                return Container(
//                                    color: Colors.red,
//                                    height: 200,
//                                    width: 200,
//                                    child: Text("No Data"));
//
////                                return Stack(
////                                  children: <Widget>[
////                                    Container(
////                                      height: MediaQuery.of(context).size.height * .20,
////                                      child: Text("No confirmed data.", style: TextStyle(color: Colors.black)),
////                                    ),
////                                  ],
////                                );
////                                return Center(
////                                      child: CircularProgressIndicator(
////                                    )
////                                );
////                                return Center(
////                                    child: Container(
////                                      child:
////                                    )
////                                );
//                              }
//                            })
//                      ],
//                    ),
//                  ),
//
////                    child: Column(
////                      children: <Widget>[
////                        StreamBuilder<QuerySnapshot>(
//////                            stream: db.collection('INTERESTED BENEFACTOR').where('Interested_ID', isEqualTo: '${widget.UidUser}').snapshots(),
////                            stream: db.collection('CONFIRMED HELP BENEFICIARY').where('Respondents_ID', isEqualTo: '${widget.UidUser}').snapshots(),
////                            builder: (context, snapshot) {
////                              if (snapshot.hasData) {
////                                return Column(
////                                    children: snapshot.data.documents
////                                        .map((doc) => buildItem(doc))
////                                        .toList());
////                              }
////                              else {
////                                return Container(
////                                  child: Text("No confirmed data.", style: TextStyle(color: Colors.black));
////                                )
//////                                return Stack(
//////                                  children: <Widget>[
//////                                    Container(
//////                                      height: MediaQuery.of(context).size.height * .20,
//////                                      child: Text("No confirmed data.", style: TextStyle(color: Colors.black)),
//////                                    ),
//////                                  ],
//////                                );
//////                                return Center(
//////                                      child: CircularProgressIndicator(
//////                                    )
//////                                );
//////                                return Center(
//////                                    child: Container(
//////                                      child:
//////                                    )
//////                                );
////                              }
////                            })
////                      ],
////                    ),
//                )
//              ],
//            );
//          },
//        ),
//      ),
//    );

  }
}

class ActivityFeedBenefactorConfirmInterested extends StatefulWidget {
  ActivityFeedBenefactorConfirmInterested(
      this._interestedItemsYouWantToGive,
      this._repondentUniqueID,
      this._useruid,
      this._nameOfUser,
      this._requestorsName,
      this._requestDescription,
      this._requestDropoffLocation,
      this._requestThingsNeeded,
      this._typeofDisaster,
      this._totalConfirmedHelpCount,
      this._requestorsID,
      this._requestorsuniqueID,
      this._totalRespondentsHelpCount,

      ) : super();

  final String _interestedItemsYouWantToGive;
  final String _repondentUniqueID;
  final String _useruid;
  final String _nameOfUser;
  final String _requestorsName;
  final String _requestDescription;
  final String _requestDropoffLocation;
  final String _requestThingsNeeded;
  final String _typeofDisaster;
  final String _requestorsID;
  final int _totalConfirmedHelpCount;
  final String _requestorsuniqueID;
  final int _totalRespondentsHelpCount;


  @override
  _ActivityFeedBenefactorConfirmInterestedState createState() => _ActivityFeedBenefactorConfirmInterestedState();

}

class _ActivityFeedBenefactorConfirmInterestedState extends State<ActivityFeedBenefactorConfirmInterested> {

  void initState() {
    super.initState();
    boolValue();
    _loadCurrentUser();
    _knowTypeofUser();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final db = Firestore.instance;
  var time = DateFormat.yMEd().add_jms().format(DateTime.now());


  File pics;
  File _imageFood;
  File _imageClothes;
  File _imageMoney;

  var uuid = Uuid();

  String _helpItems;

  String food = 'Food';
  String money = 'Money';
  String clothes = 'Clothes';

  bool valueFood;
  bool valueMoney;
  bool valueClothes;

  bool _ignoringFood = false;
  bool _ignoringClothes = false;

  Flushbar flush;

  String name;
  String typeOfUser;
  String _typeofFood;
  String _typeofClothes;

  String _uploadedFileURLFood;
  String _uploadedFileURLClothes;
  String _uploadedFileURLMoney;

  String _foodCheckValue;
  String _clothesCheckValue;

  String _amountOfClothes;
  String _amountOfFood;

  int count = 1;

  List<String> checked;

  void _deleteInterested() async {
    try {
      DocumentReference ref = db.collection('INTERESTED BENEFACTOR').document(widget._repondentUniqueID);
      return ref.delete();
    } catch (e) {
      print(e);
    }
  }

  _knowClothesValue(){
    if (_clothesCheckValue == null || _clothesCheckValue == '[]' ){
      setState(() {
        _ignoringClothes = false;
      });
    }
    else if (_clothesCheckValue != null ){
      setState(() {
        _ignoringClothes = true;
      });
    }

  }

  _knowClothesValueState(){
    if (_typeofClothes == null || _typeofClothes == '[]') {
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        title: "Hey, ${_name()}.",
        message: "Please select the type of food you're going to donate.",
        duration: Duration(seconds: 3),
      )
        ..show(context);
    }
  }

  _knowFoodValue(){
    if (_foodCheckValue == null || _foodCheckValue == '[]' ){
      setState(() {
        _ignoringFood = false;
      });
    }
    else if (_foodCheckValue != null ){
      setState(() {
        _ignoringFood = true;
      });
    }

  }

  _knowFoodValueState(){
    if (_typeofFood == null || _typeofFood == '[]') {
      Flushbar(
        margin: EdgeInsets.all(8),
        borderRadius: 8,
        title: "Hey, ${_name()}.",
        message: "Please select the type of food you're going to donate.",
        duration: Duration(seconds: 3),
      )
        ..show(context);
    }
  }

  _saveConfirmedToBenefactor() async {
    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    DocumentReference ref = db.collection('CONFIRMED INT BENEFAC').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': widget._useruid,
            'Confirmed_ItemsToGive': '${_helpItems}',
            'Confirmed_TypeOfClothesToGive': '${_typeofClothes}',
            'Confirmed_TypeOfFoodToGive': '${_typeofFood}',
            'Unique_ID': '${id}',
            'Respondents_Name': widget._nameOfUser,
            'Confirmed_Pieces/BoxesofClothes': '${_amountOfClothes}',
            'Confirmed_Pieces/BoxesofFood': '${_amountOfFood}',
            'Requestors_Name': widget._requestorsName,
            'Request_Description': widget._requestDescription,
            'Request_DropoffLocation': widget._requestDropoffLocation,
            'Confirmed_ConfirmedDate': time,
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': widget._useruid,
            'Confirmed_Items_To_Give': '${_helpItems}',
            'Confirmed_TypeOfClothesToGive': '${_typeofClothes}',
            'Confirmed_TypeOfFoodToGive': '${_typeofFood}',
            'Unique_ID': '${id}',
            'Respondents_Name': widget._nameOfUser,
            'Confirmed_Pieces/BoxesofClothes': '${_amountOfClothes}',
            'Confirmed_Pieces/BoxesofFood': '${_amountOfFood}',
            'Requestors_Name': widget._requestorsName,
            'Request_Description': widget._requestDescription,
            'Request_DropoffLocation': widget._requestDropoffLocation,
            'Confirmed_ConfirmedDate': time,
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
          });
        });
      }
    });
  }

  _saveConfirmedToBeneficiary() async {
    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    DocumentReference ref = db.collection('CONFIRMED INT BENEFIC NOTIF').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': widget._useruid,
            'Confirmed_ItemsToGive': '${_helpItems}',
            'Confirmed_TypeOfClothesToGive': '${_typeofClothes}',
            'Confirmed_TypeOfFoodToGive': '${_typeofFood}',
            'Unique_ID': '${id}',
            'Respondents_Name': widget._nameOfUser,
            'Confirmed_Pieces/BoxesofClothes': '${_amountOfClothes}',
            'Confirmed_Pieces/BoxesofFood': '${_amountOfFood}',
            'Requestors_Name': widget._requestorsName,
            'Request_Description': widget._requestDescription,
            'Request_DropoffLocation': widget._requestDropoffLocation,
            'Confirmed_ConfirmedDate': time,
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': widget._useruid,
            'Confirmed_Items_To_Give': '${_helpItems}',
            'Confirmed_TypeOfClothesToGive': '${_typeofClothes}',
            'Confirmed_TypeOfFoodToGive': '${_typeofFood}',
            'Unique_ID': '${id}',
            'Respondents_Name': widget._nameOfUser,
            'Confirmed_Pieces/BoxesofClothes': '${_amountOfClothes}',
            'Confirmed_Pieces/BoxesofFood': '${_amountOfFood}',
            'Requestors_Name': widget._requestorsName,
            'Request_Description': widget._requestDescription,
            'Request_DropoffLocation': widget._requestDropoffLocation,
            'Confirmed_ConfirmedDate': time,
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
          });
        });
      }
    });
  }

  _saveConfirmedToBeneficiaryNotif() async {
    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    DocumentReference ref = db.collection('BENEFICIARY NOTIFICATION').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': widget._useruid,
            'Confirmed_ItemsToGive': '${_helpItems}',
            'Confirmed_TypeOfClothesToGive': '${_typeofClothes}',
            'Confirmed_TypeOfFoodToGive': '${_typeofFood}',
            'Unique_ID': '${id}',
            'Respondents_Name': widget._nameOfUser,
            'Confirmed_Pieces/BoxesofClothes': '${_amountOfClothes}',
            'Confirmed_Pieces/BoxesofFood': '${_amountOfFood}',
            'Requestors_Name': widget._requestorsName,
            'Request_Description': widget._requestDescription,
            'Request_DropoffLocation': widget._requestDropoffLocation,
            'Confirmed_ConfirmedDate': time,
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': widget._useruid,
            'Confirmed_Items_To_Give': '${_helpItems}',
            'Confirmed_TypeOfClothesToGive': '${_typeofClothes}',
            'Confirmed_TypeOfFoodToGive': '${_typeofFood}',
            'Unique_ID': '${id}',
            'Respondents_Name': widget._nameOfUser,
            'Confirmed_Pieces/BoxesofClothes': '${_amountOfClothes}',
            'Confirmed_Pieces/BoxesofFood': '${_amountOfFood}',
            'Requestors_Name': widget._requestorsName,
            'Request_Description': widget._requestDescription,
            'Request_DropoffLocation': widget._requestDropoffLocation,
            'Confirmed_ConfirmedDate': time,
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
          });
        });
      }
    });
  }

  boolValue() {
    if (_helpItems == null) {
      setState(() {
        valueFood = false;
        valueMoney = false;
        valueClothes = false;
        print('Oy ${_helpItems}');
      });
    }
    else if (_helpItems == '[]') {
      setState(() {
        valueFood = false;
        valueMoney = false;
        valueClothes = false;
        print('hide ${_helpItems}');
      });
    }
    else if (_helpItems == '[Food]' && food == 'Food') {
      setState(() {
        valueFood = true;
        valueClothes = false;
        valueMoney = false;
        print('Oyeee ${_helpItems}');
      });
    }
    else if (_helpItems == '[Clothes]' && clothes == 'Clothes') {
      setState(() {
        valueClothes = true;
        valueFood = false;
        valueMoney = false;
        print('Oyeee ${_helpItems}');
      });
    }
    else if (_helpItems == '[Money]' && money == 'Money') {
      setState(() {
        valueMoney = true;
        valueFood = false;
        valueClothes = false;
        print('Oyeee ${_helpItems}');
      });
    }
    else if (_helpItems == '[Clothes, Food]' || _helpItems == '[Food, Clothes]') {
      setState(() {
        valueClothes = true;
        valueFood = true;
        valueMoney = false;
        print('Oyeee ${_helpItems}');
      });
    }
    else if (_helpItems == '[Money, Food]' || _helpItems == '[Food, Money]') {
      setState(() {
        valueMoney = true;
        valueFood = true;
        valueClothes = false;
        print('Oyeee ${_helpItems}');
      });
    }
    else if (_helpItems == '[Clothes, Money]' || _helpItems == '[Money, Clothes]') {
      setState(() {
        valueMoney = true;
        valueClothes = true;
        valueFood = false;
        print('Oyeee ${_helpItems}');
      });
    }
    else if (_helpItems == '[Food, Clothes, Money]' ||
        _helpItems == '[Food, Money, Clothes]' ||
        _helpItems == '[Clothes, Food, Money]' ||
        _helpItems == '[Clothes, Money, Food]' ||
        _helpItems == '[Money, Food, Clothes]' ||
        _helpItems == '[Money, Clothes, Food]') {
      setState(() {
        valueMoney = true;
        valueClothes = true;
        valueFood = true;
        print('Oyeee ${_helpItems}');
      });
    }
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

  Future getImageFood() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    setState(() {
      _imageFood = image;
    });
  }

  Future getImageClothes() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    setState(() {
      _imageClothes = image;
    });
  }

  Future getImageMoney() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 400);
    setState(() {
      _imageMoney = image;
    });
  }

  uploadAllPictures() async {

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${widget._useruid}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskFood = storageReferenceFood.putFile(_imageFood);
    await uploadTaskFood.onComplete;
    print('File Uploaded');

    storageReferenceFood.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLFood = fileURL;
        print(_uploadedFileURLFood);
      });
    });


    StorageReference storageReferenceClothes = FirebaseStorage.instance
        .ref()
        .child('Clothes/${widget._useruid}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskClothes = storageReferenceClothes.putFile(_imageClothes);
    await uploadTaskClothes.onComplete;
    print('File Uploaded');

    storageReferenceClothes.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLClothes = fileURL;
        print(_uploadedFileURLClothes);
      });
    });

    StorageReference storageReferenceMoney = FirebaseStorage.instance
        .ref()
        .child('Money/${widget._useruid}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskMoney = storageReferenceClothes.putFile(_imageMoney);
    await uploadTaskMoney.onComplete;
    print('File Uploaded');

    storageReferenceClothes.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLMoney = fileURL;
        print(_uploadedFileURLMoney);
      });
    });


  }

  uploadFileFood() async {

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${widget._useruid}/${Path.basename('${id}')}');

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

  uploadFileClothes () async {

    String id = uuid.v1();

    StorageReference storageReferenceClothes = FirebaseStorage.instance
        .ref()
        .child('Clothes/${widget._useruid}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskClothes = storageReferenceClothes.putFile(_imageClothes);
    await uploadTaskClothes.onComplete;
    print('File Uploaded');

    storageReferenceClothes.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLClothes = fileURL;
        print(_uploadedFileURLClothes);
      });
    });

  }

  uploadFileMoney () async {

    String id = uuid.v1();

    StorageReference storageReferenceMoney = FirebaseStorage.instance
        .ref()
        .child('Money/${widget._useruid}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskMoney = storageReferenceMoney.putFile(_imageMoney);
    await uploadTaskMoney.onComplete;
    print('File Uploaded');

    storageReferenceMoney.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLMoney = fileURL;
        print(_uploadedFileURLMoney);
      });
    });

  }

  _saveConfirmedCountToUser() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('USERS').document(user.uid);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Confirmed_Helpcount': widget._totalConfirmedHelpCount + count,
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Confirmed_Helpcount': count,
          });
        });
      }
    });
  }

  _saveConfirmedCountToBeneficiaryRespondents() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('HELP REQUEST').document(widget._requestorsuniqueID);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Confirmed_Helpcount': widget._totalRespondentsHelpCount + count,
            'Respondents_Count': widget._totalRespondentsHelpCount + count,
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Confirmed_Helpcount': count,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      color: Color(0xFFFFFFFF),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: Color(0xFF2b527f),
          title: Text('You want to help'),
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 8.0, left: 8.0, right: 8.0),
                        child: Center(child: Text('Description')),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, bottom: 8.0, left: 8.0, right: 8.0),
                        child: Center(
                            child: Text(
                              widget._requestDescription,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800
                              ),
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text('Things needed'),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget._requestThingsNeeded.replaceAll(
                                    new RegExp(r'[^\w\s\,]+'), ''),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: <Widget>[
                            Text('Drop off location'),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget._requestDropoffLocation,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800),
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 0.20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 8.0, left: 8.0, right: 8.0),
                      child: Center(child: Text('Items that you\'re interested to give.')),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 8.0, left: 8.0, right: 8.0),
                      child: Center(
                          child: Text(
                            widget._interestedItemsYouWantToGive.replaceAll(new RegExp(r'[^\w\s\,]+'), ''),
                          )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, bottom: 8.0, left: 8.0, right: 8.0),
                      child: Center(child: Text('What are the confirmed items that you can give?')),
                    ),
                    CheckboxGroup(
                      orientation: GroupedButtonsOrientation.VERTICAL,
                      labels: <String>[
                        "Food",
                        "Clothes",
                        "Money",
                      ],
                      onSelected: (List<String> checked) {
                        _helpItems = checked.toString();
                        print(_helpItems);
                        boolValue();
                      },
                    ),
                    Visibility(
                      visible: valueFood,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 5,
                          child: Form(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Offstage(
                                      offstage: true,
                                      child: Text(food)
                                  ),
                                  Text('Type of food:'),
                                  IgnorePointer(
                                    ignoring: _ignoringFood,
                                    child: CheckboxGroup(
                                      orientation: GroupedButtonsOrientation
                                          .VERTICAL,
                                      labels: <String>[
                                        "Canned Goods",
                                        "Instant Food",
                                        "Cooked Food",
                                        "Perishable Goods",
                                        "Liquid/Drinks"
                                      ],
                                      onSelected: (List<String> checked) {
                                        _typeofFood = checked.toString();
                                        print(_typeofFood);
                                        boolValue();
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Form(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Details:'),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: _width * .80,
                                              ),
                                              child: TextFormField(
                                                keyboardType: TextInputType.text,
                                                maxLines: 1,
                                                onSaved: (value) => _amountOfFood = value,
                                                validator: (String value) {
                                                  if (value.length < 1)
                                                    return 'How many families are affected field, is empty';
                                                  else
                                                    return null;
                                                },
                                                decoration: InputDecoration(
                                                  icon: Icon(FontAwesomeIcons.pizzaSlice),
                                                  labelText: 'How many pieces/boxes of food:',
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Please upload image for proof.'),
                                  ),
                                  Center(
                                    child: RaisedButton(
                                      child: Text("Choose Image:"),
                                      onPressed: (){
                                        getImageFood();
                                      },
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
                                              child: Text('No image selected.'),
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
                                  Divider(),
                                  CheckboxGroup(
                                    orientation: GroupedButtonsOrientation
                                        .VERTICAL,
                                    labels: <String>[
                                      "Click here, to lock/unlock\n"
                                          "and confirm the choices of your donations.",
                                    ],
                                    labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                    onSelected: (checked) {
                                      _foodCheckValue = checked.toString();
                                      print(_foodCheckValue);

                                      _knowFoodValue();
                                      _knowFoodValueState();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: valueClothes,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 5,
                          child: Form(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Offstage(
                                      offstage: true,
                                      child: Text(clothes)
                                  ),
                                  Text('Type of clothes:'),
                                  IgnorePointer(
                                    ignoring: _ignoringClothes,
                                    child: CheckboxGroup(
                                      orientation: GroupedButtonsOrientation
                                          .VERTICAL,
                                      labels: <String>[
                                        "Upper Apparel",
                                        "Lower Apparel",
                                        "Underware",
                                      ],
                                      onSelected: (List<String> checked) {
                                        _typeofClothes = checked.toString();
                                        print(_typeofClothes);
                                        boolValue();
                                      },
                                    ),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Form(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Details:'),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                maxWidth: _width * .80,
                                              ),
                                              child: TextFormField(
                                                keyboardType: TextInputType.text,
                                                maxLines: 1,
                                                onSaved: (value) => _amountOfClothes = value,
                                                validator: (String value) {
                                                  if (value.length < 1)
                                                    return 'How many families are affected field, is empty';
                                                  else
                                                    return null;
                                                },
                                                decoration: InputDecoration(
                                                  icon: Icon(FontAwesomeIcons.pizzaSlice),
                                                  labelText: 'How many pieces/boxes of clothes:',
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
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Please upload image for proof.'),
                                  ),
                                  Center(
                                    child: RaisedButton(
                                      child: Text("Choose Image:"),
                                      onPressed: (){
                                        getImageClothes();
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                        child: _imageClothes == null
                                            ?
                                        Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text('No image selected.'),
                                            )
                                        )
                                            :
                                        Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Image.file(_imageClothes),
                                            )
                                        )

                                    ),
                                  ),
                                  Divider(),
                                  CheckboxGroup(
                                    orientation: GroupedButtonsOrientation
                                        .VERTICAL,
                                    labels: <String>[
                                      "Click here, to lock/unlock\n"
                                          "and confirm the choices of your donations.",
                                    ],
                                    labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                    onSelected: (checked) {
                                      _clothesCheckValue = checked.toString();
                                      print(_clothesCheckValue);

                                      _knowClothesValue();
                                      _knowClothesValueState();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: valueMoney,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                          child: Card(
                            elevation: 5,
                            child: Form(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Offstage(
                                        offstage: true,
                                        child: Text(money)
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Below is the designated Account, where you can deposit your donation:"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: <Widget>[
                                          Text("Account Name:"),
                                          Text("Account Number:")
                                        ],
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Please upload image for proof.'),
                                    ),
                                    Center(
                                      child: RaisedButton(
                                        child: Text("Choose Image:"),
                                        onPressed: (){
                                          getImageMoney();
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          child: _imageMoney == null
                                              ?
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Text('No image selected.'),
                                              )
                                          )
                                              :
                                          Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Image.file(_imageMoney),
                                              )
                                          )
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10, top: 10),
                          child: Container(
                              height: _height * 0.05,
                              width: _width * 0.30,
                              child: ProgressButton(
                                  defaultWidget: const Text('Confirm help',
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
                                            Colors.white
                                        )
                                    ),
                                  ),
                                  width: _width * 0.30,
                                  height: 40,
                                  borderRadius: 20.0,
                                  color: Color(0xFF2b527f),
                                  onPressed: () async {

                                    if (_helpItems == '[Food]' && _imageFood == null && _foodCheckValue == null){
                                      print('Please select image and lock food donation');
                                    }
                                    else if (_helpItems == '[Food]' && _imageFood == null && _foodCheckValue == '[]'){
                                      print('Please select image and lock food donation.');
                                    }
                                    else if (_helpItems == '[Food]' && _imageFood != null && _foodCheckValue == '[]'){
                                      print('Please lock food donation.');
                                    }
                                    else if (_helpItems == '[Food]' && _imageFood == null && _foodCheckValue != '[]'){
                                      print('Please select food image');
                                    }
                                    else if (_helpItems == '[Food]' && _imageFood != null && _foodCheckValue == null){
                                      print('Please lock food donationss.');
                                    }
                                    else if (_helpItems == '[Food]' && _imageFood != null && _foodCheckValue != null){
                                      uploadFileFood();
                                    }

                                    else if (_helpItems == '[Clothes]' && _imageClothes == null && _clothesCheckValue == null){
                                      print('Please select image and lock clothes donation');
                                    }
                                    else if (_helpItems == '[Clothes]' && _imageClothes == null && _clothesCheckValue == '[]'){
                                      print('Please select image and lock clothes donation');
                                    }
                                    else if (_helpItems == '[Clothes]' && _imageClothes != null && _clothesCheckValue == '[]'){
                                      print('Please lock clothes donation.');
                                    }
                                    else if (_helpItems == '[Clothes]' && _imageClothes == null && _clothesCheckValue != '[]'){
                                      print('Please select clothew image');
                                    }
                                    else if (_helpItems == '[Clothes]' && _imageClothes != null && _clothesCheckValue == null){
                                      print('Please lock clothes donation');
                                    }
                                    else if (_helpItems == '[Clothes]' && _imageClothes != null && _clothesCheckValue != null){
                                      uploadFileClothes();
                                    }

                                    else if (_helpItems == '[Money]' && _imageMoney != null){
                                      uploadFileMoney();
                                    }

                                    else if (_helpItems == '[Food, Clothes]' && _imageFood == null && _foodCheckValue != null){
                                      print('Please select food image');
                                    }
                                    else if (_helpItems == '[Food, Clothes]' && _imageFood != null && _foodCheckValue == '[]'){
                                      print('Please lock food donationssss.');
                                    }
                                    else if (_helpItems == '[Food, Clothes]' && _imageClothes == null && _clothesCheckValue != null){
                                      print('Please select clothes image');
                                    }
                                    else if (_helpItems == '[Food, Clothes]' && _imageClothes != null && _clothesCheckValue == '[]'){
                                      print('Please lock clothes donation.');
                                    }

                                    else if (_helpItems == '[Food, Clothes]' && _foodCheckValue == '[]' && _clothesCheckValue == '[]'){
                                      print('Please lock food and clothes donation.');
                                    }
                                    else if (_helpItems == '[Food, Clothes]' && _foodCheckValue == null && _clothesCheckValue == null){
                                      print('Please lock food and clothes donation.');
                                    }
                                    else if (_helpItems == '[Food, Clothes]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                    }

                                    else if (_helpItems == '[Clothes, Food]' && _imageFood == null && _foodCheckValue != null){
                                      print('Please select food image');
                                    }
                                    else if (_helpItems == '[Clothes, Food]' && _imageFood != null && _foodCheckValue == '[]'){
                                      print('Please lock food donationssss.');
                                    }
                                    else if (_helpItems == '[Clothes, Food]' && _imageClothes == null && _clothesCheckValue != null){
                                      print('Please select clothes image');
                                    }
                                    else if (_helpItems == '[Clothes, Food]' && _imageClothes != null && _clothesCheckValue == '[]'){
                                      print('Please lock clothes donation.');
                                    }

                                    else if (_helpItems == '[Clothes, Food]' && _foodCheckValue == '[]' && _clothesCheckValue == '[]'){
                                      print('Please lock food and clothes donation.');
                                    }
                                    else if (_helpItems == '[Clothes, Food]' && _foodCheckValue == null && _clothesCheckValue == null){
                                      print('Please lock food and clothes donation.');
                                    }
                                    else if (_helpItems == '[Clothes, Food]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                    }

                                    else if (_helpItems == '[Food, Money]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileMoney();
                                    }
                                    else if (_helpItems == '[Money, Food]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileMoney();
                                    }

                                    else if (_helpItems == '[Clothes, Money]' && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileClothes();
                                      uploadFileMoney();
                                    }
                                    else if (_helpItems == '[Money, Clothes]' && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileClothes();
                                      uploadFileMoney();
                                    }

                                    else if (_helpItems == '[Food, Clothes, Money]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                      uploadFileMoney();
                                    }
                                    else if (_helpItems == '[Food, Money, Clothes]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                      uploadFileMoney();
                                    }
                                    else if (_helpItems == '[Clothes, Food, Money]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                      uploadFileMoney();

                                    }
                                    else if (_helpItems == '[Clothes, Money, Food]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                      uploadFileMoney();
                                    }
                                    else if (_helpItems == '[Money, Clothes, Food]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                      uploadFileMoney();
                                    }
                                    else if (_helpItems == '[Money, Food, Clothes]' && _imageFood != null && _foodCheckValue != '[]' && _foodCheckValue != null && _imageClothes != null && _clothesCheckValue != '[]' && _clothesCheckValue != null && _imageMoney != null){
                                      uploadFileFood();
                                      uploadFileClothes();
                                      uploadFileMoney();
                                    }

                                    int score = await Future.delayed(
                                        const Duration(milliseconds: 11000), () => 42);
                                    return () {

                                      if (_helpItems == null) {
                                        print(_name());
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the following items you can give: Clothes, Food or Money.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the following items you can give: Clothes, Food or Money.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes]' && _typeofClothes == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes]' && _typeofClothes == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food]' && _typeofClothes == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money]' && _typeofClothes == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes]' && _typeofClothes == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofClothes == null && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofClothes == '[]' && _typeofFood == '[]') {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes and type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofClothes == '[]' && _typeofFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofFood == '[]' && _typeofClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of food you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select the type of clothes you're going to donate.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      // Images --------------------------------------------------------------------------------------

                                      else if (_helpItems == '[Food]' && _imageFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a pictute to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes]' && _imageClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a pictute to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money]' && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a pictute to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _imageFood == null && _imageClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of food and clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money]' && _imageFood == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of food and money to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _imageFood == null && _imageClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of food and clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money]' && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of money and clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food]' && _imageMoney == null && _imageFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of money and food to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes]' && _imageMoney == null && _imageClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of money and clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _imageFood != null && _imageClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes]' && _imageFood == null && _imageClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of food to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money]' && _imageFood != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of receipt to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money]' && _imageFood == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of food to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _imageFood == null && _imageClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of food to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food]' && _imageFood != null && _imageClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money]' && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money]' && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of receipt to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food]' && _imageMoney == null && _imageFood != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of receipt to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food]' && _imageMoney != null && _imageFood == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes]' && _imageMoney == null && _imageClothes != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload a picture of receipt to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes]' && _imageMoney != null && _imageClothes == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please select a picture of clothes to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _imageFood == null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _imageFood == null && _imageClothes != null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes, Money]' && _imageFood != null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes, Money]' && _imageFood != null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _imageFood != null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes, Money]' && _imageFood == null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Clothes, Money]' && _imageFood == null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money, Clothes]' && _imageFood == null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money, Clothes]' && _imageFood == null && _imageClothes != null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _imageFood != null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _imageFood != null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money, Clothes]' && _imageFood != null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _imageFood == null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Food, Money, Clothes]' && _imageFood == null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food, Money]' && _imageFood == null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food, Money]' && _imageFood == null && _imageClothes != null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _imageFood != null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _imageFood != null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food, Money]' && _imageFood != null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _imageFood == null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Food, Money]' && _imageFood == null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money, Food]' && _imageFood == null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money, Food]' && _imageFood == null && _imageClothes != null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _imageFood != null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _imageFood != null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money, Food]' && _imageFood != null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _imageFood == null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Clothes, Money, Food]' && _imageFood == null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food, Clothes]' && _imageFood == null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food, Clothes]' && _imageFood == null && _imageClothes != null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _imageFood != null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _imageFood != null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food, Clothes]' && _imageFood != null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _imageFood == null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Food, Clothes]' && _imageFood == null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes, Food]' && _imageFood == null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes, Food]' && _imageFood == null && _imageClothes != null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _imageFood != null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _imageFood != null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes, Food]' && _imageFood != null && _imageClothes == null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _imageFood == null && _imageClothes != null && _imageMoney == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }
                                      else if (_helpItems == '[Money, Clothes, Food]' && _imageFood == null && _imageClothes == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please upload pictures of your confirmed items, to prove your donation",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food]' && _typeofFood != null && _foodCheckValue == '[]'
                                          || _helpItems == '[Food]' && _typeofFood != null && _foodCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money]' && _typeofFood != null && _foodCheckValue == '[]' && _imageMoney != null
                                          || _helpItems == '[Food, Money]' && _typeofFood != null && _foodCheckValue == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _imageMoney != null
                                          || _helpItems == '[Money, Food]' && _typeofFood != null && _foodCheckValue == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money]' && _typeofClothes != null && _clothesCheckValue == '[]' && _imageMoney != null
                                          || _helpItems == '[Clothes, Money]' && _typeofClothes != null && _clothesCheckValue == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes]' && _typeofClothes != null && _clothesCheckValue == '[]' && _imageMoney != null
                                          || _helpItems == '[Money, Clothes]' && _typeofClothes != null && _clothesCheckValue == null && _imageMoney != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Clothes, Money]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Food, Money, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Food, Money]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Clothes, Money, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Money, Clothes, Food]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue == null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your food and clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == null
                                          || _helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue == null && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else if (_helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue != null && _typeofClothes != null && _clothesCheckValue == '[]'
                                          || _helpItems == '[Money, Food, Clothes]' && _typeofFood != null && _foodCheckValue == '[]' && _typeofClothes != null && _clothesCheckValue != null) {
                                        Flushbar(
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Hey, ${_name()}.",
                                          message: "Please lock your clothes donation.",
                                          duration: Duration(seconds: 3),
                                        )
                                          ..show(context);
                                      }

                                      else {
                                        _saveConfirmedToBenefactor();
                                        _saveConfirmedToBeneficiary();
                                        _saveConfirmedToBeneficiaryNotif();
                                        _saveConfirmedCountToUser();
                                        _saveConfirmedCountToBeneficiaryRespondents();
                                        flush = Flushbar<bool>(
                                          isDismissible: false,
                                          routeBlur: 50,
                                          routeColor: Colors.white.withOpacity(0.50),
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Thank you, ${_name()}.",
                                          message: "Your response is a big help for , You have chosen to donate ${_helpItems}",
                                          mainButton: FlatButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              flush.dismiss(true);
                                              _deleteInterested();
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
                                      }
                                    };
                                  }
                              )
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class qrSample extends StatefulWidget {

  qrSample(
      this.confirmedID,
      this.uniqueId
      ) : super();

  final String confirmedID;
  final String uniqueId;

  @override
  _qrSampleState createState() => _qrSampleState();
}

class _qrSampleState extends State<qrSample> {
  @override

  void initState() {
    super.initState();

    print(widget.uniqueId);
  }


  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: new AppBar(
            backgroundColor: Color(0xFF2b527f),
            title: new Text('QR code')
        ),
        body: Container(
          color: Colors.white,
          child: Center(
            child: QrImage(
              data: widget.uniqueId,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ),
      ),
    );
  }
}



class ActivityFeedBeneficiaryController extends StatefulWidget {
  ActivityFeedBeneficiaryController(
      this.UidUser,
      this.nameofUser,
      this._userProfile,
      this.orgStatus) : super();

  final String UidUser;
  final String nameofUser;
  final String _userProfile;
  final String orgStatus;

  @override
  _ActivityFeedBeneficiaryControllerState createState() => _ActivityFeedBeneficiaryControllerState();
}

class _ActivityFeedBeneficiaryControllerState extends State<ActivityFeedBeneficiaryController> {

  @override

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        color: Color(0xFF2b527f),
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60.0),
                  child: TabBar(
                    tabs: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Tab(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.running, color: Colors.white, size: 15),
                                SizedBox(
                                  height: _height * 0.01,
                                ),
                                Text(
                                    'Pending',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Tab(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.inbox, color: Colors.white, size: 15),
                                SizedBox(
//                                  width: _width * 0.05,
                                  height: _height * 0.01,

                                ),
                                Text(
                                    'Confirmed',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                body: Container(
                  color: Colors.white,
//                decoration: BoxDecoration(
//                  gradient: LinearGradient(
//                    begin: Alignment.bottomLeft,
//                    end: Alignment.topRight,
//                    stops: [0.2, 0.9],
//                    colors: [
//                      Color(0xFFE5E7EF),
//                      Color(0xFF2b527f),
//                    ],
//                  ),
//                ),
                  child: TabBarView(
                      children: [
//                        ActivityFeedBeneficiaryNotification(widget.UidUser, widget.nameofUser),
                        ActivityFeedBeneficiaryMyRequest(widget.UidUser, widget.nameofUser, widget._userProfile, widget.orgStatus),
                        ConfirmDonationFeedBeneficiary(widget.UidUser, widget.nameofUser),
                      ]
                  ),
                )
            )
        ),
      ),
    );
  }
}

class ActivityFeedBeneficiaryNotification extends StatefulWidget {
  ActivityFeedBeneficiaryNotification(
      this.UidUser,
      this.nameofUser) : super();

  final String UidUser;
  final String nameofUser;

  @override
  _ActivityFeedBeneficiaryNotificationState createState() => _ActivityFeedBeneficiaryNotificationState();
}

class _ActivityFeedBeneficiaryNotificationState extends State<ActivityFeedBeneficiaryNotification> {
  @override


  final db = Firestore.instance;
  String _userID;
  String _stateValue;

  String statusAddText;
  String statusAddTextII;
  String status;
  String nameOfUser;
  String uniqueID;
  String date;

  bool Interested;
  bool Confirmed;


  Container buildItem(DocumentSnapshot doc) {

    uniqueID = doc.data['Unique_ID'];

    void _deleteNotification() async {

      try {
        DocumentReference ref = db.collection('BENEFICIARY NOTIFICATION').document(uniqueID);
        return ref.delete();
      } catch (e) {
        print(e);
      }
    }

    _stateValue = doc['Response_State'];

    if(_stateValue == 'Interested'){
      status = "Interested";
      statusAddText = "is interested to help. ";
      statusAddTextII = "Please wait for ${doc['Respondents_Name']} to confirm its help.";
      Confirmed = false;
      Interested = true;
      date = doc['Request_InterestedDate'];
    }
    else{
      status = "Confirmed";
      statusAddText = "has confirmed his help. ";
      statusAddTextII = "Please check \"To Confirm\" tab to confirm the donation.";
      Confirmed = true;
      Interested = true;
      date = doc['Confirmed_ConfirmedDate'];
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: RichText(
                        text: TextSpan(
                            text: "Status: ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 11
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "${status}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800
                                ),
                              )
                            ]
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 5, top: 8.0),
                      child: GestureDetector(
                        onTap: () async {
                          setState(() {
                            _deleteNotification();
                          });
                        },
                        child: InkWell(
                            child: Icon(
                              FontAwesomeIcons.times,
                              size: 15,
                            )
                        ),
                      ),
                    ),

                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text:  TextSpan(
                        text: '${doc['Respondents_Name']}, ',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: statusAddText,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal
                              )
                          ),
                          TextSpan(
                              text: statusAddTextII,
                              style: TextStyle(
                                  fontWeight: FontWeight.normal
                              )
                          ),
                        ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(date,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      Text('-DARE TEAM',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w800
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
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
                            stream: db.collection('BENEFICIARY NOTIFICATION').where('Requestors_ID', isEqualTo: '${widget.UidUser}').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                    children: snapshot.data.documents
                                        .map((doc) => buildItem(doc))
                                        .toList());
                              } else {
                                return Center(child: CircularProgressIndicator());
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

class ActivityFeedBeneficiaryMyRequest extends StatefulWidget {
  ActivityFeedBeneficiaryMyRequest(
      this.UidUser,
      this.nameofUser,
      this._userProfile,
      this.orgStatus) : super();

  final String UidUser;
  final String nameofUser;
  final String _userProfile;
  final String orgStatus;


  @override
  _ActivityFeedBeneficiaryMyRequestState createState() => _ActivityFeedBeneficiaryMyRequestState();
}

class _ActivityFeedBeneficiaryMyRequestState extends State<ActivityFeedBeneficiaryMyRequest> {

  @override

  void initState() {
    super.initState();
    _knowNameOfUser();
  }

  final db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _userID;

  bool visibleCancel = true;

  AssetImage imageType;

  void _showVerifyEmail() {
    showAlert(
      context: context,
      title: "Warning!",
      body: "Please verify email first to donate",
      actions: [
        AlertAction(
            text: "Send Verification Code",
            onPressed: (){
              _sendEmailVerification();
            }
        ),
      ],
      cancelable: true,
    );
  }

  void _sendEmailVerification () async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    await user.sendEmailVerification();
  }

  _deleteInterested(dynamic data) async {
    try {
      DocumentReference ref = db.collection('HELP REQUEST').document(data['Unique_ID']);
      return ref.delete();
    } catch (e) {
      print(e);
    }
  }

  void _knowNameOfUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    _userID = '${user.uid}';
  }

  _displayResponse (dynamic data) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25, bottom: 5),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                        child: Text("Warning!",
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
            content: Text(
              'Are you sure you have rearched your goal?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
                      child: ProgressButton(
                          defaultWidget: const Text('Yes',
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
                                    Colors.white
                                )
                            ),
                          ),
                          width: _width * 0.25,
                          borderRadius: 20.0,
                          color: Color(0xFF2b527f),
                          onPressed: () async {
                            visibleCancel = false;
                            await Future.delayed(
                                const Duration(milliseconds: 2000), () => 42);
                            return () {
                              _deleteInterested(data);
                              Navigator.pop(context);
                            };
                          }
                      ),
                    ),
                    SizedBox(
                      width: _width * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.20,
                        child: RaisedButton(
                          child: new Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                          color: Color(0xFFFFFFFF),
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
                ),
              )
            ],
          );
        });
  }


  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    if (doc['Type_OfDisaster'] == '[Drought]'){
      imageType = AssetImage('assets/Drought.jpg');
    }
    else if (doc['Type_OfDisaster'] == '[Earthquake]'){
      imageType = AssetImage('assets/Earthquake.jpg');
    }
    else if (doc['Type_OfDisaster'] == '[Flood]'){
      imageType = AssetImage('assets/Flood.jpg');
    }
    else if (doc['Type_OfDisaster'] == '[Landslide]'){
      imageType = AssetImage('assets/Landslide.jpg');
    }
    else if (doc['Type_OfDisaster'] == '[Tsunami]'){
      imageType = AssetImage('assets/Tsunami.jpg');
    }
    else if (doc['Type_OfDisaster'] == '[Typhoon]'){
      imageType = AssetImage('assets/Typhoon.jpg');
    }
    else if (doc['Type_OfDisaster'] == "null") {
      imageType = AssetImage('assets/no-image.png');
    }

    Widget picture(){
      if (doc.data['Profile_Picture'] == null){
        return CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(doc.data['Profile_Picture']),
        );
      }
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Card(
          elevation: 5,
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.circular(5),
//        ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        picture(),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Text(
                                  '${doc.data['Name_ofUser']}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(Dformat.format(doc.data['Help_DatePosted'].toDate()),
                                  style: TextStyle(
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800
                                  ),
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: imageType,
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {

                              });
                            },
                            child: Text(
                              '${doc.data['Help_Description']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
//                Padding(
//                  padding: const EdgeInsets.only(top: 8.0),
//                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    children: <Widget>[
//                      Padding(
//                        padding: const EdgeInsets.only(bottom: 10),
//                        child: Container(
//                          height: _height * 0.04,
//                          width: _width * 0.25,
//                          child: FlatButton(
//                            shape: RoundedRectangleBorder(
//                                borderRadius:
//                                BorderRadius.all(Radius.circular(20.0))),
//                            color: Color(0xFF3F6492),
//                            onPressed: ()  {
////                              _displayResponse(doc.data);
//                            },
//                            child: Text(
//                              'OPEN',
//                              style: TextStyle(
//                                  color: Colors.white,
//                                  fontSize: 12,
//                                  fontWeight: FontWeight.w800),
//                            ),
//                          ),
//                        ),
//                      )
//                    ],
//                  ),
//                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  StreamBuilder<QuerySnapshot>(
//                      stream: db.collection('HELP REQUEST').where('User_ID', isEqualTo: widget.UidUser).orderBy('Help_DatePosted', descending: true).snapshots(),
                      stream: db.collection('HELP REQUEST').where('User_ID', isEqualTo: widget.UidUser).snapshots(),

                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                              children: snapshot.data.documents
                                  .map((doc) => InkWell(
                                  onDoubleTap: (){

                                  },
                                  onTap: (){
                                    setState(() {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) => viewMyRequest(
                                                widget.nameofUser,
                                                widget._userProfile,
                                                doc['Help_Description'],
                                                doc['Help_DatePosted'],
                                                doc['Help_FamiliesAffected'],
                                                doc['Help_AreaAffected'],
                                                doc['Help_ThingsNeeded'],
                                                doc['Help_DropoffLocation'],
                                                doc['Help_Inquiry'],
                                                doc['Respondents_Count'],
                                                doc['Type_OfDisaster'],
                                                doc['Profile_Picture'],
                                                doc['Unique_ID'],
                                              )
                                          )
                                      );
                                    });

//                                    Navigator.push(
//                                      context,
//                                      MaterialPageRoute(
//                                          builder: (BuildContext context) => viewMyRequest(
//                                            widget.nameofUser,
//                                            widget._userProfile,
//                                            doc['Help_Description'],
//                                            doc['Help_DatePosted'],
//                                            doc['Help_FamiliesAffected'],
//                                            doc['Help_AreaAffected'],
//                                            doc['Help_ThingsNeeded'],
//                                            doc['Help_DropoffLocation'],
//                                            doc['Help_Inquiry'],
//                                            doc['Respondents_Count'],
//                                            doc['Type_OfDisaster'],
//                                            doc['Profile_Picture'],
//                                            doc['Unique_ID'],
//                                          )
//                                      )
//                                   );
                                  },
                                  child: buildItem(doc)
                              )
                              )
                                  .toList());
                        }
                        else {
                          return Container(
                              child: Center(
                                  child: CircularProgressIndicator()
                              )
                          );
                        }
                      })
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Container(
          height: _height * 0.05,
          width: _width * 0.34,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
              final FirebaseUser user = await _firebaseAuth.currentUser();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => _RequestBeneficiary(widget.nameofUser, widget._userProfile, widget.orgStatus)
                  )
              );
            },
            elevation: 4.0,
            label: const Text(
              'Request for help',
              style: TextStyle(fontSize: 11),
            ),
            backgroundColor: Color(0xFF121A21),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class viewMyRequest extends StatefulWidget {
  viewMyRequest(
      this.nameofUser,
      this.userProfile,
      this._PostDestription,
      this._PostDatePosted,
      this._PostFamiliesAffected,
      this._PostAffectedArea,
      this._PostThingsNeeded,
      this._PostDropoffLocation,
      this._PostContactDetails,
      this._PostRespondents,
      this._typeofDisaster,
      this._Profpic,
      this._uniqueID) : super();

  final String nameofUser;
  final String userProfile;
  final String _PostDestription;
  final Timestamp _PostDatePosted ;
  final String _PostFamiliesAffected;
  final String _PostAffectedArea;
  final String _PostThingsNeeded;
  final String _PostDropoffLocation;
  final String _PostContactDetails;
  final int _PostRespondents;
  final String _typeofDisaster;
  final String _Profpic;
  final String _uniqueID;

  @override
  _viewMyRequestState createState() => _viewMyRequestState();
}

class _viewMyRequestState extends State<viewMyRequest> {

  void initState() {
    super.initState();
  }

  DateTime parseTime(dynamic date) {
    return Platform.isIOS ? (date as Timestamp).toDate() : (date as DateTime);
  }

  String _requestorsID;
  String typeOfUser;
  String _uploadedFileURLNews;

  bool orgstat = false;
  var uuid = Uuid();
  File _imageNews;

  final _formkeyResponse = GlobalKey<FormState>();
  final _formkeyName = GlobalKey<FormState>();

  bool _autoValidate = false;
  Flushbar flush;

  AssetImage imageType;

  final db = Firestore.instance;
  String _NewsDescription;
  String _NewsTitle;

  String _helpItems;
  String _postDescription;
  String _postFamAffected;
  String _postAreaBarangay;
  String _postThingsNeeded;
  String _postDropoffLocation;
  String _postInquiries;


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  Future getImageNews() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 300);
    setState(() {
      _imageNews = image;
    });
  }

  uploadFileNewsImage() async {

    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('News/${user.uid}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskFood = storageReferenceFood.putFile(_imageNews);
    await uploadTaskFood.onComplete;
    print('File Uploaded');

    storageReferenceFood.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLNews = fileURL;
        print(_uploadedFileURLNews);
      });
    });

  }

  saveNews() async {

    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final newsPost = _formkeyResponse.currentState;
    newsPost.save();

    DocumentReference ref = db.collection('BRGY NEWS').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({
            'User_ID': user.uid,
            'Unique_ID': id,
            'News_Title': _NewsTitle,
            'News_Description': _NewsDescription,
            'News_Timeposted': Timestamp.now(),
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile,
            'News_Image': _uploadedFileURLNews,
          });
        });
      } else {
        setState(() async {
          await ref
              .setData({
            'User_ID': user.uid,
            'Unique_ID': id,
            'News_Title': _NewsTitle,
            'News_Description': _NewsDescription,
            'News_Timeposted': Timestamp.now(),
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile,
            'News_Image': _uploadedFileURLNews,
          });
        });
      }
    });
  }

  _deleteHelpRequest() async {
    try {
      DocumentReference ref = db.collection('HELP REQUEST').document(widget._uniqueID);
      return ref.delete();
    } catch (e) {
      print(e);
    }
  }

  _deleteSpecificRequest () async {
    try {
      DocumentReference refII = db.collection('DROUGHT REQUESTS').document(widget._uniqueID);
      return refII.delete();
    } catch (e) {
      print(e);
    }
  }

  _displayResponse () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25, bottom: 5),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                        child: Text("Warning!",
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
            content: Text(
              'Are you sure you have rearched your goal?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
                      child: ProgressButton(
                          defaultWidget: const Text('Yes',
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
                                    Colors.white
                                )
                            ),
                          ),
                          width: _width * 0.25,
                          borderRadius: 20.0,
                          color: Color(0xFF2b527f),
                          onPressed: () async {
//                            visibleCancel = false;
                            await Future.delayed(
                                const Duration(seconds: 3), () => 42);
                            return () {
                              _deleteHelpRequest();
                              _deleteSpecificRequest();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            };
                          }
                      ),
                    ),
                    SizedBox(
                      width: _width * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.20,
                        child: RaisedButton(
                          child: new Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                          color: Color(0xFFFFFFFF),
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
                ),
              )
            ],
          );
        });
  }

  _updatePost(
      String postDescription,
      String postFamAffected,
      String postAreaBarangay,
      String postThingsNeeded,
      String postDropoffLocation,
      String postInquiries) async {
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
                            child: Text("Edit Post",
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
              height: _height * 0.50,
              width: _width * 0.80,
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
                                initialValue: "${postDescription}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _postDescription = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Post Description:',
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
                                initialValue: "${postFamAffected}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _postFamAffected = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Families Affected:',
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
                                initialValue: "${postAreaBarangay}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _postAreaBarangay = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Area / Barangay:',
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
                                initialValue: "${postThingsNeeded}".replaceAll(new RegExp(r'[^\w\s\,]+'),''),
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _postThingsNeeded = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Things we need:',
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
                                initialValue: "${postDropoffLocation}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _postDropoffLocation = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Drop off location:',
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
                                initialValue: "${postInquiries}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _postInquiries = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'For Inquiries:',
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
                            saveUpdatePost();
                            await Future.delayed(
                                const Duration(seconds: 5), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()){
                                setState(() {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
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

  saveUpdatePost() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    if(widget._typeofDisaster == '[Drought]'){

      final nameKey = _formkeyName.currentState;
      nameKey.save();

      DocumentReference ref = db.collection('DROUGHT REQUESTS').document(widget._uniqueID);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            await ref
                .updateData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
        else {
          setState(() async {
            await ref
                .setData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
      });

    }
    else if (widget._typeofDisaster  == '[Earthquake]'){

      final nameKey = _formkeyName.currentState;
      nameKey.save();

      DocumentReference ref = db.collection('EARTHQUAKE REQUESTS').document(widget._uniqueID);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            await ref
                .updateData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
        else {
          setState(() async {
            await ref
                .setData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
      });
    }
    else if (widget._typeofDisaster  == '[Flood]'){

      final nameKey = _formkeyName.currentState;
      nameKey.save();

      DocumentReference ref = db.collection('FLOOD REQUESTS').document(widget._uniqueID);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            await ref
                .updateData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
        else {
          setState(() async {
            await ref
                .setData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
      });
    }
    else if (widget._typeofDisaster  == '[Landslide]'){

      final nameKey = _formkeyName.currentState;
      nameKey.save();

      DocumentReference ref = db.collection('LANDSLIDE REQUESTS').document(widget._uniqueID);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            await ref
                .updateData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
        else {
          setState(() async {
            await ref
                .setData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
      });

    }
    else if (widget._typeofDisaster  == '[Tsunami]'){

      final nameKey = _formkeyName.currentState;
      nameKey.save();

      DocumentReference ref = db.collection('TSUNAMI REQUESTS').document(widget._uniqueID);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            await ref
                .updateData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
        else {
          setState(() async {
            await ref
                .setData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
      });

    }
    else if (widget._typeofDisaster  == '[Typhoon]'){

      final nameKey = _formkeyName.currentState;
      nameKey.save();

      DocumentReference ref = db.collection('TYPHOON REQUESTS').document(widget._uniqueID);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            await ref
                .updateData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
        else {
          setState(() async {
            await ref
                .setData({
              'Help_Description': _postDescription,
              'Help_FamiliesAffected': _postFamAffected,
              'Help_AreaAffected': _postAreaBarangay,
              'Help_ThingsNeeded': _postThingsNeeded,
              'Help_DropoffLocation': _postDropoffLocation,
              'Help_Inquiry': _postInquiries});
            user.reload();
          });
        }
      });
    }

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('HELP REQUEST').document(widget._uniqueID);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({
            'Help_Description': _postDescription,
            'Help_FamiliesAffected': _postFamAffected,
            'Help_AreaAffected': _postAreaBarangay,
            'Help_ThingsNeeded': _postThingsNeeded,
            'Help_DropoffLocation': _postDropoffLocation,
            'Help_Inquiry': _postInquiries});
          user.reload();
        });
      }
      else {
        setState(() async {
          await ref
              .setData({
            'Help_Description': _postDescription,
            'Help_FamiliesAffected': _postFamAffected,
            'Help_AreaAffected': _postAreaBarangay,
            'Help_ThingsNeeded': _postThingsNeeded,
            'Help_DropoffLocation': _postDropoffLocation,
            'Help_Inquiry': _postInquiries});
          user.reload();
        });
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    if (widget._typeofDisaster == '[Drought]'){
      imageType = AssetImage('assets/Drought.jpg');
    }
    else if (widget._typeofDisaster == '[Earthquake]'){
      imageType = AssetImage('assets/Earthquake.jpg');
    }
    else if (widget._typeofDisaster == '[Flood]'){
      imageType = AssetImage('assets/Flood.jpg');
    }
    else if (widget._typeofDisaster == '[Landslide]'){
      imageType = AssetImage('assets/Landslide.jpg');
    }
    else if (widget._typeofDisaster == '[Tsunami]'){
      imageType = AssetImage('assets/Tsunami.jpg');
    }
    else if (widget._typeofDisaster == '[Typhoon]'){
      imageType = AssetImage('assets/Typhoon.jpg');
    }
    else if (widget._typeofDisaster == "null") {
      imageType = AssetImage('assets/no-image.png');
    }

    Widget picture(){
      if (widget._Profpic == null){
        return CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(widget._Profpic),
        );
      }
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      child: Scaffold (
        appBar: new AppBar(
          backgroundColor: Color(0xFF2b527f),
          actions: <Widget>[
//            new IconButton(
//                icon: new Icon(
//                    FontAwesomeIcons.search
//                ),
//                onPressed: (){}
//            ),
//            new IconButton(
//                icon: new Icon(
//                    FontAwesomeIcons.search
//                ),
//                onPressed: (){}
//            ),
            new IconButton(
                icon: new Icon(
                    FontAwesomeIcons.edit
                ),
                onPressed: (){
                  _updatePost(
                    widget._PostDestription,
                    widget._PostFamiliesAffected,
                    widget._PostAffectedArea,
                    widget._PostThingsNeeded,
                    widget._PostDropoffLocation,
                    widget._PostContactDetails,
                  );
                }
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            picture(),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
//                                Form(
////                                  key: _formkeyResponse,
////                                  autovalidate: _autoValidatekeyResponse,
//                                  child: Padding(
//                                    padding: const EdgeInsets.all(8.0),
//                                    child: Column(
//                                      crossAxisAlignment: CrossAxisAlignment.start,
//                                      children: <Widget>[
//                                        Padding(
//                                          padding: const EdgeInsets.only(bottom: 5.0),
//                                          child: Container(
//                                            constraints: BoxConstraints(
//                                                maxWidth: _width * .60
//                                            ),
//                                            child: TextField(
//                                              keyboardType: TextInputType.text,
//                                              maxLines: 1,
////                                              onSaved: (value) => _helpdesc = value,
//                                              decoration: InputDecoration(
//                                                border: InputBorder.none,
//                                                icon: Icon(FontAwesomeIcons.featherAlt),
//                                                labelText: 'Help description',
//                                                labelStyle: TextStyle(
//                                                    fontSize: 12,
//                                                    fontWeight: FontWeight.w800
//                                                ),
//                                              ),
//                                            ),
//                                          ),
//                                        ),
////                                        SizedBox(
////                                          height: _height * 0.02,
////                                        ),
//                                      ],
//                                    ),
//                                  ),
//                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      widget.nameofUser,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(Dformat.format(widget._PostDatePosted.toDate()),
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 25.0, top: 20.0),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {

                                });
                              },
                              child: Center(
                                child: Text(
                                  widget._PostDestription,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 13.0),
                            child: Column(
                              children: <Widget>[
                                Text('Families affected',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget._PostFamiliesAffected,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 13.0),
                            child: Column(
                              children: <Widget>[
                                Text('Area/Barangay:',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget._PostAffectedArea,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 13.0),
                            child: Column(
                              children: <Widget>[
                                Text('Things we need:',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget._PostThingsNeeded.replaceAll(new RegExp(r'[^\w\s\,]+'),''),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 13.0),
                            child: Column(
                              children: <Widget>[
                                Text('Drop off location:',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget._PostDropoffLocation,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 13.0),
                            child: Column(
                              children: <Widget>[
                                Text('For inquiries call:',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    widget._PostContactDetails,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13.5, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 15),
                  child: Container(
                    height: _height * 0.05,
                    width: _width * 0.30,
                    child: Text(
                      '${widget._PostRespondents} respondents',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    height: _height * 0.05,
                    width: _width * 0.30,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(20.0))),
                      color: Color(0xFF3F6492),
                      onPressed: ()  {
                        _displayResponse();
                        print(widget._uniqueID);
                      },
                      child: Text(
                        'Goal Reached',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

      ),
    );
  }
}

class editRequest extends StatefulWidget {
  editRequest(
      this.nameofUser,
      this.userProfile,
      this._PostDestription,
      this._PostDatePosted,
      this._PostFamiliesAffected,
      this._PostAffectedArea,
      this._PostThingsNeeded,
      this._PostDropoffLocation,
      this._PostContactDetails,
      this._PostRespondents,
      this._typeofDisaster,
      this._Profpic,
      this._uniqueID) : super();

  final String nameofUser;
  final String userProfile;
  final String _PostDestription;
  final Timestamp _PostDatePosted ;
  final String _PostFamiliesAffected;
  final String _PostAffectedArea;
  final String _PostThingsNeeded;
  final String _PostDropoffLocation;
  final String _PostContactDetails;
  final int _PostRespondents;
  final String _typeofDisaster;
  final String _Profpic;
  final String _uniqueID;
  @override
  _editRequestState createState() => _editRequestState();
}

class _editRequestState extends State<editRequest> {
  void initState() {
    super.initState();
  }

  DateTime parseTime(dynamic date) {
    return Platform.isIOS ? (date as Timestamp).toDate() : (date as DateTime);
  }

  String _requestorsID;
  String typeOfUser;
  String _uploadedFileURLNews;

  bool orgstat = false;
  var uuid = Uuid();
  File _imageNews;

  final _formkeyResponse = GlobalKey<FormState>();
  bool _autoValidate = false;
  Flushbar flush;

  AssetImage imageType;

  final db = Firestore.instance;
  String _NewsDescription;
  String _NewsTitle;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  Future getImageNews() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 300);
    setState(() {
      _imageNews = image;
    });
  }

  uploadFileNewsImage() async {

    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('News/${user.uid}/${Path.basename('${id}')}');

    StorageUploadTask uploadTaskFood = storageReferenceFood.putFile(_imageNews);
    await uploadTaskFood.onComplete;
    print('File Uploaded');

    storageReferenceFood.getDownloadURL().then((fileURL) {
      setState(()  {
        _uploadedFileURLNews = fileURL;
        print(_uploadedFileURLNews);
      });
    });

  }

  saveNews() async {

    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final newsPost = _formkeyResponse.currentState;
    newsPost.save();

    DocumentReference ref = db.collection('BRGY NEWS').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({
            'User_ID': user.uid,
            'Unique_ID': id,
            'News_Title': _NewsTitle,
            'News_Description': _NewsDescription,
            'News_Timeposted': Timestamp.now(),
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile,
            'News_Image': _uploadedFileURLNews,
          });
        });
      } else {
        setState(() async {
          await ref
              .setData({
            'User_ID': user.uid,
            'Unique_ID': id,
            'News_Title': _NewsTitle,
            'News_Description': _NewsDescription,
            'News_Timeposted': Timestamp.now(),
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile,
            'News_Image': _uploadedFileURLNews,
          });
        });
      }
    });
  }

  _deleteHelpRequest() async {
    try {
      DocumentReference ref = db.collection('HELP REQUEST').document(widget._uniqueID);
      return ref.delete();
    } catch (e) {
      print(e);
    }
  }

  _deleteSpecificRequest () async {
    try {
      DocumentReference refII = db.collection('DROUGHT REQUESTS').document(widget._uniqueID);
      return refII.delete();
    } catch (e) {
      print(e);
    }
  }

  _displayResponse () async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery.of(context).size.width;
          final _height = MediaQuery.of(context).size.height;
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 25, right: 25, bottom: 5),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Stack(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Center(
                        child: Text("Warning!",
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
            content: Text(
              'Are you sure you have rearched your goal?',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800
              ),
              textAlign: TextAlign.center,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: _height * 0.05,
                      width: _width * 0.20,
                      child: ProgressButton(
                          defaultWidget: const Text('Yes',
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
                                    Colors.white
                                )
                            ),
                          ),
                          width: _width * 0.25,
                          borderRadius: 20.0,
                          color: Color(0xFF2b527f),
                          onPressed: () async {
//                            visibleCancel = false;
                            await Future.delayed(
                                const Duration(seconds: 3), () => 42);
                            return () {
                              _deleteHelpRequest();
                              _deleteSpecificRequest();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            };
                          }
                      ),
                    ),
                    SizedBox(
                      width: _width * 0.01,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        height: _height * 0.05,
                        width: _width * 0.20,
                        child: RaisedButton(
                          child: new Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                          color: Color(0xFFFFFFFF),
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
                ),
              )
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    if (widget._typeofDisaster == '[Drought]'){
      imageType = AssetImage('assets/Drought.jpg');
    }
    else if (widget._typeofDisaster == '[Earthquake]'){
      imageType = AssetImage('assets/Earthquake.jpg');
    }
    else if (widget._typeofDisaster == '[Flood]'){
      imageType = AssetImage('assets/Flood.jpg');
    }
    else if (widget._typeofDisaster == '[Landslide]'){
      imageType = AssetImage('assets/Landslide.jpg');
    }
    else if (widget._typeofDisaster == '[Tsunami]'){
      imageType = AssetImage('assets/Tsunami.jpg');
    }
    else if (widget._typeofDisaster == '[Typhoon]'){
      imageType = AssetImage('assets/Typhoon.jpg');
    }
    else if (widget._typeofDisaster == "null") {
      imageType = AssetImage('assets/no-image.png');
    }

    Widget picture(){
      if (widget._Profpic == null){
        return CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(widget._Profpic),
        );
      }
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      color: Colors.white,
      child: Scaffold (
        appBar: new AppBar(
          backgroundColor: Color(0xFF2b527f),
          actions: <Widget>[
//            new IconButton(
//                icon: new Icon(
//                    FontAwesomeIcons.search
//                ),
//                onPressed: (){}
//            ),
//            new IconButton(
//                icon: new Icon(
//                    FontAwesomeIcons.search
//                ),
//                onPressed: (){}
//            ),
            new IconButton(
                icon: new Icon(
                    FontAwesomeIcons.edit
                ),
                onPressed: (){}
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            picture(),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Form(
//                                  key: _formkeyResponse,
//                                  autovalidate: _autoValidatekeyResponse,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5.0),
                                          child: Container(
                                            constraints: BoxConstraints(
                                                maxWidth: _width * .60
                                            ),
                                            child: TextField(
                                              keyboardType: TextInputType.text,
                                              maxLines: 1,
//                                              onSaved: (value) => _helpdesc = value,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                icon: Icon(FontAwesomeIcons.featherAlt),
                                                labelText: 'Help description',
                                                labelStyle: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
//                                        SizedBox(
//                                          height: _height * 0.02,
//                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
//                                    Text(
//                                      widget.nameofUser,
//                                      style: TextStyle(
//                                          fontSize: 14,
//                                          fontWeight: FontWeight.w800),
//                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(Dformat.format(widget._PostDatePosted.toDate()),
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w800
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                      ],
                    ),

                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 25.0, top: 20.0),
                            child: GestureDetector(
                              onTap: (){
                                setState(() {

                                });
                              },
                              child: Center(
                                child: Text(
                                  widget._PostDestription,
                                  maxLines: 6,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                          Divider(),
                          Column(
                            children: <Widget>[
                              Text('Families affected',
                                style: TextStyle(
                                  fontSize: 12.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget._PostFamiliesAffected,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          Column(
                            children: <Widget>[
                              Text('Area/Barangay:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget._PostAffectedArea,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          Divider(),

                          Column(
                            children: <Widget>[
                              Text('Things we need:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget._typeofDisaster.replaceAll(new RegExp(r'[^\w\s\,]+'),'').toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          Divider(),

                          Column(
                            children: <Widget>[
                              Text('Drop off location:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget._PostDropoffLocation,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                          Divider(),

                          Column(
                            children: <Widget>[
                              Text('For inquiries call:',
                                style: TextStyle(
                                  fontSize: 12.5,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget._PostContactDetails,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13.5, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 15),
                  child: Container(
                    height: _height * 0.05,
                    width: _width * 0.30,
                    child: Text(
                      '${widget._PostRespondents} respondents',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    height: _height * 0.05,
                    width: _width * 0.30,
                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(20.0))),
                      color: Color(0xFF3F6492),
                      onPressed: ()  {
                        _displayResponse();
                        print(widget._uniqueID);
                      },
                      child: Text(
                        'Goal Reached',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

      ),
    );
  }
}

class _RequestBeneficiary extends StatefulWidget {
  _RequestBeneficiary(
      this.nameofUser,
      this._userProfile,
      this.orgStatus) : super();

  final String nameofUser;
  final String _userProfile;
  final String orgStatus;

  @override
  _RequestBeneficiaryState createState() => _RequestBeneficiaryState();
}

class _RequestBeneficiaryState extends State<_RequestBeneficiary> {

  var uuid = Uuid();

  void initState() {
    super.initState();
    print(widget._userProfile);
    print(_disasterChoice);
  }

  final db = Firestore.instance;
  bool _autoValidatekeyResponse = false;
  bool _autoValidatekey = false;
  bool _autoValidatebank = false;

  final _formkey = GlobalKey<FormState>();
  final _formkeyResponse = GlobalKey<FormState>();
  final _formkeyBank = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  String _helpdesc;
  String _helpneeded;
  String _helplocation;
  String _helpfamiliesaffected;
  String _nameofuser;
  String _helpItems;
  String _disasterChoice;
  String _dropoffLocation;
  String _helpInquiry;
  String _bankAccountName;
  String _bankAccountNumber;

  Flushbar flush;
  bool visibleBank = false;

  checkValue(){
    if (_helpItems == null){
      setState(() {
        visibleBank = false;
      });
    }
    else if (
    _helpItems == "[Money]" ||
        _helpItems == "[Food, Money]" ||
        _helpItems == "[Money, Food]" ||
        _helpItems == "[Clothes, Money]" ||
        _helpItems == "[Money, Clothes]" ||
        _helpItems == "[Food, Money, Clothes]" ||
        _helpItems == "[Food, Clothes, Money]" ||
        _helpItems == "[Clothes, Money, Food]" ||
        _helpItems == "[Clothes, Food, Money]" ||
        _helpItems == "[Money, Food, Clothes]" ||
        _helpItems == "[Money, Clothes, Food]") {
      setState(() {
        visibleBank = true;
      });
    }
    else if (_helpItems == "[]"){
      setState(() {
        visibleBank = false;
      });
    }
    else {
      setState(() {
        visibleBank = false;
      });
    }
  }

  _saveIssueToEachDisaster() async {

    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    if(_disasterChoice == '[Drought]'){
      DocumentReference ref = db.collection('DROUGHT REQUESTS').document(id);

      final key = _formkey.currentState;
      final keyII = _formkeyResponse.currentState;
      final keyIII = _formkeyBank.currentState;

      key.save();
      keyII.save();

      if (keyIII != null){
        setState(() {
          keyIII.save();
        });
      }


      ref.get().then((document) async {
        if (document.exists) {
          ref.updateData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
        else {
          ref.setData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
      });

    }
    else if (_disasterChoice == '[Earthquake]'){
      DocumentReference ref = db.collection('EARTHQUAKE REQUESTS').document(id);

      final key = _formkey.currentState;
      final keyII = _formkeyResponse.currentState;
      final keyIII = _formkeyBank.currentState;

      key.save();
      keyII.save();

      if (keyIII != null){
        setState(() {
          keyIII.save();
        });
      }


      ref.get().then((document) async {
        if (document.exists) {
          ref.updateData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
        else {
          ref.setData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
      });
    }
    else if (_disasterChoice == '[Flood]'){
      DocumentReference ref = db.collection('FLOOD REQUESTS').document(id);

      final key = _formkey.currentState;
      final keyII = _formkeyResponse.currentState;
      final keyIII = _formkeyBank.currentState;

      key.save();
      keyII.save();

      if (keyIII != null){
        setState(() {
          keyIII.save();
        });
      }


      ref.get().then((document) async {
        if (document.exists) {
          ref.updateData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
        else {
          ref.setData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
      });
    }
    else if (_disasterChoice == '[Landslide]'){
      DocumentReference ref = db.collection('LANDSLIDE REQUESTS').document(id);

      final key = _formkey.currentState;
      final keyII = _formkeyResponse.currentState;
      final keyIII = _formkeyBank.currentState;

      key.save();
      keyII.save();

      if (keyIII != null){
        setState(() {
          keyIII.save();
        });
      }


      ref.get().then((document) async {
        if (document.exists) {
          ref.updateData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
        else {
          ref.setData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
      });
    }
    else if (_disasterChoice == '[Tsunami]'){
      DocumentReference ref = db.collection('TSUNAMI REQUESTS').document(id);

      final key = _formkey.currentState;
      final keyII = _formkeyResponse.currentState;
      final keyIII = _formkeyBank.currentState;

      key.save();
      keyII.save();

      if (keyIII != null){
        setState(() {
          keyIII.save();
        });
      }


      ref.get().then((document) async {
        if (document.exists) {
          ref.updateData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
        else {
          ref.setData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
      });
    }
    else if (_disasterChoice == '[Typhoon]'){
      DocumentReference ref = db.collection('TYPHOON REQUESTS').document(id);

      final key = _formkey.currentState;
      final keyII = _formkeyResponse.currentState;
      final keyIII = _formkeyBank.currentState;

      key.save();
      keyII.save();

      if (keyIII != null){
        setState(() {
          keyIII.save();
        });
      }


      ref.get().then((document) async {
        if (document.exists) {
          ref.updateData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
        else {
          ref.setData({
            'Unique_ID': id,
            'User_ID': '${user.uid}',
            'Name_ofUser': widget.nameofUser,
            'Help_Description': '${_helpdesc}',
            'Help_DatePosted': Timestamp.now(),
            'Help_AreaAffected': '${_helplocation}',
            'Help_DropoffLocation': '${_dropoffLocation}',
            'Help_ThingsNeeded': '${_helpItems}',
            'Help_NotificationID': '${user.uid}',
            'Type_OfDisaster': '${_disasterChoice}',
            'Help_FamiliesAffected': '${_helpfamiliesaffected}',
            'Help_Inquiry': '${_helpInquiry}',
            'Help_Status': 'Waiting',
            'Respondents_Count': 0,
            'Profile_Picture': widget._userProfile,
            'Org_status': widget.orgStatus,
            'Help_BankAccountName': '${_bankAccountNumber}',
            'Help_BankAccountNumber': '${_bankAccountName}',
          });
        }
      });
    }

    DocumentReference ref = db.collection('HELP REQUEST').document(id);

    final key = _formkey.currentState;
    final keyII = _formkeyResponse.currentState;
    final keyIII = _formkeyBank.currentState;

    key.save();
    keyII.save();

    if (keyIII != null){
      setState(() {
        keyIII.save();
      });
    }


    ref.get().then((document) async {
      if (document.exists) {
        ref.updateData({
          'Unique_ID': id,
          'User_ID': '${user.uid}',
          'Name_ofUser': widget.nameofUser,
          'Help_Description': '${_helpdesc}',
          'Help_DatePosted': Timestamp.now(),
          'Help_AreaAffected': '${_helplocation}',
          'Help_DropoffLocation': '${_dropoffLocation}',
          'Help_ThingsNeeded': '${_helpItems}',
          'Help_NotificationID': '${user.uid}',
          'Type_OfDisaster': '${_disasterChoice}',
          'Help_FamiliesAffected': '${_helpfamiliesaffected}',
          'Help_Inquiry': '${_helpInquiry}',
          'Help_Status': 'Waiting',
          'Respondents_Count': 0,
          'Profile_Picture': widget._userProfile,
          'Org_status': widget.orgStatus,
          'Help_BankAccountName': '${_bankAccountNumber}',
          'Help_BankAccountNumber': '${_bankAccountName}',
        });
      }
      else {
        ref.setData({
          'Unique_ID': id,
          'User_ID': '${user.uid}',
          'Name_ofUser': widget.nameofUser,
          'Help_Description': '${_helpdesc}',
          'Help_DatePosted': Timestamp.now(),
          'Help_AreaAffected': '${_helplocation}',
          'Help_DropoffLocation': '${_dropoffLocation}',
          'Help_ThingsNeeded': '${_helpItems}',
          'Help_NotificationID': '${user.uid}',
          'Type_OfDisaster': '${_disasterChoice}',
          'Help_FamiliesAffected': '${_helpfamiliesaffected}',
          'Help_Inquiry': '${_helpInquiry}',
          'Help_Status': 'Waiting',
          'Respondents_Count': 0,
          'Profile_Picture': widget._userProfile,
          'Org_status': widget.orgStatus,
          'Help_BankAccountName': '${_bankAccountNumber}',
          'Help_BankAccountNumber': '${_bankAccountName}',
        });
      }
    });
  }

  @override

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.white,
//      decoration: BoxDecoration(
//        gradient: LinearGradient(
//          begin: Alignment.bottomLeft,
//          end: Alignment.topRight,
//          stops: [0.3, 0.7],
//          colors: [
//            Color(0xFFE5E7EF),
//            Color(0xFF2b527f),
//          ],
//        ),
//      ),
      child: Scaffold(
          appBar: new AppBar(
              backgroundColor: Color(0xFF2b527f),
              title: new Text('Requesting for help')
          ),
          body: Container(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0, bottom: 15.0),
                    child: Card(
                      elevation: 5,
                      child:
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 15.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Divider(
                                          color: Colors.black,
                                          thickness: 0.30,
                                        ),
                                      )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                                    child: Text(
                                      'Type of Disaster', style: TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w500
                                    ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Divider(
                                          color: Colors.black,
                                          thickness: 0.30,
                                        ),
                                      )
                                  ),
                                ],
                              ),
                            ),
                            CheckboxGroup(
                              orientation: GroupedButtonsOrientation.VERTICAL,
                              labels: <String>[
                                "Drought",
                                "Earthquake",
                                "Flood",
                                "Landslide",
                                "Tsunami",
                                "Typhoon",
                              ],
                              labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800
                              ),
                              onSelected: (List<String> checked) => setState(() {
                                if (checked.length > 1) {
                                  checked.removeAt(0);
                                  _disasterChoice = checked.toString();
                                  print('${_disasterChoice}');
                                } else {
                                  _disasterChoice = checked.toString();
                                  print('${_disasterChoice}');
                                }
                              }),
                            ),
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 15.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 0.30,
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                                        child: Text(
                                          'Things I need', style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500
                                        ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 0.30,
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                CheckboxGroup(
                                  orientation: GroupedButtonsOrientation.VERTICAL,
                                  labels: <String>[
                                    "Food",
                                    "Money" ,
                                    "Clothes",
                                  ],
                                  labelStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800
                                  ),
                                  onChange: (bool isChecked, String label, int index) => print("isChecked: $isChecked   label: $label  index: $index"),
                                  onSelected: (List<String> checked){
                                    _helpItems = checked.toString();
                                    print(_helpItems);
                                    checkValue();
                                  },
                                ),
                              ],
                            ),
                            Visibility(
                              visible: visibleBank,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: _formkeyBank,
                                  autovalidate: _autoValidatebank,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text('Bank Account Details:',
                                                style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w800
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: _width * .75
                                                ),
                                                child: TextFormField(
                                                  keyboardType: TextInputType.text,
                                                  maxLines: 1,
                                                  onSaved: (value) => _bankAccountName = value,
                                                  decoration: InputDecoration(
                                                    icon: Icon(FontAwesomeIcons.penAlt),
                                                    labelText: 'Account Name:',
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
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Container(
                                                constraints: BoxConstraints(
                                                    maxWidth: _width * .75
                                                ),
                                                child: TextFormField(
                                                  keyboardType: TextInputType.number,
                                                  maxLines: 1,
                                                  onSaved: (value) => _bankAccountNumber = value,
                                                  decoration: InputDecoration(
                                                    icon: Icon(FontAwesomeIcons.listOl),
                                                    labelText: 'Account Number:',
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 0.30,
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                                        child: Text(
                                          'Description', style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500
                                        ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 0.30,
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Form(
                                    key: _formkeyResponse,
                                    autovalidate: _autoValidatekeyResponse,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: _width * .75
                                              ),
                                              child: TextFormField(
                                                keyboardType: TextInputType.text,
                                                maxLines: 6,
                                                onSaved: (value) => _helpdesc = value,
                                                validator: (String value) {
                                                  if (value.length < 1)
                                                    return 'Description, field is empty';
                                                  else
                                                    return null;
                                                },
                                                decoration: InputDecoration(
                                                  icon: Icon(FontAwesomeIcons.featherAlt),
                                                  labelText: 'Help description',
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
                            Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0, bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 0.30,
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                                        child: Text(
                                          'Information', style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500
                                        ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Divider(
                                              color: Colors.black,
                                              thickness: 0.30,
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Form(
                                    key: _formkey,
                                    autovalidate: _autoValidatekey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 5.0),
                                            child: Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: _width * .75
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
                                                  labelText: 'How many families are affected?',
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
                                                  maxWidth: _width * .75
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
                                                  maxWidth: _width * .75
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
                                                  labelText: 'Drop off location:',
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
                                                  maxWidth: _width * .75
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
                                                  labelText: 'Contact number:',
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
                              padding: const EdgeInsets.only(right: 8.0, bottom: 15.0),
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
                                    color: Color(0xFF1E2C5E),
                                    onPressed: () async {
                                      await Future.delayed(
                                          const Duration(milliseconds: 2000), () => 42);
                                      return () async {
                                        final key = _formkey.currentState;
                                        final keyResponse = _formkeyResponse.currentState;
//
//                                        if(key.validate()){
//
//                                        }
//                                        else {
//                                          setState(() {
//                                            _autoValidate = true;
//                                          });
//                                        }

//                                        if (key.validate() == false && keyResponse.validate() == false && keyBank.validate() == false) {
//                                        _autoValidatekeyResponse = true;
//                                        _autoValidatekey = true;
//
//                                        }
//
//                                        else if (key.validate() && keyResponse.validate() == false && keyBank.validate() == false) {
//                                           _autoValidatekeyResponse = true;
//                                           _autoValidatebank = true;
//                                         }
//                                        else if (key.validate() == false && keyResponse.validate() && keyBank.validate() == false) {
//                                          _autoValidatekey = true;
//                                          _autoValidatebank = true;
//                                        }
//                                        else if (key.validate() == false && keyResponse.validate() == false && keyBank.validate()) {
//                                          _autoValidatekey = true;
//                                          _autoValidatekeyResponse = true;
//                                        }
//
//                                        else if (key.validate() && keyResponse.validate() && keyBank.validate() == false) {
//                                          _autoValidatebank = true;
//                                        }
//                                        else if (key.validate()  == false && keyResponse.validate() && keyBank.validate()) {
//                                          _autoValidatekey = true;
//                                        }
//                                        else if (key.validate()  && keyResponse.validate() == false && keyBank.validate()) {
//                                          _autoValidatekeyResponse = true;
//                                        }

                                        if (key.validate() == false && keyResponse.validate() == false) {
                                          _autoValidatekeyResponse = true;
                                          _autoValidatekey = true;

                                        }

                                        else if (key.validate() && keyResponse.validate() == false) {
                                          _autoValidatekeyResponse = true;
                                          _autoValidatebank = true;
                                        }
                                        else if (key.validate() == false && keyResponse.validate()) {
                                          _autoValidatekey = true;
                                          _autoValidatebank = true;
                                        }

                                        else if (key.validate() && keyResponse.validate() && _disasterChoice == null && _helpItems == null){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select disaster choice and type of help.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice == "[]" && _helpItems == "[]"){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select disaster choice and type of help.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice != null && _helpItems == null){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of help.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice != "[]" && _helpItems == null){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of help.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice != null && _helpItems == "[]"){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of help.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice != "[]" && _helpItems == "[]"){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of help.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && _disasterChoice == null && _helpItems != null){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice == null && _helpItems != "[]"){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice == "[]" && _helpItems != null){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && _disasterChoice == "[]" && _helpItems != "[]"){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food, Money]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food, Clothes]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Food]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Clothes]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes, Food]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes, Money]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food, Money, Clothes]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food, Clothes, Clothes]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Food, Clothes]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Clothes, Food]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes, Food, Money]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }
                                        else if (key.validate() && keyResponse.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes, Money, Food]'){
                                          Flushbar(
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: 'Message',
                                            message: "Please select type of disaster.",
                                            duration: Duration(seconds: 3),
                                          )
                                            ..show(context);
                                        }

//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Food, Money]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money, Food]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Clothes, Money]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money, Clothes]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Food, Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money, Food]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Clothes, Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money, Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Food, Money]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money, Food]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Clothes, Money]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice != null || _disasterChoice != "[]") && _helpItems == '[Money, Money]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food, Money]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Food]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes, Money]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Money]' && _bankAccountName == null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food, Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Food]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes, Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Money]' && _bankAccountName != null && _bankAccountNumber == null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Food, Money]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Food]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Clothes, Money]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                          Flushbar(
//                                            margin: EdgeInsets.all(8),
//                                            borderRadius: 8,
//                                            title: 'Message',
//                                            message: "Please input bank details.",
//                                            duration: Duration(seconds: 3),
//                                          )
//                                            ..show(context);
//                                        }
//                                        else if (key.validate() && key2.validate() && (_disasterChoice == null || _disasterChoice == "[]") && _helpItems == '[Money, Clothes]' && _bankAccountName == null && _bankAccountNumber != null ){
//                                            Flushbar(
//                                              margin: EdgeInsets.all(8),
//                                              borderRadius: 8,
//                                              title: 'Message',
//                                              message: "Please input bank details.",
//                                              duration: Duration(seconds: 3),
//                                            )
//                                              ..show(context);
//                                          }
                                        else {
                                          _saveIssueToEachDisaster();
//                                          _saveIssueToHelpRequest();
                                          flush = Flushbar<bool>(
                                            isDismissible: false,
                                            routeBlur: 50,
                                            routeColor: Colors.white
                                                .withOpacity(0.50),
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: "Message",
                                            message: "Your request has been posted.",
                                            mainButton: FlatButton(
                                              onPressed: () async {
                                                flush.dismiss(true);
                                              },
                                              child: Text(
                                                "Confirm",
                                                style: TextStyle(
                                                    color: Colors.amber),
                                              ),
                                            ),
                                          )
                                            ..show(context).then((result) {
                                              setState(() {
                                                Navigator.pop(context);
                                              });
                                            });
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
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}

class ConfirmDonationFeedBeneficiary extends StatefulWidget {
  ConfirmDonationFeedBeneficiary(
      this.UidUser,
      this.nameofUser) : super();

  final String UidUser;
  final String nameofUser;


  @override
  _ConfirmDonationFeedBeneficiaryState createState() => _ConfirmDonationFeedBeneficiaryState();
}

class _ConfirmDonationFeedBeneficiaryState extends State<ConfirmDonationFeedBeneficiary> {
  @override

  void initState() {
    super.initState();
  }

  final db = Firestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  String _userID;
  String _stateValue;
  String statusAddText;
  String statusAddTextII;
  String status;
  String nameOfUser;
  String _typeofHelp;
  String _recievedItemState;

  bool Interested;
  bool Confirmed;
  bool scanValue = true;

  String imageFood;
  String imageClothes;
  String imageMoney;
  String QRcodeX;
  String uniqueCode;
  String xammpp;


  final myController = TextEditingController();
  String _scanBarcode = '';
  String barcodeScanRes;

  var uuid = Uuid();

  Flushbar flush;

  _saveConfirmedHelpBeneficiary(dynamic data) async {
    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    DocumentReference ref = db.collection('CONFIRMED HELP BENEFICIARY').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Confirmed_ConfirmedDate': time,
            'Received_AllItems': 'Yes',
            'Recieced_By': data['Requestors_Name'],
            'Recieved_Date': time,
            'Respondents_Name': data['Respondents_Name'],
            'Respondents_ID': data['Confirmed_ID'],
            'Requestors_ID': data['Requestors_ID'],
            'Unique_ID': id
          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'Confirmed_ConfirmedDate': time,
            'Received_AllItems': 'Yes',
            'Recieced_By': data['Requestors_Name'],
            'Recieved_Date': time,
            'Respondents_Name': data['Respondents_Name'],
            'Respondents_ID': data['Confirmed_ID'],
            'Requestors_ID': data['Requestors_ID'],
            'Unique_ID': id
          });
        });
      }
    });
  }

  _deleteInterested(dynamic data) async {
    try {
      DocumentReference ref = db.collection('CONFIRMED INT BENEFAC').document(data);
      return ref.delete();
    } catch (e) {
      print(e);
    }
  }

//  _deleteInterested(dynamic data) async {
//    try {
////      DocumentReference ref = db.collection('CONFIRMED INT BENEFAC').document(data['Unique_ID']);
//      DocumentReference ref = db.collection('CONFIRMED INT BENEFAC').document(data);
//
//      return ref.delete();
//    } catch (e) {
//      print(e);
//    }
//  }

  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();


    QRcodeX = doc.data['Confirmed_ID'];
    uniqueCode = doc.data['Unique_ID'];

    imageFood = doc.data['ImageFood'];
    imageClothes = doc.data['ImageClothes'];
    imageMoney = doc.data['ImageMoney'];

    _stateValue = doc.data['Response_State'];

    if(_stateValue == 'Interested'){
      status = "Interested";
      statusAddText = "is interested to help. ";
      statusAddTextII = "Please wait for ${doc.data['Respondents_Name']} to confirm its help.";
      Confirmed = false;
      Interested = true;
    }
    else{
      status = "Confirmed";
      statusAddText = "has confirmed his help. ";
      statusAddTextII = "Please check \"To Confirm\" tab to confirm the donation.";
      Confirmed = true;
      Interested = true;

    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: RichText(
                        text: TextSpan(
                            text: "Status: ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 11
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: "${status}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800
                                ),
                              )
                            ]
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      child: RichText(
                        text: TextSpan(
                            text: "Disaster: ",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 11
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${doc.data['Type_Of_Disaster']}'.replaceAll(new RegExp(r'[^\w\s\,]+'),''),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800
                                ),
                              )
                            ]
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text:  TextSpan(
                        text: '${doc.data['Respondents_Name']}, ',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: "has confirmed his help. ",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal
                              )
                          ),
                          TextSpan(
                              text: "Please do confirm the donation, upon recieving or when it arrives. Thank you!",
                              style: TextStyle(
                                  fontWeight: FontWeight.normal
                              )
                          ),
                        ]
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:  Text(Dformat.format(doc.data['Confirmed_ConfirmedDate'].toDate()),
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      Visibility(
                        visible: Confirmed,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Container(
                            height: _height * 0.05,
                            child: RaisedButton(
                              child: new Text(
                                'View donation',
                                style: TextStyle(color: Colors.white, fontSize: 12,
                                ),
                              ),
                              color: Color(0xFF2b527f),
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              onPressed: () {
//                                _viewingRequest(doc.data);
                                _viewingRequest(doc);
                                print(imageFood);
                                print(imageClothes);
                                print(imageMoney);
                              },
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
      ),
    );
  }

  Container scanbuildItem(DocumentSnapshot doc) {

    QRcodeX = doc.data['Confirmed_ID'];
    uniqueCode = doc.data['Unique_ID'];

    imageFood = doc.data['ImageFood'];
    imageClothes = doc.data['ImageClothes'];
    imageMoney = doc.data['ImageMoney'];

    _stateValue = doc.data['Response_State'];

    if(_stateValue == 'Interested'){
      status = "Interested";
      statusAddText = "is interested to help. ";
      statusAddTextII = "Please wait for ${doc.data['Respondents_Name']} to confirm its help.";
      Confirmed = false;
      Interested = true;
    }
    else{
      status = "Confirmed";
      statusAddText = "has confirmed his help. ";
      statusAddTextII = "Please check \"To Confirm\" tab to confirm the donation.";
      Confirmed = true;
      Interested = true;

    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0, left: 10, right: 10, top: 15),
                child: Center(
                  child: Text("Donation Info",
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: _height * 0.58,
                  width: _width * 0.80,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'To:',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${doc.data['Requestors_Name']}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'From:',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${doc.data['Respondents_Name']}',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Description:',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${doc.data['Request_Description']}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Items given:',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${doc.data['Confirmed_Items_To_Give']}'.replaceAll(
                                new RegExp(r'[^\w\s\,]+'), ''),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Designated drop off location:',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${doc.data['Request_DropoffLocation']}',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Gallery:',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.circular(25.0)
                              ),
                              width: _width * 0.30,
                              height: _height *0.20,
                              child: doc.data['ImageMoney'] == null
                                  ?
                              Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset('assets/no-image.png'),
                                  )
                              )
                                  :
                              Container(
                                  width: _width * 0.30,
                                  child: PhotoView(
                                    imageProvider: NetworkImage(doc.data['ImageMoney']),
                                    tightMode: true,
                                  )
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.circular(25.0)
                              ),
                              width: _width * 0.30,
                              height: _height *0.20,
                              child: doc.data['ImageFood'] == null
                                  ?
                              Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset('assets/no-image.png'),
                                  )
                              )
                                  :
                              Container(
                                  width: _width * 0.30,
                                  child: PhotoView(
                                    imageProvider: NetworkImage(doc.data['ImageFood']),
                                    tightMode: true,
                                  )
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: new BorderRadius.circular(25.0)
                              ),
                              width: _width * 0.30,
                              height: _height *0.20,
                              child: doc.data['ImageClothes'] == null
                                  ?
                              Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset('assets/no-image.png'),
                                  )
                              )
                                  :
                              Container(
                                  width: _width * 0.30,
                                  child: PhotoView(
                                    imageProvider: NetworkImage(doc.data['ImageClothes']),
                                    tightMode: true,
                                  )
                              )
                          ),
                        ),
                        Divider(
                          color: Colors.black,
                        ),
                        CheckboxGroup(
                          orientation: GroupedButtonsOrientation
                              .VERTICAL,
                          labels: <String>[
                            "I have recieved all of\n"
                                "donations given by the user.",
                          ],
                          labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          onSelected: (checked) {
                            _recievedItemState = checked.toString();
                            print(_recievedItemState);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0, top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                      child: Container(
                          height: _height * 0.05,
                          width: _width * 0.25,
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
                                        Colors.white
                                    )
                                ),
                              ),
                              width: _width * 0.30,
                              height: 40,
                              borderRadius: 20.0,
                              color: Color(0xFF2b527f),
                              onPressed: () async {
                                if (_recievedItemState == null){
                                  print('error');
                                }
                                else if (_recievedItemState == '[]'){
                                  print('error');
                                }
                                else{
                                  _saveConfirmedHelpBeneficiary(doc.data);
                                }
                                await Future.delayed(
                                    const Duration(milliseconds: 5000), () => 42);
                                return () {
                                  if (_recievedItemState == null){
                                    Flushbar(
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Hey, ${doc.data['Requestors_Name']}.",
                                      message: "Please check the last check box if you have recieved all of the donations.",
                                      duration: Duration(seconds: 3),
                                    )
                                      ..show(context);
                                  }
                                  else if (_recievedItemState == '[]'){
                                    Flushbar(
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Hey, ${doc.data['Requestors_Name']}.",
                                      message: "Please select items recieved.",
                                      duration: Duration(seconds: 3),
                                    )
                                      ..show(context);
                                  }
                                  else{
                                    flush = Flushbar<bool>(
                                      isDismissible: false,
                                      routeBlur: 50,
                                      routeColor: Colors.white.withOpacity(0.50),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Thank you, ${doc.data['Requestors_Name']}.",
                                      message: "Your response is a big help for , You have chosen to donate",
                                      mainButton: FlatButton(
                                        onPressed: () async {
                                          _deleteInterested(doc.data);
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
                                  }
                                };
                              }
                          )
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      child: Container(
                          height: _height * 0.05,
                          width: _width * 0.25,
                          child: ProgressButton(
                              defaultWidget: const Text('Cancel',
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
                                        Colors.white
                                    )
                                ),
                              ),
                              width: _width * 0.30,
                              height: 40,
                              borderRadius: 20.0,
                              color: Color(0xFF2b527f),
                              onPressed: () async {
                                setState(() {
                                  xammpp = "2";
                                });
                                scanValue = true;
                              }
                          )
                      ),
                    ),

                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _viewingRequest(DocumentSnapshot doc) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
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
                    Text("Donation Info",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                      ),
                    ),
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
                            child: Text(
                              'To:',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Requestors_Name']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'From:',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Respondents_Name']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Description:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Request_Description']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Items given:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Confirmed_Items_To_Give']}'.replaceAll(
                              new RegExp(r'[^\w\s\,]+'), ''),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Designated drop off location:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Request_DropoffLocation']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Gallery:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: new BorderRadius.circular(25.0)
                            ),
                            width: _width * 0.30,
                            height: _height *0.20,
                            child: doc.data['ImageMoney'] == null
                                ?
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset('assets/no-image.png'),
                                )
                            )
                                :
                            Container(
                                width: _width * 0.30,
                                child: PhotoView(
                                  imageProvider: NetworkImage(doc.data['ImageMoney']),
                                  tightMode: true,
                                )
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: new BorderRadius.circular(25.0)
                            ),
                            width: _width * 0.30,
                            height: _height *0.20,
                            child: doc.data['ImageFood'] == null
                                ?
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset('assets/no-image.png'),
                                )
                            )
                                :
                            Container(
                                width: _width * 0.30,
                                child: PhotoView(
                                  imageProvider: NetworkImage(doc.data['ImageFood']),
                                  tightMode: true,
                                )
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            decoration: BoxDecoration(
                                borderRadius: new BorderRadius.circular(25.0)
                            ),
                            width: _width * 0.30,
                            height: _height *0.20,
                            child: doc.data['ImageClothes'] == null
                                ?
                            Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset('assets/no-image.png'),
                                )
                            )
                                :
                            Container(
                                width: _width * 0.30,
                                child: PhotoView(
                                  imageProvider: NetworkImage(doc.data['ImageClothes']),
                                  tightMode: true,
                                )
                            )
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      CheckboxGroup(
                        orientation: GroupedButtonsOrientation
                            .VERTICAL,
                        labels: <String>[
                          "I have recieved all of\n"
                              "donations given by the user.",
                        ],
                        labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        onSelected: (checked) {
                          _recievedItemState = checked.toString();
                          print(_recievedItemState);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                      child: Container(
                          height: _height * 0.05,
                          width: _width * 0.25,
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
                                        Colors.white
                                    )
                                ),
                              ),
                              width: _width * 0.30,
                              height: 40,
                              borderRadius: 20.0,
                              color: Color(0xFF2b527f),
                              onPressed: () async {
                                if (_recievedItemState == null){
                                  print('error');
                                }
                                else if (_recievedItemState == '[]'){
                                  print('error');
                                }
                                else{
                                  _saveConfirmedHelpBeneficiary(doc.data);
                                  _deleteInterested(doc.data['Unique_ID']);
                                }
                                await Future.delayed(
                                    const Duration(milliseconds: 5000), () => 42);
                                return () {
                                  if (_recievedItemState == null){
                                    Flushbar(
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Hey, ${doc.data['Requestors_Name']}.",
                                      message: "Please check the last check box if you have recieved all of the donations.",
                                      duration: Duration(seconds: 3),
                                    )
                                      ..show(context);
                                  }
                                  else if (_recievedItemState == '[]'){
                                    Flushbar(
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Hey, ${doc.data['Requestors_Name']}.",
                                      message: "Please select items recieved.",
                                      duration: Duration(seconds: 3),
                                    )
                                      ..show(context);
                                  }
                                  else{
                                    flush = Flushbar<bool>(
                                      isDismissible: false,
                                      routeBlur: 50,
                                      routeColor: Colors.white.withOpacity(0.50),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Thank you, ${doc.data['Requestors_Name']}.",
                                      message: "Your response is a big help for , You have chosen to donate",
                                      mainButton: FlatButton(
                                        onPressed: () async {
                                          _deleteInterested(doc.data);
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
                                  }
                                };
                              }
                          )
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  Future scanBarcodeNormal () async {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.QR);

    setState(() {
      _scanBarcode = barcodeScanRes;

      scanValue = false;
      xammpp = "0";
      print(_scanBarcode);
      print(QRcodeX);

      if (_scanBarcode == QRcodeX){
//        final _width = MediaQuery.of(context).size.width;
//        final _height = MediaQuery.of(context).size.height;
//        AlertDialog(
////          title: new Text('Confirmation',
////            style: TextStyle(
////              fontSize: 16, fontWeight: FontWeight.w800,
////            ),
////          ),
//          content: new Text('Donatioszzzz.',
//            textAlign: TextAlign.center,
//            style: TextStyle(
//              fontSize: 18, fontWeight: FontWeight.w500,
//            ),
//          ),
//          shape: RoundedRectangleBorder(
//              borderRadius: BorderRadius.all(Radius.circular(10.0))),
//          actions: <Widget>[
//            // usually buttons at the bottom of the dialog
//            Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                Padding(
//                  padding: const EdgeInsets.only(bottom: 8.0, right: 35.0),
//                  child: Container(
//                      height: _height * 0.04,
//                      width: _width * 0.25,
//                      child: ProgressButton(
//                          defaultWidget: const Text('Confirm',
//                            style: TextStyle(
//                                color: Colors.white,
//                                fontSize: 12
//                            ),
//                          ),
//                          progressWidget: SizedBox(
//                            height: 20.0,
//                            width: 20.0,
//                            child: const CircularProgressIndicator(
//                                valueColor: AlwaysStoppedAnimation<Color>(
//                                    Colors.white
//                                )
//                            ),
//                          ),
//                          width: _width * 0.30,
//                          height: 40,
//                          borderRadius: 20.0,
//                          color: Color(0xFF2b527f),
//                          onPressed: () async {
//                            setState(() {
//                              _scanBarcode = "";
//                            });
//                            Navigator.of(context).pop();
//                          }
//                      )
//                  ),
//                ),
//
//              ],
//            )
//
//          ],
//        );
//  //        _showDialog();
////      setState(() {
////        StreamBuilder<QuerySnapshot>(
////            stream: db.collection('CONFIRMED INT BENEFAC').where('Unique_ID', isEqualTo: _scanBarcode).snapshots(),
////            builder: (context, snapshot) {
////              if (snapshot.hasData) {
////                final _width = MediaQuery.of(context).size.width;
////                final _height = MediaQuery.of(context).size.height;
////                return AlertDialog(
////                  content: new Text('Donation has been confirmed.',
////                    textAlign: TextAlign.center,
////                    style: TextStyle(
////                      fontSize: 18, fontWeight: FontWeight.w500,
////                    ),
////                  ),
////                  shape: RoundedRectangleBorder(
////                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
////                  actions: <Widget>[
////                    // usually buttons at the bottom of the dialog
////                    Row(
////                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                      children: <Widget>[
////                        Padding(
////                          padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
////                          child: Container(
////                              height: _height * 0.04,
////                              width: _width * 0.25,
////                              child: ProgressButton(
////                                  defaultWidget: const Text('View',
////                                    style: TextStyle(
////                                        color: Colors.white,
////                                        fontSize: 12
////                                    ),
////                                  ),
////                                  progressWidget: SizedBox(
////                                    height: 20.0,
////                                    width: 20.0,
////                                    child: const CircularProgressIndicator(
////                                        valueColor: AlwaysStoppedAnimation<Color>(
////                                            Colors.white
////                                        )
////                                    ),
////                                  ),
////                                  width: _width * 0.30,
////                                  height: 40,
////                                  borderRadius: 20.0,
////                                  color: Color(0xFF2b527f),
////                                  onPressed: ()  {
////                                    _showDialogs();
//////                            setState(() {
//////                              StreamBuilder<QuerySnapshot>(
//////                                  stream: db.collection('CONFIRMED INT BENEFAC').where('Unique_ID', isEqualTo: uniqueCode).snapshots(),
//////                                  builder: (context, snapshot) {
//////                                    if (snapshot.hasData) {
//////                                      return AlertDialog(
//////                                        title: new Text("Alert Dialog title"),
//////                                        content: new Text("Alert Dialog body"),
//////                                        actions: <Widget>[
//////                                          // usually buttons at the bottom of the dialog
//////                                          new FlatButton(
//////                                            child: new Text("Close"),
//////                                            onPressed: () {
//////                                              Navigator.of(context).pop();
//////                                            },
//////                                          ),
//////                                        ],
//////                                      );
//////                                    } else {
//////                                      return Container(
//////                                          child: Center(
//////                                              child: CircularProgressIndicator()
//////                                          )
//////                                      );
//////                                    }
//////                                  });
//////                            });
////                                  }
////                              )
////                          ),
////                        ),
////                        Padding(
////                          padding: const EdgeInsets.only(bottom: 8.0, right: 35.0),
////                          child: Container(
////                              height: _height * 0.04,
////                              width: _width * 0.25,
////                              child: ProgressButton(
////                                  defaultWidget: const Text('Confirm',
////                                    style: TextStyle(
////                                        color: Colors.white,
////                                        fontSize: 12
////                                    ),
////                                  ),
////                                  progressWidget: SizedBox(
////                                    height: 20.0,
////                                    width: 20.0,
////                                    child: const CircularProgressIndicator(
////                                        valueColor: AlwaysStoppedAnimation<Color>(
////                                            Colors.white
////                                        )
////                                    ),
////                                  ),
////                                  width: _width * 0.30,
////                                  height: 40,
////                                  borderRadius: 20.0,
////                                  color: Color(0xFF2b527f),
////                                  onPressed: () async {
////                                    setState(() {
////                                      _scanBarcode = "";
////                                    });
////                                    Navigator.of(context).pop();
////                                  }
////                              )
////                          ),
////                        ),
////
////                      ],
////                    )
////
////                  ],
////                );
////              } else {
////                return Container(
////                    child: Center(
////                        child: CircularProgressIndicator()
////                    )
////                );
////              }
////            });
////      });
      }
      else {
        print("Panget");
      }

//      print(QRcodeX);

//      print(_scanBarcode);

//      StreamBuilder<QuerySnapshot>(
////              stream: db.collection('CONFIRMED INT BENEFAC').where('Requestors_ID', isEqualTo: '${widget.UidUser}').snapshots(),
//          stream: db.collection('CONFIRMED INT BENEFAC').where('Requestors_ID', isEqualTo: widget.UidUser).snapshots(),
//          builder: (context, snapshot) {
//            if (snapshot.hasData) {
//              return Column(
//                  children: snapshot.data.documents
//                      .map((doc) => buildItem(doc))
//                      .toList());
//            } else {
//              return Container(
//                  child: Center(
//                      child: CircularProgressIndicator()
//                  )
//              );
//            }
//          });
//      _showDialog();
//      StreamBuilder<QuerySnapshot>(
//          stream: db.collection('CONFIRMED INT BENEFAC').where('Requestors_ID', isEqualTo: _scanBarcode).snapshots(),
//          builder: (context, snapshot) {
//            if (snapshot.hasData) {
//              return Column(
//                  children: snapshot.data.documents
//                      .map((doc) => buildItem(doc))
//                      .toList());
//            } else {
//              return Container(
//                  child: Center(
//                      child: CircularProgressIndicator()
//                  )
//              );
//            }
//          });


//      _deleteInterested(_scanBarcode);



//      StreamBuilder<QuerySnapshot>(
////              stream: db.collection('CONFIRMED INT BENEFAC').where('Respondents_Name', isEqualTo: myController.text).where('Requestors_ID', isEqualTo: '${widget.UidUser}').snapshots(),
//          stream: db.collection('CONFIRMED INT BENEFAC').where('Unique_ID', isEqualTo: _scanBarcode).snapshots(),
//          builder: (context, snapshot) {
//            if (snapshot.hasData) {
//              return Column(
//                  children: snapshot.data.documents
//                      .map((doc) => _showDialog(doc))
//
//                      .toList());
//            } else {
//              return Container(
//                  child: Center(
//                      child: CircularProgressIndicator()
//                  )
//              );
//            }
//          });


//
//      if (_scanBarcode == ""){
//        StreamBuilder<QuerySnapshot>(
////              stream: db.collection('CONFIRMED INT BENEFAC').where('Respondents_Name', isEqualTo: myController.text).where('Requestors_ID', isEqualTo: '${widget.UidUser}').snapshots(),
//            stream: db.collection('CONFIRMED INT BENEFAC').where('Requestors_ID', isEqualTo: widget.UidUser).snapshots(),
//            builder: (context, snapshot) {
//              if (snapshot.hasData) {
//                return Column(
//                    children: snapshot.data.documents
//                        .map((doc) => _showDialog(doc))
//
//                        .toList());
//              } else {
//                return Container(
//                    child: Center(
//                        child: CircularProgressIndicator()
//                    )
//                );
//              }
//            });
//      }
//      else {
//        StreamBuilder<QuerySnapshot>(
////              stream: db.collection('CONFIRMED INT BENEFAC').where('Respondents_Name', isEqualTo: myController.text).where('Requestors_ID', isEqualTo: '${widget.UidUser}').snapshots(),
//            stream: db.collection('CONFIRMED INT BENEFAC').where('Unique_ID', isEqualTo: _scanBarcode).snapshots(),
//            builder: (context, snapshot) {
//              if (snapshot.hasData) {
//                return Column(
//                    children: snapshot.data.documents
//                        .map((doc) => _showDialog(doc))
//
//                        .toList());
//              } else {
//                return Container(
//                    child: Center(
//                        child: CircularProgressIndicator()
//                    )
//                );
//              }
//            });
//      }

//      print(_scanBarcode);

    });
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Widget StreamBuider(){

      if (_scanBarcode == ""){
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('CONFIRMED INT BENEFAC').where('Requestors_ID', isEqualTo: widget.UidUser).snapshots(),
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
              });
      }
      else if (_scanBarcode == "-1"){
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('CONFIRMED INT BENEFAC').where('Requestors_ID', isEqualTo: widget.UidUser).snapshots(),
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
              });
      }
      else if (xammpp == "2"){
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('CONFIRMED INT BENEFAC').where('Requestors_ID', isEqualTo: widget.UidUser).snapshots(),

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
              });
      }
      else if (xammpp == "0")
      {
        return


          StreamBuilder<QuerySnapshot>(
              stream: db.collection('CONFIRMED INT BENEFAC').where('Unique_ID', isEqualTo: _scanBarcode).snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                      children: snapshot.data.documents
                          .map((doc) => scanbuildItem(doc))
                          .toList());
                } else {
                  return Container(
                      child: Center(
                          child: CircularProgressIndicator()
                      )
                  );
                }
              });


      }
    }

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
                        Padding(
                          padding: const EdgeInsets.only(left: 13.0, right: 13.0, bottom: 5.0),
                          child: Container(
                            decoration: new BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Colors.white,
                            ),
                          ),
                        ),
                        StreamBuider(),
                      ],
                    ),
                  ),
                ),

              ],
            );
          },
        ),
      ),
      floatingActionButton: Visibility(
        visible: scanValue,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            height: _height * 0.05,
            width: _width * 0.30,
            child: ProgressButton(
              borderRadius: 25,
              color: Color(0xFF121A21),
              defaultWidget: const Text(
                'Scan QR',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12
                ),
              ),
              onPressed: () async {
                await Future.delayed(
                    const Duration(milliseconds: 2000), () => 42);
                scanBarcodeNormal();
              },
              progressWidget: SizedBox(
                height: 20.0,
                width: 20.0,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}


class ActivityFeedAdminController extends StatefulWidget {
  ActivityFeedAdminController(
      this.UidUser,
      this.nameofUser,
      this._userProfile) : super();

  final String UidUser;
  final String nameofUser;
  final String _userProfile;

  @override
  _ActivityFeedAdminControllerState createState() => _ActivityFeedAdminControllerState();
}

class _ActivityFeedAdminControllerState extends State<ActivityFeedAdminController> {
  @override

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Container(
        color: Color(0xFF2b527f),
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(60.0),
                  child: TabBar(
                    tabs: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Tab(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.plus, color: Colors.white, size: 15),
                                SizedBox(
                                  height: _height * 0.01,
                                ),
                                Text(
                                    'Create Account',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Tab(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(FontAwesomeIcons.listUl, color: Colors.white, size: 15),
                                SizedBox(
                                  height: _height * 0.01,
                                ),
                                Text(
                                    'List of Accounts',
                                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                body: Container(
                  color: Colors.white,
                  child: TabBarView(
                      children: [
                        ActivityFeedAdminCreateAccount(),
                        ActivityFeedAdminListofAccounts(),
                      ]
                  ),
                )
            )
        ),
      ),
    );
  }
}

class ActivityFeedAdminCreateAccount extends StatefulWidget {
  @override
  _ActivityFeedAdminCreateAccountState createState() => _ActivityFeedAdminCreateAccountState();
}

class _ActivityFeedAdminCreateAccountState extends State<ActivityFeedAdminCreateAccount> {

  bool _autoValidate = false;
  final _formkeyName = GlobalKey<FormState>();


  String _newsTitle;
  String _newDescription;

  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      child: Scaffold(
        body: Container(
          child: DefaultTabController(
              length: 2,
              child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(50.0),
                    child: TabBar(
                      tabs: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Tab(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
//                                  Icon(FontAwesomeIcons.running, color: Colors.white, size: 15),
                                  SizedBox(
                                    height: _height * 0.01,
                                  ),
                                  Text(
                                        'Barangay',
                                      style: TextStyle(color: Color(0xFF2b527f), fontSize: 12, fontWeight: FontWeight.w800
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Tab(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: _height * 0.01,

                                  ),
                                  Text(
                                      'Admin',
                                      style: TextStyle(color:   Color(0xFF2b527f), fontSize: 12, fontWeight: FontWeight.w800
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: Container(
                    color: Colors.white,
                    child: TabBarView(
                        children: [
                          ActivityFeedAdminCreateBarangayAcc(),
                          ActivityFeedAdminCreateAdminAcc(),
                        ]
                    ),
                  )
              )
          ),
        ),
      ),
    );
  }
}

class ActivityFeedAdminCreateBarangayAcc extends StatefulWidget {
  @override
  _ActivityFeedAdminCreateBarangayAccState createState() => _ActivityFeedAdminCreateBarangayAccState();
}

class _ActivityFeedAdminCreateBarangayAccState extends State<ActivityFeedAdminCreateBarangayAcc> {

  bool _autoValidate = false;
  final _formkeyName = GlobalKey<FormState>();


  var brgyName = TextEditingController();
  var brgyEmail = TextEditingController();
  var brgyPassword = TextEditingController();

  String _brgyName;
  String _brgyEmail;
  String _brgyPassword;

  createAccountAuthentication() async{

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    Future<String> createUserWithEmailAndPassword(
        String email, String password, String name) async {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return authResult.user.uid;
    }

    final key = _formkeyName.currentState;

    key.save();

    try{
      final auth = Providers.of(context).auth;

      String uid = await createUserWithEmailAndPassword(_brgyEmail, _brgyPassword, _brgyName);
      print("Signed Up with new ID ${uid}");
      createUserAccountInDatabase(uid, _brgyName, _brgyEmail, _brgyPassword);
    }
    catch(signUperror) {
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

  createUserAccountInDatabase(String uid, String brgyname, String brgyemail, String brgypassword) async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final key = _formkeyName.currentState;
    key.save();

    DocumentReference ref = await db.collection('USERS').document(uid);

    ref.setData({
        'Email': '${_brgyEmail}',
        'Password': '${_brgyPassword}',
        'Name of Barangay': '${_brgyName}',
        'Type of User': 'Barangay',
        'Total_RequestCount': 0,
        'Total_GoalReachedCount': 0,
        'Total_ConfirmedHelp': 0,
        'Profile_Information': "",
        'Profile_Picture': "",
        'User_ID': user.uid,
        'Contact_Number': "",
        'Date_Joined': Timestamp.now(),
        'Address': "",
        'Barangay_Status': "Verified",
      });
  }

  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      child: Scaffold(
        body: Container(
            height: _height * 10,
            child: new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints viewportConstraints){
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  'Sign up Barangay',
                                    style: GoogleFonts.raleway(
                                      fontSize: 30,
                                      textStyle: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                  controller: brgyName,
                                  maxLines: 2,
                                  keyboardType: TextInputType.text,
                                  onSaved: (value) => _brgyName = value,
                                  validator: (String value) {
                                    if (value.length < 1)
                                      return 'Field is empty.';
                                    else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Barangay Name:',
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
                                  controller: brgyEmail,
                                  maxLines: 2,
                                  keyboardType: TextInputType.text,
                                  onSaved: (value) => _brgyEmail = value,
                                  validator: (String value) {

                                    Pattern pattern =
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    RegExp regex = new RegExp(pattern);

                                    if (value.length < 0)
                                      return 'Field is empty.';
                                    else if (!regex.hasMatch(value))
                                      return 'Enter Valid Email';
                                    else
                                      return null;

                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Barangay Email:',
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
                                  controller: brgyPassword,
                                  maxLines: 2,
                                  keyboardType: TextInputType.text,
                                  onSaved: (value) => _brgyPassword = value,
                                  validator: (String value) {
                                    if (value.length < 1)
                                      return 'Field is empty.';
                                    else
                                      return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Barangay Password:',
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
                );
              },
            ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            height: _height * 0.05,
            width: _width * 0.34,
            child: ProgressButton(
                defaultWidget: const Text('Register',
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
                  createAccountAuthentication();
                  await Future.delayed(
                      const Duration(milliseconds: 5000), () => 42);
                  return () async {
                    try{
                      final key = _formkeyName.currentState;
                      if (key.validate()){
                        Flushbar(
                          margin: EdgeInsets.all(8),
                          borderRadius: 8,
                          title: 'Message',
                          message: "Please select type of disaster.",
                          duration: Duration(seconds: 3),
                        )
                          ..show(context);
                        brgyName.clear();
                        brgyEmail.clear();
                        brgyPassword.clear();
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
                  };
                }
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class ActivityFeedAdminCreateAdminAcc extends StatefulWidget {
  @override
  _ActivityFeedAdminCreateAdminAccState createState() => _ActivityFeedAdminCreateAdminAccState();
}

class _ActivityFeedAdminCreateAdminAccState extends State<ActivityFeedAdminCreateAdminAcc> {
  bool _autoValidate = false;
  final _formkeyName = GlobalKey<FormState>();


  var adminName = TextEditingController();
  var adminEmail = TextEditingController();
  var adminPassword = TextEditingController();

  String _adminName;
  String _adminEmail;
  String _adminPassword;

  createAccountAuthentication() async{

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

    Future<String> createUserWithEmailAndPassword(
        String email, String password, String name) async {
      final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return authResult.user.uid;
    }

    final key = _formkeyName.currentState;

    key.save();

    try{
      final auth = Providers.of(context).auth;

//      String uid = await auth.createUserWithEmailAndPassword(_brgyEmail, _brgyPassword, _brgyName);
      String uid = await createUserWithEmailAndPassword(_adminEmail, _adminPassword, _adminName);
      print("Signed Up with new ID ${uid}");
      createUserAccountInDatabase(uid, _adminName, _adminEmail, _adminPassword);
    }
    catch(signUperror) {
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

  createUserAccountInDatabase(String uid, String brgyname, String brgyemail, String brgypassword) async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final key = _formkeyName.currentState;
    key.save();

    DocumentReference ref = await db.collection('USERS').document(uid);

    ref.setData({
      'Email': '${_adminEmail}',
      'Password': '${_adminPassword}',
      'Name of Admin': '${_adminName}',
      'Type of User': 'Admin',
      'Profile_Information': "",
      'Profile_Picture': "",
      'User_ID': user.uid,
      'Contact_Number': "",
      'Date_Joined': Timestamp.now(),
      'Address': "",
    });
  }

  @override
  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      child: Scaffold(
        body: Container(
          height: _height * 10,
          child: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints){
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                  'Sign up Admin',
                                  style: GoogleFonts.raleway(
                                    fontSize: 30,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                controller: adminName,
                                maxLines: 2,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _adminName = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Admin Name:',
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
                                controller: adminEmail,
                                maxLines: 2,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _adminEmail = value,
                                validator: (String value) {

                                  Pattern pattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = new RegExp(pattern);

                                  if (value.length < 0)
                                    return 'Field is empty.';
                                  else if (!regex.hasMatch(value))
                                    return 'Enter Valid Email';
                                  else
                                    return null;

                                },
                                decoration: InputDecoration(
                                  labelText: 'Admin Email:',
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
                                controller: adminPassword,
                                maxLines: 2,
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _adminPassword = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Admin Password:',
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
              );
            },
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            height: _height * 0.05,
            width: _width * 0.34,
            child: ProgressButton(
                defaultWidget: const Text('Register',
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
//                color: Color(0xFF121A21),
                color: Color(0xFF2b527f),
                onPressed: () async {
//                  uploadFileProfile();
                  createAccountAuthentication();
                  await Future.delayed(
                      const Duration(milliseconds: 5000), () => 42);
                  return () async {
//                    _saveConfirmedCountToBeneficiaryRespondents();
//                    Navigator.pop(context);
//                    Flushbar(
//                      margin: EdgeInsets.all(8),
//                      borderRadius: 8,
//                      title: 'Message',
//                      message: "Please select type of disaster.",
//                      duration: Duration(seconds: 3),
//                    )
//                      ..show(context);

                    try{
                      final key = _formkeyName.currentState;
                      if (key.validate()){
                        Flushbar(
                          margin: EdgeInsets.all(8),
                          borderRadius: 8,
                          title: 'Message',
                          message: "Please select type of disaster.",
                          duration: Duration(seconds: 3),
                        )
                          ..show(context);
                        adminName.clear();
                        adminEmail.clear();
                        adminPassword.clear();
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
                  };
                }
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class ActivityFeedAdminListofAccounts extends StatefulWidget {
  @override
  _ActivityFeedAdminListofAccountsState createState() => _ActivityFeedAdminListofAccountsState();
}

class _ActivityFeedAdminListofAccountsState extends State<ActivityFeedAdminListofAccounts> {

  bool _autoValidate = false;
  final _formkeyName = GlobalKey<FormState>();


  String _newsTitle;
  String _newDescription;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery
        .of(context)
        .size
        .width;
    final _height = MediaQuery
        .of(context)
        .size
        .height;

    return Container(
      child: Scaffold(
        body: Container(
          child: DefaultTabController(
              length: 3,
              child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size.fromHeight(50.0),
                    child: TabBar(
                      tabs: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Tab(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: _height * 0.01,
                                  ),
                                  Text(
                                      'Barangay',
                                      style: TextStyle(color: Color(0xFF2b527f),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Tab(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: _height * 0.01,
                                  ),
                                  Text(
                                      'Admin',
                                      style: TextStyle(color: Color(0xFF2b527f),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Tab(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: _height * 0.01,
                                  ),
                                  Text(
                                      'Normal Users',
                                      style: TextStyle(color: Color(0xFF2b527f),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  body: Container(
                    color: Colors.white,
                    child: TabBarView(
                        children: [
                          ActivityFeedAdminListofBarangayAcc(),
                          ActivityFeedAdminListofAdmin(),
                          ActivityFeedAdminListofNormalUser(),

                        ]
                    ),
                  )
              )
          ),
        ),
      ),
    );
  }

}

class ActivityFeedAdminListofBarangayAcc extends StatefulWidget {
  @override
  _ActivityFeedAdminListofBarangayAccState createState() => _ActivityFeedAdminListofBarangayAccState();
}

class _ActivityFeedAdminListofBarangayAccState extends State<ActivityFeedAdminListofBarangayAcc> {
  @override

  void initState() {
    super.initState();
  }

  String userI;
  String typeOfUser;
  String _interestedID;
  String _requestorsUniqueID;
  String _requestorsInterestedUniqueID;
  String _requestorsID;
  String _requestorsPicture;
  bool verifiedStatus = false;
  bool orgstat = false;

  final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

  final db = Firestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    _saveConfirmedToBenefactor() async {

      int count = 1;

      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final FirebaseUser user = await _firebaseAuth.currentUser();
      DocumentReference ref = db.collection('HELP REQUEST').document(doc.data['Unique_ID']);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            ref.updateData({
              'Respondents_Count': doc.data['Respondents_Count'] + count,
            });
          });
        }
      });
    }

    _requestorsUniqueID = doc.data['Unique_ID'];

    _requestorsID = doc.data['User_ID'];

    Widget picture()  {
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
        return CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(doc.data['Profile_Picture']),
        );
      }
    }

    if (doc.data['Org_status'] == "Verified"){
      orgstat = true;
    }
    else if (doc.data['Org_status'] == "Not verified"){
      orgstat = false;
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height * 0.13,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Color(0xFF2b527f),

            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget> [
                          picture(),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    '${doc.data['Name of Barangay']}',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(Dformat.format(doc.data['Date_Joined'].toDate()),
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Visibility(
                            visible: orgstat,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                              child: Icon(
                                FontAwesomeIcons.checkCircle,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("View",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(FontAwesomeIcons.arrowRight, size: 10, color: Colors.white,)
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _viewingRequest(dynamic doc) async {
    return showDialog(
        context: context,
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
                    Text("Account Information",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                      ),
                    ),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Name:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Name of Barangay']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Email:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Email']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Barangay Status:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Barangay_Status']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Date Joined:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          Dformat.format(doc.data['Date_Joined'].toDate()),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Contact:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Contact_Number']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                        child: Container(
                            height: _height * 0.05,
                            width: _width * 0.30,
                            child: ProgressButton(
                                defaultWidget: const Text('Close',
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
                                          Colors.white
                                      )
                                  ),
                                ),
                                width: _width * 0.30,
                                height: 40,
                                borderRadius: 20.0,
                                color: Color(0xFF2b527f),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }
                            )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  final myController = TextEditingController();

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Widget StreamBuider(){
      return
        StreamBuilder<QuerySnapshot>(
            stream: db.collection('USERS').where('Type of User', isEqualTo: 'Barangay').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data.documents
                        .map((doc) => InkWell(
                        onDoubleTap: (){

                        },
                        onTap: (){
                          _viewingRequest(doc);
                        },
                        child: buildItem(doc)
                    ))
                        .toList());
              } else {
                return Container(
                    child: Center(
                        child: CircularProgressIndicator()
                    )
                );
              }
            });
    }

    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuider(),
                  ],
                ),
              );
            },
          ),
        )
    );
  }
}

class ActivityFeedAdminListofAdmin extends StatefulWidget {
  @override
  _ActivityFeedAdminListofAdminState createState() => _ActivityFeedAdminListofAdminState();
}

class _ActivityFeedAdminListofAdminState extends State<ActivityFeedAdminListofAdmin> {
  @override

  void initState() {
    super.initState();
  }

  String userI;
  String typeOfUser;
  String _interestedID;
  String _requestorsUniqueID;
  String _requestorsInterestedUniqueID;
  String _requestorsID;
  String _requestorsPicture;
  bool verifiedStatus = false;
  bool orgstat = false;

  final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

  final db = Firestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    _saveConfirmedToBenefactor() async {

      int count = 1;

      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final FirebaseUser user = await _firebaseAuth.currentUser();
      DocumentReference ref = db.collection('HELP REQUEST').document(doc.data['Unique_ID']);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            ref.updateData({
              'Respondents_Count': doc.data['Respondents_Count'] + count,
            });
          });
        }
      });
    }

    _requestorsUniqueID = doc.data['Unique_ID'];

    _requestorsID = doc.data['User_ID'];

    Widget picture()  {
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
        return CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(doc.data['Profile_Picture']),
        );
      }
    }

    if (doc.data['Org_status'] == "Verified"){
      orgstat = true;
    }
    else if (doc.data['Org_status'] == "Not verified"){
      orgstat = false;
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height * 0.13,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Color(0xFF2b527f),

            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget> [
                          picture(),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    '${doc.data['Name of Admin']}',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(Dformat.format(doc.data['Date_Joined'].toDate()),
                                    style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                          Visibility(
                            visible: orgstat,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                              child: Icon(
                                FontAwesomeIcons.checkCircle,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("View",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(FontAwesomeIcons.arrowRight, size: 10, color: Colors.white,)
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  final myController = TextEditingController();

  _viewingRequest(dynamic doc) async {
    return showDialog(
        context: context,
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
                    Text("Account Information",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                      ),
                    ),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Name:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Name of Admin']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Email:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Email']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Admin Status:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Barangay_Status']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Date Joined:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          Dformat.format(doc.data['Date_Joined'].toDate()),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Contact:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Contact_Number']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                        child: Container(
                            height: _height * 0.05,
                            width: _width * 0.30,
                            child: ProgressButton(
                                defaultWidget: const Text('Close',
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
                                          Colors.white
                                      )
                                  ),
                                ),
                                width: _width * 0.30,
                                height: 40,
                                borderRadius: 20.0,
                                color: Color(0xFF2b527f),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }
                            )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Widget StreamBuider(){
      return
        StreamBuilder<QuerySnapshot>(
            stream: db.collection('USERS').where('Type of User', isEqualTo: 'Admin').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data.documents
                        .map((doc) => InkWell(
                        onDoubleTap: (){

                        },
                        onTap: (){
                          _viewingRequest(doc);
                        },
                        child: buildItem(doc)
                    ))
                        .toList());
              } else {
                return Container(
                    child: Center(
                        child: CircularProgressIndicator()
                    )
                );
              }
            });
    }

    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuider(),
                  ],
                ),
              );
            },
          ),
        )
    );
  }
}

class ActivityFeedAdminListofNormalUser extends StatefulWidget {
  @override
  _ActivityFeedAdminListofNormalUserState createState() => _ActivityFeedAdminListofNormalUserState();
}

class _ActivityFeedAdminListofNormalUserState extends State<ActivityFeedAdminListofNormalUser> {
  @override

  void initState() {
    super.initState();
    _reloadCurrentUser();
  }

  String userI;
  String typeOfUser;
  String _interestedID;
  String _requestorsUniqueID;
  String _requestorsInterestedUniqueID;
  String _requestorsID;
  String _requestorsPicture;
  bool verifiedStatus = false;
  bool orgstat = false;


  final db = Firestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showVerifyEmail(dynamic data) {
    showAlert(
      context: context,
      title: "Warning!",
      body: "Please verify email first to donate",
      actions: [
        AlertAction(
            text: "Send Verification Code",
            onPressed: (){
              _sendEmailVerification();
            }
        ),
      ],
      cancelable: true,
    );
  }

  void _reloadCurrentUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    user.reload();
  }

  void _sendEmailVerification () async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    await user.sendEmailVerification();
  }

  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    _saveConfirmedToBenefactor() async {

      int count = 1;

      final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
      final FirebaseUser user = await _firebaseAuth.currentUser();
      DocumentReference ref = db.collection('HELP REQUEST').document(doc.data['Unique_ID']);

      ref.get().then((document) async {
        if (document.exists) {
          setState(() async {
            ref.updateData({
              'Respondents_Count': doc.data['Respondents_Count'] + count,
            });
          });
        }
      });
    }

    _requestorsUniqueID = doc.data['Unique_ID'];

    _requestorsID = doc.data['User_ID'];

    Widget picture()  {
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
        return CircleAvatar(
          radius: 20,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(doc.data['Profile_Picture']),
        );
      }
    }

    if (doc.data['Org_status'] == "Verified"){
      orgstat = true;
    }
    else if (doc.data['Org_status'] == "Not verified"){
      orgstat = false;
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      height: _height * 0.13,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
//            color: Color(0xFFFFFFFF),
            color: Color(0xFF2b527f),

            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget> [
                          picture(),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Text(
                                    '${doc.data['Name of User']}',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
//                              Row(
//                                children: <Widget>[
////                                  Text(Dformat.format(doc.data['Date_Joined'].toDate()),
//                                  Text(doc.data['Date_Joined'],
//                                    style: TextStyle(
//                                        fontSize: 9,
//                                        fontWeight: FontWeight.w800,
//                                        color: Colors.white
//                                    ),
//                                  ),
//                                ],
//                              )
                            ],
                          ),
                          Visibility(
                            visible: orgstat,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, bottom: 5.0),
                              child: Icon(
                                FontAwesomeIcons.checkCircle,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text("View",
                                style: TextStyle(
                                    color: Colors.white
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(FontAwesomeIcons.arrowRight, size: 10, color: Colors.white,)
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _viewingRequest(dynamic doc) async {
    return showDialog(
        context: context,
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
                    Text("Account Information",
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                      ),
                    ),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Name:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Name of User']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Email:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Email']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Admin Status:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Barangay_Status']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Date Joined:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text(
//                          Dformat.format(doc.data['Date_Joined'].toDate()),
//                          style: TextStyle(
//                              fontSize: 15, fontWeight: FontWeight.w800),
//                        ),
//                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Contact:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Contact_Number']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                        child: Container(
                            height: _height * 0.05,
                            width: _width * 0.30,
                            child: ProgressButton(
                                defaultWidget: const Text('Close',
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
                                          Colors.white
                                      )
                                  ),
                                ),
                                width: _width * 0.30,
                                height: 40,
                                borderRadius: 20.0,
                                color: Color(0xFF2b527f),
                                onPressed: () async {
                                  Navigator.pop(context);
                                }
                            )
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }


  final myController = TextEditingController();

  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Widget StreamBuider(){
      return
        StreamBuilder<QuerySnapshot>(
            stream: db.collection('USERS').where('Type of User', isEqualTo: 'Normal User').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    children: snapshot.data.documents
                        .map((doc) => InkWell(
                        onDoubleTap: (){

                        },
                        onTap: (){
                          _viewingRequest(doc);
                        },
                        child: buildItem(doc)
                    ))
                        .toList());
              } else {
                return Container(
                    child: Center(
                        child: CircularProgressIndicator()
                    )
                );
              }
            });
    }

    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          child: new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuider(),
                  ],
                ),
              );
            },
          ),
        )
    );
  }
}



