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
import '../SignUp/SignUp.dart';
import '../interestPage.dart';

class GoogleSignInPage extends StatefulWidget {
  String e,n;
  GoogleSignInPage({Key? key, required this.e,required this.n}) : super(key: key);

  @override
  State<GoogleSignInPage> createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  TextEditingController passwordController= new TextEditingController();
  TextEditingController cPasswordController= new TextEditingController();
  bool passwordCheck=false;
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final _formKey= GlobalKey<FormState>();
  bool signupPressed=false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _checkFieldValidation() async{
    if(_formKey.currentState != null && _formKey.currentState!.validate()) {
        if(passwordController.text.trim().length>=6){
          if(passwordController.text.trim()==cPasswordController.text.trim()){
            setState(() {
              signupPressed=true;
            });
            try{
              UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                email: widget.e.trim().toLowerCase(),
                password: passwordController.text.trim(), // This should be more secure and managed
              );
              await FirebaseFirestore.instance.collection('UserInfo').add({
                'uid': userCredential.user?.uid,
                'name': widget.n,
                'email': widget.e,
                'bio':"none",
                'github':"none",
                'linkedin':"none",
                "image_url":"none",
                "notifications":[],
                "commentLiked":[]
                //'password' : password,
              });
              SplashScreenState.email=widget.e.trim();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool(SplashScreenState.keyLogin, true);
              await prefs.setString('email', widget.e);
              await prefs.setString('uid', userCredential.user!.uid);
              SplashScreenState.uid=userCredential.user!.uid;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => selectIntersts()),
                    (route) => false,
              );

            }on FirebaseAuthException catch(e){
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${e.message}',style: TextStyle(
                    color: Colors.white
                ),),backgroundColor: Colors.red,
              ));
              setState(() {
                signupPressed=false;
              });
            }
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Confirm password doesn\'t match!',style: TextStyle(
                  color: Colors.white
              ),),backgroundColor: Colors.red,
            ));
            cPasswordController.text='';
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
          }
        }
    }

  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Provide password to proceed",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
              fontSize: 17,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
        ),
        backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],
      ),
      backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],

      body: Padding(
        padding: const EdgeInsets.only(left: 40,right: 40,top: 60),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: passwordController,
                cursorColor: Color(0xff00cfd8),
                cursorWidth: 1.5,
                obscureText: true,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),
                  contentPadding: EdgeInsets.only(left: 15,right: 2,top: 18,bottom: 18),
                  labelText: "Password",
                  labelStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        fontSize: 18,
                        // fontWeight: themeNotifier.isDarkTheme? FontWeight.normal:FontWeight.bold
                      )),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: themeNotifier.isDarkTheme?1.5:2,
                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: themeNotifier.isDarkTheme?1.5:2,
                      color: Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.5,
                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.5,
                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Password cannot be Empty";
                  }
                  return null;
                },
                onChanged: (value) {
                  if(passwordController.text.trim().length<6){
                    setState(() {
                      passwordCheck=true;
                    });
                  }
                  else{
                    setState(() {
                      passwordCheck=false;
                    });
                  }
                },
              ),
              passwordCheck?Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10,top: 3),
                  child: Text("password should be of atleast 6 characters.",style: TextStyle(
                      color: Colors.red,
                      fontSize: 13
                  ),),
                ),
              ):SizedBox(),
              SizedBox(height: 30),
              TextFormField(
                controller: cPasswordController,
                focusNode: _confirmPasswordFocusNode,
                cursorColor: Color(0xff00cfd8),
                obscureText: true,
                cursorWidth: 1.5,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),
                  contentPadding: EdgeInsets.only(left: 15,right: 2,top: 18,bottom: 18),
                  labelText: "Confirm Password",
                  labelStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        fontSize: 18,
                        // fontWeight: themeNotifier.isDarkTheme? FontWeight.normal:FontWeight.bold
                      )),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: themeNotifier.isDarkTheme?1.5:2,
                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: themeNotifier.isDarkTheme?1.5:2,
                      color: Colors.red,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.5,
                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1.5,
                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Confirm Password cannot be Empty";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 45),
              themeNotifier.isDarkTheme?
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  _checkFieldValidation();
                  //_sendVerificationEmail();
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
                    child: signupPressed?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                    ):
                    Text("Next",style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff00cfd8)
                    ),),
                  ),

                ),
              )
                  :InkWell  (
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  _checkFieldValidation();
                  // _sendVerificationEmail();

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
                    child: signupPressed?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                    ):
                    Text("Next",style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),),
                  ),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
