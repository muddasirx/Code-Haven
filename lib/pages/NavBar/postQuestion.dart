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
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:flutter_chip_tags/flutter_chip_tags.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../NavBar.dart';
import '../interestPage.dart';


class postQuestion extends StatefulWidget {
  const postQuestion({super.key});

  @override
  State<postQuestion> createState() => _postQuestionState();
}

class _postQuestionState extends State<postQuestion> {
  final _formKey= GlobalKey<FormState>();
  TextEditingController titleController= TextEditingController();
  TextEditingController descriptionController= TextEditingController();
  TextEditingController codeController= TextEditingController();
  TextEditingController tagController= TextEditingController();
  final MultiSelectController dropDowncontroller = MultiSelectController();
  bool descriptionCheck=false;
  bool codeCheck=false;
  bool uploadPressed=false;
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFiles = [];
  String imageSource='';
  bool addImagePressed=false;
  List<String> tags=selectInterstsState.allTags;
  bool tagCheck=false;
  bool postPressed=false;
  final List<String> _selectedTags = [];
  String userID=SplashScreenState.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> imagesURL=[];
  late String postID;
  bool hasConnection=true;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  Future<void> checkConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (mounted) {
      setState(() {
        hasConnection = result;
      });
    }
  }

  void post() async{
    if(_formKey.currentState != null && _formKey.currentState!.validate()) {
      if(_selectedTags.length>=3){
        try{
          setState(() {
            postPressed=true;
          });
          String title = titleController.text.trim();
          String description = descriptionController.text.trim();
          String code = codeController.text.trim().isNotEmpty ? codeController.text.trim() : "none";
          List<String> images = ["none", "none", "none"];
          DateTime now = DateTime.now();

          DocumentReference docRef = _firestore.collection('Post_Info').doc();
          postID = docRef.id;

          Map<String, dynamic> postData = {
            'uid': userID,
            'comments':[],
            'title': title,
            'description': description,
            'code': code,
            'images_url': images,
            'tags': _selectedTags,
            'postedDate':now
          };

          if (images.isNotEmpty) {
            postData['images_url'] = images;
            print("----------${postData['images_url']}----------");
          }

          await docRef.set(postData);

          await _uploadImage();

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/NavBar',
                (route) => false, // Remove all routes from the stack
          );

          final theme = Provider.of<ThemeNotifier>(context, listen: false);
          Fluttertoast.showToast(
            msg: "Post uploaded successfully.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
            textColor: theme.isDarkTheme?Colors.white:Colors.black,
          );

        }catch(e){
          setState(() {
            postPressed=false;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Unable to store data in database : ${e.toString()}',style: TextStyle(
                color: Colors.white
            ),),backgroundColor: Colors.red,
          ));
        }
      }
    }
  }

  Future<void> _pickImages(ImageSource source) async {

    var pickedFiles = await _picker.pickMultiImage(
      maxWidth: 400,
      imageQuality: 20,
    );
    if(addImagePressed){
      pickedFiles.addAll(_imageFiles as Iterable<XFile>);
    }
    if (pickedFiles != null && pickedFiles.length <= 3) {
      setState(() {
        _imageFiles = pickedFiles;
        imageSource='gallery';
        addImagePressed=false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Select up to 3 images only.',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _pickImageFromCamera() async {
      List<XFile>? pickedFiles = <XFile>[];
      if(addImagePressed){
        pickedFiles=_imageFiles;
      }
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        pickedFiles?.add(pickedFile);
      }


    if (pickedFiles!.isNotEmpty) {
      setState(() {
        imageSource='camera';
        _imageFiles = pickedFiles;
      });
    }
  }

  Future<void> _uploadImage() async {
    final storageRef = FirebaseStorage.instance.ref();
    int i=0;
    try {
      for (var x in _imageFiles!) {
        final uploadRef = storageRef.child('postImages/${postID}/$i.jpg');

        await uploadRef.putFile(File(x.path));

        String downloadURL = await FirebaseStorage.instance
            .ref('postImages/${postID}/$i.jpg')
            .getDownloadURL();
        imagesURL.add(downloadURL);
        ++i;
        print("Image Url  : $downloadURL");
      }

      if (i == 1) {
        imagesURL.add('none');
        imagesURL.add('none');
      } else if (i == 2) {
        imagesURL.add('none');
      }

      await FirebaseFirestore.instance
          .collection('Post_Info')
          .doc(postID)
          .update({'images_url': imagesURL});

    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Image uploading Error: ${e.toString()}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }


  }


  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Material(
      child:WillPopScope(
        onWillPop: () async {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/NavBar',
            (route) => false, // Remove all routes from the stack
      );//Navigator.pushReplacementNamed(context, "/loginRoute");
      return false; // Return false to prevent default back button behavior
    },
        child:Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Post Query",
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
            children:[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 30,),
                        TextFormField(
                          controller: titleController,
                          cursorColor: Color(0xff00cfd8),
                          cursorWidth: 1.5,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red),
                            contentPadding: EdgeInsets.only(left: 18,right: 2,top: 18,bottom: 18),
                            labelText: "Title",
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
                              return "Title cannot be Empty.";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        SizedBox(height: 20,),
                        TextFormField(
                          controller: descriptionController,
                          cursorColor: Color(0xff00cfd8),
                          cursorWidth: 1.5,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                          keyboardType: TextInputType.multiline,
                          minLines: 3,
                          maxLines: 8,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(450),
                          ],
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red),
                            contentPadding: EdgeInsets.only(left: 18,right: 2,top: 18,bottom: 18),
                            labelText: "Description",
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
                              return "Description cannot be Empty.";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            print('Description length: ${descriptionController.text.trim().length}');
                            if(descriptionController.text.length==450){
                              setState(() {
                                descriptionCheck=true;
                              });
                            }

                          },
                        ),
                        descriptionCheck?Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10,top: 3),
                            child: Text("Description cannot exceed 450 characters..",style: TextStyle(
                                color: Colors.red,
                                fontSize: 13
                            ),),
                          ),
                        ):SizedBox(),
                        SizedBox(height: 20,),
                        TextFormField(
                          controller: codeController,
                          cursorColor: Color(0xff00cfd8),
                          cursorWidth: 1.5,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(2500),
                          ],
                          minLines: 18,
                          maxLines: 18,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(color: Colors.red),
                            contentPadding: EdgeInsets.only(left: 18,right: 2,top: 18,bottom: 18),
                            labelText: "Code",
                            hintText: "(optional)",
                            labelStyle: GoogleFonts.lato(
                                textStyle:TextStyle(
                                  color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                  fontSize: 21,
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
                          onChanged: (value){
                            print('Code length: ${codeController.text.trim().length}');
                            if(codeController.text.trim().length==2499){
                              setState(() {
                                codeCheck=true;
                              });
                            }
                          },
                        ),
                        codeCheck?Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10,top: 3),
                            child: Text("Code cannot exceed 2500 characters..",style: TextStyle(
                                color: Colors.red,
                                fontSize: 13
                            ),),
                          ),
                        ):SizedBox(),
                        SizedBox(height: 40,),
                        InkWell(
                          onTap: (){
                            setState(() {
                              uploadPressed=true;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 100,
                            width: 200,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 2,color: themeNotifier.isDarkTheme? Color(0xff00cfd8):Colors.black12),
                                color: themeNotifier.isDarkTheme? Colors.transparent:Colors.grey[200]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(width: 23,),
                                    Icon(Icons.upload,size: 22,color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),),
                                    SizedBox(width: 3,),
                                    Text("Upload Images",style: GoogleFonts.lato(
                                        textStyle:TextStyle(
                                          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                          fontSize: 18,
                                          // fontWeight: themeNotifier.isDarkTheme? FontWeight.normal:FontWeight.bold
                                        )),)
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Text("(optional)",style: GoogleFonts.lato(
                                    textStyle:TextStyle(
                                      color: themeNotifier.isDarkTheme ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 14,
                                      // fontWeight: themeNotifier.isDarkTheme? FontWeight.normal:FontWeight.bold
                                    )),)
                              ],
                            ),

                          ),
                        ),
                        (_imageFiles != null && _imageFiles!.isNotEmpty)?SizedBox(height: 40,):SizedBox(),
                        Row(
                          children: [
                            SizedBox(width: 10,),
                            _imageFiles != null && _imageFiles!.isNotEmpty
                                ? Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: _imageFiles!.asMap().entries.map((entry) {
                                int index = entry.key;
                                XFile file = entry.value;
                                return Stack(
                                  children: [
                                    Image.file(
                                      File(file.path),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      right: -13,
                                      bottom: 66,
                                      child: IconButton(
                                        icon: Icon(Icons.highlight_remove, color:Colors.white,
                                            size: 27), // Adjust the size as needed
                                        onPressed: () {
                                          setState(() {
                                            _imageFiles?.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            )
                                :Container(),
                            (imageSource!='none' && (_imageFiles!.length>0 && _imageFiles!.length<3))?Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    addImagePressed=true;
                                  });
                                  if(imageSource=='camera'){
                                    _pickImageFromCamera();
                                  }
                                  if(imageSource=='gallery'){
                                    _pickImages(ImageSource.gallery);
                                  }
                                },
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: themeNotifier.isDarkTheme?Colors.grey[850]:Colors.grey[400],
                                  child: Icon(Icons.add,size: 30,
                                    color: themeNotifier.isDarkTheme?Colors.white:Colors.grey[700],),
                                ),
                              ),
                            ):Container()
                          ],
                        ),
                        SizedBox(height: 40,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TypeAheadField<String>(
                              /*
                                decoration: InputDecoration(
                                  labelText: 'Search tags',
                                  border: OutlineInputBorder(),
                                ),*/

                              builder: (context, controller, focusNode) => TextField(
                                onChanged: (value){
                                  if(_selectedTags.length<3){
                                    setState(() {
                                      tagCheck=true;
                                    });
                                  }
                                  else {
                                    setState(() {
                                      tagCheck=false;
                                    });
                                  }
                                },
                                controller: controller,
                                focusNode: focusNode,
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .copyWith(fontStyle: FontStyle.italic),
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: themeNotifier.isDarkTheme?1.5:2,
                                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: themeNotifier.isDarkTheme?1.5:2,
                                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                                    ),
                                  ),
                                  hintText: "Search tags related to your post",
                                ),
                              ),
                              suggestionsCallback: (pattern) {
                                if (pattern.isEmpty) {
                                  return [];
                                }
                                return tags.where((tag) => tag.toLowerCase().contains(pattern.toLowerCase().trim())).toList();
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion),
                                );
                              },
                              onSelected: (suggestion) {
                                if (!_selectedTags.contains(suggestion)) {
                                  setState(() {
                                    _selectedTags.add(suggestion);
                                  });


                                }
                              },
                              hideOnEmpty: true,
                            ),
                            tagCheck?Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10,top: 3),
                                child: Text("Select atleast 3 tags.",style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12
                                ),),
                              ),
                            ):SizedBox(),
                            SizedBox(height: 15),
                            Wrap(
                              spacing: 6.0,
                              runSpacing: 6.0,
                              children: _selectedTags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  onDeleted: () {
                                    setState(() {
                                      _selectedTags.remove(tag);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        SizedBox(height: 50,),
                        themeNotifier.isDarkTheme?
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: (){
                            if(!postPressed)
                              post();
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
                              child: postPressed?Padding(
                                padding: const EdgeInsets.symmetric(horizontal:45 ,vertical: 10),
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                              ):
                              Text("Post",style: TextStyle(
                                  fontSize: 15.5,
                                  color: Color(0xff00cfd8)
                              ),),
                            ),

                          ),
                        )
                            :InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: (){
                              if(!postPressed)
                                post();
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
                              child: postPressed?Padding(
                                padding: const EdgeInsets.symmetric(horizontal:44 ,vertical: 9),
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                              ):
                              Text("Post",style: TextStyle(
                                  fontSize: 15.5,
                                  color: Colors.black
                              ),),
                            ),

                          ),
                        ),
                        SizedBox(height: 80,)
                      ],
                    ),
                  ),
                ),
              ),

              uploadPressed?InkWell(
                onTap: (){
                  setState(() {
                    uploadPressed=false;
                  });
                },
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: themeNotifier.isDarkTheme?Colors.black54:Colors.white60,
                ),
              ):Container(),

              uploadPressed? Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: Container(
                    height: 170,
                    width: 270,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color:themeNotifier.isDarkTheme?Colors.grey[850]:Colors.grey[300],
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 50),
                       InkWell(
                         onTap: (){
                           setState(() {
                             uploadPressed=false;
                           });
                           _pickImageFromCamera();
                         },
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Icon(Icons.camera_alt_outlined,size: 40,
                               color: themeNotifier.isDarkTheme ? Colors.grey[400] : Color(0xff00a6b5),),
                             Text(
                               "Camera",
                               style: GoogleFonts.lato(
                                 textStyle: TextStyle(
                                   color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
                                   fontSize: 17,
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                        SizedBox(width: 55),
                        InkWell(
                          onTap: (){
                            setState(() {
                              uploadPressed=false;
                            });
                            _pickImages(ImageSource.gallery);
                          },
                          child: Column(
                            children: [
                              SizedBox(height: 54,),
                              FaIcon(FontAwesomeIcons.images,size: 35,
                                color:themeNotifier.isDarkTheme ? Colors.grey[400] : Color(0xff00a6b5),),
                              SizedBox(height: 4,),
                              Text(
                                "Gallery",
                                style: GoogleFonts.lato(
                                  textStyle: TextStyle(
                                    color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ):Container(),

              !hasConnection?
              Container(
                height: double.infinity,
                width: double.infinity,
                color: themeNotifier.isDarkTheme?Colors.black54:Colors.white60,
              ):Container(),
              !hasConnection
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 120),
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
        )
      )
    );
  }
}
