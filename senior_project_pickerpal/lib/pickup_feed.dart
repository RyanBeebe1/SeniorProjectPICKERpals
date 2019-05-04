import 'package:flutter/material.dart';
import 'package:seniorprojectnuked/chat.dart';
import 'package:seniorprojectnuked/general_alert.dart';
import 'package:seniorprojectnuked/session.dart';
import 'backend_service.dart';
import 'pickup_entry.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ListingFeed extends StatefulWidget {
  ListingFeed({Key key, this.title, this.endpoint, this.personalMode})
      : super(key: key);
  final String title;
  String endpoint;
  final List<Listing> items = [];
  final bool personalMode;
  ListingFeedState state = ListingFeedState();
  @override
  ListingFeedState createState() => state;
}

class ListingFeedState extends State<ListingFeed> {
  bool emptyList;
  bool ratePress = false;
  int pageNum;
  ScrollController _controller = ScrollController();

  bool loading = false, refreshing = false;
  bool diff;

  int rating_id = 0;
  int test = 1;
  int _radioValue = -1;
  String endpoint;

  List<Listing> getItems() {
    return widget.items;
  }

  Future<void> onRefresh() async {
    await Future.delayed(Duration(milliseconds: 3000));
    BackendService.fetchListing(widget.endpoint)
        .whenComplete(() {})
        .then((pick) {
      print(pick[0].item_title);
      setState(() {
        widget.items.addAll(pick);
      });
    });

    refreshing = false;
    print("loading done.");
    return null;
  }

  Future<void> onLoad() async {
    await Future.delayed(Duration(milliseconds: 500));
    BackendService.fetchListing(widget.endpoint)
        .whenComplete(() {})
        .then((pick) {
      print(pick[0].item_title);
      setState(() {
        widget.items.addAll(pick);
      });
    });

    loading = false;
    print("loading done.");
    return null;
  }

  void setEndpoint(String url) {
    widget.endpoint = url;
  }

  Future<void> newList() async {
    await Future.delayed(Duration(milliseconds: 1000));
    BackendService.fetchListing(widget.endpoint)
        .whenComplete(() {})
        .then((pick) {
      setState(() {
        widget.items.clear();
        widget.items.addAll(pick);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addOne(Listing item) {
    setState(() {
      widget.items.insert(0, item);
    });
  }

  @override
  void initState() {
    pageNum = 1;
    onLoad();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        setState(() {
          if (!loading) {
            loading = true;
            print("now loading");
            onLoad();
            pageNum++;
          }
        });
      }
      if (_controller.offset <= _controller.position.minScrollExtent &&
          !_controller.position.outOfRange) {
        setState(() {
          print("reach the top");
        });
      }
    });
    super.initState();
  }

  bool showRefresh() {
    bool visibleFeed;
    if (widget.items.length < 8) {
      visibleFeed = false;
    } else {
      visibleFeed = true;
    }
    return visibleFeed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {
            refreshing = true;
          });
          widget.items.clear();
          return onRefresh();
        },
        child: ListView.separated(
            separatorBuilder: (context, ind) {
              return Divider(
                color: Colors.lightGreen,
              );
            },
            primary: false,
            controller: _controller,
            itemCount: widget.items.length + 1,
            itemBuilder: (context, index) {
              if (index == widget.items.length && !refreshing) {
                if (!widget.personalMode) {
                  emptyList = widget.items.isEmpty;
                  return ListTile(
                    title: emptyList
                        ? Center(child: Text("Server is Offline!"))
                        : Center(
                            child: Visibility(
                            visible: showRefresh() ? true : false,
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.green,
                            ),
                          )),
                  );
                } else {
                  return ListTile(
                    title: Center(child: Text("End of List")),
                  );
                }
              } else if (!refreshing) {
                final item = widget.items[index];
                return ListTile(
                    leading: Image.network(
                        "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/thumbs/" +
                            item.listing_id.toString()),
                    onLongPress: () {
                      if (widget.personalMode) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(child: Text('Alert')),
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Are you sure you want to delete this listing?",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                                FlatButton(
                                    child: Text('Yes'),
                                    onPressed: () {
                                      BackendService.deleteListing(
                                          "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/deletelisting/" +
                                              item.listing_id.toString());
                                      setState(() {
                                        widget.items.removeAt(index);
                                      });
                                      Navigator.of(context).pop();
                                    })
                              ],
                            );
                          },
                        );
                      }
                    },
                    onTap: () async {
                      if (SessionVariables.loggedIn) {
                        diff = SessionVariables.user.userId != item.user.userId;
                      }
                      item.user.overallRating = await BackendService.getOverall(
                          "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/get_overall/" +
                              item.user.userId.toString());
                      showDialog(
                        context: context,
                        builder: (_) => new ItemView(item: item, diff: diff),
                      );
                    },
                    title: Text(item.item_title),
                    subtitle: Text(item.description),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.chat),
                          onPressed: () {
                            !SessionVariables.loggedIn
                                ? SessionVariables.loggedInDialogue(
                                    context, "Please log in to send messages")
                                : SessionVariables.user.userId ==
                                        item.user.userId
                                    ? SessionVariables.loggedInDialogue(
                                        context, "You can't message yourself")
                                    : Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                            builder: (context) => new Chat(
                                                  myChats: false,
                                                  senderId: SessionVariables
                                                      .user.userId,
                                                  receiverId: item.user.userId,
                                                )));
                          }),
                      Visibility(
                          child: IconButton(
                              icon: Icon(Icons.star),
                              onPressed: () async {
                                if (item.user.userId !=
                                    SessionVariables.user.userId) {
                                  bool changing = false;
                                  if (await BackendService.inquireRating(
                                      "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/inquire_rating/" +
                                          SessionVariables.user.userId
                                              .toString() +
                                          "/" +
                                          item.listing_id.toString())) {
                                    int rat = await BackendService.fetchRating(
                                        "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/fetch_rating/" +
                                            SessionVariables.user.userId
                                                .toString() +
                                            "/" +
                                            item.listing_id.toString());
                                    String info =
                                        "You've already given this listing a " +
                                            rat.toString() +
                                            ". Would you like to change it?";
                                    changing = await showDialog(
                                      context: context,
                                      builder: (_) => GeneralAlert(
                                          text: info,
                                          positive: "Yes",
                                          negative: "No"),
                                    );
                                    if (changing) {
                                      await showDialog(
                                          context: context,
                                          builder: (_) => RatingDialog(
                                              item: item, changing: changing));
                                    }
                                  } else {
                                    await showDialog(
                                        context: context,
                                        builder: (_) => RatingDialog(
                                              item: item,
                                              changing: false,
                                            ));
                                  }
                                } else {
                                  SessionVariables.loggedInDialogue(
                                      context, "You can't rate your own items");
                                }
                                setState(() {
                                  ratePress = true;
                                });
                              }),
                          visible: ratePress ? true : true)
                    ]));
              }
            }),
      ),
    );
  }
}

class ItemView extends StatelessWidget {
  ItemView({this.item, this.diff});
  final Listing item;
  bool diff;
  @override
  Widget build(BuildContext context) {
    return new SimpleDialog(
      contentPadding: EdgeInsets.all(10.0),
      children: <Widget>[
        Row(children: <Widget>[
          Text(
            item.item_title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
          ),
          Visibility(
              child: IconButton(
                  icon: Icon(Icons.flag),
                  onPressed: () async {
                    bool reporting = await showDialog(
                        context: context,
                        builder: (_) => new GeneralAlert(
                            text: "Report this listing?",
                            positive: "Yes",
                            negative: "No"));
                    if (reporting) {
                      BackendService.reportListing(
                          "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/reportlisting/" +
                              item.listing_id.toString());
                    }
                  }),
              visible: (!SessionVariables.loggedIn) ? true : diff)
        ]),
        Padding(padding: EdgeInsets.all(20.0)),
        CachedNetworkImage(
          imageUrl:
              "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/images/" +
                  item.listing_id.toString(),
          placeholder: (context, url) => new Center(
              child: Container(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 5.0,
                  ))),
          errorWidget: (context, url, error) => new Icon(Icons.error_outline),
        ),
        Text("Posted by: " + item.user.displayName),
        Text("User's overall rating: " +
            item.user.overallRating.toString() +
            "\n"),
        Text(
          item.description,
          style: TextStyle(fontSize: 15.0),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Container(
            height: 30.0,
            width: 10.0,
            child: Text(
              "Ok",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            decoration: BoxDecoration(
              color: Colors.lightGreen,
              border: Border.all(color: Colors.black),
            ),
          ),
        )
      ],
    );
  }
}

class RatingDialog extends StatefulWidget {
  RatingDialog({Key key, this.title, this.item, this.changing})
      : super(key: key);

  final String title;
  final Listing item;
  final bool changing;

  @override
  _RatingDialogState createState() => new _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _radioValue = null;
  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
    switch (_radioValue) {
      case 0:
        setState(() {
          _radioValue = 0;
        });
        break;
      case 1:
        setState(() {
          _radioValue = 1;
        });
        break;
      case 2:
        setState(() {
          _radioValue = 2;
        });
        break;
      case 3:
        setState(() {
          _radioValue = 3;
        });
        break;
      case 4:
        setState(() {
          _radioValue = 4;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: Text("Rate this listing"),
      content: Text("Choose from 1 to 5:"),
      actions: <Widget>[
        Center(
            child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Radio(
                    value: 1,
                    groupValue: _radioValue,
                    onChanged: _handleRadioValueChange),
                new Text("1"),
                new Radio(
                    value: 2,
                    groupValue: _radioValue,
                    onChanged: _handleRadioValueChange),
                new Text("2"),
                new Radio(
                    value: 3,
                    groupValue: _radioValue,
                    onChanged: _handleRadioValueChange),
                new Text("3"),
                new Radio(
                    value: 4,
                    groupValue: _radioValue,
                    onChanged: _handleRadioValueChange),
                new Text("4"),
                new Radio(
                    value: 5,
                    groupValue: _radioValue,
                    onChanged: _handleRadioValueChange),
                new Text("5"),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            new RaisedButton(
              color: Colors.lightGreen,
              onPressed: () {
                Navigator.of(context).pop();
                Rating r = new Rating(
                  _radioValue.toString(),
                  widget.item.listing_id.toString(),
                  SessionVariables.user.userId.toString(),
                  widget.item.user.userId.toString(),
                );
                if (!widget.changing) {
                  BackendService.addRating(r);
                } else {
                  BackendService.changeRating(r);
                }
                _radioValue = null; //or back to -1?
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        )),
      ],
    );
  }
}
