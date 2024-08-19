import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/pages/viewPost.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../SplashScreen.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class viewProfile extends StatefulWidget {
  var id;
  viewProfile({Key? key, required this.id}) : super(key: key);

  @override
  State<viewProfile> createState() => _viewProfileState();
}

class _viewProfileState extends State<viewProfile> {
  var userID;
  DocumentSnapshot? userData ;
  File? _imageFile;
  String imageUrl="";
  bool dataRecieved=false;
  List<dynamic>userQueries=[];

  @override
  void initState() {
    super.initState();
    userID=widget.id;
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      print("----------------inside fetch method---------------");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserInfo')
          .where('uid', isEqualTo: userID)
          .limit(1)
          .get();
      print("----------------fetching queries---------------");
      await fetchUserQueries();
      print("----------------queries fetched---------------");
      setState(() {
        userData = querySnapshot.docs.first;
      });

      imageUrl = userData?['image_url'];
      print("----------------fetching image now---------------");
      if(imageUrl!='none'){
          await _fetchImage();
        }

      setState(() {
        dataRecieved=true;
        print("----------------Data Recieved---------------");
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${e.toString()}',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> fetchUserQueries() async {
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Post_Info')
          .where('uid', isEqualTo: userID)
          .get();
      setState(() {
        userQueries = querySnapshot.docs;
      });
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to fetch userQueries : ${e.toString()}',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _fetchImage() async {
    try {
      // Fetch the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Convert response body to bytes and store in a File
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/temp.jpg';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        setState(() {
          _imageFile = file;
        });
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        title: Text(
          userData?['name']?? '',
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color:  themeNotifier.isDarkTheme?Colors.grey[300]:Colors.grey[700],
              fontSize: 18,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
        ),
        backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],
      ),
      body: (!dataRecieved)?Center(
    child: Padding(
    padding: const EdgeInsets.only(bottom: 100),
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),strokeWidth: 2,),
    )):
      SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            child: Column(
              children: [
                SizedBox(height: 10,),
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundImage: (_imageFile!=null)?
                    FileImage(_imageFile!)as ImageProvider:
                    themeNotifier.isDarkTheme
                        ? AssetImage('assets/images/pfp1.jpg')
                        : AssetImage('assets/images/pfp2.jpg'),
        
                  ),
                ),
                SizedBox(height: 70,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      (userData?['bio']!="none")?
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bio :  ",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color:  themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              userData?['bio'],
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                  fontSize: 17,
                                ),
                              ),
                              softWrap: true,  // This ensures that the text will wrap to the next line
                            ),
                          ),
                        ],
                      ):Container(),
                      (userData?['linkedin']!="none")?
                      Column(
                        children: [
                          SizedBox(height: 20,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:  EdgeInsets.only(bottom:0),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.linkedin,color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),),
                                    Text(
                                      "  :  ",
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                          color:  themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
        
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData?['linkedin'],
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                      fontSize: 17,
                                    ),
                                  ),
                                  softWrap: true,  // This ensures that the text will wrap to the next line
                                ),
                              ),
                            ],
                          )
                        ],
                      ):Container(),
                      (userData?['github']!="none")?
                      Column(
                        children: [
                          SizedBox(height: 20,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:  EdgeInsets.only(bottom:0),
                                child: Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.github,color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),),
                                    Text(
                                      "  :  ",
                                      style: GoogleFonts.lato(
                                        textStyle: TextStyle(
                                          color:  themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5),
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
        
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  userData?['github'],
                                  style: GoogleFonts.lato(
                                    textStyle: TextStyle(
                                      color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                      fontSize: 17,
                                    ),
                                  ),
                                  softWrap: true,  // This ensures that the text will wrap to the next line
                                ),
                              ),
                            ],
                          )
                        ],
                      ):Container(),
                      SizedBox(height: 60),
                     //Divider(thickness: 2, color: themeNotifier.isDarkTheme?Colors.grey[700]:Colors.grey[300],),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.75,
                              color: themeNotifier.isDarkTheme
                                  ? Color(0xff00cfd8)
                                  : Color(0xff00a9b1),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("Posts", style: TextStyle(fontSize: 16,
                              color: themeNotifier.isDarkTheme
                                  ? Color(0xff00cfd8)
                                  : Color(0xff00a9b1),
                            )),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.75,
                              color: themeNotifier.isDarkTheme
                                  ? Color(0xff00cfd8)
                                  : Color(0xff00a9b1),
                            ),
                          ),
                        ],
                      ),
                      //SizedBox(height: 20),
                     (userQueries.isEmpty)?
                      Padding(
                        padding: const EdgeInsets.only(top:0),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 60),
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
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context,index){
                              return InkWell(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => viewPost(p: userQueries[index])),
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
                                                      color: themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[800],
                                                      fontSize: 17,
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
                            itemCount: userQueries.length),

        
                    ],
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
