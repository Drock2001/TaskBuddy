import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '';

class ChatPage extends StatefulWidget {
  final docs;

  const ChatPage({Key key, this.docs}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  int _counter = 0;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _getToken() {
    _firebaseMessaging.getToken().then((deviceToken) {
      print("Device Token: $deviceToken");
    });
  }

  _configureFirebaseListeners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async{
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async{
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async{
        print("onResume: $message");
      },
    );
  }

  String groupChatId;
  String userID;

  TextEditingController textEditingController = TextEditingController();

  TabController tabController;

  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    getGroupChatId();
    super.initState();
    _getToken();
    _configureFirebaseListeners();
    tabController = TabController(length: 3, vsync: this);

    tabController.index = 1;

  }

  getGroupChatId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    userID = sharedPreferences.getString('id');

    String anotherUserId = widget.docs.get('id');


    if (userID.compareTo(anotherUserId) > 0) {
      groupChatId = '$userID - $anotherUserId';
    } else {
      groupChatId = '$anotherUserId - $userID';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docs.get('name').toUpperCase()),
        backgroundColor: Colors.green,
        bottom: TabBar(
          tabs: [
            Tab(
              child: Text('Your Tasks'),
            ),
            Tab(
              child: Text('Chat'),
            ),
            Tab(
              child: Text('Buddy Tasks'),
            ),
          ],
          controller: tabController,
        ),
      ),
      body: TabBarView(
        children: [
          task(),chat(),task(),
        ],
        controller: tabController,
      ),
    );
  }

  Widget task(){
    return Container();
  }

  Widget chat(){
    return Container(
      color: Colors.black87,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .doc(groupChatId)
              .collection(groupChatId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Column(
                children: <Widget>[
                  Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemBuilder: (listContext, index) =>
                            buildItem(snapshot.data.documents[index]),
                        itemCount: snapshot.data.documents.length,
                        reverse: true,
                      )),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: textEditingController,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.white,),
                        onPressed: () => sendMsg(),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Center(
                  child: SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ));
            }
          },
        ),
      ),
    );
  }

  sendMsg() {
    String msg = textEditingController.text.trim();

    /// Upload images to firebase and returns a URL
    if (msg.isNotEmpty) {
      print('thisiscalled $msg');
      var ref = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        await transaction.set(ref, {
          "senderId": userID,
          "anotherUserId": widget.docs.get('id'),
          "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
          'content': msg,
          "type": 'text',
        });
      });

      FirebaseFirestore.instance.collection('users').doc(userID).collection('friends').doc(widget.docs.get('id')).update({
        'msgread': "1",
      });

      FirebaseFirestore.instance.collection('users').doc(widget.docs.get('id')).collection('friends').doc(userID).update({
        'msgread': "0",
      });
      textEditingController.clear();
      scrollController.animateTo(0.0,
          duration: Duration(milliseconds: 100), curve: Curves.bounceInOut);
    } else {
      print('Please enter some text to send');
    }
  }

  buildItem(doc) {
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0,
          left: ((doc.get('senderId') == userID) ? 64 : 0),
          right: ((doc.get('senderId') == userID) ? 0 : 64)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: ((doc.get('senderId') == userID)
                  ? Colors.white70
                  : Colors.greenAccent),
              borderRadius: BorderRadius.circular(8.0)),
          child: (doc.get('type') == 'text')
              ? Text('${doc.get('content')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
              : Image.network(doc.get('content')),
        ),
      ),
    );
  }
}
