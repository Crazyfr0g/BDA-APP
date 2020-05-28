import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/navs/OrgProfile.dart';
import 'package:comvida/navs/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Trends extends StatefulWidget {
  Trends(
      this.picture
      ) : super();

  final String picture;
  @override
  _TrendsState createState() => _TrendsState();
}

class _TrendsState extends State<Trends> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Scaffold(
          body: TrendsPage(widget.picture),
        ),
      ),
    );
  }
}

class TrendsPage extends StatefulWidget {
  TrendsPage(
      this.picture
      ) : super();

  final String picture;
  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  @override

  final db = Firestore.instance;
  var selectedCurrency, selectedType;
  String organizationInfo;

  AssetImage imageBeneficiary;
  NetworkImage imageBeneficiarys;


  Widget build(BuildContext context) {

    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    final double circleRadius = 100.0;
    final double circleBorderWidth = 8.0;
    final padding = _height * 20;

    Container buildItem(DocumentSnapshot doc) {

      Widget picture()  {
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

      final _width = MediaQuery.of(context).size.width;
      final _height = MediaQuery.of(context).size.height;
      return Container(
        height: _height * 0.10,
        width: _width * 0.70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: Color(0xFFFFFFFF),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget> [
                      picture(),
                      SizedBox(
                        width: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${doc.data['Name of Organization']}',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${doc.data['Name of User']}',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Container ListBarangay(DocumentSnapshot doc) {

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

      final _width = MediaQuery.of(context).size.width;
      final _height = MediaQuery.of(context).size.height;

      return Container(
        height: _height * 0.10,
        width: _width * 0.70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Color(0xFFFFFFFF),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      picture(),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${doc.data['Name of Barangay']}',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Text(
                    '${doc.data['Total_ConfirmedHelp']}',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Container ListNormalUser(DocumentSnapshot doc) {

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

      final _width = MediaQuery.of(context).size.width;
      final _height = MediaQuery.of(context).size.height;

      return Container(
        height: _height * 0.10,
        width: _width * 0.70,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: Color(0xFFFFFFFF),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      picture(),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        '${doc.data['Name of User']}',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Text(
                    '${doc.data['Confirmed_Helpcount']}',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }


    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection('USERS')
                        .where('Type of User', isEqualTo: 'Barangay')
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('TOP 10 MOST HELPED BARANGAY',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                  ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Container(
                                  height: _height * 0.60,
                                  child: ListView(
                                      scrollDirection: Axis.vertical,
                                      children: snapshot.data.documents
                                          .map((doc) => ListBarangay(doc))
                                          .toList()),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        return Container(
                            child: Center(
                                child: CircularProgressIndicator()
                            )
                        );
                      }
                    }),

                StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection('USERS')
                        .where('Type of User', isEqualTo: 'Normal User')
                        .orderBy('Confirmed_Helpcount', descending: true)
                        .limit(10)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15.0),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('TOP 10 ACTIVE BENEFACTOR',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800
                                  ),),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Container(
                                  height: _height * 0.60,
                                  child: ListView(
                                      scrollDirection: Axis.vertical,
                                      children: snapshot.data.documents
                                          .map((doc) => ListNormalUser(doc))
                                          .toList()),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        return Container(
                            child: Center(
                                child: CircularProgressIndicator()
                            )
                        );
                      }
                    })

              ]),
            )
        )
    );
  }
}


