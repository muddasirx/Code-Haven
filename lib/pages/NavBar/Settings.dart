import 'dart:async';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/interestPage.dart';
import 'package:code_haven/pages/login/loginPage.dart';
import 'package:code_haven/pages/settings/privacyPolicy.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:code_haven/main.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import '../../SplashScreen.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool hasConnection=true;
  bool lightTheme=false;
  bool logoutPressed=false;

  void logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SplashScreenState.keyLogin, false);
    Navigator.pushReplacementNamed(context, '/login');
  }

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
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Settings",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
              fontSize: 26,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
        ),
        backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],
      ),

      backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],

      body:SafeArea(
        child:Stack(
          children: [
            Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Theme :",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Container(
                        height: 46,
                        width: 60,
                        child: DayNightSwitcher(
                          isDarkModeEnabled: themeNotifier.isDarkTheme,
                          onStateChanged: (isDarkModeEnabled) async {
                            setState(() {
                              themeNotifier.toggleTheme();
                            });
                            bool isLight= !themeNotifier.isDarkTheme;
                            SharedPreferences prefLogin = await SharedPreferences.getInstance();
                            await prefLogin.setBool(SplashScreenState.theme, isLight);

                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5,),
                Divider(
                  thickness: 1,
                  color: themeNotifier.isDarkTheme
                      ? Color(0xff00cfd8)
                      : Color(0xff00a9b1),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/MyProfile");
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "My profile",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Icon(Icons.navigate_next,size: 27,
                                color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),)
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: themeNotifier.isDarkTheme
                      ? Color(0xff00cfd8)
                      : Color(0xff00a9b1),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/ChangePassword");
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Change Password",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Icon(Icons.navigate_next,size: 27,
                                color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),)
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: themeNotifier.isDarkTheme
                      ? Color(0xff00cfd8)
                      : Color(0xff00a9b1),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/deleteAccount");
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Delete account",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Icon(Icons.navigate_next,size: 27,
                                color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),)
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: themeNotifier.isDarkTheme
                      ? Color(0xff00cfd8)
                      : Color(0xff00a9b1),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/PrivacyPolicy");
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Privacy Policy",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Icon(Icons.navigate_next,size: 27,
                                color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),)
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: themeNotifier.isDarkTheme
                      ? Color(0xff00cfd8)
                      : Color(0xff00a9b1),
                ),
                InkWell(
                  onTap: (){
                    Navigator.pushNamed(context, "/AboutUs");
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "About us",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Icon(Icons.navigate_next,size: 27,
                                color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),)
                            ],
                          ),
                          SizedBox(height: 10,),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: themeNotifier.isDarkTheme
                      ? Color(0xff00cfd8)
                      : Color(0xff00a9b1),
                ),
                SizedBox(height: 50),
                themeNotifier.isDarkTheme?
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: (){
                    if(!logoutPressed){
                      setState(() {
                        logoutPressed=true;
                      });
                      logoutUser();
                    }

                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xff00cfd8), // Border color
                        width: 1.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Center(
                      child: logoutPressed?Padding(
                        padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                      ):
                      Text("Log Out",style: TextStyle(
                          fontSize: 18,
                          color: Color(0xff00cfd8)
                      ),),
                    ),

                  ),
                )
                    :InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: (){
                    if(!logoutPressed){
                      setState(() {
                        logoutPressed=true;
                      });
                      logoutUser();
                    }

                  },
                  child: Container(
                    height: 40,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Color(0xff00d0da),
                      border: Border.all(
                        color: Color(0xff00a4a4), // Border color
                        width: 1.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Center(
                      child: logoutPressed?Padding(
                        padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                      ):
                      Text("Log Out",style: TextStyle(
                          fontSize: 18,
                          color: Colors.black
                      ),),
                    ),

                  ),
                ),

              ],
            ),
            !hasConnection?
            Container(
              height: double.infinity,
              width: double.infinity,
              color: themeNotifier.isDarkTheme?Colors.black54:Colors.white60,
            ):Container(),
            !hasConnection
                ? Padding(
              padding: const EdgeInsets.only(bottom:70),
              child:FocusScope(
                    node: FocusScopeNode(),
                    child: AlertDialog(
                      title: Text('No Internet Connection'),
                      content: Text(
                          'You need an internet connection to proceed. Please check your connection and try again.'),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      actions: [
                        TextButton(
                          onPressed: () => SystemNavigator.pop(),
                          child: Text('Exit'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await checkConnection();
                            // Navigator.pop() can be used here if desired
                          },
                          child: Text('Retry'),
                        ),
                      ],),
                  )

            )
                : Container(),
          ],
        )

      )

    );
  }
}
