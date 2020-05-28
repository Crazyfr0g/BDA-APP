import 'dart:async';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/navs/NewsfeedCategory/DroughtFeed.dart';
import 'package:comvida/navs/NewsfeedCategory/EarthquakeFeed.dart';
import 'package:comvida/navs/NewsfeedCategory/FloodFeed.dart';
import 'package:comvida/navs/NewsfeedCategory/LandslideFeed.dart';
import 'package:comvida/navs/NewsfeedCategory/TsunamiFeed.dart';
import 'package:comvida/navs/NewsfeedCategory/TyphoonFeed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:timeago/timeago.dart' as timeago;

class DisasterFeed extends StatefulWidget {
  DisasterFeed(
      this.typeOfUser,
      this.availableDonations,
      this.totalInterestedCount,
      this.totalConfirmedHelpCount,
      this.nameofUser) : super();

  final String typeOfUser;
  final String availableDonations;
  final int totalInterestedCount;
  final int totalConfirmedHelpCount;
  final String nameofUser;

  @override
  _DisasterFeedState createState() => _DisasterFeedState();
}

class _DisasterFeedState extends State<DisasterFeed> {

  String typeOfUser;
  @override
  void initState() {
    super.initState();
    knowTypeofUser();
    }

  final db = Firestore.instance;

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


  knowTypeofUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    db.collection('USERS').document(user.uid).get().then((DocumentSnapshot ds) {
      setState(() {
        this.typeOfUser = ds['Type of User'];
      });
    });
  }

  final myController = TextEditingController();

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
        color: Color(0xFF2b527f),
        child: DefaultTabController(
          length: 6,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: TabBar(
              isScrollable: true,
              labelColor: Color(0xFFFFFFFF),
              tabs: <Widget>[
                Tab(
                  child: Text(
                    'Drought',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                Tab(
                  child: Text(
                    'Earthquake',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                Tab(
                  child: Text(
                    'Flood',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                Tab(
                  child: Text(
                    'Landslide',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                Tab(
                  child: Text(
                    'Tsunami',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
                Tab(
                  child: Text(
                    'Typhoon',
                     style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            body: Container(
//              color: Color(0xFFE5E7EF),
            color: Colors.white,
              child: TabBarView(
                  children: [
                    ShowDrought(widget.typeOfUser, widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, myController, widget.nameofUser),
                    ShowEarthquake(widget.typeOfUser, widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, myController, widget.nameofUser),
                    ShowFlood(widget.typeOfUser, widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, myController, widget.nameofUser),
                    ShowLandslide(widget.typeOfUser, widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, myController, widget.nameofUser),
                    ShowTsunami(widget.typeOfUser, widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, myController, widget.nameofUser),
                    ShowTyphoon(widget.typeOfUser, widget.availableDonations, widget.totalInterestedCount, widget.totalConfirmedHelpCount, myController, widget.nameofUser),
                ]
              ),
            )
          )
        ),
      ),
    );
  }
}
