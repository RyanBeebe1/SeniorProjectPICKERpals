import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seniorprojectnuked/backend_service.dart';
import 'package:seniorprojectnuked/pickup_entry.dart';
import 'package:seniorprojectnuked/session.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  Chat({Key key, this.receiverId,this.receiverId2}) : super(key: key);
  final String receiverId;
  final int receiverId2;
  @override
  ChatWindow createState() => new ChatWindow();
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  String _getDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }
  
  Future<void> _getMessages() async {
    List<UserChat> chats = await BackendService.fetchChats("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/getchats/"+SessionVariables.user.userId.toString());
    List<Message> messages;
    if (chats.length > 0) {
    for (UserChat c in chats) {
        if ((c.sender.emailAddress == SessionVariables.user.emailAddress && c.recipient.emailAddress == widget.receiverId)||
        (c.sender.emailAddress == widget.receiverId && c.recipient.emailAddress == SessionVariables.user.emailAddress)) {
          messages = await BackendService.fetchMessages("http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/getmessages/"+c.chat_id.toString());
        }
    }
    }
    if (messages != null) {
    for (Message m in messages) {
      String name = m.user.displayName;
      setState(() {
         _messages.add(new Msg(txt:m.body,animationController: new AnimationController(
          vsync: this,
        duration: new Duration(milliseconds: 800)
      ),name: name,));
      });
     
    }
    }
  }
  @override
  void initState() {
      super.initState();
      _getMessages().then((hi) {
      });
   

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
              itemBuilder: (ctx, int index) => _messages[index],
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
      ),name: SessionVariables.user.displayName
    );
    setState(() {
      _messages.insert(0, msg);
      print(_messages.length);
    });
    BackendService.addMessage(new Message(body:txt, date:_getDateTime(), user: SessionVariables.user), SessionVariables.user.userId, widget.receiverId2);
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
  Msg({this.txt, this.animationController,this.name});
  final String txt;
  final AnimationController animationController;
  final String name;
  @override
  Widget build(BuildContext ctx) {
    return ListTile(
      leading: new CircleAvatar(child: new Text(name.substring(0,1).toUpperCase())),
      title:  Text(name),
      subtitle:  Text(txt),
      );
  }
}