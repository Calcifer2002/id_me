import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:id_me/main.dart';
import 'package:id_me/pages/collect_data.dart';
import 'package:id_me/pages/login_page.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _auth = FirebaseAuth.instance;
  FirebaseDatabase Database = FirebaseDatabase.instance;
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
  late DatabaseReference databaseReference;
  _checkVerify() async {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    final reflinks = Database.ref().child(uid).child("Status");
    var snapshot = await reflinks.get();
    var prev = snapshot.value;
    print(prev);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Text("Idkman"),

        ),
        floatingActionButton: Padding(padding: const EdgeInsets.only(left: 30),
            child:Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [ FloatingActionButton(
                onPressed: () async {  Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Collectdata()));},
          child: Icon(Icons.add),
        ),  FloatingActionButton(onPressed: () async{
          _checkVerify();

                }),
    Expanded(child: Container()),
          FloatingActionButton(
            onPressed: () async {

              await _auth.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            },
            child: Icon(Icons.logout),
          ),


        ])));
  }
}
