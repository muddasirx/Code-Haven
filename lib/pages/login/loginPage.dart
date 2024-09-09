import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import '../../SplashScreen.dart';
import '../SignUp/GoogleSignIn.dart';
import '../SignUp/SignUp.dart';
import '../interestPage.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool hasConnection = true; // Initial assumption
  bool loginPressed=false;
  final _formKey= GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool forgotPassword=false;

 //Functions

  void googleSignIn() async{
    try{
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if(googleUser == null){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Google Signin Failed!',style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
      }else{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GoogleSignInPage(e:googleUser.email.toString(),n:googleUser.displayName.toString())),
        );
      }
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could\'nt Signin : ${e.toString()}',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> checkConnection() async {
    var result = await InternetConnectionChecker().hasConnection;
    if (mounted) {
      setState(() {
        hasConnection = result;
      });
    }
  }

  bool _isValidEmail(String email) {
    // Regular expression for validating an email
    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );
    return emailRegex.hasMatch(email);
  }

  void checkLogin() async{
    if(_formKey.currentState != null && _formKey.currentState!.validate()) {
      if(_isValidEmail((emailController.text.trim()))){
        setState(() {
          loginPressed=true;
        });
        final userCredential = await loginUser(emailController.text.trim(), passwordController.text.trim());
        if(userCredential!=null){
          SplashScreenState.email=emailController.text.trim();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool(SplashScreenState.keyLogin, true);
          await prefs.setString('email', emailController.text);
          await prefs.setString('uid', userCredential.user!.uid);
          SplashScreenState.uid=userCredential.user!.uid;

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => selectIntersts()),
                (route) => false,
          );
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid Email.',style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<UserCredential?> loginUser(String email, String password) async {
    try {
      // Sign in with email and password
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid email or password.",style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
        setState(() {
          loginPressed=false;
          forgotPassword=true;
        });
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid email or password.",style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
        print('Wrong password provided for that user.');
        setState(() {
          loginPressed=false;
          forgotPassword=true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid email or password.",style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
        setState(() {
          loginPressed=false;
          forgotPassword=true;
        });
        print(e.code); // Print other errors
      }
    }
    return null;
  }


  @override
  void initState() {
    checkConnection();
    loginPressed=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      /*appBar: AppBar(
        title: Text("Login",
          style: GoogleFonts.prompt(
            textStyle: TextStyle(color: Colors.black,fontSize: 28, ),
          ),
        ),
        backgroundColor: Color(0xff00cfd8),
        centerTitle: true,
      ),*/
      backgroundColor:themeNotifier.isDarkTheme?Theme.of(context).colorScheme.background:Colors.grey[290],
      body: SingleChildScrollView(
        child: Stack(
          children:[ Column(
            children: [
              forgotPassword?SizedBox(height: 110):SizedBox(height: 120,),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Image.asset('assets/icon/logo.png',height: 125,),

                        SizedBox(height: 40,),
                        TextFormField(
                          // autovalidateMode: AutovalidateMode.onUserInteraction,
                          cursorWidth: 1.5,
                          controller: emailController,
                          cursorColor: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 15),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red,),
                            contentPadding: EdgeInsets.only(left: 27,right: 2,top: 22,bottom: 22),
                            hintText: "Email",//currentHeight.toString(),
                            hintStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                  fontSize: 18,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(29),
                                borderSide: BorderSide(
                                    width: 2,
                                    color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5)
                                )
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(29),
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.red, // Customize the error border color as needed
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(29),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5)
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(29),
                              borderSide: BorderSide(
                                width: 2,
                                color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5), // Customize the error border color as needed
                              ),
                            ),

                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 10,right: 5),
                              child: Icon(Icons.account_circle_outlined,
                                  color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5),
                                  size: 30),
                            ),

                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (value){
                            setState(() {});
                          },

                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          // autovalidateMode: AutovalidateMode.onUserInteraction,
                          cursorWidth: 1.5,
                          controller: passwordController,
                          obscureText: true,
                          cursorColor: Color(0xff00cfd8),
                          style: TextStyle(color: Theme.of(context).colorScheme.primary,fontSize: 15),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red,),
                            contentPadding: EdgeInsets.only(left: 27,right: 2,top: 22,bottom: 22),
                            hintText: "Password",//currentHeight.toString(),
                            hintStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                  fontSize: 18,
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(29),
                                borderSide: BorderSide(
                                    width: 2,
                                    color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5)
                                )
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(29),
                              borderSide: BorderSide(
                                width: 2,
                                color: Colors.red, // Customize the error border color as needed
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(29),
                              borderSide: BorderSide(
                                  width: 2,
                                  color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5)
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(29),
                              borderSide: BorderSide(
                                width: 2,
                                color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5), // Customize the error border color as needed
                              ),
                            ),

                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 10,right: 5),
                              child: Icon(Icons.lock_outline,
                                  color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5),
                                  size: 28),
                            ),

                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password cannot be Empty";
                            }
                            return null;
                          },
                          onChanged: (value){
                            setState(() {});
                          },

                        ),
                        SizedBox(height:30 ,),
                        themeNotifier.isDarkTheme?
                        InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: (){
                                  /*if(!loginPressed){
                                    setState(() {
                                      loginPressed=true;
                                    });
                                    }*/
                                  checkLogin();
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
                                  child: loginPressed?Padding(
                                    padding: EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                                  ):
                                  Text("Login",style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xff00cfd8)
                                  ),),
                                ),

                              ),
                            )
                        :InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: (){
                            /*if(!loginPressed){
                              setState(() {
                                loginPressed=true;
                              });
                            }*/
                            checkLogin();
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
                              child: loginPressed?Padding(
                                padding: EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                              ):
                              Text("Login",style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black
                              ),),
                            ),

                          ),
                        ),
                        forgotPassword?Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, "/forgotPassword");
                            },
                            child: Text("Forgot Password?",
                              style: TextStyle(
                                fontSize: 16,
                                  //decoration: TextDecoration.underline,
                                //decorationColor: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a9b1),
                                color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a9b1),//Color(0xff00a6b5),

                              ),),
                          ),
                        ):SizedBox(),
                        forgotPassword?SizedBox(height: 30,):SizedBox(height: 40,),
                        Row(
                          children: [
                            SizedBox(width: 50,),
                            Text("Don't have an account?",
                              style: TextStyle(
                                fontSize: 16,
                                color: themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a9b1),//Color(0xff00a6b5),

                              ),),
                            SizedBox(width: 5,),
                            InkWell(
                                onTap: (){
                                  setState(() {
                                    loginPressed= false;
                                  });
                                  Navigator.pushNamed(context, "/SignUp");

                                  },
                                child: Text("SignUp",style: TextStyle(
                                  fontSize: 16,
                                  color: themeNotifier.isDarkTheme?Colors.white:Colors.black,
                                  //decoration: TextDecoration.underline
                                ),))
                          ],
                        ),
                        SizedBox(height:14),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                //thickness: 2,
                                color: themeNotifier.isDarkTheme
                                    ? Color(0xff00cfd8)
                                    : Color(0xff00a9b1),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("OR", style: TextStyle(
                                color: themeNotifier.isDarkTheme
                                    ? Color(0xff00cfd8)
                                    : Color(0xff00a9b1),
                              )),
                            ),
                            Expanded(
                              child: Divider(
                               // thickness: 2,
                                color: themeNotifier.isDarkTheme
                                    ? Color(0xff00cfd8)
                                    : Color(0xff00a9b1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            googleSignIn();

                          },
                          child: Container(
                            height: 50,
                            width: 208,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: themeNotifier.isDarkTheme?Colors.white:Colors.black, // Border color
                                width: 1.0, // Border width
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: 10,),
                                Image.asset("assets/images/google.png",height: 22,),
                                SizedBox(width: 10,),
                                Text("Continue with Google",style: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).colorScheme.primary
                                ),)


                              ],
                            ),
                          ),
                        )

                      ],
                    ),
                  ),
                ),


            ],
          ),
            !hasConnection?
            Container(
              height: 900,
              width: double.infinity,
              color: themeNotifier.isDarkTheme?Colors.black54:Colors.white60,
            ):Container(),
            !hasConnection
                ? Padding(
                  padding: EdgeInsets.only(top: 255),
                  child: Center(
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
                  ],)
                  ),
                )
                : Container(),
          ]
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 135,bottom: 5),
        child: Text("Code Haven",
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(color:themeNotifier.isDarkTheme?Color(0xff00cfd8):Color(0xff00a6b5)
              ,fontSize: 20, //fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    );
  }
}

