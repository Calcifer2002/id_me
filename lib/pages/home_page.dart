import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:id_me/main.dart';
import 'package:id_me/pages/login_page.dart';

class Homepage extends StatefulWidget {


  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Idkman"),
      ),floatingActionButton: FloatingActionButton(
      onPressed: () async{
await _auth.signOut();
Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      },
      child: Icon(Icons.logout),
    ),
    );
  }
}
