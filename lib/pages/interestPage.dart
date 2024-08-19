import 'dart:async';
import 'package:code_haven/SplashScreen.dart';
import 'package:code_haven/pages/NavBar/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:code_haven/theme/themeNotifier.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'NavBar.dart';

class selectIntersts extends StatefulWidget {
  const selectIntersts({super.key});

  @override
  State<selectIntersts> createState() => selectInterstsState();
}

class selectInterstsState extends State<selectIntersts> {
  List<String> filteredTags = [];
  Set<String> selectedTags = {};

  TextEditingController _controller = TextEditingController();

  static List<String> allTags = [
    // General programming
    'Programming', 'Development', 'Coding', 'Software', 'Algorithm',
    'Data-Structures','Object Oriented Programming',
    'Debugging', 'Performance', 'Optimization', 'Design-Patterns',
    'Best-Practices',

    // Languages
    'Python', 'Java', 'JavaScript', 'C++', 'C#', 'PHP', 'Ruby', 'Swift',
    'Kotlin', 'TypeScript', 'Go',
    'Rust', 'R', 'Perl', 'Scala', 'Objective-C', 'Dart', 'Groovy', 'Haskell',
    'Lua', 'Erlang', 'Clojure',
    'Elixir', 'Shell', 'HTML/CSS',

    // Frameworks and Libraries
    'Django', 'Flask', 'ReactJS', 'Angular', 'Vue.js', 'jQuery', 'Spring',
    'Laravel', 'TensorFlow', 'Pandas', 'Express', 'Bootstrap', 'Ember.js',
    'Backbone.js', 'Next.js', 'Nuxt.js', 'ASP.NET', 'Rails', 'GraphQL',
    'Apollo', 'Redux', 'Flutter', 'React Native', 'Xamarin', 'Ionic',
    'Cordova', 'Twilio', 'Socket.io', 'Axios', 'Moment', 'Lodash',
    'Jest', 'Mocha', 'Chai', 'Jasmine', 'Sequelize', 'TypeORM',
    'Hibernate', 'Mongoose', 'SQLite', 'MongoDB', 'Redis',
    'GraphQL Yoga', 'NextAuth', 'Sentry', 'Prisma', 'SocketCluster', 'Cypress','AWS'

    // Databases
    'MySQL', 'PostgreSQL', 'SQLite', 'MongoDB', 'Redis', 'Oracle', 'Microsoft SQL Server', 'MariaDB',
    'Cassandra', 'DynamoDB', 'CouchDB', 'Elasticsearch', 'Firebase', 'Neo4j', 'HBase', 'CockroachDB',
    'IBM Db2', 'RedisGraph', 'RavenDB'

    // Platforms and Environments
    'Windows', 'MacOS', 'Linux', 'Android', 'IOS', 'Web', 'Mobile', 'Cloud', 'Docker',

    // Other
    'Git','GitHub', 'Version-Control', 'Machine-Learning', 'Artificial-Intelligence',
    'Data-Science', 'Web-Development', 'Mobile-Development', 'Game-Development',
    'Security',

    //IDE
    'Visual-Studio-Code','WebStorm','Dreamweaver','Android-Studio','Xcode','PyCharm','IntelliJ-IDEA',
    'Eclipse','Jupyter-Notebook','RStudio','Unity','Unreal-Engine','Godot','Arduino IDE','PlatformIO',
    'Keil-uVision'
  ];

  @override
  void initState() {
    super.initState();
    filteredTags = List.from(allTags);
    _controller.addListener(_filterTags);
  }


  void _filterTags() {
    setState(() {
      filteredTags = allTags
          .where((tag) =>
             tag.toLowerCase().contains(_controller.text.toLowerCase().trim())).toList();

    });
  }

  void _toggleTag(String tag) {
    setState(() {
      if (selectedTags.contains(tag)) {
        selectedTags.remove(tag);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        //centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //SizedBox(width: 5,),
            Text(
              "Select your interests",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  color: themeNotifier.isDarkTheme ? Colors.white:Colors.black,
                  fontSize: 22,
                ),
              ),
            ),
            //SizedBox(width: 10,),
            InkWell(
              onTap: () async {
                if(selectedTags.length<5){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Select atleast 5 tags to proceed.',style: TextStyle(
                        color: Colors.white
                    ),),backgroundColor: Colors.red,
                  ));
                }
                else{
                  String interests= selectedTags.join(',');
                  SharedPreferences prefLogin = await SharedPreferences.getInstance();
                  await prefLogin.setString('userTags', interests);
                  SplashScreenState.userInterests=selectedTags.toList();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => NavBar()),
                        (route) => false,
                  );
                }
              },
              child: Text(
                "Next",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
          child: Column(
            children: [
              SizedBox(height: 30),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "eg. Java, git, react, docker",
                  labelText: 'Search tags',
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
                  focusedBorder:OutlineInputBorder(
                    borderSide: BorderSide(
                      width: themeNotifier.isDarkTheme?1.5:2,
                      color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              if (_controller.text.isNotEmpty) ...[
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: filteredTags.map((tag) {
                    bool isSelected = selectedTags.contains(tag);
                    return ChoiceChip(
                      label: Text(tag),
                      labelStyle: TextStyle(
                          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5)
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        _toggleTag(tag);
                      },
                      side: BorderSide(
                        color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                        width: 1.5,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
              ],
              SizedBox(height: 18),
              Text(
                'Selected Tags:',
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    fontSize: 18,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: selectedTags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    labelStyle: TextStyle(
                      color: themeNotifier.isDarkTheme ? Colors.white:Colors.black
                    ),
                    deleteIcon: Icon(Icons.cancel,color: themeNotifier.isDarkTheme ? Colors.white:Colors.black,),
                    onDeleted: () {
                      _toggleTag(tag);
                    },
                    side: BorderSide(
                      color: themeNotifier.isDarkTheme ? Colors.white:Colors.black,
                      width: 1.5,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
