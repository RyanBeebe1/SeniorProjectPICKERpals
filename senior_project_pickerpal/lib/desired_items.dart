
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_tags/input_tags.dart';
import 'package:flutter_tags/selectable_tags.dart';
import 'package:seniorprojectnuked/backend_service.dart';
import 'package:seniorprojectnuked/pickup_entry.dart';
import 'session.dart';

class DesiredItemTag extends StatefulWidget{
  DesiredItemTag({Key key, this.title}) : super(key: key);
  final String title;
  DesiredItemTagState createState() => DesiredItemTagState();
} 

class DesiredItemTagState extends State<DesiredItemTag> with SingleTickerProviderStateMixin
{
  TabController _tabController;
  ScrollController _scrollViewController;
/*
  final List<String> _list = [
    '0','SDk','plugin updates','Facebook','哔了狗了QP又不够了',
    'Kirchhoff','Italy','France','Spain','美','Dart','Foo','Select','lorem ip','9',
    'Star','Flutter Selectable Tags','1','Hubble','2','Input flutter tags','A B C','8','Android Studio developer','welcome to the jungle','Gauss',
      '美术',
      '互联网',
      '炫舞时代',
      '篝火营地',
  ];
*/
  bool _symmetry = false;
  bool _singleItem = false;
  bool _withSuggesttions = false;
  int _count = 0;
  int _column = 8;
  double _fontSize = 14;

  String _selectableOnPressed = '';
  String _inputOnPressed = '';

  List<Tag> _selectableTags = [];
  List<String> _inputTags = [];
  List<DesiredItem> items = [];

  List _icon=[
    Icons.home,
    Icons.language,
    Icons.headset
  ];

  Future<void> _getItems() async {
    items = await BackendService.fetchDesiredItems("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/desireditems/" + SessionVariables.user.userId.toString());
    if (items.length > 0) {
      for (DesiredItem d in items) {
        setState(() {
             _inputTags.add(d.keyword);
        });
      }
    }

  }

  @override
  void initState()
  {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollViewController = ScrollController();
    _getItems();
   

    

  }


  @override
  Widget build(BuildContext context)
  {
        return Scaffold(
          body: NestedScrollView(
              controller: _scrollViewController,
              headerSliverBuilder: (BuildContext context,bool boxIsScrolled){
                return <Widget>[
                  SliverAppBar(
                    title: Text("Desired Items"),
                    centerTitle: true,
                    pinned: true,
                    expandedHeight: 110.0,
                    floating: true,
                    forceElevated: boxIsScrolled,
                    /** */
                    bottom: TabBar(
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: TextStyle(fontSize: 18.0),
                      tabs: [
                       // Tab(text: "Selectable"),
                        Tab(text: "Input"),
                      ],
                      controller: _tabController,
                    ),
                  )
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children:  [
                  ListView(
                      children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                          ),
                         
                          Padding(
                              padding: EdgeInsets.all(10),
                          ),
                          Container(
                              child:
                              InputTags(
                                onDelete: (item) {
                                  DesiredItem temp;
                                  for (DesiredItem d in items) {
                                    if (d.keyword == item) {
                                        temp = d;
                                        break;
                                    }
                                  }
                                  items.remove(temp);
                                  BackendService.deleteDesiredItem("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/deletedesireditem/" + temp.desiredItemId.toString());
                                },
                                  onInsert: (item) {
                                    DesiredItem d = new DesiredItem(keyword: item, userId: SessionVariables.user.userId);
                                    BackendService.addDesiredItem(d).then((onValue) {
                                      print(onValue.desiredItemId);
                                      items.add(onValue);
                                    });
      


                                  },
                                  tags: _inputTags,
                                  columns: _column,
                                  fontSize: _fontSize,
                                  symmetry: _symmetry,
                                  iconBackground: Colors.green[800],
                                  lowerCase: true,
                                  autofocus: false,
                                  suggestionsList: !_withSuggesttions ? null :
                                  [
                    
                                  ],
                                  popupMenuBuilder: (String tag){
                                      return <PopupMenuEntry>[
                                          PopupMenuItem(
                                              child: Text(tag,
                                                  style: TextStyle(
                                                      color: Colors.black87,fontWeight: FontWeight.w800
                                                  ),
                                              ),
                                              enabled: false,
                                          ),
                                          PopupMenuDivider(),
                                          PopupMenuItem(
                                              value: 1,
                                              child: Row(
                                                  children: <Widget>[
                                                      Icon(Icons.content_copy,size: 18,),
                                                      Text(" Copy text"),
                                                  ],
                                              ),
                                          ),
                                          PopupMenuItem(
                                              value: 2,
                                              child: Row(
                                                  children: <Widget>[
                                                      Icon(Icons.delete,size: 18),
                                                      Text(" Remove"),
                                                  ],
                                              ),
                                          )
                                      ];
                                  },
                                  popupMenuOnSelected: (int id,String tag){
                                      switch(id){
                                          case 1:
                                              Clipboard.setData( ClipboardData(text: tag));
                                              break;
                                          case 2:
                                              setState(() {
                                                  _inputTags.remove(tag);
                                              });
                                      }
                                  },
                                  //textFieldHidden: true,
                                  //boxShadow: [],
                                  //offset: -2,
                                  //padding: EdgeInsets.only(left: 11),
                                  //margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                  //iconPadding: EdgeInsets.all(5),
                                  //iconMargin: EdgeInsets.only(right:5,left: 2),
                                  //borderRadius: BorderRadius.all(Radius.elliptical(50, 5)),
                                  //onDelete: (tag) => print(tag),
                                  //onInsert: (tag) => print(tag),

                              ),
                          ),
                          Padding(
                              padding: EdgeInsets.all(10),
                          ),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(_inputOnPressed),
                          ),
                      ],
                  )
                ],
              )
          ),
        );
  }
 ///Random Colors
  Color _color = Color(0xFFFFFFFF);
  final Random _random = Random();

  void _randomColors()
  {
      setState(() {
          _color = Color.fromARGB(
              _random.nextInt(256),
              _random.nextInt(256),
              _random.nextInt(256),
              _random.nextInt(256),
          );
      });
  }

}


