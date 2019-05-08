import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:seniorprojectnuked/backend_service.dart';
import 'package:seniorprojectnuked/pickup_entry.dart';
import 'package:seniorprojectnuked/session.dart';
import 'package:seniorprojectnuked/general_alert.dart';
import 'package:intl/intl.dart';

class Chat extends StatefulWidget {
  Chat({Key key, this.receiverId, this.senderId, this.myChats})
      : super(key: key);
  final int receiverId;
  final int senderId;
  final bool myChats;
  @override
  ChatWindow createState() => new ChatWindow();
}
//This state represents the chat interface.
class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  String _getDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
    return formattedDate;
  }

  //Gets previous messages if a chat between the sender and receiver exists.
  Future<void> _getMessages() async {
    List<UserChat> chats = await BackendService.fetchChats(
        "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/getchats/" +
            SessionVariables.user.userId.toString());
    List<Message> messages;
    if (chats.length > 0) {
      for (UserChat c in chats) {
        if ((c.sender.userId == widget.senderId &&
                c.recipient.userId == widget.receiverId) ||
            (c.sender.userId == widget.receiverId &&
                c.recipient.userId == widget.senderId)) {
          messages = await BackendService.fetchMessages(
              "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/getmessages/" +
                  c.chat_id.toString());
        }
      }
    }
    if (messages != null) {
      for (Message m in messages) {
        String name = m.user.displayName;
        setState(() {
          _messages.add(new Msg(
            txt: m.body,
            animationController: new AnimationController(
                vsync: this, duration: new Duration(milliseconds: 800)),
            name: name,
            senderId: m.user.userId,
            messageId: m.messageId,
          ));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getMessages().then((hi) {});
  }

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Chat Page"),
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
              child: Container(
                height: 55,
                child: new TextField(
                  cursorColor: Colors.lightGreen,
                  controller: _textController,
                  onChanged: (String txt) {
                    setState(() {
                      _isWriting = txt.length > 0;
                    });
                  },
                  onSubmitted: _submitMsg,
                  decoration: new InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 5),
                      border: OutlineInputBorder(),
                      fillColor: Colors.lightGreen,
                      hintText: "  Enter some text to send a message"),
                ),
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
  //Submit a message to the server and update the chat window with the new message.
  void _submitMsg(String txt) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = new Msg(
        txt: txt,
        animationController: new AnimationController(
            vsync: this, duration: new Duration(milliseconds: 800)),
        name: SessionVariables.user.displayName,
        senderId: SessionVariables.user.userId,
        messageId: 0);
    setState(() {
      _messages.insert(0, msg);
      print(_messages.length);
    });
    if (!widget.myChats) {
      BackendService.addMessage(
          new Message(
              body: txt, date: _getDateTime(), user: SessionVariables.user),
          SessionVariables.user.userId,
          widget.receiverId);
    } else {
      //If chat already exists, otherUserId is not the sender
      int otherUserId;
      if (widget.senderId == SessionVariables.user.userId) {
        otherUserId = widget.receiverId;
      } else {
        otherUserId = widget.senderId;
      }
      BackendService.addMessage(
          new Message(
              body: txt, date: _getDateTime(), user: SessionVariables.user),
          SessionVariables.user.userId,
          otherUserId);
    }
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
//Widget that represents a message in the chat window.
class Msg extends StatelessWidget {
  Msg(
      {this.txt,
      this.animationController,
      this.name,
      this.senderId,
      this.messageId});
  final String txt;
  final AnimationController animationController;
  final String name;
  final int senderId;
  final int messageId;
  @override
  Widget build(BuildContext ctx) {
    return ListTile(
      leading:
          new CircleAvatar(child: new Text(name.substring(0, 1).toUpperCase())),
      title: Text(name),
      subtitle: Text(txt),
      trailing: Visibility(
          child: IconButton(
              icon: Icon(Icons.flag),
              onPressed: () async {
                bool reporting = await showDialog(
                    context: ctx,
                    builder: (_) => new GeneralAlert(
                        text: "Report this message?",
                        positive: "Yes",
                        negative: "No"));
                if (reporting) {
                  BackendService.reportMessage(
                      "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/reportmessage/" +
                          this.messageId.toString());
                }
              }),
          visible: name != SessionVariables.user.displayName),
    );
  }
}

class MyChats extends StatefulWidget {
  MyChats();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyChatsState();
  }
}
//This state represents the 'My Chats' page, which contains a history of a users past chats.
class MyChatsState extends State<MyChats> {
  List<ChatTile> _chats = <ChatTile>[];

  Future<void> _buildTiles() async {
    List<UserChat> chat = await BackendService.fetchChats(
        "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/getchats/" +
            SessionVariables.user.userId.toString());
    if (chat.length > 0) {
      for (UserChat c in chat) {
        Message m = await BackendService.fetchLastMessage(
            "http://ec2-3-88-8-44.compute-1.amazonaws.com:5000/lastmessage/" +
                c.chat_id.toString());

        String otherUser;

        if (SessionVariables.user.userId == c.sender.userId) {
          otherUser = c.recipient.displayName;
        } else {
          otherUser = c.sender.displayName;
        }
        setState(() {
          _chats.add(new ChatTile(
            lastMsgName: m.user.displayName,
            name: otherUser,
            txt: m.body,
            senderId: c.sender.userId,
            receiverId: c.recipient.userId,
          ));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _buildTiles();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("My Chats"),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          itemBuilder: (ctx, int index) => _chats[index],
          itemCount: _chats.length,
          padding: new EdgeInsets.all(6.0),
        )),
        new Divider(height: 1.0),
      ]),
    );
  }
}
//Represents a chat tile in the 'My Chats' page.
class ChatTile extends StatelessWidget {
  ChatTile(
      {this.txt, this.name, this.receiverId, this.senderId, this.lastMsgName});
  final String txt;
  final String name;
  final String lastMsgName;
  final int senderId;
  final int receiverId;
  @override
  Widget build(BuildContext ctx) {
    return ListTile(
      onTap: () {
        Navigator.push(
            ctx,
            new MaterialPageRoute(
                builder: (context) => new Chat(
                      senderId: senderId,
                      receiverId: receiverId,
                      myChats: true,
                    )));
      },
      leading:
          new CircleAvatar(child: new Text(name.substring(0, 1).toUpperCase())),
      title: Text(name),
      subtitle: Text(lastMsgName + ": " + txt),
    );
  }
}
