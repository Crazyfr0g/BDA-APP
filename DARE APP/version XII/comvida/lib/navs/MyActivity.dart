import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/login/loadingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flare_splash_screen/flare_splash_screen.dart';
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
import 'package:loading_animations/loading_animations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class MyActivity extends StatefulWidget {
  MyActivity(
      this.typeOfUser,
      this.UidUser,
      this.nameofUser,
      this.totalConfirmedHelpCount,
      this._userProfile,
      this.orgStatus,
      this.totalConfirmedHelpCountBarangay,
      this.totalGoalReached) : super();

  final String typeOfUser;
  final String UidUser;
  final String nameofUser;
  final int totalConfirmedHelpCount;
  final String _userProfile;
  final String orgStatus;
  final int totalConfirmedHelpCountBarangay;
  final int totalGoalReached;



  @override
  _MyActivityState createState() => _MyActivityState();
}

class _MyActivityState extends State<MyActivity> {
  @override

  void initState() {
    super.initState();
    _knowNameOfUser();
    _buildUserRequest();
  }

  Widget _buildUserRequest() {
    if (widget.typeOfUser == "Barangay") {
      return ActivityFeedBeneficiaryController(widget.UidUser, widget.nameofUser, widget._userProfile, widget.orgStatus, widget.totalConfirmedHelpCountBarangay, widget.totalGoalReached);
    }
    else {
      return ActivityFeedBenefactorController(widget.UidUser, widget.nameofUser, widget.totalConfirmedHelpCount);
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
                  child: TabBarView(children: [
                    ActivityFeedBenefactorPendingList(widget.UidUser, widget._nameOfUser),
                    ActivityFeedBenefactorConfirmedList(widget.UidUser, widget._nameOfUser, widget.totalConfirmedHelpCount),
                    ]
                  ),
                )
            )
        ),
      ),
    );
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

  final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

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
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) => QRcode(doc.data['Confirmed_ID'], doc.data['Unique_ID'])
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
                      fontSize: 20, fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0.0),
                      width: 30.0,
                      child: IconButton(
                          icon:Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          ),
                          onPressed: (){
                            Navigator.pop(context);
                          }
                      ),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Date:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          Dformat.format(data['Confirmed_ConfirmedDate'].toDate()),
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
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: <Widget>[
                      StreamBuilder<QuerySnapshot>(
                          stream: db.collection('CONFIRMED INT BENEFAC').where('Confirmed_ID', isEqualTo: widget.UidUser).snapshots(),
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
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class QRcode extends StatefulWidget {

  QRcode(
      this.confirmedID,
      this.uniqueId
      ) : super();

  final String confirmedID;
  final String uniqueId;

  @override
  _QRcodeState createState() => _QRcodeState();
}

class _QRcodeState extends State<QRcode> {
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

class ActivityFeedBenefactorConfirmedList extends StatefulWidget {
  ActivityFeedBenefactorConfirmedList(
      this.UidUser,
      this._nameOfUser,
      this.totalConfirmedHelpCount) : super();

  final String UidUser;
  final String _nameOfUser;
  final int totalConfirmedHelpCount;

  @override
  _ActivityFeedBenefactorConfirmedListState createState() => _ActivityFeedBenefactorConfirmedListState();
}

class _ActivityFeedBenefactorConfirmedListState extends State<ActivityFeedBenefactorConfirmedList> {
  @override

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

  _viewingRequest(DocumentSnapshot doc) async {

    _deleteConfirmedMessage() async {
      try {
        DocumentReference ref = db.collection('CONFIRMED HELP BENEFICIARY').document(doc.data['Unique_ID']);
        return ref.delete();
      } catch (e) {
        print(e);
      }
    }

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
                    Text("Recieved Information",
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0.0),
                      width: 30.0,
                      child: IconButton(
                          icon:Icon(
                            FontAwesomeIcons.times,
                            size: 17,
                          ),
                          onPressed: (){
                            Navigator.pop(context);
                          }
                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Respondents Name:',
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Recieved By:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Recieced_By']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Recieved Date:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Dformat.format(doc.data['Recieved_Date'].toDate()),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Confirmed Date:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          Dformat.format(doc.data['Confirmed_ConfirmedDate'].toDate()),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Message:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Thank you for helping us, ${doc.data['Respondents_Name']}. \n'
                              'We will make sure your donations will reach to the affected area.\n\n'
                              'Sincerly,\n'
                              '${doc.data['Recieced_By']}.',
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
                            width: _width * 0.25,
                            child: ProgressButton(
                                defaultWidget: const Text('Delete',
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
                                  _deleteConfirmedMessage();
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
                                    '${doc.data['Recieced_By']}',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(Dformat.format(doc.data['Confirmed_ConfirmedDate'].toDate()),
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

  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<QuerySnapshot>(
                            stream: db.collection('CONFIRMED HELP BENEFICIARY')
                                .where('Respondents_ID', isEqualTo: widget.UidUser)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                    children: snapshot.data.documents
                                        .map((doc) => InkWell(
                                        onTap: (){
                                          _viewingRequest(doc);
                                        },
                                        child: buildItem(doc)
                                    ))
                                        .toList());
                              }
                              else {
                                return Center(child: CircularProgressIndicator());
                              }
                            }
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
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
      this.orgStatus,
      this.totalHelpCount,
      this.totalGoalReached) : super();

  final String UidUser;
  final String nameofUser;
  final String _userProfile;
  final String orgStatus;
  final int totalHelpCount;
  final int totalGoalReached;

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
                  child: TabBarView(
                      children: [
                        ActivityFeedBeneficiaryPendingRequest(widget.UidUser, widget.nameofUser, widget._userProfile, widget.orgStatus, widget.totalGoalReached),
                        ConfirmDonationFeedBeneficiary(widget.UidUser, widget.nameofUser, widget.totalHelpCount),
                      ]
                  ),
                )
            )
        ),
      ),
    );
  }
}

class ActivityFeedBeneficiaryPendingRequest extends StatefulWidget {
  ActivityFeedBeneficiaryPendingRequest(
      this.UidUser,
      this.nameofUser,
      this._userProfile,
      this.orgStatus,
      this.totalGoalReached) : super();

  final String UidUser;
  final String nameofUser;
  final String _userProfile;
  final String orgStatus;
  final int totalGoalReached;



  @override
  _ActivityFeedBeneficiaryPendingRequestState createState() => _ActivityFeedBeneficiaryPendingRequestState();
}

class _ActivityFeedBeneficiaryPendingRequestState extends State<ActivityFeedBeneficiaryPendingRequest> {

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

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
                                                widget.totalGoalReached,
                                                widget.UidUser
                                              )
                                          )
                                      );
                                    });
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
      this._uniqueID,
      this.totalGoalReached,
      this.uid) : super();

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
  final int totalGoalReached;
  final String uid;

  @override
  _viewMyRequestState createState() => _viewMyRequestState();
}

class _viewMyRequestState extends State<viewMyRequest> {

  void initState() {
    super.initState();
    _loadCurrentUser();
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

  int count = 1;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  Future getImageNews() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 400, maxHeight: 300);
    setState(() {
      _imageNews = image;
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

  _saveConfirmedGoalCountBarangay() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('USERS').document(widget.uid);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Total_GoalReachedCount': widget.totalGoalReached + count,
          });
          user.reload();
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Total_GoalReachedCount':  count,
          });
          user.reload();
        });
      }
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
    if (widget._typeofDisaster == "[Drought]"){
      try {
        DocumentReference refII = db.collection('DROUGHT REQUESTS').document(widget._uniqueID);
        return refII.delete();
      } catch (e) {
        print(e);
      }
    }
    else if (widget._typeofDisaster == "[Earthquake]"){
      try {
        DocumentReference refII = db.collection('EARTHQUAKE REQUESTS').document(widget._uniqueID);
        return refII.delete();
      } catch (e) {
        print(e);
      }
    }
    else if (widget._typeofDisaster == "[Flood]"){
      try {
        DocumentReference refII = db.collection('FLOOD REQUESTS').document(widget._uniqueID);
        return refII.delete();
      } catch (e) {
        print(e);
      }
    }
    else if (widget._typeofDisaster == "[Landslide]"){
      try {
        DocumentReference refII = db.collection('LANDSLIDE REQUESTS').document(widget._uniqueID);
        return refII.delete();
      } catch (e) {
        print(e);
      }
    }
    else if (widget._typeofDisaster == "[Tsunami]"){
      try {
        DocumentReference refII = db.collection('TSUNAMI REQUESTS').document(widget._uniqueID);
        return refII.delete();
      } catch (e) {
        print(e);
      }
    }
    else if (widget._typeofDisaster == "[Typhoon]"){
      try {
        DocumentReference refII = db.collection('TYPHOON REQUESTS').document(widget._uniqueID);
        return refII.delete();
      } catch (e) {
        print(e);
      }
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
                              fontSize: 20,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0.0),
                        width: 30.0,
                        child: IconButton(
                            icon:Icon(
                              FontAwesomeIcons.times,
                              size: 17,
                            ),
                            onPressed: (){
                              Navigator.pop(context);
                            }
                        ),
                      ),
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
                            setState(() {
                              _saveConfirmedGoalCountBarangay();
                            });
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

  _displayResponses () async {
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
                              fontSize: 20,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0.0),
                        width: 30.0,
                        child: IconButton(
                            icon:Icon(
                              FontAwesomeIcons.times,
                              size: 17,
                            ),
                            onPressed: (){
                              Navigator.pop(context);
                            }
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            content: Text(
              'Are you sure to delete this post?',
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
      if (widget._Profpic == null || widget._Profpic == ""){
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

    List<String> choices = <String>[
      'Edit',
      'Delete',
    ];

    choiceAction(String choice){
      if (choice == "Edit"){
        _updatePost(
          widget._PostDestription,
          widget._PostFamiliesAffected,
          widget._PostAffectedArea,
          widget._PostThingsNeeded,
          widget._PostDropoffLocation,
          widget._PostContactDetails,
        );
      }
      else {
        _displayResponses();
      }
    }

    return Container(
      color: Colors.white,
      child: Scaffold (
        appBar: new AppBar(
          leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed: (){
                Navigator.pop(context);
                Flushbar(
                  flushbarPosition: FlushbarPosition.BOTTOM,
                  isDismissible: false,
                  routeBlur: 15,
                  routeColor: Colors.white
                      .withOpacity(0.10),
                  padding: EdgeInsets.only(bottom: 50, left: 350),
                  backgroundColor: Colors.white
                      .withOpacity(0.10),
                  message: " ",
                  duration: Duration(milliseconds: 1500),
                )
                  ..show(context).then((result) {
                    setState(() {
                      Navigator.pop(context);
                    });
                  });
           }
          ),
          backgroundColor: Color(0xFF2b527f),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext buildContext){
                return choices.map((String choice){
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
            'Help_BankAccountName': '${_bankAccountName}',
            'Help_BankAccountNumber': '${_bankAccountNumber}',
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
          'Help_BankAccountName': '${_bankAccountName}',
          'Help_BankAccountNumber': '${_bankAccountNumber}',
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
          'Help_BankAccountName': '${_bankAccountName}',
          'Help_BankAccountNumber': '${_bankAccountNumber}',
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
      child: Scaffold(
          appBar: new AppBar(
              backgroundColor: Color(0xFF2b527f),
              title: new Text('Requesting for help'),
              leading: IconButton(icon:Icon(Icons.arrow_back),
                onPressed: (){
                  Navigator.pop(context);
                  Flushbar(
                    flushbarPosition: FlushbarPosition.BOTTOM,
                    isDismissible: false,
                    routeBlur: 15,
                    routeColor: Colors.white
                        .withOpacity(0.10),
                    padding: EdgeInsets.only(bottom: 50, left: 350),
                    backgroundColor: Colors.white
                        .withOpacity(0.10),
                    message: " ",
                    duration: Duration(milliseconds: 1500),
                  )
                    ..show(context).then((result) {
                      setState(() {
                        Navigator.pop(context);
                      });
                    });
               }
              )
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
                                                  validator: (String value) {
                                                    if (value.length < 1)
                                                      return 'Please indicate Account Name.';
                                                    else
                                                      return null;
                                                  },
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
                                                  validator: (String value) {
                                                    if (value.length < 1 )
                                                      return 'Please indicate Account Number.';
                                                    else
                                                      return null;
                                                  },
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
                                        final keyBank = _formkeyBank.currentState;

                                        if (key.validate() == false && keyResponse.validate() == false && keyBank.validate() == false) {
                                          _autoValidatekeyResponse = true;
                                          _autoValidatekey = true;
                                          _autoValidatebank = true;
                                        }

                                        else if (key.validate() && keyResponse.validate() == false)  {
                                          _autoValidatekeyResponse = true;
                                        }
                                        else if (key.validate() == false && keyResponse.validate()) {
                                          _autoValidatekey = true;
                                        }

                                        else if (key.validate() && keyResponse.validate() && keyBank.validate() == false){
                                          _autoValidatebank = true;
                                        }

                                        else if (key.validate() == false && keyResponse.validate() && keyBank.validate() ){
                                          _autoValidatekey = true;
                                        }

                                        else if (key.validate()  && keyResponse.validate() == false && keyBank.validate() ){
                                          _autoValidatekeyResponse = true;
                                        }

                                        else if (key.validate() == false  && keyResponse.validate() == false && keyBank.validate() ){
                                          _autoValidatekeyResponse = true;
                                          _autoValidatekey = true;
                                        }

                                        else if (key.validate() == false  && keyResponse.validate()  && keyBank.validate() == false){
                                          _autoValidatebank = true;
                                          _autoValidatekey = true;
                                        }

                                        else if (key.validate() == false  && keyResponse.validate() == false && keyBank.validate() ){
                                          _autoValidatekeyResponse = true;
                                          _autoValidatekey = true;
                                        }

                                        else if (key.validate()  && keyResponse.validate() == false && keyBank.validate() == false){
                                          _autoValidatekeyResponse = true;
                                          _autoValidatebank = true;
                                        }

                                        else if (key.validate()  && keyResponse.validate() == false && keyBank.validate() == false){
                                          _autoValidatekeyResponse = true;
                                          _autoValidatebank = true;
                                        }

                                        else if (key.validate() == false && keyResponse.validate()  && keyBank.validate() == false){
                                          _autoValidatebank = true;
                                          _autoValidatekey = true;
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
                                        else {
                                          _saveIssueToEachDisaster();
                                          flush = Flushbar<bool>(
                                            duration: Duration(seconds: 2),
                                            blockBackgroundInteraction: true,
                                            isDismissible: false,
                                            routeBlur: 50,
                                            routeColor: Colors.white
                                                .withOpacity(0.50),
                                            margin: EdgeInsets.all(8),
                                            borderRadius: 8,
                                            title: "Message",
                                            message: "Your request has been posted.",
//                                            mainButton: FlatButton(
//                                              onPressed: () async {
//                                                flush.dismiss(true);
//                                              },
//                                              child: Text(
//                                                "Confirm",
//                                                style: TextStyle(
//                                                    color: Colors.amber),
//                                              ),
//                                            ),
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
      this.nameofUser,
      this.totalHelpCount) : super();

  final String UidUser;
  final String nameofUser;
  final int totalHelpCount;


  @override
  _ConfirmDonationFeedBeneficiaryState createState() => _ConfirmDonationFeedBeneficiaryState();
}

class _ConfirmDonationFeedBeneficiaryState extends State<ConfirmDonationFeedBeneficiary> {
  @override

  void initState() {
    super.initState();
    _loadCurrentUser();
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

  int count = 1;
  int totalHelp;

  _loadCurrentUser() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    db.collection('USERS').document(user.uid).get().then((DocumentSnapshot ds) {
      setState(() {
        this.totalHelp = ds['Type Confirmed_Helpcount'];
      });
    });
  }

  _saveConfirmedHelpCountBarangay() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('USERS').document(widget.UidUser);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Total_ConfirmedHelp': widget.totalHelpCount + count,
          });
          user.reload();
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Total_ConfirmedHelp': widget.totalHelpCount + count,
          });
          user.reload();
        });
      }
    });
  }

  _saveConfirmedHelpBeneficiary(dynamic data) async {
    String id = uuid.v1();

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    DocumentReference ref = db.collection('CONFIRMED HELP BENEFICIARY').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Confirmed_ConfirmedDate': Timestamp.now(),
            'Received_AllItems': 'Yes',
            'Recieced_By': data['Requestors_Name'],
            'Recieved_Date': data['Confirmed_ConfirmedDate'],
            'Respondents_Name': data['Respondents_Name'],
            'Respondents_ID': data['Confirmed_ID'],
            'Requestors_ID': data['Requestors_ID'],
            'Unique_ID': id,
            'Request_AreaAffected': data['Request_AreaAffected']
          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'Confirmed_ConfirmedDate': Timestamp.now(),
            'Received_AllItems': 'Yes',
            'Recieced_By': data['Requestors_Name'],
            'Recieved_Date': data['Confirmed_ConfirmedDate'],
            'Respondents_Name': data['Respondents_Name'],
            'Respondents_ID': data['Confirmed_ID'],
            'Requestors_ID': data['Requestors_ID'],
            'Unique_ID': id,
            'Request_AreaAffected': data['Request_AreaAffected']
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
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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

  _viewingRequest(DocumentSnapshot doc) async {


    Widget pictureMoney() {
      if (doc.data['ImageMoney'] == null || doc.data['ImageMoney'] == "")
      {
        return Image.asset('assets/no-image.png',
            fit: BoxFit.contain);
      }
      else {
        return Image.network(doc.data['ImageMoney'],
            fit: BoxFit.contain);
      }
    }

    Widget pictureFood() {
      if (doc.data['ImageFood'] == null || doc.data['ImageFood'] == "")
      {
        return Image.asset('assets/no-image.png',
            fit: BoxFit.contain);
      }
      else {
        return Image.network(doc.data['ImageFood'],
            fit: BoxFit.contain);
      }
    }

    Widget pictureClothes() {
      if (doc.data['ImageClothes'] == null || doc.data['ImageClothes'] == "")
      {
        return Image.asset('assets/no-image.png',
            fit: BoxFit.contain);
      }
      else {
        return Image.network(doc.data['ImageClothes'],
            fit: BoxFit.contain);
      }
    }


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
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Donation Info",
                      style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(0.0),
                      width: 30.0,
                      child: IconButton(
                         icon:Icon(
                           FontAwesomeIcons.times,
                           size: 17,
                         ),
                         onPressed: (){
                           Navigator.pop(context);
                         }
                      ),
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
                            width: _width * 0.30,
                            child: Card(
                              elevation: 2,
                              child: Container(
                                height: _height * 0.20,
                                child:  FittedBox(
                                    child: pictureMoney(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          )
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Container(
                              width: _width * 0.30,
                              child: Card(
                                elevation: 2,
                                child: Container(
                                  height: _height * 0.20,
                                  child:  FittedBox(
                                    child: pictureFood(),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Container(
                              width: _width * 0.30,
                              child: Card(
                                elevation: 2,
                                child: Container(
                                  height: _height * 0.20,
                                  child:  FittedBox(
                                    child: pictureClothes(),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
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
                      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, top: 5),
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
                                setState(() {
                                  if (_recievedItemState == null){
                                    print('error');
                                  }
                                  else if (_recievedItemState == '[]'){
                                    print('error');
                                  }
                                  else{
//                                  _saveConfirmedHelpBeneficiary(doc.data);
//                                  _saveConfirmedHelpCountBarangay(doc.data['Requestors_ID']);
//                                  _deleteInterested(doc.data['Unique_ID']);
                                    setState(() {
                                      _saveConfirmedHelpBeneficiary(doc.data);
                                      _saveConfirmedHelpCountBarangay();
                                      _deleteInterested(doc.data['Unique_ID']);
                                    });
                                  }
                                });
                                await Future.delayed(
                                    const Duration(milliseconds: 3000), () => 42);
                                return () {
                                  _scanBarcode = "";

                                  if (_recievedItemState == null){
                                    Flushbar(
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Hey, ${doc.data['Requestors_Name']}.",
                                      message: "Please check the check box below if you have recieved all of the donations.",
                                      duration: Duration(seconds: 3),
                                    )
                                      ..show(context);
                                  }
                                  else if (_recievedItemState == '[]'){
                                    Flushbar(
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Hey, ${doc.data['Requestors_Name']}.",
                                      message: "Please check the check box below if you have recieved all of the donations.",
                                      duration: Duration(seconds: 3),
                                    )
                                      ..show(context);
                                  }
                                  else{
                                    flush = Flushbar<bool>(
                                      duration: Duration(seconds: 2),
                                      blockBackgroundInteraction: true,
                                      isDismissible: false,
                                      routeBlur: 50,
                                      routeColor: Colors.white.withOpacity(0.50),
                                      margin: EdgeInsets.all(8),
                                      borderRadius: 8,
                                      title: "Message",
                                      message: "Successfully confirmed the dontation.",
                                    )
                                      ..show(context).then((result) {
                                        setState(() {
                                          Navigator.pop(context);
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

    });
  }

  _viewingRequests() async {
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
//                      Row(
//                        children: <Widget>[
//                          Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: Text(
//                              '${doc.data['Name of User']}',
//                              style: TextStyle(
//                                  fontSize: 15, fontWeight: FontWeight.w800),
//                            ),
//                          ),
//                        ],
//                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Email:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
//                      Row(
//                        crossAxisAlignment: CrossAxisAlignment.center,
//                        children: <Widget>[
//                          Padding(
//                            padding: const EdgeInsets.all(8.0),
//                            child: Text(
//                              '${doc.data['Email']}',
//                              style: TextStyle(
//                                  fontSize: 15, fontWeight: FontWeight.w800),
//                            ),
//                          ),
//                        ],
//                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Password:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text(
//                          '${doc.data['Password']}',
//                          style: TextStyle(
//                              fontSize: 15, fontWeight: FontWeight.w800),
//                        ),
//                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Admin Status:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text(
//                          '${doc.data['Barangay_Status']}',
//                          style: TextStyle(
//                              fontSize: 15, fontWeight: FontWeight.w800),
//                        ),
//                      ),
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
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: Text(
//                          '${doc.data['Contact_Number']}',
//                          style: TextStyle(
//                              fontSize: 15, fontWeight: FontWeight.w800),
//                        ),
//                      ),
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
      else{
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('CONFIRMED INT BENEFAC').where('Unique_ID', isEqualTo: _scanBarcode).snapshots(),
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



