import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seniorprojectnuked/backend_service.dart';
import 'package:seniorprojectnuked/pickup_entry.dart';
import 'package:seniorprojectnuked/session.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  Chat({Key key, this.receiverId}) : super(key: key);
  final int receiverId;
  @override
  ChatWindow createState() => new ChatWindow();
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  String _getDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }
  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Chat Application"),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: new EdgeInsets.all(6.0),
            )),
        new Divider(height: 1.0),
        new Container(
          child: _buildComposer(),
          decoration: new BoxDecoration(color: Theme.of(ctx).cardColor),
        ),
      ]),
    );
  }


  Widget _buildComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                  child: new TextField(
                    controller: _textController,
                    onChanged: (String txt) {
                      setState(() {
                        _isWriting = txt.length > 0;
                      });
                    },
                    onSubmitted: _submitMsg,
                    decoration:
                      new InputDecoration.collapsed(hintText: "Enter some text to send a message"),
                  ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 3.0),
              ),
            ],
          ),
        ),
    );
  }

  void _submitMsg(String txt) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = new Msg(
      txt: txt,
      animationController: new AnimationController(
          vsync: this,
        duration: new Duration(milliseconds: 800)
      ),
    );
    setState(() {
      _messages.insert(0, msg);
    });
    print(SessionVariables.user.userId);
    print(widget.receiverId);
    BackendService.addMessage(new Message(body:txt, date:_getDateTime()), SessionVariables.user.userId, widget.receiverId);
    msg.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }

}

class Msg extends StatelessWidget {
  Msg({this.txt, this.animationController});
  final String txt;
  final AnimationController animationController;

  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 18.0),
              child: new CircleAvatar(child: new Text(SessionVariables.user.displayName.substring(0,1).toUpperCase())),
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(SessionVariables.user.displayName, style: Theme.of(ctx).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(txt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}