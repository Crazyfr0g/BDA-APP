import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrgProfile extends StatefulWidget {
  OrgProfile(this.orgName) : super();
  final String orgName;
  @override
  _OrgProfileState createState() => _OrgProfileState();
}

class _OrgProfileState extends State<OrgProfile>  {
  @override

  final db = Firestore.instance;

  Container buildItem(DocumentSnapshot doc) {

    Widget picture(){
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

    String _profInfo (){
      if (doc.data['Profile_Information'] == ""){
        return 'Please update profile information.';
      }
      else{
        return doc.data['Profile_Information'];
      }
    }

    Color _statusColor (){
      if (doc.data['Org_status'] == "Not verified"){
        return Colors.red;
      }
      else if (doc.data['Org_status'] == "Verified"){
        return Colors.green;
      }
    }

    String _orgStatus (){
      if (doc.data['Org_status'] == "Not verified"){
        return "Not verified";
      }
      else if (doc.data['Org_status'] == "Verified"){
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
                    child: Text (doc['Name of Organization'],
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white
                      ),
                    ),
                  ),
                  Container(
                    child: Text(doc['Email'],
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
                            child: Text('Organization Details',
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
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text('Org status:',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              _orgStatus(),
                              style: TextStyle(
                                  color: _statusColor(),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800
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
                            child: Text('Org name:',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Text(
                              doc.data['Name of Organization'],
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800
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
                            child: Text('Email:',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              doc.data['Email'],
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800
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
                            child: Text('Contact Number:',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              doc.data['Contact_Number'],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800
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
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Address:',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13
                                ),
                              ),
                            ),
                            Container(
                              width: _width * 0.70,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                                child: Text(
                                  doc.data['Address'],
                                  maxLines: 3,
                                  overflow: TextOverflow.visible,
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
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_profInfo(),
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13
                          ),
                        ),
                      )
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
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                            child: Text('Date joined',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              doc.data['Date_Joined'],
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                            child: Text(
                              'Total Request',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              doc.data['Total_RequestCount'].toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800
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
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text('Total Goal Reached',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Text(
                                doc.data['Total_GoalReachedCount'].toString(),
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
        appBar: AppBar(
          backgroundColor: Color(0xFF2b527f),
          title: Text(widget.orgName),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[ SizedBox(
              height: _height * 0.05,
            ),
              StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection('USERS')
                      .where('Name of Organization', isEqualTo: widget.orgName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                          children: snapshot.data.documents
                              .map((doc) => buildItem(doc))
                              .toList());
                    } else {
                      return SizedBox();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
