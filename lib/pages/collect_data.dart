import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:id_me/pages/home_page.dart';
import 'package:image_picker/image_picker.dart';

class Collectdata extends StatefulWidget {
  const Collectdata({Key? key}) : super(key: key);

  @override
  State<Collectdata> createState() => _CollectdataState();
}

class _CollectdataState extends State<Collectdata> {
  File? imageFileFace;
  File? imageFileID;
  String? idlink;
  String? facelink;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String folderFace = "Face";
  String folderID = "ID";
   FirebaseDatabase Database = FirebaseDatabase.instance;
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
  late DatabaseReference databaseReference ;

  //

  //   });
  // }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: Column(children: [
          SizedBox(
            height: 100,
          ),
          if (imageFileFace != null)
            Container(
                width: 250,
                height: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                      image: FileImage(imageFileFace!), fit: BoxFit.cover),
                  border: Border.all(width: 8, color: Colors.black),
                  borderRadius: BorderRadius.circular(12.0),
                ))
          else
            Container(
              width: 200,
              height: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border.all(width: 8, color: Colors.black12),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          TextButton(
            onPressed: () async {
              getImageFace(source: ImageSource.camera);
            },
            child: Text("Upload Face", style: TextStyle(fontSize: 20)),
          ),
          if (imageFileID != null)
            Container(
                width: 250,
                height: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  image: DecorationImage(
                      image: FileImage(imageFileID!), fit: BoxFit.cover),
                  border: Border.all(width: 8, color: Colors.black),
                  borderRadius: BorderRadius.circular(12.0),
                ))
          else
            Container(
              width: 200,
              height: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue,
                border: Border.all(width: 8, color: Colors.black12),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          TextButton(
            onPressed: () async {
              getImageID(source: ImageSource.camera);
            },
            child: Text("Upload ID", style: TextStyle(fontSize: 20)),
          ),
          SizedBox(
            height: 30,
          ),
          TextButton(
            onPressed: () async {
              _uploadImageFace();
              _uploadImageID();

            },
            child: Text("SEND TO VERIFY", style: TextStyle(fontSize: 20)),
          ),
        ]))),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              FloatingActionButton(
                onPressed: () async {
                  getImageFace(source: ImageSource.camera);
                },
                child: Icon(Icons.face_rounded),
              ),
              SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () async {
                  getImageID(source: ImageSource.camera);
                },
                child: Icon(Icons.add_card),
              ),
              Expanded(child: Container()),
              FloatingActionButton(
                onPressed: () async {},
                child: Icon(Icons.arrow_back),
              ),
            ])));
  }

  void getImageFace({required ImageSource source}) async {
    final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 480,
        imageQuality: 70 //0 - 100
        );

    if (file?.path != null) {
      setState(() {
        imageFileFace = File(file!.path);
      });
    }
  }

  _uploadImageFace() async {

    var key = firestoreRef.collection(folderFace);
    String uploadFaceName =
        DateTime.now().millisecondsSinceEpoch.toString() + "jpg";
    Reference reference =
        firebaseStorageRef.ref().child(folderFace).child(uploadFaceName);
    UploadTask uploadTask = reference.putFile(File(imageFileFace!.path));

    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() +
          " " +
          event.totalBytes.toString());
    });
    await uploadTask.whenComplete(() async{
      var uploadlink = await uploadTask.snapshot.ref.getDownloadURL();

      facelink = uploadlink;
      final User? user = auth.currentUser;
      final uid = user!.uid;
      final reflinks = Database.ref().child(uid).child("Face");
      var snapshot = await reflinks.get();
      var prev = snapshot.value;
      print(prev);
      await reflinks.set(prev.toString() + ", " + facelink.toString());

      await reflinks.set(facelink);
    });
  }
  _uploadImageID() async {
    var key = firestoreRef.collection(folderID);
    String uploadFaceID =
        DateTime.now().millisecondsSinceEpoch.toString() + "jpg";
    Reference reference =
    firebaseStorageRef.ref().child(folderID).child(uploadFaceID);
    UploadTask uploadTask = reference.putFile(File(imageFileFace!.path));

    uploadTask.snapshotEvents.listen((event) {
      print(event.bytesTransferred.toString() +
          " " +
          event.totalBytes.toString());
    });
    await uploadTask.whenComplete(() async{
      var uploadlink = await uploadTask.snapshot.ref.getDownloadURL();

      idlink = uploadlink;

    });
    final User? user = auth.currentUser;
    final uid = user!.uid;
    final reflinks = Database.ref().child(uid).child("ID");
    final statuslinks = Database.ref().child(uid).child("Status");
    var snapshot = await reflinks.get();
    var prev = snapshot.value;
    print(prev);
    await reflinks.set(prev.toString() + ", " + idlink.toString());
    await statuslinks.set("Unapproved");

  }

  void getImageID({required ImageSource source}) async {
    final file = await ImagePicker().pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 480,
        imageQuality: 70 //0 - 100
        );

    if (file?.path != null) {
      setState(() {
        imageFileID = File(file!.path);
      });
    }
  }
}
