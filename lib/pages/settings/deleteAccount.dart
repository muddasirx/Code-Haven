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

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  String dropdownValue="No";
  TextEditingController passwordController=TextEditingController();
  bool deletePressed=false;
  final _formKey= GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteAccount() async {
    if(_formKey.currentState != null && _formKey.currentState!.validate()) {
        setState(() {
          deletePressed=true;
        });
        String password=passwordController.text.trim();
        String email=SplashScreenState.email;
        try {
          // Authenticate the user
          UserCredential userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          User user = userCredential.user!;

          QuerySnapshot querySnapshot = await _firestore
              .collection('UserInfo')
              .where('email', isEqualTo: email)
              .get();

          // Check if any documents were found
          if (querySnapshot.docs.isNotEmpty) {
            for (var doc in querySnapshot.docs) {
              await _firestore.collection('UserInfo').doc(doc.id).delete();
            }
          } else {
            throw Exception('Invalid Password');
          }
          List<dynamic>userQueries=[];
          QuerySnapshot qs = await FirebaseFirestore.instance
              .collection('Post_Info')
              .where('uid', isEqualTo: SplashScreenState.uid)
              .get();
            userQueries = qs.docs;
            for(int index=0;index<userQueries.length;index++){
              await _firestore.collection('Post_Info').doc(userQueries[index].id).delete();
              List<dynamic> x=[];
              QuerySnapshot q = await FirebaseFirestore.instance
                  .collection('Notifications')
                  .where('postID', isEqualTo: userQueries[index].id)
                  .get();
              x=q.docs;
              for(var i in x){
                await _firestore.collection('Notifications').doc(i.id).delete();
              }
            }
          await user.delete();

          final theme = Provider.of<ThemeNotifier>(context, listen: false);
          Fluttertoast.showToast(
            msg: "Account deleted successfully.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
            textColor: theme.isDarkTheme?Colors.white:Colors.black,
          );
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool(SplashScreenState.keyLogin, false);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
                (route) => false,
          );
        }on FirebaseAuthException catch (e) {
          if (e.toString() == '[firebase_auth/invalid-credential] The supplied auth credential is incorrect, malformed or has expired.') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Incorrect Password.', style: TextStyle(
                  color: Colors.white
              ),), backgroundColor: Colors.red,
            ));
            setState(() {
              deletePressed= false;
            });
          } else {
            print('${e.toString()}');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${e.toString()}', style: TextStyle(
                  color: Colors.white
              ),), backgroundColor: Colors.red,
            ));
            setState(() {
              deletePressed= false;
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${e.toString()}', style: TextStyle(
                color: Colors.white
            ),), backgroundColor: Colors.red,
          ));
          setState(() {
            deletePressed= false;
          });
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
          "Delete Account",
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

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 40,),
                  Text(
                    "Are you sure you want to delete your account? This action is permanent and will result in the loss of all your saved data and preferences. If you're certain about this decision, please confirm below. If not, you can always reconsider or reach out to our support team for assistance. Your satisfaction is important to us, and we're here to help in any way we can.",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 30,),
                  Row(
                    children: [
                      Text(
                        " Choose:  ",
                        style: TextStyle(
                          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: dropdownValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
                        },
                        dropdownColor: themeNotifier.isDarkTheme ? Colors.grey[850] : Colors.grey[400],
                        style: TextStyle(
                          color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
                          fontSize: 16,
                        ),
                        underline: Container(
                          height: 2,
                          color: themeNotifier.isDarkTheme ? Colors.white70 : Colors.black54,
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: themeNotifier.isDarkTheme ? Colors.white70 : Colors.black54,
                        ),
                        items: (dropdownValue=='No')?<String>['No','Yes']
                            .map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList():<String>['Yes','No']
                            .map<DropdownMenuItem<String>>(
                              (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  (dropdownValue=='Yes')?
                  Column(
                    children: [
                      TextFormField(
                        controller: passwordController,
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
                            return "Password cannot be left Empty";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 45,),
                      themeNotifier.isDarkTheme?
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: (){
                          if(!deletePressed){
                            deleteAccount();
                          }

                        },
                        child: Container(
                          height: 43,
                          width: 143,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xff00cfd8), // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: deletePressed?Padding(
                              padding: const EdgeInsets.symmetric(horizontal:60 ,vertical: 10),
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                            ):
                            Text("Delete Account",style: TextStyle(
                                fontSize: 15.5,
                                color: Color(0xff00cfd8)
                            ),),
                          ),

                        ),
                      )
                          :InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: (){
                          if(!deletePressed){
                            deleteAccount();
                          }

                        },
                        child: Container(
                          height: 43,
                          width: 143,
                          decoration: BoxDecoration(
                            color: Color(0xff00d0da),
                            border: Border.all(
                              color: Color(0xff00a4a4), // Border color
                              width: 1.0, // Border width
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Center(
                            child: deletePressed?Padding(
                              padding: const EdgeInsets.symmetric(horizontal:60 ,vertical: 10),
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                            ):
                            Text("Delete Account",style: TextStyle(
                                fontSize: 15.5,
                                color: Colors.black
                            ),),
                          ),

                        ),
                      ),
                    ],
                  ):SizedBox(),
                  SizedBox(height: 30,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
