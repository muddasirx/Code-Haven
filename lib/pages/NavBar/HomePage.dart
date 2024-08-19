import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/SplashScreen.dart';
import 'package:code_haven/pages/interestQueries.dart';
import 'package:code_haven/pages/searchQuery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../viewPost.dart';
import '../viewProfile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool hasConnection=true;
  TextEditingController searchController=TextEditingController();
  bool interestDataRecieved=false;
  List<DocumentSnapshot> interestQueries = [];

  Future<void> checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (mounted) {
      setState(() {
        hasConnection = result;
        if(hasConnection)
          fetchInterestQueries();
      });
    }
  }

  Future<void> fetchInterestQueries()async {
    try {
      print("----------------fetching documents now---------------------");
      print(SplashScreenState.userInterests);
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Post_Info')
          .where('tags', arrayContainsAny: SplashScreenState.userInterests)
          //.where('uid',isNotEqualTo: SplashScreenState.uid)
          .limit(3)
          .get();

      print("----------------documents recieved---------------------");

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
    checkConnection();
    print("${SplashScreenState.userInterests}");
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],
      body: SafeArea(
        child: Stack(
          children:[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Container(
                      height: 150,
                      width: 350,
                
                      child:Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(width: 40),
                        Text(
                        "Code\nHaven",
                        style: GoogleFonts.wallpoet(
                          textStyle: TextStyle(
                            color: themeNotifier.isDarkTheme ? Color(0xffd4f5ff):Color(0xffe3f7ff),//Colors.grey[200],
                            fontSize: 38,//43,
                            //fontWeight: FontWeight.bold
                          ),
                        ),),
                          SizedBox(width: 40,),
                          Image.asset('assets/icon/logo.png',height: 100,),
                        ],
                      ) ,
                
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                          gradient:LinearGradient(
                            colors: [Color(0xff0bcdfe), Color(0xff00646b)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                
                        /*LinearGradient(
                          colors: [Color(0xff00b4db), Color(0xff0083b0)],
                          stops: [0.2, 1],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )*/
                
                        //color: themeNotifier.isDarkTheme ? Color(0xff007a7b) : Color(0xff00a6b5),
                
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextField(
                      controller: searchController,
                      cursorColor: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                      decoration: InputDecoration(
                        hintText: "Search any query",
                        contentPadding:EdgeInsets.only(left:20,top: 18,bottom: 18,right: 10),
                        hintStyle: TextStyle(
                          color: Colors.grey
                        ),
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
                          borderRadius: BorderRadius.circular(40)
                        ),
                        focusedBorder:OutlineInputBorder(
                          borderSide: BorderSide(
                            width: themeNotifier.isDarkTheme?1.5:2,
                            color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                          ),
                            borderRadius: BorderRadius.circular(40)
                        ),
                        suffixIcon: IconButton(icon:Icon(Icons.search),
                          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                          onPressed: () {
                              if(searchController.text.isEmpty){
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text('Please input your query before proceeding.',style: TextStyle(
                                      color: Colors.white
                                  ),),backgroundColor: Colors.red,
                                ));
                              }
                              else{
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => searchQuery(q:searchController.text.trim())),
                                );
                              }
                          },)
                      ),
                    ),
                    SizedBox(height: 23,),
                    Text(
                        "Queries related to your interests",
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                            fontSize: 16,
                          ),
                        ),
                      ),

                    SizedBox(height: 10,),
                    Container(
                      height: 330,
                      width: double.infinity,
                      child:(!interestDataRecieved)?(hasConnection)?Center(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),strokeWidth: 2,),
                        ),
                      ):Container()
                          :(interestQueries.isEmpty)?
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Center(
                          child: Text(
                            "No queries found.",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[800],
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ):
                      ListView.separated(
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
                                              child: Text(
                                                interestQueries[index]['title'],
                                                style: GoogleFonts.lato(
                                                  textStyle: TextStyle(
                                                    color: themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[700],
                                                    fontSize: 15,
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
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                          border:Border.all(width:2,color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),)
                      )
                
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => moreInterestQueries()),
                          );
                          /*Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => viewProfile(id:SplashScreenState.uid)),
                          );*/
                        },
                        child: Text(
                          "show more",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                              decorationColor: themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),
                            ),
                          ),
                        ),)
                  ],
                ),
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
                  padding: const EdgeInsets.only(top:30),
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
            ]
        ),
      ),

    );
  }



}
