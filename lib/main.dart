import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pets_services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String _imageClass = "Unknown";
  File? imageURI;

  @override
  Widget build(BuildContext context) {
    String? imagePath;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageURI == null
                ? Text('No image selected.')
                : Image.file(imageURI!,
                    width: 300, height: 200, fit: BoxFit.cover),
            Text(
              _imageClass,
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final XFile? pickedFile =
              await ImagePicker().pickImage(source: ImageSource.camera);

          if (pickedFile == null) {
            print('no file selected');
            return null;
          } else {
            final imgFile = File(pickedFile.path);

            setState(() {
              imageURI = imgFile;
            });

            final imgBytes = imgFile.readAsBytesSync();
            String base64Image =
                "data:image/png;base64," + base64Encode(imgBytes);

            final result = await classifyPetImage(base64Image);
            print(result['confidences']);
            print(result['label']);

            setState(() {
              _imageClass = result['label'];
            });
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
