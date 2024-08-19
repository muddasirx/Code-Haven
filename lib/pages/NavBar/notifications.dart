import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/interestPage.dart';
import 'package:code_haven/pages/login/loginPage.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:code_haven/main.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../SplashScreen.dart';
import '../viewPost.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  bool interestDataRecieved=false;
  List<dynamic> notifications=[];
  List<dynamic> posts=[];
  bool dataRecieved=false;
  bool hasConnection=true;

  Future<void> checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (mounted) {
      setState(() {
        hasConnection = result;
      });
      if(hasConnection)
        fetchUserNotifications();
    }
  }

  Future<void> fetchUserNotifications() async {
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Notifications')
          .where('uid', isEqualTo: SplashScreenState.uid).orderBy('time',descending:false)
          .get();
      notifications = querySnapshot.docs;
      notifications=notifications.reversed.toList();

      if(notifications.isNotEmpty){
        for(int i=0;i< notifications.length;i++){
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('Post_Info')
              .where(FieldPath.documentId, isEqualTo: notifications[i]['postID'])
              .get();
          setState(() {
            print("postID of queryFetched : ${querySnapshot.docs.first.id}");
            posts.add(querySnapshot.docs.first);
            print("post ID of index ${i} : ${posts[i].id}");
          });
        }
      }
      setState(() {
        dataRecieved=true;
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to fetch userData : ${e.toString()}',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> navigateToPost(index) async{

      if(!notifications[index]['postViewed']) {
        DocumentReference docRef = notifications[index].reference;
        await docRef.update({
          'postViewed': true,
        });

      }
      print("--------index: "+index.toString()+"-------------");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => viewPost(p:posts[index])),
    );
  }

  String timeAgoSinceDate(Timestamp timestamp) {
    DateTime postDate = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(postDate);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h";
    } else if (difference.inDays < 30) {
      return "${difference.inDays}d";
    } else if (difference.inDays < 365) {
      return "${(difference.inDays / 30).floor()}mo";
    } else {
      return "${(difference.inDays / 365).floor()}yr";
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Notifications",
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

      backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],

      body:Stack(
        children: [
          (!dataRecieved)?Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),strokeWidth: 3,),
            ),
          ):Padding(
            padding: const EdgeInsets.only(top:30),
            child: (notifications.isEmpty)?
            Padding(
              padding: const EdgeInsets.only(top:0),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "No notifications available.",
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[800],
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ):
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListView.separated(
                  itemBuilder: (context,index){
                    return InkWell(
                      onTap: (){
                        navigateToPost(index);
                      },
                      child:Column(
                          children: [
                            Container(
                              height:70,
                              width: double.infinity,
                              color: (notifications[index]['postViewed'])?Colors.transparent:themeNotifier.isDarkTheme?Colors.grey[800]:Colors.grey[300],
                              child: Row(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left:18),
                                      child: Container(
                                        width: 355,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notifications[index]['notification'],
                                                style: GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                    color: themeNotifier.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                            Text(
                                              timeAgoSinceDate(notifications[index]['time']),
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),//themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[800],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),


                    );
                  },
                  separatorBuilder: (context,index){
                    return Divider(thickness: 2,color: themeNotifier.isDarkTheme?Colors.grey[700]:Colors.grey[300],);
                  },
                  itemCount: notifications.length),
            ),

          ),
          !hasConnection?
          Container(
            height: double.infinity,
            width: double.infinity,
            color: themeNotifier.isDarkTheme?Colors.black54:Colors.white60,
          ):Container(),
          !hasConnection
              ? Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Center(
                child: FocusScope(
                  node: FocusScopeNode(),
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
                    ],),
                )
            ),
          )
              : Container(),
        ],
      ),
    );
  }
}
