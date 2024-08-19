import 'package:code_haven/SplashScreen.dart';
import 'package:code_haven/pages/NavBar.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/NavBar/postQuestion.dart';
import 'package:code_haven/pages/SignUp/SignUp.dart';
import 'package:code_haven/pages/interestPage.dart';
import 'package:code_haven/pages/login/forgotPassword.dart';
import 'package:code_haven/pages/login/loginPage.dart';
import 'package:code_haven/pages/settings/AboutUs.dart';
import 'package:code_haven/pages/settings/changePassword.dart';
import 'package:code_haven/pages/settings/deleteAccount.dart';
import 'package:code_haven/pages/settings/myProfile.dart';
import 'package:code_haven/pages/settings/privacyPolicy.dart';
import 'package:code_haven/pages/updatePost.dart';
import 'package:code_haven/theme/darkTheme.dart';
import 'package:code_haven/theme/lightTheme.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'a.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
    runApp(MyApp());

}

class MyApp extends StatelessWidget {
    MyApp({super.key});
  bool dart_theme=false;
    static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            return MaterialApp(
              title: 'Code Haven',
              theme: themeNotifier.isDarkTheme ? darkTheme : lightTheme,
              //darkTheme: darkTheme,
              debugShowCheckedModeBanner: false,
              routes: {
                "/": (context) => SplashScreen(),
                "/login": (context) => loginPage(),
                "/SignUp": (context) => SignUp(),
                "/HomePage": (context) => HomePage(),
                "/forgotPassword": (context)=>forgotPassword(),
                "/selectInterests": (context)=>selectIntersts(),
                "/postQuestion": (context)=>postQuestion(),
                "/NavBar": (context)=>NavBar(),
                "/PrivacyPolicy": (context)=>PrivacyPolicy(),
                "/AboutUs": (context)=>AboutUs(),
                "/deleteAccount": (context)=>DeleteAccount(),
                "/MyProfile": (context)=>MyProfile(),
                "/ChangePassword": (context)=>ChangePassword(),

              },
            );
          },
        ),
      );
    }
}

