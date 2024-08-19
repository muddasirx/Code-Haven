import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:code_haven/pages/interestPage.dart';
import 'package:code_haven/pages/login/loginPage.dart';
import 'package:code_haven/pages/updatePost.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:code_haven/main.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../SplashScreen.dart';
import 'package:popover/popover.dart';

import '../viewPost.dart';


class MyQuestions extends StatefulWidget {
  const MyQuestions({super.key});

  @override
  State<MyQuestions> createState() => _MyQuestionsState();
}

class _MyQuestionsState extends State<MyQuestions> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic>userQueries=[];
  bool dataRecieved=false;
  bool hasConnection=true;

  Future<void> checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (mounted) {
      setState(() {
        hasConnection = result;
      });
      if(hasConnection)
        fetchUserQueries();
    }
  }

  Future<void> fetchUserQueries() async {
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Post_Info')
          .where('uid', isEqualTo: SplashScreenState.uid)
          .get();
      setState(() {
        userQueries = querySnapshot.docs;
        dataRecieved=true;
        print("---------length of userQueries: ${userQueries.length}----------");
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to fetch userQueries : ${e.toString()}',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
    }
  }

  Widget deletePost(int index){
    final theme = Provider.of<ThemeNotifier>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: AlertDialog(
        title: Text('Delete post'),
        content: Text('Are you sure you want to delete this post?'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          TextButton(onPressed:(){
            Navigator.pop(context);
          },
              child: Text("Cancel")),
          TextButton(onPressed:() async{
            try{
              await _firestore.collection('Post_Info').doc(userQueries[index].id).delete();

              print("----------Post deleted now moving to comments---------");
              print("ID of comment: "+userQueries[index]['comments'].toString());
              for (var cid in userQueries[index]['comments']) {
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Comments').where('commentID', isEqualTo: cid).get();

                print("ID of comment doc: "+querySnapshot.docs.first.id);

                await FirebaseFirestore.instance.collection('Comments').doc(querySnapshot.docs.first.id).delete();
              }

              List<dynamic> x=[];
              QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                  .collection('Notifications')
                  .where('postID', isEqualTo: userQueries[index].id)
                  .get();
              x=querySnapshot.docs;
              for(var i in x){
                await _firestore.collection('Notifications').doc(i.id).delete();
              }


              print("----------Post deleted now moving to comments---------");
              setState(() {
                userQueries.removeAt(index);
              });
              
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Post deleted successfully.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
                textColor: theme.isDarkTheme?Colors.white:Colors.black,
              );
            }catch(e){
              print('${e.toString()}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${e.toString()}', style: TextStyle(
                    color: Colors.white
                ),), backgroundColor: Colors.red,
              ));
              print('${e.toString()}');
            }
          },
              child: Text("Delete"))
        ],
      ),
    );
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
          "My Posts",
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

      body: Stack(
        children: [
          (!dataRecieved)?Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),strokeWidth: 3,),
            ),
          ):Padding(
            padding: const EdgeInsets.only(top:30),
            child: (userQueries.isEmpty)?
                Padding(
                  padding: const EdgeInsets.only(top:0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Text(
                        "No queries posted yet.",
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
            ListView.separated(
                      itemBuilder: (context,index){
                        return InkWell(
                            onTap: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => viewPost(p:userQueries[index])),
                              );
                            },
                          child:Padding(
                              padding: const EdgeInsets.only(left: 17,right:0),
                              child: Column(
                                children: [
                                  Container(
                                    height:100,
                                    width: double.infinity,
                                    child: Row(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            width: 311,
                                            child: Text(
                                              userQueries[index]['title'],
                                              style: GoogleFonts.lato(
                                                textStyle: TextStyle(
                                                  color: themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[700],
                                                  fontSize: 17,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 15.8,),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 0),
                                          child: PopupMenuButton<String>(
                                            color:themeNotifier.isDarkTheme ? Colors.grey[900] : Colors.grey[200],
                                            icon: Icon(
                                              Icons.more_vert, // Change the icon to more_vert
                                              color: themeNotifier.isDarkTheme ? Colors.grey[500] : Colors.grey[600], // Change the color of the icon
                                            ),
                                            onSelected: (value) async {
                                              if (value == 'delete') {
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return deletePost(index);
                                                    }
                                                );
                                              }
                                              else if(value == 'update') {
                                                print("--------- index is $index ----------");
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => updateQuestion(pd:userQueries[index])),
                                                );
                                                if (result != null) {
                                                  // Reload data or update UI
                                                  setState(() {
                                                    dataRecieved=false;
                                                  });
                                                  fetchUserQueries();
                                                }
                                              }
                                            },
                                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                              PopupMenuItem<String>(
                                                value: 'update',
                                                child: Text(
                                                  'Update post',
                                                  style: GoogleFonts.lato(
                                                    textStyle: TextStyle(
                                                      color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                //color: Colors.white38,
                                              ),
                                              PopupMenuDivider(),
                                              PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text(
                                                    'Delete post',
                                                    style: GoogleFonts.lato(
                                                      textStyle: TextStyle(
                                                        color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),

                                                ),

                                            ],
                                          ),
                                        )

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
                      itemCount: userQueries.length),

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
