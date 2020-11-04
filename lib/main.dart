import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_buddy/chat.dart';
import 'package:task_buddy/signincontroller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Task Buddy",
      theme: ThemeData(
        primarySwatch: Colors.green,
        disabledColor: Colors.white,


        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  GoogleSignIn googleSignIn = GoogleSignIn();
  String userId = " ";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg2.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black54,
          child: Column(
            children: <Widget>[
              Spacer(),
              Center(
                  child: Image.asset(
                    'assets/taskbuddy.png',
                    height: 200,
                  )),

              SizedBox(
                height: 50,
              ),
              Text(
                "tASKbuddy",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    color: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "There's someone to help you with your To-Do",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 25,
                    color: Colors.white),
              ),
              Spacer(),
              MaterialButton(
                onPressed: () async {
                  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
                  setState(() {
                    userId = sharedPreferences.getString('id');
                  });
                  //DocumentSnapshot variable = await FirebaseFirestore.instance.collection('users').doc(userId).get();
                  bool userLoggedIn = (sharedPreferences.getString('id')??'').isNotEmpty;

                  if(userLoggedIn){
                    Navigator.push(context,
                       MaterialPageRoute(builder: (context) => Home()));
                  }
                  else {
                    Dialogs.showLoadingDialog(context, _keyLoader);
                    bool res = await AuthProvider().loginwithGoogle();
                    Navigator.of(_keyLoader.currentContext, rootNavigator: true)
                        .pop();
                    if (!res)
                      print("error");
                    else {
                      Navigator.push(context,
                       MaterialPageRoute(builder: (context) => Home()));
                    }
                  }
                },
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
                elevation: 5,
                height: 50,
                child: Container(
                  width: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(FontAwesomeIcons.google),
                      SizedBox(width: 10),
                      Text('Sign-in',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              Container(height: 10,),
            ],
          ),
        ),
      ),
    );
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10,),
                        Text("Please Wait....",style: TextStyle(color: Colors.green),)
                      ]),
                    )
                  ]));
        });
  }
}
