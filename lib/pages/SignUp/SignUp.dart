import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../main.dart';
import 'checkEmailVerification.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey= GlobalKey<FormState>();
  bool signupPressed=false;
  TextEditingController nameController= new TextEditingController();
  TextEditingController passwordController= new TextEditingController();
  TextEditingController cPasswordController= new TextEditingController();
  TextEditingController emailController= new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSendingVerification = false;
  bool emailNotSent=false;
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  late UserCredential _user;
  bool passwordCheck=false;

  bool _isValidEmail(String email) {
    // Regular expression for validating an email
    final RegExp emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );
    return emailRegex.hasMatch(email);
  }

  void _sendVerificationEmail() async {
    setState(() {
      _isSendingVerification = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text.trim(), // This should be more secure and managed
      );
      _user=userCredential;
      User? user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        final theme = Provider.of<ThemeNotifier>(context, listen: false);
        Fluttertoast.showToast(
          msg: "Verification email sent.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
          textColor: theme.isDarkTheme?Colors.white:Colors.black,
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${e.message}',style: TextStyle(
          color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
      emailNotSent=true;
    } finally {
      if(!emailNotSent){
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => CheckEmailVerificationPage(
              n:nameController.text.trim(),
              em:emailController.text.trim(),
              p:passwordController.text.trim(),
              u: _user.user?.uid
          )
          ), // Replace with your home page
        );
      }
      setState(() {
        _isSendingVerification = false;
        signupPressed=false;
      });

    }
  }

  void _checkFieldValidation(){
    if(_formKey.currentState != null && _formKey.currentState!.validate()) {
        if(_isValidEmail(emailController.text.trim())){
            if(passwordController.text.trim().length>=6){
              if(passwordController.text.trim()==cPasswordController.text.trim()){
                setState(() {
                  signupPressed=true;
                });
                _sendVerificationEmail();
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
        }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid Email!',style: TextStyle(
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Create an Account",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
              fontSize: 22,
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
            padding: const EdgeInsets.only(left: 40,right: 40,top:60),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the Column vertically
                  children: [
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: nameController,
                      cursorColor: Color(0xff00cfd8),
                      cursorWidth: 1.5,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.red),
                        contentPadding: EdgeInsets.only(left: 15,right: 2,top: 18,bottom: 18),
                        labelText: "Full Name",
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
                          return "Name cannot be Empty";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 30),
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
                    SizedBox(height: 30),
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
                          Text("Sign Up",style: TextStyle(
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
                          Text("Sign Up",style: TextStyle(
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
          ),

    );
  }
}
