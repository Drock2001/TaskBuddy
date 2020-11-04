import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthProvider{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> logOut() async{
    try {
      await _auth.signOut();
    }
    catch(e) {
      print("logout failed");
    }
  }

  Future<dynamic> loginwithGoogle() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    GoogleSignIn googleSignIn = GoogleSignIn();
    try
    {
      GoogleSignInAccount account = await googleSignIn.signIn();
      if (account == null) {
        return false;
      }
      UserCredential res = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
              idToken: (await account.authentication).idToken,
              accessToken: (await account.authentication).accessToken));
      if (res.user == null) {
        return false;
      } else {
        final result = (await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: res.user.uid).get()).docs;

        if(result.length == 0){
          //new user
          FirebaseFirestore.instance.collection('users').doc(res.user.uid).set({
            "id" : res.user.uid,
            "name" : res.user.displayName,
            "profile_pic" : res.user.photoURL,
            "created_at" : DateTime.now().microsecondsSinceEpoch,
          });

          sharedPreferences.setString("id", res.user.uid);
          sharedPreferences.setString("name", res.user.displayName);
          sharedPreferences.setString("profile_pic", res.user.photoURL);

        }else{
          //old user
          sharedPreferences.setString("id", result[0].get("id"));
          sharedPreferences.setString("name", result[0].get("name"));
          sharedPreferences.setString("profile_pic", result[0].get("profile_pic"));
        }
        return true;
      }
    }
    catch(e){
      print("login failed");
    }
  }
}
