import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/SplashScreen.dart';
import 'package:code_haven/pages/searchQuery.dart';
import 'package:code_haven/pages/viewPost.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NavBar.dart';
import 'filterInterestQueries.dart';

class moreInterestQueries extends StatefulWidget {
  const moreInterestQueries({super.key});

  @override
  State<moreInterestQueries> createState() => moreInterestQueriesState();
}

class moreInterestQueriesState extends State<moreInterestQueries> {
  bool interestDataRecieved=false;
  List<DocumentSnapshot> interestQueries = [];
  static List<String>tags=[];


  Future<void> fetchInterestQueries()async {
    tags=(SplashScreenState.userInterests);
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Post_Info')
          .where('tags', arrayContainsAny: tags)
          .get();

      setState(() {
        interestQueries = querySnapshot.docs;
        interestDataRecieved=true;
      });
    } catch (e) {
      print('Error fetching documents: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchInterestQueries();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Material(
      child: WillPopScope(
        onWillPop: () async{
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NavBar()),
                (route) => false,
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            //centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed:(){
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => NavBar()),
                        (route) => false,
                  );
                },
                    icon: Icon(Icons.arrow_back,size: 25,
                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),),),
                SizedBox(width: 0,),
                Text(
                  "Interest Queries",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: themeNotifier.isDarkTheme ? Colors.white:Colors.black,
                      fontSize: 22,
                    ),
                  ),
                ),
                SizedBox(width: 0),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => filterQueries()),
                    );
                  },
                  child: Text(
                    "filter",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

              ],
            ),
            iconTheme: IconThemeData(
              color:
              themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
            ),
            backgroundColor: themeNotifier.isDarkTheme
                ? Colors.black
                : Colors.grey[290],
          ),
          backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],

          body: (!interestDataRecieved)? Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),strokeWidth: 2,),
            ),
          )
              :(interestQueries.isEmpty)?
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Center(
              child: Text(
                "No queries found.",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: themeNotifier.isDarkTheme?Colors.grey[300]:Colors.grey[700],
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ):
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: ListView.separated(
                itemBuilder: (context,index){
                  return InkWell(
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => viewPost(p:interestQueries[index])),
                      );
                    },
                    child:Padding(
                      padding: const EdgeInsets.only(left: 17,right:0),
                      child: Column(
                        children: [
                          Container(
                            height:95,
                            width: double.infinity,
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 311,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Text(
                                        interestQueries[index]['title'],
                                        style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            color: themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[800],
                                            fontSize: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  );
                },
                separatorBuilder: (context,index){
                  return Divider(thickness: 2,color: themeNotifier.isDarkTheme?Colors.grey[700]:Colors.grey[300],);
                },
                itemCount: interestQueries.length),
          ),
        ),
      ),
    );
  }
}
