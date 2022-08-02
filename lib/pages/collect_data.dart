import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
  late DatabaseReference databaseReference;

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
                  color: Colors.indigoAccent,
                  image: DecorationImage(
                      image: FileImage(imageFileFace!), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(12.0),
                ))
          else
            Container(
              width: 200,
              height: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),SizedBox(
                    height: 30,
                  ),
          ElevatedButton(
            onPressed: () async {
              getImageFace(source: ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              elevation: 12.0,
              primary: Colors.black, // background
              onPrimary: Colors.white, // foreground

              textStyle: const TextStyle(color: Colors.white),
            ),
            child: const Text('Upload Face'),
          ),
          if (imageFileID != null)
            Container(
                width: 250,
                height: 300,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.indigoAccent,
                  image: DecorationImage(
                      image: FileImage(imageFileID!), fit: BoxFit.cover),

                  borderRadius: BorderRadius.circular(12.0),
                ))
          else
            Container(
              width: 200,
              height: 250,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.indigoAccent,
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () async {
              getImageID(source: ImageSource.camera);
            },
            style: ElevatedButton.styleFrom(
              elevation: 12.0,
              primary: Colors.black, // background
              onPrimary: Colors.white, // foreground

              textStyle: const TextStyle(color: Colors.white),
            ),
            child: const Text('Upload ID'),
          ),
          SizedBox(
            height: 30,
          ),
          ElevatedButton(
            onPressed: () async {
              _uploadImageID();
              _uploadImageFace();
            },
            style: ElevatedButton.styleFrom(
              elevation: 12.0,
              primary: Colors.black, // background
              onPrimary: Colors.white, // foreground

              textStyle: const TextStyle(color: Colors.white),
            ),
            child: const Text('Send to verify'),
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
                backgroundColor: Colors.indigoAccent,
              ),
              SizedBox(width: 10),
              FloatingActionButton(
                onPressed: () async {
                  getImageID(source: ImageSource.camera);
                },
                backgroundColor: Colors.indigoAccent,
                child: Icon(Icons.add_card),
              ),
              Expanded(child: Container()),
              FloatingActionButton(
                onPressed: () async {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Homepage()));
                },
                child: Icon(Icons.arrow_back),
                backgroundColor: Colors.indigoAccent,
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

    uploadTask.snapshotEvents.listen((event) {});
    await uploadTask.whenComplete(() async {
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

  Future<String?> shortenUrl({required String url}) async {
    try {
      final result = await http.post(
          Uri.parse('https://cleanuri.com/api/v1/shorten'),
          body: {'url': url});

      if (result.statusCode == 200) {
        final jsonResult = jsonDecode(result.body);
        return jsonResult['result_url'];
      }
    } catch (e) {
      print('Error ${e.toString()}');
    }
    return null;
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
    await uploadTask.whenComplete(() async {
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
