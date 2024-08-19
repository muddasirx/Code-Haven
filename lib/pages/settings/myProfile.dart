import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool updatePressed=false;
  bool isEditPressed=false;
  bool pfpChanged=false;
  bool isRemoved=false;
  TextEditingController nameController=TextEditingController();
  TextEditingController bioController=TextEditingController();
  TextEditingController githubController=TextEditingController();
  TextEditingController linkedinController=TextEditingController();
  late DocumentSnapshot userData ;
  File? _image,_imageFile;
  final ImagePicker _picker = ImagePicker();
  bool pfpTap=false;
  String imageUrl="";
  bool dataRecieved=false;

  Future<void> fetchUserData() async {
    try {
      print("----------------inside fetch method---------------");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('UserInfo')
          .where('email', isEqualTo: SplashScreenState.email).limit(1)
          .get();

      setState(() {
        userData = querySnapshot.docs.first;
      });
      if(userData['bio']!='none'){
        bioController.text=userData['bio'];
      }
      if(userData['github']!='none'){
        githubController.text=userData['github'];
      }
      if(userData['linkedin']!='none'){
        linkedinController.text=userData['linkedin'];
      }
      nameController.text=userData['name'];

      imageUrl = userData['image_url'];

      print("----------------fetching image now---------------");
      if(imageUrl!='none'){
        if(SplashScreenState.pfp==null){
          await _fetchImage();
        }
        else{
          setState(() {
            _imageFile=SplashScreenState.pfp;
          });
        }
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

  Future<void> updateUserData() async {
    if(nameController.text.isNotEmpty){
      setState(() {
        updatePressed=true;
      });
      try {
        await FirebaseFirestore.instance
            .collection('UserInfo')
            .doc(userData.id)
            .update({
          'name': nameController.text.trim(),
          'bio': (bioController.text.isNotEmpty)?bioController.text.trim():"none",
          'github': (githubController.text.isNotEmpty)?githubController.text.trim():"none",
          'linkedin': (linkedinController.text.isNotEmpty)?linkedinController.text.trim():"none",
        });

        if(!(userData['image_url']=='none' && _imageFile==null && _image==null)){
          if(userData['image_url']!='none' && _imageFile==null ) {
            print(_imageFile);
            print("-----------------(Image URL: ${userData['image_url']})-------------------");
            print("--------------inside image deletion statement--------------");
            await FirebaseStorage.instance
                .ref('userImages/${userData
                .id}.jpg') // Replace with the actual path to the image
                .delete();
            if(_imageFile==null && _image==null){
              await FirebaseFirestore.instance
                  .collection('UserInfo')
                  .doc(userData.id)
                  .update({'image_url': 'none'});
            }else
              _uploadImage();
          }else
            _uploadImage();
        }

        setState(() {
          isEditPressed=false;
        });
        fetchUserData();
        final theme = Provider.of<ThemeNotifier>(context, listen: false);
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: theme.isDarkTheme?Colors.grey[700]:Colors.grey[300], // Change this to your desired background color
          textColor: theme.isDarkTheme?Colors.white:Colors.black,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${e.toString()}',style: TextStyle(
              color: Colors.white
          ),),backgroundColor: Colors.red,
        ));
      }
      setState(() {
        updatePressed=false;
      });
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Name cannot be left empty.',style: TextStyle(
            color: Colors.white
        ),),backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  Future<void> _uploadImage() async {
      try {
        setState(() {
          SplashScreenState.pfp=_image;
        });
        final storageRef = FirebaseStorage.instance
            .ref();
           final uploadRef= storageRef.child('userImages/${userData.id}.jpg');

        await uploadRef.putFile(_image!);

        String downloadURL = await FirebaseStorage.instance
            .ref('userImages/${userData.id}.jpg')
            .getDownloadURL();

        print("Image Url  : ${downloadURL} ");

        await FirebaseFirestore.instance
            .collection('UserInfo')
            .doc(userData.id)
            .update({'image_url': downloadURL});


      } catch (e) {
        print("${e.toString()}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Image uploading Error: ${e.toString()}',style: TextStyle(
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
        final filePath = '${tempDir.path}/temp_image.jpg';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        setState(() {
          _imageFile = file;
          SplashScreenState.pfp= file;
        });
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print(e);
    }
  }

  Widget textFields(){
    final theme = Provider.of<ThemeNotifier>(context, listen: false);
    return Column(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 13,
              width: 150,
              color: theme.isDarkTheme?Colors.grey[850]:Colors.grey[300],
            ),
          ),
          SizedBox(height: 10,),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              height: 18,
              width: 300,
              color: theme.isDarkTheme?Colors.grey[850]:Colors.grey[300],
            ),
          ),
          SizedBox(height: 20,)
        ],
    );
  }



  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar:AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Row(
           // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SingleChildScrollView(
                child: Text(
                  "My Profile",
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 92),
              (dataRecieved)?(!isEditPressed)?IconButton(onPressed: (){
                setState(() {
                  isEditPressed=true;
                });
              },
                  icon: Icon(Icons.edit_note,size: 35,
                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5)//themeNotifier.isDarkTheme?Colors.grey[500]:Colors.grey[600]
                    ,),):SizedBox():SizedBox()
            ],
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
          (!dataRecieved)?Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),strokeWidth: 2,),
            ),
          ):
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 40,),
                  Center(
                    child: isEditPressed?
                    Stack(
                      children: [

                        // Adjust the size as needed
                        InkWell(
                          splashColor :Colors.transparent,
                          borderRadius: BorderRadius.circular(100.0),
                          child:CircleAvatar(
                            radius: 55,
                            backgroundImage: (_imageFile!=null)?
                            FileImage(_imageFile!)as ImageProvider:
                            (_image!=null)? FileImage(_image!) as ImageProvider:
                            themeNotifier.isDarkTheme
                                ? AssetImage('assets/images/pfp1.jpg')
                                : AssetImage('assets/images/pfp2.jpg'),
                          ),
                          /*Icon(Icons.account_circle_rounded,
                                color: themeNotifier.isDarkTheme?Colors.grey[600]:Colors.grey[400]
                                ,size:150),*/

                          onTap: () {
                            if(_image==null && _imageFile==null){
                              _pickImage();
                              if(_image!=null){
                                setState(() {
                                  _imageFile=null;
                                });
                              }
                            }
                            else{
                              setState(() {
                                pfpTap=true;
                              });
                            }
                          },
                        ),
                        Positioned(
                          right: -5,
                          bottom: -10,
                          child: IconButton(
                            icon: Icon(Icons.camera_alt, color:themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[700],
                                size: 25), // Adjust the size as needed
                            onPressed: () {
                              // Add your onPressed code here
                            },
                          ),
                        ),
                      ],
                    ):
                    CircleAvatar(
                      radius: 55,
                      backgroundImage: (_imageFile!=null)?
                      FileImage(_imageFile!)as ImageProvider:
                      (_image!=null)? FileImage(_image!) as ImageProvider:
                      themeNotifier.isDarkTheme
                          ? AssetImage('assets/images/pfp1.jpg')
                          : AssetImage('assets/images/pfp2.jpg'),

                    ),
                  ),
                  SizedBox(height: 50,),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    enabled: isEditPressed,
                    cursorColor: Color(0xff00cfd8),
                    cursorWidth: 1.5,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 17),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10),
                      labelText: "Full Name",
                      labelStyle:
                      TextStyle(color:themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                          fontSize: 17),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        ),
                        // Change line color here
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),),
                        // Change line color here
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: bioController,
                    keyboardType: TextInputType.text,
                    enabled: isEditPressed,
                    cursorColor: Color(0xff00cfd8),
                    cursorWidth: 1.5,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 17),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(left: 10),
                      labelText: "Bio",
                      labelStyle:
                      TextStyle(color:themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                          fontSize: 17),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        ),
                        // Change line color here
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),),
                        // Change line color here
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: githubController,
                    enabled: isEditPressed,
                    keyboardType: TextInputType.text,
                    cursorColor: Color(0xff00cfd8),
                    cursorWidth: 1.5,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 17),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10),
                        labelText: "GitHub",
                        hintText: "account link",
                        hintStyle: TextStyle(
                          fontSize: 16,
                        ),
                        labelStyle:
                        TextStyle(color:themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                            fontSize: 17),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                          ),
                          // Change line color here
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),),
                          // Change line color here
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 13,left: 15),
                          child: FaIcon(FontAwesomeIcons.github),
                        )
                    ),

                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    controller: linkedinController,
                    keyboardType: TextInputType.text,
                    enabled: isEditPressed,
                    cursorColor: Color(0xff00cfd8),
                    cursorWidth: 1.5,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 17),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10,),
                        labelText: "LinkedIn",
                        hintText: "account link",
                        hintStyle: TextStyle(
                          fontSize: 16,
                        ),
                        labelStyle:
                        TextStyle(color:themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                            fontSize: 17),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                          ),
                          // Change line color here
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),),
                          // Change line color here
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(top: 13,left: 17),
                          child: FaIcon(FontAwesomeIcons.linkedin),
                        )
                    ),

                  ),
                  SizedBox(height: 50),
                  isEditPressed?themeNotifier.isDarkTheme?
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: (){
                      if(!updatePressed){
                        linkedinController.selection = TextSelection.fromPosition(
                          TextPosition(offset: 0),
                        );
                        updateUserData();
                      }

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
                        child: updatePressed?Padding(
                          padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                        ):
                        Text("Update",style: TextStyle(
                            fontSize: 18,
                            color: Color(0xff00cfd8)
                        ),),
                      ),

                    ),
                  )
                      :InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: (){
                      if(!updatePressed){
                        updateUserData();
                      }

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
                        child: updatePressed?Padding(
                          padding: const EdgeInsets.symmetric(horizontal:40 ,vertical: 10),
                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                        ):
                        Text("Update",style: TextStyle(
                            fontSize: 18,
                            color: Colors.black
                        ),),
                      ),

                    ),
                  ):
                  Container(),
                ],
              ),
            ),
          ),
          (isEditPressed && (_image!=null || _imageFile!=null )&& pfpTap)?InkWell(
            onTap: (){
              setState(() {
                pfpTap=false;
              });
            },
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: themeNotifier.isDarkTheme?Colors.black54:Colors.white60,
            ),
          ):Container(),

          (isEditPressed && (_image!=null || _imageFile!=null) && pfpTap)?
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Container(
                height: 170,
                width: 270,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color:themeNotifier.isDarkTheme?Colors.grey[850]:Colors.grey[300],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:57),
                      child: Column(
                        children: [
                          SizedBox(height: 20,),
                            TextButton(
                                onPressed: (){
                                  setState(() {
                                    pfpTap=false;
                                  });
                                  _pickImage();
                                  if(_image!=null){
                                    setState(() {
                                      _imageFile=null;
                                    });
                                  }
                                },
                                child: Text("Upload Image",style: TextStyle(
                                  fontSize: 19,
                                  color: themeNotifier.isDarkTheme ? Colors.white//Color(0xff00cfd8)
                                      : Colors.black//Color(0xff00a6b5)
                                ),)),
                          SizedBox(height: 20,),
                          TextButton(
                              onPressed: (){
                                  setState(() {
                                    _image=null;
                                    pfpTap=false;
                                    _imageFile=null;
                                  });
                              },
                              child: Text("Remove Image",style: TextStyle(
                                  fontSize: 19,
                                  color: themeNotifier.isDarkTheme ? Colors.white//Color(0xff00cfd8)
                                      : Colors.black//Color(0xff00a6b5)
                              ),))

                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ):Container(),

        ]
      ),
    );
  }
}
