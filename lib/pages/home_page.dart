import 'dart:io';
import 'dart:math';
import 'package:image_grid/image_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:id_me/main.dart';
import 'package:id_me/pages/collect_data.dart';
import 'package:id_me/pages/login_page.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final Dio dio = Dio();
  late String imagePath;
  List<String> idslist = [];
  bool loading = false;
  double progress = 0;
  final _auth = FirebaseAuth.instance;
  FirebaseDatabase Database = FirebaseDatabase.instance;
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage firebaseStorageRef = FirebaseStorage.instance;
  late DatabaseReference databaseReference;
  @override
  initState() {
    // this is called when the class is initialized or called for the first time
    super.initState();
    downloadFile();
    print(
        idslist); //  this is the material super constructor for init state to link your instance initState to the global initState context
  }

  Future<bool> saveImage(String url, String fileName) async {
    Directory directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = (await getExternalStorageDirectory()) as Directory;
          String newPath = "";
          print(directory);
          List<String> paths = directory.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/Verif-ID";
          imagePath = newPath;
          directory = Directory(newPath);
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }
      File saveFile = File(directory.path + "/$fileName");
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        await dio.download(url, saveFile.path,
            onReceiveProgress: (value1, value2) {
          setState(() {
            progress = value1 / value2;
          });
        });
        if (Platform.isIOS) {
          await ImageGallerySaver.saveFile(saveFile.path,
              isReturnPathOfIOS: true);
        }
        return true;
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<File> get localfile async {
    final path = imagePath;
    return File(path);
  }

  Future<String> readData() async {
    try {
      final file = await localfile;
      String image_path = await file.readAsString();
      print(image_path);
      return image_path;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  downloadFile() async {
    final User? user = _auth.currentUser;
    final uid = user!.uid;
    final reflinks = Database.ref().child(uid).child("Status");
    final idlinks = Database.ref().child(uid).child("ID");
    var idsnapshots = await idlinks.get();
    var snapshot = await reflinks.get();
    var prev = snapshot.value;
    var ids = idsnapshots.value;
    idslist = ids.toString().split(", ");

    var ran = Random();
    for (int i = 0; i < idslist.length; i++) {
      await saveImage(idslist[i], (ran.nextInt(10000)).toString() + ".jpg");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      itemBuilder: (BuildContext ctx, int index) {
        return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: <Widget>[
              Image.network(idslist[index]),
            ]));

      },
      itemCount: idslist.length,
    ), floatingActionButton:
    Padding(
        padding: const EdgeInsets.only(left: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => Collectdata()));
              },
              child: Icon(Icons.add),backgroundColor: Colors.indigoAccent,
            ),

            Expanded(child: Container()),
            FloatingActionButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: Icon(Icons.logout),
              backgroundColor: Colors.indigoAccent,
            )
          ],
        ))  );
  }
}
