import 'package:code_haven/pages/login/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../theme/themeNotifier.dart';

class CheckEmailVerificationPage extends StatefulWidget {
  var n,em,p,u;
  CheckEmailVerificationPage({Key? key, this.n,this.em,this.p,this.u}) : super(key: key);
  @override
  _CheckEmailVerificationPageState createState() => _CheckEmailVerificationPageState();
}

class _CheckEmailVerificationPageState extends State<CheckEmailVerificationPage> with TickerProviderStateMixin{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var email,name,password,uid;
  User? user;
  bool isVerified = false;
  bool checking = false;

  late AnimationController _controller;
  late Animation<int> _animation;

  String get _dots {
    int dotCount = _animation.value;
    return '.' * dotCount;
  }

  Future<void> _checkEmailVerified() async {
    await user?.reload();
    user = _auth.currentUser;

    setState(() {
      isVerified = user?.emailVerified ?? false;
    });

    if (isVerified) {
      try{
        await FirebaseFirestore.instance.collection('UserInfo').add({
          'uid': uid,
          'name': name,
          'email': email,
          'bio':"none",
          'github':"none",
          'linkedin':"none",
          "image_url":"none",
          "notifications":[],
          "commentLiked":[]
          //'password' : password,
        });
      }
      catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unable to store data in database : ${e.toString()}',style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
        Navigator.pop(context);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => loginPage()), // Replace with your home page
      );
      final theme = Provider.of<ThemeNotifier>(context, listen: false);
      Fluttertoast.showToast(
        msg: "Account created Successfully.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
        textColor: theme.isDarkTheme?Colors.white:Colors.black,
      );
    }
    else{
      setState(() {
        checking=false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _animation = IntTween(begin: 0, end: 3).animate(_controller);
    email=widget.em;
    name=widget.n;
    password=widget.p;
    user = _auth.currentUser;
    uid=widget.u;
    _checkEmailVerified();
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Email Verification",
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
      body: AnimatedBuilder(
          animation: _animation,
          builder: (BuildContext context, child) {
            return checking
                ? Padding(
                  padding: const EdgeInsets.only(top: 290,left:55),
                  child: Text("Checking if the email was verified$_dots",style: TextStyle(
                  fontSize: 18,
                  color: themeNotifier.isDarkTheme?Colors.white:Colors.black
                              ),),
                )
                : Padding(
                  padding: const EdgeInsets.only(top: 290,left:90),
                  child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                    Text("Email is not verified yet!",style: TextStyle(
                        fontSize: 20,
                        color: themeNotifier.isDarkTheme?Colors.white:Colors.black
                    ),),
                    SizedBox(height: 20),
                    themeNotifier.isDarkTheme?
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: (){
                        checking=true;
                        _checkEmailVerified();
                      },
                      child: Container(
                        height: 40,
                        width: 120,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xff00cfd8), // Border color
                            width: 1.0, // Border width
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: checking?Padding(
                            padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                          ):
                          Text("Check Again",style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff00cfd8)
                          ),),
                        ),

                      ),
                    )
                        :InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: (){
                        checking=true;
                        _checkEmailVerified();
                      },
                      child: Container(
                        height: 40,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Color(0xff00d0da),
                          border: Border.all(
                            color: Color(0xff00a4a4), // Border color
                            width: 1.0, // Border width
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Center(
                          child: checking?Padding(
                            padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                          ):
                          Text("Check Again",style: TextStyle(
                              fontSize: 16,
                              color: Colors.black
                          ),),
                        ),

                      ),
                    ),
                                  ],
                                ),
                );
          },

        ),


    );
  }
}
