import 'dart:async';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({super.key});

  @override
  State<forgotPassword> createState() => _forgotPasswordState();
}

class _forgotPasswordState extends State<forgotPassword> {
  final _formKey= GlobalKey<FormState>();
  TextEditingController emailController= new TextEditingController();
  bool buttonPressed=false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool _isValidEmail(String email) {
    // Regular expression for validating an email
    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );
    return emailRegex.hasMatch(email);
  }

  void resetPassword(){
    if(_formKey.currentState != null && _formKey.currentState!.validate()) {
      if(_isValidEmail(emailController.text.trim())){
        setState(() {
          buttonPressed=true;
        });
        try{
          auth.sendPasswordResetEmail(email: emailController.text.trim());
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text('A password reset email has been sent to you.'),
          // ));
          final theme = Provider.of<ThemeNotifier>(context, listen: false);
          Fluttertoast.showToast(
            msg: "A password reset email has been sent to you.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
            textColor: theme.isDarkTheme?Colors.white:Colors.black,
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (route) => false, // Remove all routes from the stack
          );
        }on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${e.toString()}',style: TextStyle(
                color: Colors.white
            ),),backgroundColor: Colors.red,
          ));
          setState(() {
            buttonPressed=false;
          });
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

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        title: Text(
          "Reset Password",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
              fontSize: 22,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
        ),
        backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],
      ),
      backgroundColor:themeNotifier.isDarkTheme?Theme.of(context).colorScheme.background:Colors.grey[290],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 70,),
              TextFormField(
                controller: emailController,
                cursorColor: Color(0xff00cfd8),
                cursorWidth: 1.5,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),
                  contentPadding: EdgeInsets.only(left: 15,right: 2,top: 18,bottom: 18),
                  labelText: "Email",
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
                    return "Email cannot be Empty";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 30,),
              themeNotifier.isDarkTheme?
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  resetPassword();
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
                    child: buttonPressed?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                    ):
                    Text("Reset",style: TextStyle(
                        fontSize: 18,
                        color: Color(0xff00cfd8)
                    ),),
                  ),

                ),
              )
                  :InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  resetPassword();
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
                    child: buttonPressed?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                    ):
                    Text("Reset",style: TextStyle(
                        fontSize: 18,
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
