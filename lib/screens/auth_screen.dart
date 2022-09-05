import 'package:chatapp/main.dart';
import 'package:chatapp/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});


  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future signInFunction()async{
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if(googleUser == null){
      return;
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken
    );
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    DocumentSnapshot userExist = await firestore.collection('users').doc(userCredential.user!.uid).get();

    if(userExist.exists){
      if (kDebugMode) {
        print("User Already Exists in Database");
      }
    }else{
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'email':userCredential.user!.email,
        'name':userCredential.user!.displayName,
        'image':userCredential.user!.photoURL,
        'uid':userCredential.user!.uid,
        'date':DateTime.now(),
      });
    }

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>MyApp()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage("https://cdn.iconscout.com/icon/free/png-256/chat-2639493-2187526.png")
                    )
                ),
              ),
            ),
            const Text("Chat App",style: TextStyle(fontSize: 36,fontWeight: FontWeight.bold, color: Colors.white),),
            Container(
              width: 280,
              height: 90,
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              child: ElevatedButton(
                onPressed: ()async{
                      await signInFunction();
                },
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: const BorderSide(color: Colors.red)
                      )
                    )
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(child: Image.network('https://www.freepnglogos.com/uploads/google-logo-png/google-logo-png-webinar-optimizing-for-success-google-business-webinar-13.png',height: 36,),backgroundColor: Colors.grey[900]),
                      const SizedBox(width: 10,),
                      const Text("Sign in With Google",style: TextStyle(fontSize: 20),)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}