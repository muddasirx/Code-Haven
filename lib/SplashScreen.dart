import 'dart:async';
import 'dart:io';
import 'package:code_haven/pages/NavBar.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/interestPage.dart';
import 'package:code_haven/pages/login/loginPage.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:code_haven/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static const String keyLogin= "login";
  static const String theme= "light" ;
  static late var isLight;
  static var email;
  static var uid;
  var userTags;
  static List<String> userInterests=[];
  static File? pfp;


  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor: Colors.black//Color(0xff062929)//Color(0xff052020)//Theme.of(context).colorScheme.background
      ,body: Center(
        child: FadeTransition(
          opacity: _animation,
          child:Padding(
            padding: EdgeInsets.only(top: 250),
            child: Column(
              children: [
                Image.asset('assets/icon/logo.png',height: 200,),
                SizedBox(height: 15,),
                Text("Welcome to Code Haven",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(color:Color(0xff00cfd8)
                      ,fontSize: 24,//fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          )


        ),
      ),
    );
  }

  Future<void> _initializeFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAIxEY5oxRBLV-tKUggByXZJyHrN7GxfiU",
        appId: "1:259116621222:android:48090d7851cc82f2590367",
        messagingSenderId: "259116621222",
        projectId: "code-haven-be4ef",
        storageBucket: "code-haven-be4ef.appspot.com"
      ),
    );

    fetchEmailAndUid();

    print("------------------------ UserID: $uid ------------------------");
    _controller.forward().then((_) {
      Timer(Duration(seconds: 3), () async {
        var pref= await SharedPreferences.getInstance();
        var isLoggedIn= pref.getBool(keyLogin);
        isLight= pref.getBool(theme);
        if(isLight == true){
          final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
          themeNotifier.toggleTheme();
        }
        if (isLoggedIn == null || isLoggedIn == false) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => loginPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = Offset(1.0, 0.0);
                var end = Offset.zero;
                var tween = Tween(begin: begin, end: end);
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => NavBar(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                var begin = Offset(1.0, 0.0);
                var end = Offset.zero;
                var tween = Tween(begin: begin, end: end);
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
            ),
          );
        }
      });
    });
  }

  Future<void> fetchEmailAndUid() async{
    SharedPreferences prefLogin = await SharedPreferences.getInstance();
    email= await prefLogin.getString('email') ?? '';

    uid= await prefLogin.getString('uid') ?? '';

    userTags= await prefLogin.getString('userTags') ?? '';
    userInterests=userTags.split(',');
    List<String> x=[];
    for(String i in userInterests){
      x.add(i.trim());
    }
    userInterests.clear();
    userInterests=x;

  }

}
