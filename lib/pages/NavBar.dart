import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/SplashScreen.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/NavBar/MyQuestions.dart';
import 'package:code_haven/pages/NavBar/notifications.dart';
import 'package:code_haven/pages/NavBar/postQuestion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'NavBar/Settings.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  final List _pages = [
    HomePage(),
    MyQuestions(),
    postQuestion(),
    Notifications(),
    Setting()
  ];

  bool isHomeActive = true;
  bool isQuestionActive = false;
  bool isNotificationActive = false;
  bool isSettingActive = false;
  bool isPostActive = false;

  bool hasConnection=true;

  Future<void> checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (mounted) {
      setState(() {
        hasConnection = result;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    print("---------- userInterests: ${SplashScreenState.userInterests}----------");
    checkConnection(); // Check connection on app launch
  }

  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
     // backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],
      bottomNavigationBar:
          Container(
            color: themeNotifier.isDarkTheme?Colors.black:Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              child: GNav(
                backgroundColor: themeNotifier.isDarkTheme?Colors.black:Colors.white,
                color: themeNotifier.isDarkTheme?Colors.white:Colors.black,
                tabBackgroundColor: Color(0xff00839c) ,//themeNotifier.isDarkTheme ? Color(0xff007a7b): Color(0xff00a6b5),//themeNotifier.isDarkTheme?Colors.grey.shade800:Colors.grey,
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                    setState(() {
                      if (index == 2)
                        Navigator.pushNamed(context, "/postQuestion");
                      else
                        _selectedIndex = index;
                    });

                },
                padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                tabs:  [
                  GButton(
                    icon: isHomeActive?Icons.home:Icons.home_outlined,
                    // text: " Home",
                    iconActiveColor: Colors.white,
                    iconSize: 24,
                    onPressed: () {
                      setState(() {
                        isHomeActive = true;
                        isQuestionActive = false;
                        isNotificationActive = false;
                        isSettingActive = false;
                        isPostActive = false;
                      });
                    },
                  ),
                  GButton(
                    icon: isQuestionActive?Icons.question_answer:Icons.question_answer_outlined,
                   // text: " MyQuestions",
                    iconActiveColor: Colors.white,
                    iconSize: 23,
                    onPressed: () {
                      setState(() {
                        isHomeActive = false;
                        isQuestionActive = true;
                        isNotificationActive = false;
                        isSettingActive = false;
                        isPostActive = false;
                      });
                    },
                  ),
                  GButton(
                    backgroundColor: themeNotifier.isDarkTheme?Colors.white:Colors.black,
                    icon: Icons.add_box,//Icons.add_circle_outline,
                    iconColor: themeNotifier.isDarkTheme ? Colors.white
                        : Colors.black,//Color(0xff00a6b5),
                    // text: " MyQuestions",
                    //iconActiveColor: Colors.white,
                    iconSize: 35,
                    iconActiveColor: themeNotifier.isDarkTheme ? Color(0xff00cfd8)//Color(0xff008f90)
                        : Color(0xff00a6b5),
                    onPressed: () {
                      setState(() {
                        isHomeActive = false;
                        isQuestionActive = true;
                        isNotificationActive = false;
                        isSettingActive = false;
                        isPostActive = false;
                      });
                    },
                  ),
                  GButton(
                    icon: isNotificationActive?Icons.notifications_on_rounded:Icons.notifications_none,
                     iconActiveColor: Colors.white,
                    iconSize: 23,
                    //text: "Profile",
                    onPressed: () {
                      setState(() {
                        isHomeActive = false;
                        isQuestionActive = false;
                        isNotificationActive = true;
                        isSettingActive = false;
                        isPostActive = false;
                      });
                    },
                  ),
                  GButton(
                    icon:  isSettingActive
                        ? Icons.settings
                        : Icons.settings_outlined,
                    iconActiveColor: Colors.white,
                    iconSize: 23,
                    //text: "Settings",
                    onPressed: () {
                      setState(() {
                        isHomeActive = false;
                        isQuestionActive = false;
                        isNotificationActive = false;
                        isSettingActive = true;
                        isPostActive = false;
                      });
                    },
                  )
                ],
              ),
            ),
          ),

      body: _pages[_selectedIndex],

    );
  }
}

/*
floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color(0xff00a6b5), // Change this to your desired border color
           width: 2.0, // Change the width as needed
          ),
        ),
        child: ClipOval(
          child: Material(
            color: Colors.white,

            elevation: 10,
            child: InkWell(
              onTap: (){},
              child: SizedBox(
                height: 45,width: 45,
                child: Icon(Icons.add_circle_outline_sharp,
                size: 30,color: Color(0xff00a6b5),),
              ),

            ),

          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
 */
