import 'package:easy_dialog/easy_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class loginChoice extends StatefulWidget {
  @override
  _loginChoiceState createState() => _loginChoiceState();
}

class _loginChoiceState extends State<loginChoice> {

  List<Slide> slides = new List();

  @override
  void initState() {
    super.initState();

    slides.add(
      new Slide(
        title: "B-DA: Barangay Disaster App",
        description:
            "Is a crowdsourcing platform designed to create an avenue for Benefactors and Beneficiaries.  "
            "The app encourages Benefactors to help other people in need by sharing what they can give no matter if it is Money, Food or Clothing. "
            "Through the app, Benefactors will become more active and they are more able to help many people who are affected by calamities. "
            "Benefactors on the other hand, will be given the higher assurance that their donations reaches their Beneficiaries. With just a few taps away, "
            "the beneficiaries can already request for help and get help.",
        //pathImage: "images/photo_eraser.png",
        backgroundColor: Color(0xFF2b527f),
          styleDescription: TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w800
          ),
          styleTitle: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w800
        )
      ),
    );
    slides.add(
      new Slide(
        title: "THE TEAM",
        description: "Our team is composed of three aspiring students from WMSU. Our goal is to give more choices where people can donate "
        "a head, during and after any disaster , man-made or not.",
        //pathImage: "images/photo_pencil.png",
        backgroundColor: Color(0xFF2b527f),
          styleDescription: TextStyle(
              fontSize: 17,
              color: Colors.white,
              fontWeight: FontWeight.w800
          ),
          styleTitle: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.w800
          )
      ),
    );
  }

  void onDonePress() {
    Navigator.pushReplacementNamed(context, '/signIn');
    //_showDialog();
  }


  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: new IntroSlider(
        colorActiveDot: Colors.black,
        slides: this.slides,
        onDonePress: this.onDonePress,
      ),
    );
  }
}

