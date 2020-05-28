import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comvida/navs/OrgProfile.dart';
import 'package:comvida/navs/Profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrgAndNews extends StatefulWidget {
  OrgAndNews(
      this.picture
      ) : super();

  final String picture;
  @override
  _OrgAndNewsState createState() => _OrgAndNewsState();
}

class _OrgAndNewsState extends State<OrgAndNews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: AppBar(
          backgroundColor: Color(0xFF2b527f),
          title: Text(
            'DĀRE',
            style: TextStyle(
              fontFamily: 'Pacifico',
              letterSpacing: 2.5,
              fontSize: ScreenUtil.getInstance().setSp(65),
              fontWeight: FontWeight.w300,
              color: Color(0xFFFFFFFF),
            ),
          ),
          actions: <Widget>[
            new IconButton( icon: new Icon( FontAwesomeIcons.ellipsisV), tooltip: 'Air it', onPressed: (){} ),
          ],
        ),
      ),
      body: Container(
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
          body: OrganizationPage(widget.picture),
        ),
      ),
    );
  }
}

class OrganizationPage extends StatefulWidget {
  OrganizationPage(
      this.picture
      ) : super();

  final String picture;
  @override
  _OrganizationPageState createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage> {
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

     buildItem(DocumentSnapshot doc) {
       var ig = widget.picture;

       if (doc.data['Profile_Information'] == null || doc.data['Profile_Information'] == ""){
         organizationInfo = "The organization did not specify profile information yet.";
       }
       else{
         organizationInfo = doc.data['Profile_Information'];

       }

       Widget picture () {
         if (doc.data['Profile_Picture'] == null || doc.data['Profile_Picture'] == ""){
           return CircleAvatar(
             radius: 70,
             backgroundImage: AssetImage('assets/no-image.png'),
           );
         }
         else{
           return CircleAvatar(
             radius: 70,
             backgroundImage: NetworkImage(doc.data['Profile_Picture']),
           );
         }
       }


       return Padding(
         padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 15.0),
        child: Container(
//          height: _height * 0.50,
          child: Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Column(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: circleRadius / 2.0),
                        child: Container(
                          //replace this Container with your Card
//                          color: Color(0xFF121A21),
                          color: Color(0xFF2b527f),
                          height: _height * 0.30,
                        ),
                      ),
                      Container(
                        width: circleRadius,
                        height: circleRadius,
                        decoration:
                        ShapeDecoration(shape: CircleBorder(), color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(circleBorderWidth),
                          child: picture(),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 115.0),
                            child: Text(
                              '${doc.data['Name of Organization']}', style: TextStyle(
                              color: Colors.white
                            ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 15.0),
                            child: Center(
                              child: Text(
                                organizationInfo, style: TextStyle(
                                  color: Colors.white
                              ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0, top: 10.0),
                                child: Container(
                                  height: _height * 0.06,
                                  width: _width * 0.50,
                                  child: FlatButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(20.0))),
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) => new OrgProfile(
                                                  doc.data['Name of Organization'])));
                                    },
                                    child: Text(
                                      'View Profile',
                                      style: TextStyle(color: Color(0xFF121A21), fontSize: 12.5, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              )
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
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        body: Container(
            child: SingleChildScrollView(
              child: Column(children: <Widget>[
                SizedBox(
                  height: 5,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection('USERS')
                      .where('Type of User', isEqualTo: 'Organization').limit(5)
                      .snapshots(),
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
                })
              ]),
            )
        )
    );
  }
}

