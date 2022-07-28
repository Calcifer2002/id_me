import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final Directory _photoDir = new Directory(
    '/storage/emulated/0/Android/data/com.eclixtech.doc_scanner/files/CroppedImages');


class ImageCapture extends StatefulWidget {
  @override
  _ImageCaptureState createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doc Scanner'),
      ),
      body: Container(
        child: FutureBuilder(
          builder: (context, status) {
            return ImageGrid(directory: _photoDir, key: key,);
          },
        ),
      ),
    );
  }
}
class ImageGrid extends StatelessWidget {
  final Directory directory;

  const ImageGrid({required Key key, required this.directory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var refreshGridView;
    var imageList = directory
        .listSync()
        .map((item) => item.path)
        .where((item) => item.endsWith(".jpg"))
        .toList(growable: false);
    return GridView.builder(
      itemCount: imageList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 3.0 / 4.6),
      itemBuilder: (context, index) {
        File file = new File(imageList[index]);
        String name = file.path.split('/').last;

                    Navigator.push(context, MaterialPageRoute(builder: (context) {

              ),
            ),
          ),
        );
      },
    );
  }
}}
}
