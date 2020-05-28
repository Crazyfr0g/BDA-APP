import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_progress_button/flutter_progress_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;



class NewsFeed extends StatefulWidget {
  NewsFeed(
      this.typeOfUser,
      this.availableDonations,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount,
      this.nameofUser,
      this.userProfile,
      this.userID) : super();

  final String typeOfUser;
  final String availableDonations;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;
  final String nameofUser;
  final String userProfile;
  final String userID;

  @override
  _NewsFeedState createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  String typeOfUser;
  final db = Firestore.instance;

  @override

  void initState() {
    super.initState();
    _knowNameOfUser();
    _buildNewsRequest();
  }


  Icon cusIcon = Icon(FontAwesomeIcons.search);
  Widget cusAppBarTitle = Text
    ('B-DA',
      style: GoogleFonts.raleway(
        textStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
        ),
      )
  );

  final myController = TextEditingController();


  Widget _buildNewsRequest() {
    if (widget.typeOfUser == "Barangay") {
      return DroughtFeedBeneficiary(widget.nameofUser, widget.userProfile, widget.userID, myController);
    }
    else if (widget.typeOfUser == "Normal User") {
      return DroughtFeedBenefactor(widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount);
    }
    else if (widget.typeOfUser == "Admin"){
      return DroughtFeedAdmin(widget.nameofUser, widget.userProfile, widget.userID);

    }
  }

  void _knowNameOfUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    db.collection('USERS').document(user.uid).get().then((DocumentSnapshot ds) {
      setState(() {
        this.typeOfUser = ds['Type of User'];

      });
    });
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppBar(
          backgroundColor: Color(0xFF2b527f),
          title: cusAppBarTitle,
          actions: <Widget>[
            IconButton(
              onPressed: (){
                setState(() {
                  if(this.cusIcon.icon == FontAwesomeIcons.search){
                    this.cusIcon = Icon(FontAwesomeIcons.timesCircle);
                    this.cusAppBarTitle = Container(
                      height: _height * 0.05,
                      child: new Theme(
                        data: new ThemeData(
                          primaryColor: Color(0xFFFFFFFF),
                        ),
                        child: TextFormField(
                          controller: myController,
                          autofocus: false,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          keyboardType: TextInputType.text,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: const BorderSide(color: Colors.white, width: 2),
                              ),
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 15),
                              hintText: "Search Barangay",
                              hintStyle:
                              TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFFFFFF)
                              )),
                        ),
                      ),
                    );
                  }
                  else{
                    setState(() {
                      myController.text = "";
                      this.cusIcon = Icon(FontAwesomeIcons.search);
                      this.cusAppBarTitle = Text
                        ('B-DA',
                          style: GoogleFonts.raleway(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFFFFF),
                            ),
                          )
                      );
                    });
                  }
                });
              },
              icon: cusIcon,
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
          child: _buildNewsRequest()
      ),
    );
  }

}

class DroughtFeedBenefactor extends StatefulWidget {
  DroughtFeedBenefactor(
      this.availableDonations,
      this.totalInterestedCount,
      this.totalConfirmedhelpCount,) : super();

      final String availableDonations;
      final int totalInterestedCount;
      final int totalConfirmedhelpCount;

  @override
  _DroughtFeedBenefactorState createState() => _DroughtFeedBenefactorState();
}

class _DroughtFeedBenefactorState extends State<DroughtFeedBenefactor> {
  void initState() {
    super.initState();
  }

  String _requestorsID;
  String typeOfUser;
  bool orgstat = false;
  var uuid = Uuid();


  final _formkeyResponse = GlobalKey<FormState>();
  bool _autoValidate = false;


  final db = Firestore.instance;
  String _NewsDescription;
  String _NewsTitle;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    Widget picture() {
      if (doc.data['News_Image'] == null || doc.data['News_Image'] == "") {
        return Image.asset('assets/no-image.png',
            fit: BoxFit.contain);

      }
      else {
        return Image.network(doc.data['News_Image'],
            fit: BoxFit.contain);
      }
    }

    _requestorsID = '${doc.data['User_ID']}';

    if (doc.data['Org_status'] == "Verified"){
      orgstat = true;
    }
    else if (doc.data['Org_status'] == "Not verified"){
      orgstat = false;
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Card(
//          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: _width * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            '${doc.data['News_Title']}',
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(Dformat.format(doc.data['News_Timeposted'].toDate()),
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            width: _width * 0.85,
                            child: Card(
                              elevation: 2,
                              child: Container(
                                height: _height * 0.30,
                                child:  FittedBox(
                                  child: picture(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      ExpandablePanel(
                        header: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(doc.data['News_Postedby'],),
                        ),
                        collapsed: Text('${doc.data['News_Description']}', maxLines: 1, overflow: TextOverflow.ellipsis,),
                        expanded: Text('${doc.data['News_Description']}', softWrap: true, textAlign: TextAlign.justify,),
                        tapHeaderToExpand: true,
                        hasIcon: true,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override

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
                      stream: db.collection('BRGY NEWS').orderBy('News_Timeposted', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                              children: snapshot.data.documents
                                  .map((doc) => buildItem(doc))
                                  .toList());
                        }
                        else if (snapshot.hasData == null) {
                          return Container(
                              child: Center(
                                  child: Text("No data")
                              )
                          );
                        }
                        else{
                         return Container();
                        }
                      }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}


class DroughtFeedBeneficiary extends StatefulWidget {
  DroughtFeedBeneficiary(
      this.nameofUser,
      this.userProfile,
      this.userID,
      this.mycontroller) : super();

  final String nameofUser;
  final String userProfile;
  final String userID;
  final mycontroller;

  @override
  _DroughtFeedBeneficiaryState createState() => _DroughtFeedBeneficiaryState();
}

class _DroughtFeedBeneficiaryState extends State<DroughtFeedBeneficiary> {

  void initState() {
    super.initState();
    countDocuments();
  }

  String _requestorsID;
  String typeOfUser;
  bool orgstat = false;
  var uuid = Uuid();


  final _formkeyResponse = GlobalKey<FormState>();
  bool _autoValidate = false;


  final db = Firestore.instance;
  String _NewsDescription;
  String _NewsTitle;
  final _formkeyName = GlobalKey<FormState>();
  final sad = GlobalKey<FormState>();

  String _newsTitle;
  String _newDescription;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  void countDocuments() async {
    QuerySnapshot _myDoc = await Firestore.instance.collection('HELP REQUEST').getDocuments();
    List<DocumentSnapshot> _myDocCount = _myDoc.documents;
    print(_myDocCount.length);  // Count of Documents in Collection
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
            'News_Timeposted': time,
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile
          });
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({
            'User_ID': user.uid,
            'Unique_ID': id,
            'News_Title': _NewsTitle,
            'News_Description': _NewsDescription,
            'News_Timeposted': time,
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile
          });
          user.reload();
        });
      }
    });
  }

  saveEditNews(String newsUniqueID) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('BRGY NEWS').document(newsUniqueID);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({
            'News_Description': _newDescription,
            'News_Title': _newsTitle});
        });
      } else {
        setState(() async {
          await ref
              .setData({
            'News_Description': _newDescription,
            'News_Title': _newsTitle});
        });
      }
    });
  }

  _updatePost(
      String newsTitle,
      String newsDescription,
      String newsImage,
      String newsUniqueID) async {
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
                            child: Text("Edit News",
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
                                maxLines: 5,
                                initialValue: "${newsTitle}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _newsTitle = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'News Title:',
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
                                maxLines: 5,
                                initialValue: "${newsDescription}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _newDescription = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'News Description:',
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
                            saveEditNews(newsUniqueID);
//                            saveName();
                            await Future.delayed(
                                const Duration(seconds: 5), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()){
                                setState(() {
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

  Container buildItem(DocumentSnapshot doc) {

    editNews(
        String newsTitle,
        String newsDescription,
        String newsImage,
        ){

      _deleteHelpRequest() async {
        try {
          DocumentReference ref = db.collection('BRGY NEWS').document(doc.data['Unique_ID']);
          return ref.delete();
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
                  'Are you sure to delete this news?',
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

      choiceAction(String choice){
        if (choice == "Edit"){
          _updatePost(newsTitle, newsDescription, newsImage, doc.data['Unique_ID']);
        }
        else {
          _displayResponse();
        }
      }

      List<String> choices = <String>[
        'Edit',
        'Delete',
      ];

      if (doc.data['User_ID'] == widget.userID){
       return(
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
       );
      }
    }

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    Widget picture() {
      if (doc.data['News_Image'] == null || doc.data['News_Image'] == "") {
        return Image.asset('assets/no-image.png',
            fit: BoxFit.contain);

      }
      else {
        return Image.network(doc.data['News_Image'],
            fit: BoxFit.contain);
      }
    }

    _requestorsID = '${doc.data['User_ID']}';

    if (doc.data['Org_status'] == "Verified"){
      orgstat = true;
    }
    else if (doc.data['Org_status'] == "Not verified"){
      orgstat = false;
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: _width * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  '${doc.data['News_Title']}',
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      fontSize: 25, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15, bottom: 15),
                              child: editNews(
                                doc.data['News_Title'],
                                doc.data['News_Description'],
                                doc.data['News_Image']
                              )
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(Dformat.format(doc.data['News_Timeposted'].toDate()),
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            width: _width * 0.85,
                            child: Card(
                              elevation: 2,
                              child: Container(
                                height: _height * 0.30,
                                child:  FittedBox(
                                  child: picture(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ExpandablePanel(
                        header: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(doc.data['News_Postedby'],
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        collapsed: Text('${doc.data['News_Description']}', maxLines: 1, overflow: TextOverflow.ellipsis,),
                        expanded: Text('${doc.data['News_Description']}', softWrap: true, textAlign: TextAlign.justify,),
                        tapHeaderToExpand: true,
                        hasIcon: true,
              )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override

  Widget build(BuildContext context) {

//    Widget StreamBuider(){
//
//      if (widget.mycontroller.text == ""){
//        return
//          StreamBuilder<QuerySnapshot>(
//              stream: db.collection('BRGY NEWS').orderBy('News_Timeposted', descending: true).snapshots(),
//              builder: (context, snapshot) {
//                if (snapshot.hasData) {
//                  return Column(
//                      children: snapshot.data.documents
//                          .map((doc) => buildItem(doc))
//                          .toList());
//                }
//                else {
//                  return Container(
//                      child: Center(
//                          child: CircularProgressIndicator()
//                      )
//                  );
//                }
//              });
//      }
//      else
//      {
//        return
//          StreamBuilder<QuerySnapshot>(
//              stream: db.collection('BRGY NEWS').where('News_Postedby', isEqualTo: '${widget.mycontroller.text}').snapshots(),
//              builder: (context, snapshot) {
//                if (snapshot.hasData) {
//                  return Column(
//                      children: snapshot.data.documents
//                          .map((doc) => buildItem(doc))
//                          .toList());
//                } else {
//                  return Container(
//                      child: Center(
//                          child: CircularProgressIndicator()
//                      )
//                  );
//                }
//              });
//      }
//    }

    Widget StreamBuider(){

      if (widget.mycontroller.text == ""){
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('BRGY NEWS').orderBy('News_Timeposted', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                      children: snapshot.data.documents
                          .map((doc) => buildItem(doc))
                          .toList());
                }
                else {
                  return Container(
                      child: Center(
                          child: CircularProgressIndicator()
                      )
                  );
                }
              });
      }
      else
      {
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('BRGY NEWS').where('News_Postedby', isEqualTo: '${widget.mycontroller.text}').snapshots(),
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
                  StreamBuider(),
//                  StreamBuilder<QuerySnapshot>(
//                      stream: db.collection('BRGY NEWS').orderBy('News_Timeposted', descending: true).snapshots(),
//                      builder: (context, snapshot) {
//                        if (snapshot.hasData) {
//                          return Column(
//                              children: snapshot.data.documents
//                                  .map((doc) => buildItem(doc))
//                                  .toList());
//                        }
//                        else {
//                          return Container(
//                              child: Center(
//                                  child: CircularProgressIndicator()
//                              )
//                          );
//                        }
//                      }),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: FloatingActionButton(
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => addNewNews(widget.nameofUser, widget.userProfile)
                )
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF2b527f),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class addNewNews extends StatefulWidget {
  addNewNews(
      this.nameofUser,
      this.userProfile) : super();

  final String nameofUser;
  final String userProfile;

  @override
  _addNewNewsState createState() => _addNewNewsState();
}

class _addNewNewsState extends State<addNewNews> {

  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    return Container(
    color: Colors.white,
      child: Scaffold(
        appBar: new AppBar(
            backgroundColor: Color(0xFF2b527f),
            title: new Text('Post News')
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0, bottom: 15.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Form(
                            key: _formkeyResponse,
                            autovalidate: _autoValidate,
                            child: Container(
                              height: _height * 0.45,
                              width: _width * 0.80,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: _width * .75
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        maxLines: 2,
                                        onSaved: (value) => _NewsTitle = value,
                                        validator: (String value) {
                                          if (value.length < 1)
                                            return 'Title, field is empty';
                                          else if (value.length <= 3)
                                            return 'Title, must be longer than 3 letters.';
                                          else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          icon: Icon(FontAwesomeIcons.featherAlt),
                                          labelText: 'Title',
                                          labelStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: _height * 0.05,
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: _width * .75
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        maxLines: 5,
                                        onSaved: (value) => _NewsDescription = value,
                                        validator: (String value) {
                                          if (value.length < 1)
                                            return 'Description, field is empty';
                                          else if (value.length <= 10)
                                            return 'Content, must be longer than 10 letters.';
                                          else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          icon: Icon(FontAwesomeIcons.info),
                                          labelText: 'Content of news',
                                          labelStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text('Please upload one image for the news content.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800
                            ),
                          ),
                        ),
                        Center(
                          child: RaisedButton(
                            child: Text("Choose Image:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            onPressed: (){
                              getImageNews();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              child: _imageNews == null
                                  ?
                              Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('',
                                    ),
                                  )
                              )
                                  :
                              Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.file(_imageNews),
                                  )
                              )

                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0, top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                        if (_imageNews == null){
                                          print("Upload a picute");
                                        }
                                        else{
                                          uploadFileNewsImage();
                                        }
                                        await Future.delayed(
                                            const Duration(seconds: 7), () => 42);
                                        return () async {
                                          final key = _formkeyResponse.currentState;
                                          if (key.validate() == false) {
                                            _autoValidate = true;
                                          }
                                          else if(key.validate() != false && _imageNews == null){
                                            Flushbar(
                                              margin: EdgeInsets.all(8),
                                              borderRadius: 8,
                                              title: "Message",
                                              message: "Please upload one picture.",
                                              duration: Duration(seconds: 3),
                                            )
                                              ..show(context);
                                          }
                                          else {
                                            saveNews();
                                            flush = Flushbar<bool>(
                                              isDismissible: false,
                                              routeBlur: 50,
                                              routeColor: Colors.white.withOpacity(0.50),
                                              margin: EdgeInsets.all(8),
                                              borderRadius: 8,
                                              title: "Message",
                                              message: "You have posted a new news.",
                                              duration: Duration(seconds: 2),
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
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        )
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
}

class editNewS extends StatefulWidget {
  editNewS(
      this.nameofUser,
      this.userProfile) : super();

  final String nameofUser;
  final String userProfile;
  @override
  _editNewSState createState() => _editNewSState();
}

class _editNewSState extends State<editNewS> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


class DroughtFeedAdmin extends StatefulWidget {
  DroughtFeedAdmin(
      this.nameofUser,
      this.userProfile,
      this.userID) : super();

  final String nameofUser;
  final String userProfile;
  final String userID;

  @override
  _DroughtFeedAdminState createState() => _DroughtFeedAdminState();
}

class _DroughtFeedAdminState extends State<DroughtFeedAdmin> {
  void initState() {
    super.initState();
    countDocuments();
  }

  String _requestorsID;
  String typeOfUser;
  bool orgstat = false;
  var uuid = Uuid();


  final _formkeyResponse = GlobalKey<FormState>();
  bool _autoValidate = false;


  final db = Firestore.instance;
  String _NewsDescription;
  String _NewsTitle;
  final _formkeyName = GlobalKey<FormState>();
  final sad = GlobalKey<FormState>();

  String _newsTitle;
  String _newDescription;


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  void countDocuments() async {
    QuerySnapshot _myDoc = await Firestore.instance.collection('HELP REQUEST')
        .getDocuments();
    List<DocumentSnapshot> _myDocCount = _myDoc.documents;
    print(_myDocCount.length); // Count of Documents in Collection
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
            'News_Timeposted': time,
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile
          });
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({
            'User_ID': user.uid,
            'Unique_ID': id,
            'News_Title': _NewsTitle,
            'News_Description': _NewsDescription,
            'News_Timeposted': time,
            'News_Postedby': widget.nameofUser,
            'Profile_Picture': widget.userProfile
          });
          user.reload();
        });
      }
    });
  }

  saveEditNews(String newsUniqueID) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    final nameKey = _formkeyName.currentState;
    nameKey.save();

    DocumentReference ref = db.collection('BRGY NEWS').document(newsUniqueID);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({
            'News_Description': _newDescription,
            'News_Title': _newsTitle});
        });
      } else {
        setState(() async {
          await ref
              .setData({
            'News_Description': _newDescription,
            'News_Title': _newsTitle});
        });
      }
    });
  }

  _updatePost(String newsTitle,
      String newsDescription,
      String newsImage,
      String newsUniqueID) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          final _width = MediaQuery
              .of(context)
              .size
              .width;
          final _height = MediaQuery
              .of(context)
              .size
              .height;
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
                            child: Text("Edit News",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 10.0, bottom: 3),
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
                                maxLines: 5,
                                initialValue: "${newsTitle}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _newsTitle = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'News Title:',
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
                                maxLines: 5,
                                initialValue: "${newsDescription}",
                                keyboardType: TextInputType.text,
                                onSaved: (value) => _newDescription = value,
                                validator: (String value) {
                                  if (value.length < 1)
                                    return 'Field is empty.';
                                  else
                                    return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'News Description:',
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
                            saveEditNews(newsUniqueID);
                            await Future.delayed(
                                const Duration(seconds: 5), () => 42);
                            return () async {
                              final key = _formkeyName.currentState;
                              if (key.validate()) {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              } else {
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
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.02,
                  ),
                ],
              )
            ],
          );
        });
  }

  Container buildItem(DocumentSnapshot doc) {

    editNews(String newsTitle,
        String newsDescription,
        String newsImage,) {

      _deleteHelpRequest() async {
        try {
          DocumentReference ref = db.collection('BRGY NEWS').document(doc.data['Unique_ID']);
          return ref.delete();
        } catch (e) {
          print(e);
        }
      }

      _displayResponse() async {
        return showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              final _width = MediaQuery
                  .of(context)
                  .size
                  .width;
              final _height = MediaQuery
                  .of(context)
                  .size
                  .height;
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
                  'Are you sure to delete this news?',
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
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.02,
                        ),
                      ],
                    ),
                  )
                ],
              );
            });
      }

      choiceAction(String choice) {
        if (choice == "Edit") {
          _updatePost(
              newsTitle, newsDescription, newsImage, doc.data['Unique_ID']);
        }
        else {
          _displayResponse();
        }
      }
      List<String> choices = <String>[
        'Edit',
        'Delete',
      ];

      return (
            PopupMenuButton<String>(
              onSelected: choiceAction,
              itemBuilder: (BuildContext buildContext) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
        );
    }

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    Widget picture() {
      if (doc.data['News_Image'] == null || doc.data['News_Image'] == "") {
        return Image.asset('assets/no-image.png',
            fit: BoxFit.contain);
      }
      else {
        return Image.network(doc.data['News_Image'],
            fit: BoxFit.contain);
      }
    }

    _requestorsID = '${doc.data['User_ID']}';

    if (doc.data['Org_status'] == "Verified") {
      orgstat = true;
    }
    else if (doc.data['Org_status'] == "Not verified") {
      orgstat = false;
    }

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return Container(
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Card(
//          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: _width * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 7,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  '${doc.data['News_Title']}',
                                  maxLines: 10,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, bottom: 15),
                                child: editNews(
                                    doc.data['News_Title'],
                                    doc.data['News_Description'],
                                    doc.data['News_Image']
                                )
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(Dformat.format(
                                doc.data['News_Timeposted'].toDate()),
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            width: _width * 0.85,
                            child: Card(
                              elevation: 2,
                              child: Container(
                                height: _height * 0.30,
                                child:  FittedBox(
                                  child: picture(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

//                      Padding(
//                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
//                        child: Text('News:', style: TextStyle(
//                          fontSize: 11.5,
//                        ),
//                        ),
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.all(8.0),
//                        child: GestureDetector(
//                          onTap: (){
//                            setState(() {
//
//                            });
//                          },
//                          child: Text(
//                            '${doc.data['News_Description']}',
//                            maxLines: 10,
//                            overflow: TextOverflow.ellipsis,
//                            textAlign: TextAlign.justify,
//                            style: TextStyle(
//                                fontSize: 13.5, fontWeight: FontWeight.w500),
//                          ),
//                        ),
//                      ),

                      ExpandablePanel(
                        header: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(doc.data['News_Postedby'],
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
//                            Padding(
//                              padding: const EdgeInsets.only(top: 10.0),
//                              child: editNews(),
//                            )
                          ],
                        ),
//                        header: Padding(
//                          padding: const EdgeInsets.only(top: 10.0),
//                          child: Text(doc.data['News_Postedby'],
//                            style: TextStyle(
//                                fontSize: 14,
//                                fontWeight: FontWeight.w800),
//                          ),
//                        ),
                        collapsed: Text('${doc.data['News_Description']}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,),
                        expanded: Text('${doc.data['News_Description']}',
                          softWrap: true, textAlign: TextAlign.justify,),
                        tapHeaderToExpand: true,
                        hasIcon: true,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      stream: db.collection('BRGY NEWS').orderBy(
                          'News_Timeposted', descending: true).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                              children: snapshot.data.documents
                                  .map((doc) => buildItem(doc))
                                  .toList());
                        }
                        else {
                          return Container(
                              child: Center(
                                  child: CircularProgressIndicator()
                              )
                          );
                        }
                      }),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: FloatingActionButton(
          onPressed: () async {
//            _displayResponse();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        addNewsAdmin(widget.nameofUser, widget.userProfile)
                )
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Color(0xFF2b527f),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class addNewsAdmin extends StatefulWidget {
  addNewsAdmin(
      this.nameofUser,
      this.userProfile) : super();

  final String nameofUser;
  final String userProfile;

  @override
  _addNewsAdminState createState() => _addNewsAdminState();
}

class _addNewsAdminState extends State<addNewsAdmin> {

  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
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
        appBar: new AppBar(
            backgroundColor: Color(0xFF2b527f),
            title: new Text('Post News')
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0, bottom: 15.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Form(
                            key: _formkeyResponse,
                            autovalidate: _autoValidate,
                            child: Container(
                              height: _height * 0.45,
                              width: _width * 0.80,
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: _width * .75
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        maxLines: 2,
                                        onSaved: (value) => _NewsTitle = value,
                                        validator: (String value) {
                                          if (value.length < 1)
                                            return 'Title, field is empty';
                                          else if (value.length <= 3)
                                            return 'Title, must be longer than 3 letters.';
                                          else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          icon: Icon(FontAwesomeIcons.featherAlt),
                                          labelText: 'Title',
                                          labelStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: _height * 0.05,
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: _width * .75
                                      ),
                                      child: TextFormField(
                                        keyboardType: TextInputType.text,
                                        maxLines: 5,
                                        onSaved: (value) => _NewsDescription = value,
                                        validator: (String value) {
                                          if (value.length < 1)
                                            return 'Description, field is empty';
                                          else if (value.length <= 10)
                                            return 'Content, must be longer than 10 letters.';
                                          else
                                            return null;
                                        },
                                        decoration: InputDecoration(
                                          icon: Icon(FontAwesomeIcons.info),
                                          labelText: 'Content of news',
                                          labelStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text('Please upload one image for the news content.',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800
                            ),
                          ),
                        ),
                        Center(
                          child: RaisedButton(
                            child: Text("Choose Image:",
                              style: TextStyle(
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                            onPressed: (){
                              getImageNews();
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              child: _imageNews == null
                                  ?
                              Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('',
                                    ),
                                  )
                              )
                                  :
                              Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.file(_imageNews),
                                  )
                              )

                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0, top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                        if (_imageNews == null){
                                          print("Upload a picute");
                                        }
                                        else{
                                          uploadFileNewsImage();
                                        }
                                        await Future.delayed(
                                            const Duration(seconds: 7), () => 42);
                                        return () async {
                                          final key = _formkeyResponse.currentState;
                                          if (key.validate() == false) {
                                            _autoValidate = true;
                                          }
                                          else if(key.validate() != false && _imageNews == null){
                                            Flushbar(
                                              margin: EdgeInsets.all(8),
                                              borderRadius: 8,
                                              title: "Message",
                                              message: "Please upload one picture.",
                                              duration: Duration(seconds: 3),
                                            )
                                              ..show(context);
                                          }
                                          else {
                                            saveNews();
                                            flush = Flushbar<bool>(
                                              isDismissible: false,
                                              routeBlur: 50,
                                              routeColor: Colors.white.withOpacity(0.50),
                                              margin: EdgeInsets.all(8),
                                              borderRadius: 8,
                                              title: "Message",
                                              message: "You have posted a new news.",
                                              duration: Duration(seconds: 2),
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
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.02,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
//        child: Column(
//          children: <Widget>[
//            Form(
//              key: _formkeyResponse,
//              autovalidate: _autoValidate,
//              child: Container(
//                height: _height * 0.50,
//                width: _width * 0.80,
//                child: SingleChildScrollView(
//                  child: Column(
//                    children: <Widget>[
//                      TextFormField(
//                        keyboardType: TextInputType.text,
//                        maxLines: 2,
//                        onSaved: (value) => _NewsTitle = value,
//                        validator: (String value) {
//                          if (value.length < 1)
//                            return 'Title, field is empty';
//                          else
//                            return null;
//                        },
//                        decoration: InputDecoration(
//                          icon: Icon(FontAwesomeIcons.featherAlt),
//                          labelText: 'News title',
//                          labelStyle: TextStyle(
//                              fontSize: 12,
//                              fontWeight: FontWeight.w800
//                          ),
//                        ),
//                      ),
//                      SizedBox(
//                        height: _height * 0.05,
//                      ),
//                      TextFormField(
//                        keyboardType: TextInputType.text,
//                        maxLines: 5,
//                        onSaved: (value) => _NewsDescription = value,
//                        validator: (String value) {
//                          if (value.length < 1)
//                            return 'Description, field is empty';
//                          else
//                            return null;
//                        },
//                        decoration: InputDecoration(
//                          icon: Icon(FontAwesomeIcons.info),
//                          labelText: 'Description of news',
//                          labelStyle: TextStyle(
//                              fontSize: 12,
//                              fontWeight: FontWeight.w800
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              ),
//            ),
//          ],
//        ),
      ),
    );
  }
}



