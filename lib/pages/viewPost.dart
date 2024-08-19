import 'dart:ffi';

import 'package:code_haven/pages/settings/myProfile.dart';
import 'package:code_haven/pages/viewProfile.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_haven/SplashScreen.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:flutter_chip_tags/flutter_chip_tags.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'interestPage.dart';
import 'package:uuid/uuid.dart';

class viewPost extends StatefulWidget {
  var p;
   viewPost({Key? key, required this.p}) : super(key: key);

  @override
  State<viewPost> createState() => _viewPostState();
}

class _viewPostState extends State<viewPost> {
  var postData;
  List<XFile>? _imageFiles = [];
  XFile? image;
  bool dataRecieved = false;
  final Uuid uuid = Uuid();
  bool imagePressed=false;
  int imageIndex=-1;
  String userName="Unknown";
  TextEditingController commentController = new TextEditingController();
  var currentUser;
  List<dynamic> commentLiked=[];
  List<dynamic> comments=[];
  bool commentLengthExceed=false;
  bool progress=false;
  bool showReplies=false;
  int showRepliesIndex=-1;
  final FocusNode _focusNode = FocusNode();
  bool replyPressed=false;
  String replyTo='';
  String commentID_of_Reply="";
  String replyToID="";
  bool replyToComment=false;

  Future<void> fetchComments() async {

      QuerySnapshot qs = await FirebaseFirestore.instance
          .collection('Comments')
          .where('commentID', whereIn: postData['comments'])
          .get();

      List<QueryDocumentSnapshot> x = qs.docs;

      x.sort((a, b) {
        // Ensure 'numberOfLikes' is treated as an int
        int likesA = int.parse('${a.get('numberOfLikes')}');
        int likesB = int.parse('${b.get('numberOfLikes')}');
        return likesB.compareTo(likesA); // Descending order
      });
      print("-------------Comments fetched----------------");
      setState(() {
        comments= x;
      });
      print(comments.toString());

  }

  Future<void> fetchData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('email', isEqualTo: SplashScreenState.email).limit(1)
        .get();
    currentUser = querySnapshot.docs.first;
    commentLiked=currentUser['commentLiked'];

    if(postData['comments'].isNotEmpty){
      fetchComments();
    }





    print("----------------About to fetch Images----------------");

    if(postData['images_url'].isNotEmpty){
      if (postData['images_url'][0] != "none") {
        _fetchImage(postData['images_url'][0]);
      }
      if (postData['images_url'][1] != "none") {
        _fetchImage(postData['images_url'][1]);
      }
      if (postData['images_url'][2] != "none") {
        _fetchImage(postData['images_url'][2]);
      }
    }
    var snapshot = await FirebaseFirestore.instance
        .collection('UserInfo')
        .where('uid', isEqualTo: postData['uid'])
        .get();

    if (snapshot.docs.isNotEmpty) {
      var userDoc = snapshot.docs.first;
      setState(() {
        userName = userDoc['name'];
      });
    }
    print("----------------Images fetched Images----------------");
    setState(() {
      dataRecieved = true;
    });
  }

  Future<void> _fetchImage(var imageUrl) async {
    try {
      // Fetch the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        // Convert response body to bytes and store in a temporary file
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final fileName = uuid.v4();
        print(fileName);
        final filePath = '${tempDir.path}/temp_image_$fileName.jpg';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // Ensure the file is written correctly
        if (await file.length() > 0) {
          // Convert File to XFile
          final XFile xFile = XFile(filePath);
          setState(() {
            _imageFiles?.add(xFile);
          });
        } else {
          throw Exception('File is empty after writing bytes.');
        }
      } else {
        throw Exception('Failed to load image or response is empty.');
      }
    } catch (e) {
      print('Error in _fetchImage : $e');
    }
  }

  void _showImageDialog(BuildContext context, XFile imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(imageFile.path),
                fit: BoxFit.contain,
              ),

            ],
          ),
        );
      },
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

  Widget deleteComment(int index){
    final theme = Provider.of<ThemeNotifier>(context, listen: false);
    print("----------------inside delete widget----------------");
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: AlertDialog(
        title: Text('Delete comment'),
        content: Text('Are you sure you want to delete this comment ?'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          TextButton(onPressed:(){
            Navigator.pop(context);
          },
              child: Text("Cancel")),
          TextButton(onPressed:() async{
            try{
              await FirebaseFirestore.instance.collection('Comments').doc(comments[index].id).delete();
              postData['comments'].remove(comments[index]['commentID']);

              DocumentReference postRef = FirebaseFirestore.instance.collection('Post_Info').doc(postData.id);
              await postRef.update({
                'comments': FieldValue.arrayRemove([comments[index]['commentID']])
              });

              setState(() {
                comments.removeAt(index);
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Comment deleted successfully.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
                textColor: theme.isDarkTheme?Colors.white:Colors.black,
              );
            }catch(e){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${e.toString()}', style: TextStyle(
                    color: Colors.white
                ),), backgroundColor: Colors.red,
              ));
            }
          },
              child: Text("Delete"))
        ],
      ),
    );
  }

  Widget deleteReply(int index,int index2){
    final theme = Provider.of<ThemeNotifier>(context, listen: false);
    print("----------------inside delete widget----------------");
    return Padding(
      padding: const EdgeInsets.only(bottom: 50),
      child: AlertDialog(
        title: Text('Delete reply'),
        content: Text('Are you sure you want to delete this reply ?'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        actions: [
          TextButton(onPressed:(){
            Navigator.pop(context);
          },
              child: Text("Cancel")),
          TextButton(onPressed:() async{
            try{

              DocumentReference postRef = FirebaseFirestore.instance.collection('Comments').doc(comments[index].id);
              await postRef.update({
                'replies': FieldValue.arrayRemove([comments[index]['replies'][index2]])
              });
              fetchComments();
              setState(() {
                print("-----Before removing ${comments[index]['replies']}--------");
                comments[index]['replies'].removeAt(index2);
                print("-----After removing ${comments[index]['replies']}--------");
              });
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Reply deleted successfully.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
                textColor: theme.isDarkTheme?Colors.white:Colors.black,
              );
            }catch(e){
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${e.toString()}', style: TextStyle(
                    color: Colors.white
                ),), backgroundColor: Colors.red,
              ));
              print("----------------${e.toString()}------------------");
            }
          },
              child: Text("Delete"))
        ],
      ),
    );
  }

  Future<void> postComment() async{
    final theme = Provider.of<ThemeNotifier>(context, listen: false);
    setState(() {
      progress=true;
    });
    try{
      var uuid = Uuid();

      String uniqueId = uuid.v4().replaceAll('-', '');

      String cid = uniqueId.substring(0, 20);
      DateTime now = DateTime.now();
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserInfo')
          .where('uid', isEqualTo: SplashScreenState.uid)
          .limit(1)
          .get();

      DocumentReference docRef = FirebaseFirestore.instance.collection('Comments').doc();

      Map<String, dynamic> commentData = {
        'comment': commentController.text.trim(),
        'commentID':cid,
        'commentFrom': {'userName':querySnapshot.docs.first['name'],'userID':SplashScreenState.uid},
        'numberOfLikes': 0,
        'time': now,
        'replies': [],
      };

      await docRef.set(commentData);

      await FirebaseFirestore.instance
          .collection('Post_Info')
          .doc(postData.id)
          .update({
        'comments': FieldValue.arrayUnion([cid]),
      });

      //DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('Post_Info').doc(postData.id).get();
      QuerySnapshot qs = await FirebaseFirestore.instance.collection('Post_Info').where(FieldPath.documentId, isEqualTo: postData.id).get();


      print("-------------before adding comment id postIDs: ${postData['comments']}-------------");
      postData = qs.docs.first;
      //postData['comments'].add(cid);
      print("-------------comment id:${cid}-------------");
      print("-------------after adding comment id postIDs: ${postData['comments']}-------------");
      fetchComments();

      if(postData['uid']!=SplashScreenState.uid) {
        Map<String, dynamic> notification = {
          'notification': "${currentUser['name']} commented on your post.",
          'postID': postData.id,
          'uid': postData['uid'],
          'time':now,
          'postViewed':false
        };
        DocumentReference x = FirebaseFirestore.instance.collection('Notifications').doc();
        await x.set(notification);

        /*QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('UserInfo')
            .where('uid', isEqualTo: postData['uid'])
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference docRef = querySnapshot.docs.first.reference;

          await docRef.update({
            'notifications': FieldValue.arrayUnion([notification]),
          });
        } */
      }

      setState(() {
        commentController.text='';
        progress=false;
      });
      Fluttertoast.showToast(
        msg: "Comment posted successfully.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
        textColor: theme.isDarkTheme?Colors.white:Colors.black,
      );
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to store data in database : ${e.toString()}',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
      print('Unable to store data in database : ${e.toString()}');
    }
  }

  Future<void> postReply() async{
    final theme = Provider.of<ThemeNotifier>(context, listen: false);
    setState(() {
      progress=true;
    });
    try{

      DateTime now = DateTime.now();
      Map<String, dynamic> replyData = {
        'reply': commentController.text.trim(),
        'replyFrom': {'userName':currentUser['name'],'userID':SplashScreenState.uid},
        'replyTo': {'userName':replyTo,'userID':replyToID},
        'time': now,
      };

      await FirebaseFirestore.instance
          .collection('Comments')
          .doc(commentID_of_Reply)
          .update({
        'replies': FieldValue.arrayUnion([replyData]),
      });

      if(replyToID!=SplashScreenState.uid) {
        print("--------Inside post Reply-----------");
        Map<String, dynamic> notification = {
          'notification': (replyToComment)?"${currentUser['name']}  replied to your comment.":
          "${currentUser['name']}  mentioned you in a comment.",
          'postID': postData.id,
          'uid': replyToID,
          'time':now,
          'postViewed':false
        };
        DocumentReference x = FirebaseFirestore.instance.collection('Notifications').doc();
        await x.set(notification);

        print("--------Notified User ID : $replyToID-----------");

      }

      fetchComments();

      setState(() {
        progress=false;
        replyPressed=false;
        replyToComment=false;
        commentController.text='';
      });

      Fluttertoast.showToast(
        msg: "Reply posted successfully.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
        textColor: theme.isDarkTheme?Colors.white:Colors.black,
      );

    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to post reply: ${e.toString()}',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
      print('Unable to post reply : ${e.toString()}');
    }
  }


  void initState() {
    super.initState();
    postData = widget.p;
    print("Images URL: -------"+postData['images_url'].toString()+"-------");
    fetchData();
    final fileName = uuid.v4();
    print(fileName);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: (!dataRecieved)?Text(""):Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
              "Posted by  ",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                  fontSize: 17,
                  //fontWeight: FontWeight.bold
                ),
              ),),
                InkWell(
                  onTap: (){
                    if(postData['uid']==SplashScreenState.uid){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyProfile()),
                      );
                    }else{
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => viewProfile(id:postData['uid'])),
                      );
                    }
                  },
                  child: Text(
                    userName,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
                        fontSize: 16,
                        //fontWeight: FontWeight.bold
                      ),
                    ),),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                timeAgoSinceDate(postData['postedDate']),
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: themeNotifier.isDarkTheme ? Colors.grey[500] : Colors.grey[600],
                    fontSize: 14,
                    //fontWeight: FontWeight.bold
                  ),
                ),),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
        ),
        backgroundColor: themeNotifier.isDarkTheme ? Theme
            .of(context)
            .colorScheme
            .background : Colors.grey[290],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: imagePressed ? NeverScrollableScrollPhysics() : BouncingScrollPhysics(),
            child: (!dataRecieved)
                ? Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 280),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),
                  strokeWidth: 3,
                ),
              ),
            )
                : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Title:  ",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            postData['title'],
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                fontSize: 17,
                              ),
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Description:",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Container(
                          child: Text(
                            postData['description'],
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                fontSize: 17,
                              ),
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      if (postData['code'] != "none")
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Code:",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Text(
                                        postData['code'],
                                        style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            color: themeNotifier.isDarkTheme ? Colors.grey[300] : Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                height: 400,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 1,
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      SizedBox(height: 30),
                      if (postData['images_url'].isNotEmpty && _imageFiles!.isNotEmpty)
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Images:",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Wrap(
                              spacing: (_imageFiles?.length == 2) ? 40 : 20,
                              runSpacing: 10,
                              children: _imageFiles!.asMap().entries.map((entry) {
                                int index = entry.key;
                                XFile file = entry.value;
                                return InkWell(
                                  onTap: () {
                                    _showImageDialog(context, file);
                                  },
                                  child: Image.file(
                                    File(file.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      SizedBox(height: 30),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Comments:",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      (replyPressed)?Container(
                        color: themeNotifier.isDarkTheme?Colors.grey[900]:Colors.grey[200],
                        height:50,
                        width: 350,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "  Reply to  ${replyTo}",
                              style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                  color: themeNotifier.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            IconButton(onPressed: (){
                              setState(() {
                                replyPressed=false;
                              });
                            },
                                icon: Icon(Icons.cancel_outlined,color: Colors.grey,size: 22,))
                          ],
                        ),
                      ):SizedBox(),
                      TextFormField(
                        focusNode: _focusNode,
                        controller: commentController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(450),
                        ],
                        minLines: 1,
                        maxLines: 4,
                        keyboardType: TextInputType.text,
                        cursorColor: Color(0xff00cfd8),
                        cursorWidth: 1.5,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 15),
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top:12,left: 10),
                            hintText: (!replyPressed)?"Add a comment...":"",
                            hintStyle: TextStyle(fontSize: 16,color: Colors.grey),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Colors.white54 : Colors.black54),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Colors.white54 : Colors.black54),
                            ),
                            suffixIcon: TextButton(
                              onPressed: () {
                                if(commentController.text.trim().isNotEmpty){
                                  FocusScope.of(context).unfocus();
                                  if(!replyPressed)
                                    postComment();
                                  else
                                    postReply();
                                }
                                else{
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('comment field cannot be left empty.',style: TextStyle(
                                        color: Colors.white
                                    ),),backgroundColor: Colors.red,
                                  ));
                                }
                              },
                              child: Text(
                                "post",
                                style: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    fontSize: 14
                                ),),

                            )
                        ),
                        onChanged: (value) {
                          print('Comment length: ${commentController
                              .text
                              .trim()
                              .length}');
                          if (commentController.text.length == 450) {
                            setState(() {
                              commentLengthExceed = true;
                            });
                          }else{
                            setState(() {
                              commentLengthExceed = false;
                            });
                          }
                        },
                      ),
                      commentLengthExceed ? Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, top: 3),
                          child: Text(
                            "Comment cannot exceed 450 characters.",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 12
                            ),),
                        ),
                      ) : SizedBox(),
                      SizedBox(height: 30,),
                      if (postData['comments'].isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 50, bottom: 70),
                          child: Text(
                            "No comments yet",
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: themeNotifier.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 17, right: 0,top: 15,bottom: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (comments[index]['commentFrom']['userID'] == SplashScreenState.uid) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => MyProfile()),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => viewProfile(id: comments[index]['commentFrom']['userID'])),
                                              );
                                            }
                                          },
                                          child: Text(
                                            comments[index]['commentFrom']['userName'],
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                        (comments[index]['numberOfLikes']>=100)?Icon(Icons.verified_rounded,size:23,
                                            color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                        ):SizedBox()
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          comments[index]['comment'],
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              color: themeNotifier.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                              fontSize: 15,
                                            ),
                                          ),
                                          softWrap: true,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              print("---------Before pressed: ${commentLiked}---------");
                                              print("---------Before pressed: ${comments[index]['numberOfLikes']}---------");
                                              if (commentLiked.contains(comments[index]['commentID'])) {
                                                print("--------------inside remove like---------------");
                                                await comments[index].reference.update({
                                                  'numberOfLikes': FieldValue.increment(-1), // Atomically increment by 1
                                                });
                                                fetchComments();

                                                setState(() {
                                                  commentLiked.remove(comments[index]['commentID']);
                                                });
                                                await FirebaseFirestore.instance
                                                    .collection('UserInfo')
                                                    .doc(currentUser.id)
                                                    .update({
                                                  'commentLiked': FieldValue.arrayRemove([comments[index]['commentID']]),
                                                });
                                              } else {
                                                print("--------------inside Add like---------------");
                                                print("--------------increement like---------------");
                                                await comments[index].reference.update({
                                                  'numberOfLikes': FieldValue.increment(1), // Atomically increment by 1
                                                });
                                                fetchComments();
                                                setState(() {
                                                  print("--------------Adding like---------------");
                                                  commentLiked.add(comments[index]['commentID']);
                                                });
                                                print("--------------increement completed---------------");
                                                await FirebaseFirestore.instance
                                                    .collection('UserInfo')
                                                    .doc(currentUser.id)
                                                    .update({
                                                  'commentLiked': FieldValue.arrayUnion([comments[index]['commentID']]),
                                                });
                                                print("--------------liked added to user DB---------------");
                                              }
                                              print("---------After pressed: ${commentLiked}---------");
                                              print("---------After pressed: ${comments[index]['numberOfLikes']}---------");
                                            },
                                            icon: Icon(
                                              commentLiked.contains(comments[index]['commentID']) ? Icons.favorite : Icons.favorite_border,
                                              color: commentLiked.contains(comments[index]['commentID']) ? Colors.red : Colors.grey,
                                              size: 22,
                                            ),
                                          ),
                                          Text(
                                            "${comments[index]['numberOfLikes']}",
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                              ),
                                            ),
                                            softWrap: true,
                                          ),
                                          SizedBox(height: 10,),
                                          (comments[index]['commentFrom']['userID'] == SplashScreenState.uid)?
                                          IconButton(onPressed: (){
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return deleteComment(index);
                                                }
                                            );
                                          },
                                            icon: Icon(Icons.delete,size: 22,color: Colors.grey),):SizedBox()
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height:10),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap:(){
                                          FocusScope.of(context).requestFocus(_focusNode);
                                          setState(() {
                                            replyTo=comments[index]['commentFrom']['userName'];
                                            replyToID=comments[index]['commentFrom']['userID'];
                                            commentID_of_Reply=comments[index].id;
                                            replyPressed=true;
                                            replyToComment=true;
                                          });
                                        },
                                        child: Text(
                                          "Reply",
                                          style: GoogleFonts.lato(
                                            textStyle: TextStyle(
                                              color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),SizedBox(width: 15,),
                                      Text(
                                        timeAgoSinceDate(comments[index]['time']),
                                        style: GoogleFonts.lato(
                                          textStyle: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  (comments[index]['replies'].isNotEmpty && (!showReplies || showRepliesIndex!=index))?Column(
                                    children: [
                                      SizedBox(height:20),
                                      Align(
                                        alignment:Alignment.center,
                                        child: InkWell(
                                          onTap:(){
                                            setState(() {
                                              showReplies=true;
                                              showRepliesIndex=index;
                                            });
                                          },
                                          child: Text(
                                            "Show all replies",
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ):Container(),
                                  (comments[index]['replies'].isNotEmpty && showReplies && index==showRepliesIndex)?SizedBox(height: 5,):SizedBox(),
                                  (comments[index]['replies'].isNotEmpty && showReplies && index==showRepliesIndex)?
                                  Column(
                                    children: [
                                      ListView.separated(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (context,index2){
                                            return Padding(
                                                padding: const EdgeInsets.only(left: 30,top: 10,bottom: 10),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    InkWell(
                                                      onTap:(){
                                                        if (comments[index]['replies'][index2]['replyFrom']['userID'] == SplashScreenState.uid) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => MyProfile()),
                                                          );
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => viewProfile(id: comments[index]['replies'][index2]['replyFrom']['userID'])),
                                                          );
                                                        }
                                                      },
                                                      child: Text(
                                                        comments[index]['replies'][index2]['replyFrom']['userName'],
                                                        style: GoogleFonts.lato(
                                                          textStyle: TextStyle(
                                                            color: themeNotifier.isDarkTheme?Colors.white:Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                                child:Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: "@${comments[index]['replies'][index2]['replyTo']['userName']}  ", // Text that changes color
                                                                        style: GoogleFonts.lato(
                                                                          textStyle: TextStyle(
                                                                            color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) :Color(0xff00a6b5), // Change to the color you want
                                                                            fontSize: 13,
                                                                          ),
                                                                        ),
                                                                        recognizer: TapGestureRecognizer()
                                                                          ..onTap = () {
                                                                            if (comments[index]['replies'][index2]['replyTo']['userID'] == SplashScreenState.uid) {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(builder: (context) => MyProfile()),
                                                                              );
                                                                            } else {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(builder: (context) => viewProfile(id: comments[index]['replies'][index2]['replyTo']['userID'])),
                                                                              );
                                                                            }
                                                                          },
                                                                      ),
                                                                      TextSpan(
                                                                        text: comments[index]['replies'][index2]['reply'], // The rest of the paragraph
                                                                        style: GoogleFonts.lato(
                                                                          textStyle: TextStyle(
                                                                            color: themeNotifier.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                                                            fontSize: 13,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  softWrap: true,
                                                                ),
                                                              ),
                                                        (comments[index]['replies'][index2]['replyFrom']['userID'] == SplashScreenState.uid)?
                                                        IconButton(onPressed: (){
                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                return deleteReply(index,index2);
                                                              }
                                                          );
                                                        },
                                                          icon: Icon(Icons.delete,size: 22,color: Colors.grey),):SizedBox()
                                                      ],
                                                    ),
                                                    SizedBox(height:10),
                                                    Row(
                                                      children: [
                                                        InkWell(
                                                          onTap:(){
                                                           // commentController.text="@${comments[index]['replies'][index2]['replyFrom']['userName']}  ";
                                                            FocusScope.of(context).requestFocus(_focusNode);
                                                            setState(() {
                                                              replyTo=comments[index]['replies'][index2]['replyFrom']['userName'];
                                                              replyToID=comments[index]['replies'][index2]['replyFrom']['userID'];
                                                              commentID_of_Reply=comments[index].id;
                                                              replyPressed=true;
                                                            });
                                                          },
                                                          child: Text(
                                                            "Reply",
                                                            style: GoogleFonts.lato(
                                                              textStyle: TextStyle(
                                                                color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ),
                                                        ),SizedBox(width: 15,),
                                                        Text(
                                                          timeAgoSinceDate(comments[index]['replies'][index2]['time']),
                                                          style: GoogleFonts.lato(
                                                            textStyle: TextStyle(
                                                              color: Colors.grey,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                  ],
                                                ),
                                              );
                                          },
                                          separatorBuilder: (context,index){
                                            return Padding(
                                              padding: const EdgeInsets.only(left: 20),
                                              child: Divider(thickness: 2,color: themeNotifier.isDarkTheme?Colors.grey[700]:Colors.grey[300],),
                                            );
                                          },
                                          itemCount: comments[index]['replies'].length),
                                      SizedBox(height: 8,),
                                      Align(
                                        alignment:Alignment.center,
                                        child: InkWell(
                                          onTap:(){
                                            setState(() {
                                              showReplies=false;
                                              showRepliesIndex=-1;
                                            });
                                          },
                                          child: Text(
                                            "Hide all replies",
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                      :Container()

                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context,index){
                            return Divider(thickness: 2,
                              color: themeNotifier.isDarkTheme?Colors.grey[700]:Colors.grey[300],);
                          },
                          itemCount: comments.length,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          (progress)?Container(
    height: double.infinity,
    width: double.infinity,
    color: themeNotifier.isDarkTheme ? Colors.black54 : Colors
        .white60,
    ): Container(),
          (progress)?Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),
                strokeWidth: 3,
              ),
            ),
          ):Container()
        ],
      )


    );
  }
}
