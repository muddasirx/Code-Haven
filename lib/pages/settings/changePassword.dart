import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/interestPage.dart';
import 'package:code_haven/pages/login/loginPage.dart';
import 'package:code_haven/pages/settings/privacyPolicy.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:code_haven/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:day_night_switcher/day_night_switcher.dart';
import '../../SplashScreen.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController currentPasswordController=TextEditingController();
  TextEditingController newPasswordController=TextEditingController();
  TextEditingController confirmPasswordController=TextEditingController();
  bool updatePressed=false;
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _currentPasswordFocusNode = FocusNode();
  final _formKey= GlobalKey<FormState>();
  bool passwordCheck=false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updatePassword()async {
    if(_formKey.currentState != null && _formKey.currentState!.validate()){
      if(newPasswordController.text.trim()==confirmPasswordController.text.trim()){
        setState(() {
          updatePressed=true;
        });
        try{
          UserCredential credential = await _auth.signInWithEmailAndPassword(
            email: SplashScreenState.email,
            password: currentPasswordController.text.trim(),
          );
          User? user = _auth.currentUser;

          if (user != null) {
            print('------------User is signed in!------------');
            print('------------User ID: ${user.uid}------------');
            print('------------User Email: ${user.email}------------');
          } else {
            print('------------No user is signed in.------------');
          }
          await user?.updatePassword(newPasswordController.text);

          final theme = Provider.of<ThemeNotifier>(context, listen: false);
          Fluttertoast.showToast(
            msg: "Password updated successfully.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
            textColor: theme.isDarkTheme?Colors.white:Colors.black,
          );
          Navigator.pop(context);

        }on FirebaseAuthException catch (e) {
          if (e.toString() == '[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired.') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Current password is incorrect.', style: TextStyle(
                  color: Colors.white
              ),), backgroundColor: Colors.red,
            ));

            FocusScope.of(context).requestFocus(_currentPasswordFocusNode);
            setState(() {
              updatePressed= false;
            });
          } else {
            print('${e.toString()}');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${e.toString()}', style: TextStyle(
                  color: Colors.white
              ),), backgroundColor: Colors.red,
            ));
            setState(() {
              updatePressed= false;
            });
          }
        }
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Confirm password doesn\'t match.',style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
        confirmPasswordController.text='';
        FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
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
          "Change Password",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
              fontSize: 23,
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
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 40,),
              TextFormField(
                focusNode: _currentPasswordFocusNode,
                controller: currentPasswordController,
                cursorColor: Color(0xff00cfd8),
                cursorWidth: 1.5,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),
                  contentPadding: EdgeInsets.only(left: 15,right: 2,top: 16,bottom: 16),
                  labelText: "Current Password",
                  labelStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        fontSize: 16,
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
                    return "Current Password cannot be left Empty";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 40,),
              TextFormField(
                controller: newPasswordController,
                cursorColor: Color(0xff00cfd8),
                cursorWidth: 1.5,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),
                  contentPadding: EdgeInsets.only(left: 15,right: 2,top: 16,bottom: 16),
                  labelText: "New Password",
                  labelStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        fontSize: 16,
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
                    return "New Password cannot be left Empty";
                  }
                  return null;
                },
                onChanged: (value) {
                  if(newPasswordController.text.trim().length<6){
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
                  padding: const EdgeInsets.only(left: 5,top: 3),
                  child: Text("password should be of atleast 6 characters.",style: TextStyle(
                      color: Colors.red,
                      fontSize: 11
                  ),),
                ),
              ):SizedBox(),
              SizedBox(height: 40,),
              TextFormField(
                focusNode: _confirmPasswordFocusNode,
                controller: confirmPasswordController,
                cursorColor: Color(0xff00cfd8),
                cursorWidth: 1.5,
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18),
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  errorStyle: TextStyle(color: Colors.red),
                  contentPadding: EdgeInsets.only(left: 15,right: 2,top: 16,bottom: 16),
                  labelText: "Confirm Password",
                  labelStyle: GoogleFonts.lato(
                      textStyle:TextStyle(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        fontSize: 16,
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
                    return "Confirm Password cannot be left Empty";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              SizedBox(height: 40,),
              themeNotifier.isDarkTheme?
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  if(!updatePressed)
                    updatePassword();
                },
                child: Container(
                  height: 40,
                  width: 110,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff00cfd8), // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: updatePressed?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:43.5 ,vertical: 8.5),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                    ):
                    Text("Update",style: TextStyle(
                        fontSize: 15.5,
                        color: Color(0xff00cfd8)
                    ),),
                  ),
          
                ),
              )
                  :InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  if(!updatePressed)
                    updatePassword();
                },
                child: Container(
                  height: 40,
                  width: 110,
                  decoration: BoxDecoration(
                    color: Color(0xff00d0da),
                    border: Border.all(
                      color: Color(0xff00a4a4), // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: updatePressed?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:43 ,vertical: 8),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                    ):
                    Text("Update",style: TextStyle(
                        fontSize: 15.5,
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
