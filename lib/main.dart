import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:expandable/expandable.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food Recipe',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController textEditingController = TextEditingController();
  List items = [];
  List dataItems = [];
  int totalCount = 0;
  int pageCount = 0;
  String pageCountText = '';
  String searchedItem = '';
  bool searchStatus = false;
  bool showTotalSearch = false;
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.center;
  FocusNode focusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  void _showScaffold(String message) {
    try {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: '',
          onPressed: () {},
        ),
      ));
    } on Exception catch (e, s) {
      print(s);
    }
  }

  // Get Data : REST API
  getData(search) async {
    setState(() {
      items = [];
      searchedItem = "Searching : " + search;
      searchStatus = true;
      showTotalSearch = true;
    });
    dataItems = [];
    var url =
        "https://api.edamam.com/search?q=${search}&app_id=35415686&app_key=a67a3e31295996b90f996df842ad1b3d&from=${pageCount}&to=${pageCount + 10}";
    var path = await http.get(url);

    var datas = jsonDecode(path.body);

    dataItems = datas['hits'];
    if (dataItems.length > 0) {
      try {
        //adding data
        dataItems.forEach((element) {
          setState(() {
            items.add(element);
          });
        });
        focusNode.unfocus();
        setState(() {
          totalCount = datas['count'];
          mainAxisAlignment = MainAxisAlignment.start;
          searchedItem = "Searched : " + search;
          pageCountText = search;
        });
        //assigning flags
        textEditingController.clear();
        searchStatus = false;
      } catch (e) {
        setState(() {
          totalCount = 0;
          mainAxisAlignment = MainAxisAlignment.center;
          searchedItem = "Searched Failed : " + e;
          searchStatus = false;
        });
      }
    } else {
      if (search.length > 0) {
        setState(() {
          totalCount = 0;
          mainAxisAlignment = MainAxisAlignment.center;
          searchedItem = "Searched Failed : " + search;
          searchStatus = false;
        });
      } else {
        setState(() {
          totalCount = 0;
          mainAxisAlignment = MainAxisAlignment.center;
          searchedItem = "Searched Failed : Nothing to Search";
          searchStatus = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Food Recipe"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            //Search TextField
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: "Recipe Name",
                ),
                onSubmitted: (str) {
                  getData(str);
                  setState(() {
                    pageCount = 0;
                  });
                },
              ),
            ),
            //Search Button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              child: RaisedButton(
                color: Colors.green.withOpacity(.8),
                onPressed: () {
                  getData(textEditingController.text);
                  pageCount = 0;
                },
                child: Text(
                  "Search",
                  style: GoogleFonts.spectral(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            //searched item text
            showTotalSearch
                ? Container(
                    margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 1,
                          color: Colors.black.withOpacity(.5),
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          searchedItem,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        Text(
                          "Total Results: " + totalCount.toString(),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ],
                    ))
                : Container(),
            //Each item
            items.length > 0
                ? Expanded(
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                    onNotification:
                        (OverscrollIndicatorNotification overscroll) {
                      overscroll.disallowGlow();
                      return;
                    },
                    child: Container(
                      child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            // Outer Container
                            return index == items.length - 1
                                ? Column(
                                    children: <Widget>[
                                      eachItem(index),
                                      //prev and next bottom
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 40),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            RaisedButton(
                                              onPressed: () {
                                                if (pageCount > 9) {
                                                  setState(() {
                                                    pageCount -= 10;
                                                    getData(pageCountText);
                                                  });
                                                } else {
                                                  _showScaffold(
                                                      "Can't Navigate down !!!");
                                                }
                                              },
                                              color: Colors.green,
                                              child: Text(
                                                "Prev",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                                child: Center(
                                              child: Text(
                                                  "Page : " +
                                                      pageCount.toString() +
                                                      " - " +
                                                      (pageCount + 10)
                                                          .toString(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.blue,
                                                  )),
                                            )),
                                            RaisedButton(
                                              onPressed: () {
                                                if (pageCount == totalCount) {
                                                  _showScaffold(
                                                      "Can't Navigate up !!!");
                                                } else if (pageCount + 10 ==
                                                    totalCount) {
                                                  setState(() {
                                                    pageCount = totalCount;
                                                  });
                                                } else if (pageCount <
                                                    totalCount - 10) {
                                                  setState(() {
                                                    pageCount += 10;
                                                  });
                                                  getData(pageCountText);
                                                }
                                              },
                                              color: Colors.green,
                                              child: Text("Next",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : eachItem(index);
                          }),
                    ),
                  ))
                : searchStatus
                    ? Expanded(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }

  //Custom Widget's
  //eachItem

  Widget eachItem(index) {
    List<Widget> healthCaution = [];
    items[index]['recipe']['healthLabels'].forEach((val) {
      healthCaution.add(Container(
        margin: EdgeInsets.only(right: 5, bottom: 3),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.green,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green,
              Colors.green[800],
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          val,
          style: TextStyle(color: Colors.white),
        ),
      ));
    });
    items[index]['recipe']['cautions'].forEach((val) {
      healthCaution.add(Container(
        margin: EdgeInsets.only(right: 5, bottom: 3),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red,
              Colors.red[800],
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          val,
          style: TextStyle(color: Colors.white),
        ),
      ));
    });

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            width: 1,
            color: Colors.grey.withOpacity(.2),
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(240, 240, 240, 1),
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 1.0, //extend the shadow
            )
          ],
        ),

        //Inner Column for all card item
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              //Image of Recipe
              AspectRatio(
                aspectRatio: 1.3,
                child: Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                            items[index]['recipe']['image'],
                          ))),
                ),
              ),
              // Recipe Label
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  items[index]['recipe']['label'],
                  textAlign: TextAlign.left,
                  style: GoogleFonts.robotoSlab(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),

              // Recipe good and bad
              Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Wrap(
                    children: healthCaution.map<Widget>((val) => val).toList(),
                  )),
              // Recipe Calories
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Calories: " +
                      items[index]['recipe']['calories'].toInt().toString(),
                  style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              // Recipe total weight
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Total Weight: " +
                      items[index]['recipe']['totalWeight'].toInt().toString(),
                  style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.w500, fontSize: 16),
                ),
              ),
              // Recipe total time
              items[index]['recipe']['totalTime'].toString() == "0.0"
                  ? Container()
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Total Time: " +
                            items[index]['recipe']['totalTime'].toString(),
                        style: GoogleFonts.notoSans(
                            fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ),
              // Dropdown
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ExpandablePanel(
                    header: Text(
                      "Ingredient's (${items[index]['recipe']['ingredientLines'].length})",
                      style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    headerAlignment: ExpandablePanelHeaderAlignment.center,
                    expanded: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: items[index]['recipe']['ingredientLines']
                          .map<Widget>((val) => Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    "-",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(left: 10),
                                      child: Text(
                                        val,
                                        style: TextStyle(
                                          color: Colors.black45.withOpacity(.7),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )))
                          .toList(),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ));
  }
}
