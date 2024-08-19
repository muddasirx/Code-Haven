import 'dart:async';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/interestPage.dart';
import 'package:code_haven/pages/login/loginPage.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:code_haven/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import '../../../SplashScreen.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
              fontSize: 26,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(
              0xff00a6b5),
        ),
        backgroundColor: themeNotifier.isDarkTheme ? Theme
            .of(context)
            .colorScheme
            .background : Colors.grey[290],
      ),

      backgroundColor: themeNotifier.isDarkTheme ? Theme
          .of(context)
          .colorScheme
          .background : Colors.grey[290],

      body: Padding(
        padding: const EdgeInsets.only(left: 25,right: 25,top: 50),
        child: Text(
          "At Code Haven, your privacy is our priority. When you create an account with us, we collect your personal information to provide you with the best experience possible. Your account allows you to search for coding queries and upload your own questions for the community to answer. We are committed to safeguarding your data and ensuring your interactions on Code Haven remain secure and private. We do not share your personal information with third parties without your consent, and we use industry-standard measures to protect your data. Your trust is essential to us, and we strive to maintain the highest standards of privacy and security.",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
              fontSize: 18,
            ),
          ),
        ),
      ),


    );
  }
}
