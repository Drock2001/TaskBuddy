import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatPage.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  String userId;
  int created;
  String msgread = "0";

  @override
  void initState() {
    getUserId();
    super.initState();
  }

  getUserId() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    userId = sharedPreferences.getString('id');
    created = sharedPreferences.get('created_at');
  }

  DocumentSnapshot variable;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("tASKbuddy"),
          backgroundColor: Colors.green[800],

          actions: [
            IconButton(icon: Icon(Icons.search, color: Colors.white,), color: Colors.white,),
          ],
        ),
        body: Container(
          color: Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return ListView.builder(
                    itemBuilder: (listContext, index) =>
                        buildItem(snapshot.data.docs[index]),
                    itemCount: snapshot.data.docs.length,
                  );
                }

                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
  buildItem(doc) {
    if ((userId != doc.get('id'))) {
      Variable(doc.get('id'));
      return GestureDetector(
        onTap: () {
          FirebaseFirestore.instance.collection('users').doc(userId).collection('friends').doc(doc.get('id')).set({
            'msgread': "1",
          });
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ChatPage(docs: doc)));
        },
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              child: Row(
                children: <Widget>[

                  CircleAvatar(
                    radius: 20.0,
                    backgroundImage:
                    NetworkImage(doc.get('profile_pic')),
                    backgroundColor: Colors.transparent,
                  ),

                  Container(
                    width: 10,
                  ),
                  Center(
                    child: Text(doc.get('name').toUpperCase(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  ),
                  Spacer(),
                  (msgread == "0") ? Icon(Icons.circle, size: 20, color: Colors.green[800], ): Container(),
                  Container(
                    width: 10,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Container(height: 10, width: 10,) ;
    }
  }
  Variable(anouser) async{
      variable = await FirebaseFirestore.instance.collection('users').doc(userId).collection('friends').doc(anouser).get();
      if(variable.data()['msgread'].isNotEmpty) {
        setState(() {
          msgread = variable.data()['msgread'];
        });
      }
  }
}



