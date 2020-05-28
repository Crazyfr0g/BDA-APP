import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/navs/MyActivity.dart';
import 'package:comvida/navs/UserProfile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:comvida/login/provider.dart';
import 'package:comvida/services/auth_services.dart';
import 'package:comvida/navs/DisasterFeed.dart';
import 'package:comvida/navs/Profile.dart';
import 'package:comvida/navs/OrgAndNews.dart';
import 'package:comvida/navs/CreateAccountAdmin.dart';

import 'navs/NewsFeed.dart';
import 'navs/NewsfeedCategory/EarthquakeFeed.dart';
import 'navs/Trends.dart';
import 'navs/MyActivity.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  FirebaseUser currentUser;
  String name;
  String email;
  String typeOfUser;
  String userID;
  String availableDonations;
  String orgStatus;
  int totalInterestedCount;
  int totalConfirmedHelpCount;
  int totalConfirmedHelpBarangay;
  int totalGoalReached;
  int currentPage = 0;
  String _userProfile;

  GlobalKey bottomNavigationKey = GlobalKey();
  final navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _knowTypeofUser();
    _reloadCurrentUser();
  }

  void _reloadCurrentUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    user.reload();
  }

  final db = Firestore.instance;

  _knowTypeofUser() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final FirebaseUser user = await _firebaseAuth.currentUser();
    db.collection('USERS').document(user.uid).get().then((DocumentSnapshot ds) {
      setState(() {
        if (typeOfUser == 'Normal User') {
          return this.name = ds['Name of User'];
        }
        else if (typeOfUser == "Barangay"){
          return this.name = ds['Name of Barangay'];
        }
        else{
          return this.name = ds['Name of Admin'];
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
        this.availableDonations = ds['Donations_ICanGive'];
        this.totalInterestedCount = ds['Interested_Helpcount'];
        this.totalConfirmedHelpCount = ds['Confirmed_Helpcount'];
        this._userProfile = ds['Profile_Picture'];
        this.orgStatus = ds['Org_status'];
        this.totalConfirmedHelpBarangay = ds['Total_ConfirmedHelp'];
        this.totalGoalReached = ds['Total_GoalReachedCount'];
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

  Widget build(BuildContext context) {
    var provider = Provider.of<BottomNavigationBarProvider>(context);
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    ScreenUtil.instance = ScreenUtil(width: 1080, height: 1794)..init(context);




      var _widget = [
      Trends(_userProfile),
      NewsFeed(typeOfUser, availableDonations, totalInterestedCount, totalConfirmedHelpCount, _name(), _userProfile, userID),
      DisasterFeed(typeOfUser, availableDonations, totalInterestedCount, totalConfirmedHelpCount, _name()),
      MyActivity(typeOfUser, userID, _name(), totalConfirmedHelpCount, _userProfile, orgStatus, totalConfirmedHelpBarangay, totalGoalReached),
      UserProfile(userID, _name(), _email(), typeOfUser, totalInterestedCount, totalConfirmedHelpCount, _userProfile),
    ];

    var _widgetAdmin = [
      Trends(_userProfile),
      NewsFeed(typeOfUser, availableDonations, totalInterestedCount, totalConfirmedHelpCount, _name(), _userProfile, userID),
      DisasterFeed(typeOfUser, availableDonations, totalInterestedCount, totalConfirmedHelpCount, _name()),
      MyActivityAdmin(typeOfUser, userID, _name(), totalConfirmedHelpCount, _userProfile, orgStatus),
      UserProfile(userID, _name(), _email(), typeOfUser, totalInterestedCount, totalConfirmedHelpCount, _userProfile),
    ];

    accChoice(){
      if (typeOfUser == "Normal User"){
        return _widget[provider.currentIndex];
      }
      else if (typeOfUser == "Barangay"){
        return  _widget[provider.currentIndex];
      }
      else {
        return _widgetAdmin[provider.currentIndex];
      }

    }

     _createRoute () {
      return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => accChoice(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = Offset(0.0, 1.0);
            var end = Offset.zero;
            var curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          });
    }


    return Scaffold(
      body: Container(
//        child: _widget[provider.currentIndex],
        child: accChoice(),
      ),
      bottomNavigationBar: Container(
        height: _height * .08,
        child: BottomNavigationBar(
          fixedColor: Color(0xFF2b527f),
          unselectedItemColor: Color(0xFF626261),
          currentIndex: provider.currentIndex,
          onTap: (index) {
            provider.currentIndex = index;
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.poll, size: 21),
              title: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text('Trends', style: TextStyle(fontSize: 9.5,
                  fontWeight: FontWeight.w800),
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.solidNewspaper, size: 21),
              title: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text('News', style: TextStyle(fontSize: 9.5,
                    fontWeight: FontWeight.w800),
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.handHoldingHeart, size: 21),
              title: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Center(
                  child: Text('Send Help', style: TextStyle(fontSize: 9.5,
                      fontWeight: FontWeight.w800),),
                ),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.listUl, size: 21),
              title: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text('My Activity', style: TextStyle(fontSize: 9.5,
                    fontWeight: FontWeight.w800),),
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.userAlt, size: 21),
              title: Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text('Profile', style: TextStyle(fontSize: 9.5,
                    fontWeight: FontWeight.w800),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomNavigationBarProvider with ChangeNotifier {
  int _currentIndex = 2;
  get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class containerSettings extends StatelessWidget {
  containerSettings({@required this.icon, @required this.text, this.function});
  final IconData icon;
  final Text text;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: double.infinity,
      child: Align(
        alignment: Alignment.center,
        child: FlatButton.icon(
          color: Color(0xFFFFFFFF),
          label: text,
          icon: Icon(
            icon,
            color: Color(0xff045135),
          ),
          textColor: Color(0xFF121A21),
          onPressed: function,
        ),
      ),
    );
  }
}

class UpdateDonateInfo extends StatefulWidget {
  @override
  _UpdateDonateInfoState createState() => _UpdateDonateInfoState();
}

class _UpdateDonateInfoState extends State<UpdateDonateInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Donate Info'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('Press Me'),
              onPressed: (){
                setState(() {
                  Navigator.pop(context);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}


class Org extends StatefulWidget {
  @override
  _OrgState createState() => _OrgState();
}
class _OrgState extends State<Org> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(child: Text('Some content')),
          DraggableScrollableSheet(
            minChildSize: 0.2,
            initialChildSize: 0.2,
            builder: (context, scrollController) => Container(
              color: Colors.lightBlueAccent,
              child: ListView.builder(
                controller: scrollController,
                itemCount: 20,
                itemBuilder: (context, index) => SizedBox(
                  height: 200,
                  child: Text('Item $index'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

