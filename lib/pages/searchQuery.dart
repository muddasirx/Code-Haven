import 'package:code_haven/pages/viewPost.dart';
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

class searchQuery extends StatefulWidget {
  String q;
  searchQuery({Key? key, required this.q}) : super(key: key);

  @override
  State<searchQuery> createState() => _searchQueryState();
}

class _searchQueryState extends State<searchQuery> {
  TextEditingController searchController=TextEditingController();
  List<DocumentSnapshot> _results = [];
  bool isDataRecieved=false;

  final List<String> _stopWords =["able","about","above","abroad","according","accordingly","across","actually","adj","after","afterwards","again","against","ago","ahead","ain't","all","allow","allows","almost","alone","along","alongside","already","also","although","always","am","amid","amidst","among","amongst","an","and","another","any","anybody","anyhow","anyone","anything","anyway","anyways","anywhere","apart","appear","appreciate","appropriate","are","aren't","around","as","a's","aside","ask","asking","associated","at","available","away","awfully","back","backward","backwards","be","became","because","become","becomes","becoming","been","before","beforehand","begin","behind","being","believe","below","beside","besides","best","better","between","beyond","both","brief","but","by","came","can","cannot","cant","can't","caption","cause","causes","certain","certainly","changes","clearly","c'mon","co","co.","com","come","comes","concerning","consequently","consider","considering","contain","containing","contains","corresponding","could","couldn't","course","c's","currently","dare","daren't","definitely","described","despite","did","didn't","different","directly","do","does","doesn't","doing","done","don't","down","downwards","during","each","edu","eg","eight","eighty","either","else","elsewhere","end","ending","enough","entirely","especially","et","etc","even","ever","evermore","every","everybody","everyone","everything","everywhere","ex","exactly","example","except","fairly","far","farther","few","fewer","fifth","first","five","followed","following","follows","for","forever","former","formerly","forth","forward","found","four","from","further","furthermore","get","gets","getting","given","gives","go","goes","going","gone","got","gotten","greetings","had","hadn't","half","happens","hardly","has","hasn't","have","haven't","having","he","he'd","he'll","hello","help","hence","her","here","hereafter","hereby","herein","here's","hereupon","hers","herself","he's","hi","him","himself","his","hither","hopefully","how","howbeit","however","hundred","i'd","ie","if","ignored","i'll","i'm","immediate","in","inasmuch","inc","inc.","indeed","indicate","indicated","indicates","inner","inside","insofar","instead","into","inward","is","isn't","it","it'd","it'll","its","it's","itself","i've","just","k","keep","keeps","kept","know","known","knows","last","lately","later","latter","latterly","least","less","lest","let","let's","like","liked","likely","likewise","little","look","looking","looks","low","lower","ltd","made","mainly","make","makes","many","may","maybe","mayn't","me","mean","meantime","meanwhile","merely","might","mightn't","mine","minus","miss","more","moreover","most","mostly","mr","mrs","much","must","mustn't","my","myself","name","namely","nd","near","nearly","necessary","need","needn't","needs","neither","never","neverf","neverless","nevertheless","new","next","nine","ninety","no","nobody","non","none","nonetheless","noone","no-one","nor","normally","not","nothing","notwithstanding","novel","now","nowhere","obviously","of","off","often","oh","ok","okay","old","on","once","one","ones","one's","only","onto","opposite","or","other","others","otherwise","ought","oughtn't","our","ours","ourselves","out","outside","over","overall","own","particular","particularly","past","per","perhaps","placed","please","plus","possible","presumably","probably","provided","provides","que","quite","qv","rather","rd","re","really","reasonably","recent","recently","regarding","regardless","regards","relatively","respectively","right","round","said","same","saw","say","saying","says","second","secondly","see","seeing","seem","seemed","seeming","seems","seen","self","selves","sensible","sent","serious","seriously","seven","several","shall","shan't","she","she'd","she'll","she's","should","shouldn't","since","six","so","some","somebody","someday","somehow","someone","something","sometime","sometimes","somewhat","somewhere","soon","sorry","specified","specify","specifying","still","sub","such","sup","sure","take","taken","taking","tell","tends","th","than","thank","thanks","thanx","that","that'll","thats","that's","that've","the","their","theirs","them","themselves","then","thence","there","thereafter","thereby","there'd","therefore","therein","there'll","there're","theres","there's","thereupon","there've","these","they","they'd","they'll","they're","they've","thing","things","think","third","thirty","this","thorough","thoroughly","those","though","three","through","throughout","thru","thus","till","to","together","too","took","toward","towards","tried","tries","truly","try","trying","t's","twice","two","un","under","underneath","undoing","unfortunately","unless","unlike","unlikely","until","unto","up","upon","upwards","us","use","used","useful","uses","using","usually","v","value","various","versus","very","via","viz","vs","want","wants","was","wasn't","way","we","we'd","welcome","well","we'll","went","were","we're","weren't","we've","what","whatever","what'll","what's","what've","when","whence","whenever","where","whereafter","whereas","whereby","wherein","where's","whereupon","wherever","whether","which","whichever","while","whilst","whither","who","who'd","whoever","whole","who'll","whom","whomever","who's","whose","why","will","willing","wish","with","within","without","wonder","won't","would","wouldn't","yes","yet","you","you'd","you'll","your","you're","yours","yourself","yourselves","you've","zero","a","how's","i","when's","why's","b","c","d","e","f","g","h","j","l","m","n","o","p","q","r","s","t","u","uucp","w","x","y","z","I","www","amount","bill","bottom","call","computer","con","couldnt","cry","de","describe","detail","due","eleven","empty","fifteen","fifty","fill","find","fire","forty","front","full","give","hasnt","herse","himse","interest","itse”","mill","move","myse”","part","put","show","side","sincere","sixty","system","ten","thick","thin","top","twelve","twenty","abst","accordance","act","added","adopted","affected","affecting","affects","ah","announce","anymore","apparently","approximately","aren","arent","arise","auth","beginning","beginnings","begins","biol","briefly","ca","date","ed","effect","et-al","ff","fix","gave","giving","heres","hes","hid","home","id","im","immediately","importance","important","index","information","invention","itd","keys","kg","km","largely","lets","line","'ll","means","mg","million","ml","mug","na","nay","necessarily","nos","noted","obtain","obtained","omitted","ord","owing","page","pages","poorly","possibly","potentially","pp","predominantly","present","previously","primarily","promptly","proud","quickly","ran","readily","ref","refs","related","research","resulted","resulting","results","run","sec","section","shed","shes","showed","shown","showns","shows","significant","significantly","similar","similarly","slightly","somethan","specifically","state","states","stop","strongly","substantially","successfully","sufficiently","suggest","thered","thereof","therere","thereto","theyd","theyre","thou","thoughh","thousand","throug","til","tip","ts","ups","usefully","usefulness","'ve","vol","vols","wed","whats","wheres","whim","whod","whos","widely","words","world","youd","youre"];

  String _stem(String word) {
    word = word.toLowerCase();
    if (word.endsWith('ing')) return word.substring(0, word.length - 3);
    if (word.endsWith('ed')) return word.substring(0, word.length - 2);
    if (word.endsWith('s')) return word.substring(0, word.length - 1);
    return word;
  }

  Future<void> _search() async {
    String query = searchController.text.trim();
    if (query.isEmpty) return;

    List<String> keywords = query.split(' ')
        .where((word) => !_stopWords.contains(word.toLowerCase()))
        .map(_stem)
        .toList();

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Post_Info')
        .get();

    List<DocumentSnapshot> results = querySnapshot.docs.where((doc) {
      String title = doc['title'].toString().toLowerCase();
      return keywords.any((keyword) => title.contains(keyword));
    }).toList();

    setState(() {
      _results = results;
      isDataRecieved=true;
    });
  }

  @override
  void initState() {
    super.initState();
    searchController.text=widget.q;
    _search();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Material(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/NavBar',
                (route) => false, // Remove all routes from the stack
          );//Navigator.pushReplacementNamed(context, "/loginRoute");
          return false; // Return false to prevent default back button behavior
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Search Query",
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

          body: Padding(
            padding:EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 30,),
                  TextField(
                    controller: searchController,
                    cursorColor: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),
                    decoration: InputDecoration(
                        hintText: "Search any query",
                        contentPadding:EdgeInsets.only(left:20,top: 18,bottom: 18,right: 10),
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
                              _search();
                              setState(() {
                                isDataRecieved=false;
                              });
                          },)
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(
                    height: 580,
                    width: double.infinity,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border:Border.all(width:1.5,color: themeNotifier.isDarkTheme ? Color(0xff00cfd8) : Color(0xff00a6b5),)
                      ),
                    child: isDataRecieved?
                    _results.isEmpty?Center(
                      child: Padding(
                        padding:EdgeInsets.only(bottom: 80),
                        child: Text(
                          "No matching query was found.",
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                              color: themeNotifier.isDarkTheme?Colors.grey[300]:Colors.grey[700],
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ):
                    ListView.separated(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = _results[index];
                        return InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => viewPost(p:_results[index])),
                            );
                          },
                          child:Padding(
                            padding: const EdgeInsets.only(left: 18,right:0),
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
                                            _results[index]['title'],
                                            style: GoogleFonts.lato(
                                              textStyle: TextStyle(
                                                color:  themeNotifier.isDarkTheme?Colors.grey[400]:Colors.grey[700],
                                                fontSize: 16,
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
                      separatorBuilder: (context, index) => Divider(thickness: 2,color: themeNotifier.isDarkTheme?Colors.grey[700]:Colors.grey[300],),
                    ):Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xff00cfd8)),strokeWidth: 2,),
                      ),
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
