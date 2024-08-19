import 'package:code_haven/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/themeNotifier.dart';
import 'NavBar.dart';
import 'interestPage.dart';
import 'interestQueries.dart';

class filterQueries extends StatefulWidget {
  const filterQueries({super.key});

  @override
  State<filterQueries> createState() => _filterQueriesState();
}

class _filterQueriesState extends State<filterQueries> {
  List<String> filteredTags = [];
  Set<String> selectedTags = {};

  TextEditingController _controller = TextEditingController();

  void _filterTags() {
    setState(() {
      filteredTags = selectInterstsState.allTags
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
  void initState() {
    super.initState();
    selectedTags.addAll(SplashScreenState.userInterests);
    filteredTags = List.from(selectInterstsState.allTags);
    _controller.addListener(_filterTags);
  }
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Filter Queries",
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: themeNotifier.isDarkTheme ? Colors.white : Colors.black,
              fontSize: 23,
            ),
          ),
        ),
        iconTheme: IconThemeData(
          color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
        ),
        backgroundColor: themeNotifier.isDarkTheme ? Theme.of(context).colorScheme.background : Colors.grey[290],
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
                 // hintText: "select tags",
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
              SizedBox(height: 60,),
              themeNotifier.isDarkTheme?
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  SplashScreenState.userInterests.clear();
                  SplashScreenState.userInterests=selectedTags.toList();
                  // moreInterestQueriesState.tags.addAll(selectedTags);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => moreInterestQueries()),
                        (route) => false,
                  );
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
                    child: false?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:45 ,vertical: 10),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),strokeWidth: 1.5,),
                    ):
                    Text("Filter",style: TextStyle(
                        fontSize: 15.5,
                        color: Color(0xff00cfd8)
                    ),),
                  ),

                ),
              )
                  :InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: (){
                  SplashScreenState.userInterests.clear();
                  SplashScreenState.userInterests.addAll(selectedTags);
                 // moreInterestQueriesState.tags.addAll(selectedTags);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => moreInterestQueries()),
                        (route) => false,
                  );
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
                    child: false?Padding(
                      padding: const EdgeInsets.symmetric(horizontal:44 ,vertical: 9),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.black),strokeWidth: 1.5,),
                    ):
                    Text("Filter",style: TextStyle(
                        fontSize: 15.5,
                        color: Colors.black
                    ),),
                  ),

                ),
              ),
              SizedBox(height: 50,)
            ],
          ),
        ),
      ),
    );
  }
}
