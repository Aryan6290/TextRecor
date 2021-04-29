import 'dart:io';

import 'package:clipboard/clipboard.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  BuildContext _buildContext;
  String text = "Scan to see the text";
  PickedFile _image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      } else {
        print("no image was selected");
      }
    });
  }

  Future scanImage() async {
    print("working");
    showDialog(
      context: context,
      builder: (context) => Center(
          child: SizedBox(
              width: 30, height: 30, child: CircularProgressIndicator())),
    );
    String result = "";
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(File(_image.path));
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        result += line.text + '\n';
      }
    }
    Navigator.of(context).pop();
    setState(() {
      text = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text("Text Recognition"),
          actions: [
            TextButton(
              onPressed: scanImage,
              child: Text(
                "Scan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
                decoration: BoxDecoration(),
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                width: double.infinity,
                height: 350,
                child: _image != null
                    ? Image.file(
                        File(_image.path),
                        fit: BoxFit.contain,
                      )
                    : Container(
                        child: Icon(Icons.image),
                      )),
            Flexible(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent)),
                      padding: EdgeInsets.all(20),
                      margin:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      width: double.infinity,
                      child: SingleChildScrollView(child: Text(text)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.0),
                    child: IconButton(
                      onPressed: () {
                        FlutterClipboard.copy(text).then((value) =>
                            _key.currentState.showSnackBar(
                                new SnackBar(content: Text('Copied'))));
                      },
                      icon: Icon(
                        Icons.copy,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: getImage,
          child: Icon(Icons.add_a_photo),
        ));
  }
}
