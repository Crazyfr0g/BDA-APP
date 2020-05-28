import 'dart:async';
import 'dart:io';


import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;


class ShowTsunami extends StatefulWidget {
  ShowTsunami(
      this.typeOfUser,
      this.availableDonations,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount,
      this.mycontroller,
      this.nameOfUser) : super();

  final String typeOfUser;
  final String availableDonations;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;
  final mycontroller;
  final String nameOfUser;

  @override
  _ShowTsunamiState createState() => _ShowTsunamiState();
}

class _ShowTsunamiState extends State<ShowTsunami> {
  String typeOfUser;
  final db = Firestore.instance;

  @override

  void initState() {
    super.initState();
    _knowNameOfUser();
    _buildTsunamiRequest();
  }


  Widget _buildTsunamiRequest() {
    if (widget.typeOfUser == "Barangay") {
      return TsunamiFeedBeneficiary(widget.mycontroller);
    }
    else if (widget.typeOfUser == "Normal User") {
      return TsunamiFeedBenefactor(widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, widget.mycontroller, widget.nameOfUser);
    }
    else if (widget.typeOfUser == "Admin"){
      return TsunamiFeedAdmin(widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, widget.mycontroller);

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
    return Scaffold(
      body: _buildTsunamiRequest(),
    );
  }
}


class TsunamiFeedBenefactor extends StatefulWidget {
  TsunamiFeedBenefactor(
      this.availableDonations,
      this.totalInterestedCount,
      this.totalConfirmedhelpCount,
      this.mycontroller,
      this.nameOfUser) : super();

  final String availableDonations;
  final int totalInterestedCount;
  final int totalConfirmedhelpCount;
  final mycontroller;
  final String nameOfUser;

  @override
  _TsunamiFeedBenefactorState createState() => _TsunamiFeedBenefactorState();
}

class _TsunamiFeedBenefactorState extends State<TsunamiFeedBenefactor> {
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
      body: "Please verify email first to donate.",
      actions: [
        AlertAction(
            text: "Send Email Verification",
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
                                    '${doc.data['Name_ofUser']}',
                                    style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(Dformat.format(doc.data['Help_DatePosted'].toDate()),
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

  _viewingRequest(DocumentSnapshot doc) async {
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
                    Text("Request Information",
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
                ),              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              content: Container(
                height: _height * 0.45,
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
                              '${doc.data['Name_ofUser']}',
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
                              '${doc.data['Help_Description']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Families Affected:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_FamiliesAffected']}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Area / Barangay:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Help_AreaAffected']}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Things We Need:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Help_ThingsNeeded']}'.replaceAll(
                              new RegExp(r'[^\w\s\,]+'), ''),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Drop Off Location:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Help_DropoffLocation']}',
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
                          'For Inquiries:',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${doc.data['Help_Inquiry']}',
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Center(
                                  child: Icon(
                                    FontAwesomeIcons.heart,
                                    size: 14,
                                    color: Color(0xFF2b527f),//Color of the border
                                  )
                              ),
                            ),
                            SizedBox(
                              width: _width * 0.03,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 7.0),
                              child: Center(
                                child: Text(
                                  '${doc.data['Respondents_Count'].toString()}',
                                  style: TextStyle(
                                    color: Color(0xFF2b527f),//Color of the border
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                        child: Container(
                            height: _height * 0.05,
                            width: _width * 0.30,
                            child: ProgressButton(
                                defaultWidget: const Text('I want to help',
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
                                  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
                                  final FirebaseUser user = await _firebaseAuth.currentUser();
                                  if (user.isEmailVerified){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) => TsunamiFeedBenefactorAnswerHelp(
                                                doc.data['Help_Description'],
                                                doc.data['Name_ofUser'],
                                                doc.data['User_ID'],
                                                doc.data['Help_DropoffLocation'],
                                                doc.data['Help_ThingsNeeded'],
                                                doc.data['Type_OfDisaster'],
                                                doc.data['Unique_ID'],
                                                widget.nameOfUser,
                                                widget.totalConfirmedhelpCount,
                                                doc.data['Respondents_Count'],
                                                doc.data['Help_AreaAffected'],
                                                doc.data['Help_BankAccountName'],
                                                doc.data['Help_BankAccountNumber'],
                                            )
                                        )
                                    );
                                  }else{
                                    _showVerifyEmail(doc.data);
                                  }
                                }
                            )
                        ),
                      ),
                    ],
                  )
                  ,
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
      if (widget.mycontroller.text == ""){
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('TSUNAMI REQUESTS').orderBy('Help_DatePosted', descending: true).snapshots(),
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
              stream: db.collection('TSUNAMI REQUESTS').where('Name_ofUser', isEqualTo: 'Barangay ${widget.mycontroller.text}').snapshots(),
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
                  ],
                ),
              );
            },
          ),
        )
    );
  }
}

class TsunamiFeedBenefactorAnswerHelp extends StatefulWidget {
  TsunamiFeedBenefactorAnswerHelp(
      this._requestDescription,
      this._requestorsName,
      this._requestorsID,
      this._requestDropoffLocation,
      this._requestThingsNeeded,
      this._typeofDisaster,
      this._requestorsuniqueID,
      this._nameOfUser,
      this._totalConfirmedHelpCount,
      this._totalRespondentsHelpCount,
      this._requestAreaAffected,
      this._bankAccountName,
      this._bankAccountNumber) : super();

  final String _requestDescription;
  final String _requestorsName;
  final String _requestorsID;
  final String _requestDropoffLocation;
  final String _requestThingsNeeded;
  final String _typeofDisaster;
  final String _requestorsuniqueID;
  final String _nameOfUser;
  final int _totalConfirmedHelpCount;
  final int _totalRespondentsHelpCount;
  final String _requestAreaAffected;
  final String _bankAccountName;
  final String _bankAccountNumber;

  @override
  _TsunamiFeedBenefactorAnswerHelpState createState() => _TsunamiFeedBenefactorAnswerHelpState();
}

class _TsunamiFeedBenefactorAnswerHelpState extends State<TsunamiFeedBenefactorAnswerHelp> {

  void initState() {
    super.initState();
    print(widget._requestorsID);
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
            'Confirmed_ID': user.uid,
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
            'Confirmed_ConfirmedDate': Timestamp.now(),
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
            'Request_AreaAffected': widget._requestAreaAffected

          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': user.uid,
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
            'Confirmed_ConfirmedDate': Timestamp.now(),
            'Requestors_ID': widget._requestorsID,
            'Response_State': 'Confirmed',
            'Type_Of_Disaster': widget._typeofDisaster,
            'Request_AreaAffected': widget._requestAreaAffected

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
            'Confirmed_ID': user.uid,
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
            'Request_AreaAffected': widget._requestAreaAffected

          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': user.uid,
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
            'Request_AreaAffected': widget._requestAreaAffected

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
            'Confirmed_ID': user.uid,
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
            'Request_AreaAffected': widget._requestAreaAffected

          });
        });
      }
      else {
        setState(() async {
          ref.setData({
            'ImageFood': _uploadedFileURLFood,
            'ImageClothes': _uploadedFileURLClothes,
            'ImageMoney': _uploadedFileURLMoney,
            'Confirmed_ID': user.uid,
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
            'Request_AreaAffected': widget._requestAreaAffected

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

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${user.uid}/${Path.basename('${id}')}');

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
        .child('Clothes/${user.uid}/${Path.basename('${id}')}');

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
        .child('Money/${user.uid}/${Path.basename('${id}')}');

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

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    String id = uuid.v1();

    StorageReference storageReferenceFood = FirebaseStorage.instance
        .ref()
        .child('Food/${user.uid}/${Path.basename('${id}')}');

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

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    String id = uuid.v1();

    StorageReference storageReferenceClothes = FirebaseStorage.instance
        .ref()
        .child('Clothes/${user.uid}/${Path.basename('${id}')}');

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

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    String id = uuid.v1();

    StorageReference storageReferenceMoney = FirebaseStorage.instance
        .ref()
        .child('Money/${user.uid}/${Path.basename('${id}')}');

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

  _saveConfirmedCountToBeneficiaryRespondentsHelpRequest() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('HELP REQUEST').document(widget._requestorsuniqueID);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Respondents_Count': widget._totalRespondentsHelpCount + count,
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
            'Respondents_Count': widget._totalRespondentsHelpCount + count,
          });
        });
      }
    });
  }

  _saveConfirmedCountToBeneficiaryRespondentsDroughtRequest() async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();

    DocumentReference ref = db.collection('TSUNAMI REQUESTS').document(widget._requestorsuniqueID);

    ref.get().then((document) async{
      if (document.exists) {
        setState(() async {
          ref.updateData({
            'Respondents_Count': widget._totalRespondentsHelpCount + count,
          });
        });
      }
      else
      {
        setState(() async {
          ref.setData({
//            'Confirmed_Helpcount': count,
            'Respondents_Count': widget._totalRespondentsHelpCount + count,
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    String bankAccountName (){
      if (widget._bankAccountName == null || widget._bankAccountName == "null" || widget._bankAccountName == ""){
        return "Not Indicated.";
      }
      else {
        return widget._bankAccountName;
      }
    }

    String bankAccountNumber (){
      if (widget._bankAccountNumber == null || widget._bankAccountNumber == "null" || widget._bankAccountNumber == ""){
        return "Not Indicated.";
      }
      else {
        return widget._bankAccountNumber;
      }
    }

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
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("Account Name: ${bankAccountName()}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontStyle: FontStyle.italic
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("Account Number: ${bankAccountNumber()}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontStyle: FontStyle.italic
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text('Note: '),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                                          child: Text
                                            ('You can also donate money by bringing it to the drop off location.',
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontStyle: FontStyle.italic
                                            ),
                                          ),
                                        )
                                      ],
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

                                    await Future.delayed(
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
                                        _saveConfirmedCountToBeneficiaryRespondentsHelpRequest();
                                        _saveConfirmedCountToBeneficiaryRespondentsDroughtRequest();
                                        flush = Flushbar<bool>(
                                          duration: Duration(seconds: 2),
                                          blockBackgroundInteraction: true,
                                          isDismissible: false,
                                          routeBlur: 50,
                                          routeColor: Colors.white.withOpacity(0.50),
                                          margin: EdgeInsets.all(8),
                                          borderRadius: 8,
                                          title: "Thank you, ${_name()}.",
                                          message: "Your response is a big help for a lot of people.",
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


class TsunamiFeedBeneficiary extends StatefulWidget {
  TsunamiFeedBeneficiary(
      this.mycontroller) : super();
  final mycontroller;

  @override
  _TsunamiFeedBeneficiaryState createState() => _TsunamiFeedBeneficiaryState();
}

class _TsunamiFeedBeneficiaryState extends State<TsunamiFeedBeneficiary> {
  @override

  String _requestorsID;

  final db = Firestore.instance;

  bool orgstat = false;


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final fifteenAgo = new DateTime.now();
  var time = DateFormat.yMEd().add_jms().format(DateTime.now());
  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());

  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    Widget picture(){
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
        return CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(doc.data['Profile_Picture']),
        );
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
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
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
                                  '${doc.data['Name_ofUser']}',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(Dformat.format(doc.data['Help_DatePosted'].toDate()),
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800
                                  ),)
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
                              color: Colors.green,
                              size: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/Tsunami.jpg')
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Description:', style: TextStyle(
                          fontSize: 11.5,
                        ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (){
                            setState(() {

                            });
                          },
                          child: Text(
                            '${doc.data['Help_Description']}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text('Families affected:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_FamiliesAffected']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Area/Barangay:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_AreaAffected']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Things we need:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_ThingsNeeded']}'.replaceAll(new RegExp(r'[^\w\s\,]+'),''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Drop off location:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_DropoffLocation']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('For inquiries call:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_Inquiry']}',
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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          height: _height * 0.05,
                          width: _width * 0.30,
                          child: Text(
                            '${doc.data['Respondents_Count'].toString()} respondents.',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
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
    );
  }

  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    Widget StreamBuider(){
      if (widget.mycontroller.text == ""){
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('TSUNAMI REQUESTS').orderBy('Help_DatePosted', descending: true).snapshots(),
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
              stream: db.collection('TSUNAMI REQUESTS').where('Name_ofUser', isEqualTo: 'Barangay ${widget.mycontroller.text}').snapshots(),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


class TsunamiFeedAdmin extends StatefulWidget {
  TsunamiFeedAdmin(
      this.availableDonations,
      this.totalInterestedCount,
      this.totalConfirmedhelpCount,
      this.mycontroller) : super();

  final String availableDonations;
  final int totalInterestedCount;
  final int totalConfirmedhelpCount;
  final mycontroller;

  @override
  _TsunamiFeedAdminState createState() => _TsunamiFeedAdminState();
}

class _TsunamiFeedAdminState extends State<TsunamiFeedAdmin> {
  @override


  void initState() {
    super.initState();
    print(widget.availableDonations);
    print(_requestorsUniqueID);
  }

  String typeOfUser;
  String _requestorsUniqueID;

  String _requestorsID;
  bool orgstat = false;

  var uuid = Uuid();

  final db = Firestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var time = DateFormat.yMEd().add_jms().format(DateTime.now());

  void _deleteIssue(String uniqueID) async {
    try {
      DocumentReference ref = db.collection('DROUGHT REQUESTS').document(uniqueID);
      return ref.delete();
    } catch (e) {
      print(e);
    }
  }

  _deleteHelpRequest(String uniqueID) async {
    try {
      DocumentReference ref = db.collection('HELP REQUEST').document(uniqueID);
      return ref.delete();
    } catch (e) {
      print(e);
    }
  }

  _deleteResponse (String uniqueID) async {
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
                            await Future.delayed(
                                const Duration(seconds: 3), () => 42);
                            return () {
                              _deleteIssue(uniqueID);
                              _deleteHelpRequest(uniqueID);
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

  saveDeletedRequest(dynamic data) async {

    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final db = Firestore.instance;

    String id = uuid.v1();


    DocumentReference ref = db.collection('ADMIN DELETED REQUESTS').document(id);

    ref.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({
            'Date deleted': time,
            'Name of Requestor': data['Name_ofUser'],
            'Requestors_ID': data['User_ID'],
            'Type of Disaster': data['Type_OfDisaster'],
            'Unique_ID': id,
          }
          );
          user.reload();
        });
      } else {
        setState(() async {
          await ref
              .setData({
            'Date deleted': time,
            'Name of Requestor': data['Name_ofUser'],
            'Requestors_ID': data['User_ID'],
            'Type of Disaster': data['Type_OfDisaster'],
            'Unique_ID': id,
          }
          );
          user.reload();
        });
      }
    });


    DocumentReference reF = db.collection('BENEFACTOR NOTIFICATION').document(id);

    reF.get().then((document) async {
      if (document.exists) {
        setState(() async {
          await ref
              .updateData({
            'Date deleted': time,
            'Name of User': data['Name_ofUser'],
            'Requestors_ID': data['User_ID'],
            'Type of Disaster': data['Type_OfDisaster'],
            'Unique_ID': id,
          }
          );
          user.reload();
        });
      } else {
        setState(() async {
          await reF
              .setData({
            'Date deleted': time,
            'Name of User': data['Name_ofUser'],
            'Requestors_ID': data['User_ID'],
            'Type of Disaster': data['Type_OfDisaster'],
            'Unique_ID': id,
          }
          );
          user.reload();
        });
      }
    });
  }

  final myController = TextEditingController();

  Container buildItem(DocumentSnapshot doc) {

    final Dformat = new DateFormat.yMMMMd("en_US").add_jm();

    Widget picture(){
      if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
        return CircleAvatar(
          radius: 30,
          backgroundImage: AssetImage('assets/no-image.png'),
        );
      }
      else{
        return CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(doc.data['Profile_Picture']),
        );
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
                                  '${doc.data['Name_ofUser']}',
                                  style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(Dformat.format(doc.data['Help_DatePosted'].toDate()),
                                  style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800
                                  ),)
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
                              color: Colors.green,
                              size: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage('assets/Tsunami.jpg')
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text('Description:', style: TextStyle(
                          fontSize: 11.5,
                        ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: (){
                            setState(() {

                            });
                          },
                          child: Text(
                            '${doc.data['Help_Description']}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Text('Families affected:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_FamiliesAffected']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Area/Barangay:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_AreaAffected']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Things we need:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_ThingsNeeded']}'.replaceAll(new RegExp(r'[^\w\s\,]+'),''),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('Drop off location:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_DropoffLocation']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text('For inquiries call:', style: TextStyle(
                            fontSize: 11.5,
                          ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${doc.data['Help_Inquiry']}',
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
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          height: _height * 0.05,
                          width: _width * 0.30,
                          child: Text(
                            '${doc.data['Respondents_Count'].toString()} respondents.',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
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
                                    Colors.white,
                                  ),
                                ),
                              ),
                              width: _width * 0.30,
                              height: 40,
                              borderRadius: 20.0,
                              color: Color(0xFF3F6492),
                              onPressed: () async {
                                _deleteResponse(doc.data['Unique_ID']);
                              }
                          ),
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
    );
  }

  Widget build(BuildContext context) {

    Widget StreamBuider(){
      if (widget.mycontroller.text == ""){
        return
          StreamBuilder<QuerySnapshot>(
              stream: db.collection('TSUNAMI REQUESTS').orderBy('Help_DatePosted', descending: true).snapshots(),
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
              stream: db.collection('TSUNAMI REQUESTS').where('Name_ofUser', isEqualTo: 'Barangay ${widget.mycontroller.text}').snapshots(),
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
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10.0),
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
              );
            },
          ),
        )
    );
  }
}

