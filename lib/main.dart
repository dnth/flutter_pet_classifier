import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
      title: 'Pet Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Pet Classifier'),
      debugShowCheckedModeBanner: false,
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
  String? _resultString;
  File? imageURI;
  Uint8List? imgBytes;
  bool isClassifying = false;

  String parseResults(Map results) {
    return """
    ${results['confidences'][0]['label']} - ${(results['confidences'][0]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][1]['label']} - ${(results['confidences'][1]['confidence'] * 100.0).toStringAsFixed(2)}% \n
    ${results['confidences'][2]['label']} - ${(results['confidences'][2]['confidence'] * 100.0).toStringAsFixed(2)}% """;
  }

  Future<File> cropImage(XFile pickedFile) async {
    // Crop image here
    final File? croppedFile = await ImageCropper.cropImage(
      sourcePath: pickedFile.path,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        // CropAspectRatioPreset.ratio3x2,
        // CropAspectRatioPreset.original,
        // CropAspectRatioPreset.ratio4x3,
        // CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: const IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );

    return croppedFile!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              imageURI == null
                  ? const Text(
                      'Select an image by pressing the camera icon and I will tell you my',
                      textAlign: TextAlign.center,
                    )
                  : Image.file(imageURI!, height: 300, fit: BoxFit.cover),
              const SizedBox(
                height: 10,
              ),
              Text("Top 3 predictions",
                  style: Theme.of(context).textTheme.headline6),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _resultString ?? "",
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isClassifying || imageURI == null
                          ? null // null disables the button
                          : () async {
                              setState(() {
                                isClassifying = true;
                              });

                              imgBytes = imageURI!.readAsBytesSync();
                              String base64Image = "data:image/png;base64," +
                                  base64Encode(imgBytes!);
                              final result =
                                  await classifyPetImage(base64Image);
                              // print(result['confidences']);
                              // print(result['label']);

                              setState(() {
                                _resultString = parseResults(result);
                                // _resultString =
                                //     result['confidences'][0]['label'];
                                isClassifying = false;
                              });
                            },
                      child: isClassifying
                          ? const Text("Loading..")
                          : const Text("Classify!"),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              //to set border radius to button
                              borderRadius: BorderRadius.circular(30))),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return Container(
                    height: 130,
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera),
                          title: const Text("Camera"),
                          onTap: () async {
                            final XFile? pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.camera);

                            if (pickedFile != null) {
                              // Clear result of previous inference as soon as new image is selected
                              setState(() {
                                _resultString = "";
                              });

                              File croppedFile = await cropImage(pickedFile);
                              final imgFile = File(croppedFile.path);

                              setState(() {
                                imageURI = imgFile;
                              });
                              Navigator.pop(context);
                            }
                            // if (pickedFile == null) {
                            //   // print('no file selected');
                            //   return;
                            // } else {
                            //   // Clear result of previous inference as soon as new image is selected
                            //   setState(() {
                            //     _resultString = "";
                            //   });

                            //   File croppedFile = await cropImage(pickedFile);
                            //   final imgFile = File(croppedFile.path);

                            //   setState(() {
                            //     imageURI = imgFile;
                            //   });
                            //   Navigator.pop(context);
                            // }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text("Gallery"),
                          onTap: () async {
                            final XFile? pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            if (pickedFile != null) {
                              // Clear result of previous inference as soon as new image is selected
                              setState(() {
                                _resultString = "";
                              });

                              File croppedFile = await cropImage(pickedFile);
                              final imgFile = File(croppedFile.path);

                              setState(() {
                                imageURI = imgFile;
                              });
                              Navigator.pop(context);
                            }

                            // if (pickedFile == null) {
                            //   print('no file selected');
                            //   return null;
                            // } else {
                            //   // Clear result of previous inference as soon as new image is selected
                            //   setState(() {
                            //     _resultString = "";
                            //   });

                            //   File croppedFile = await cropImage(pickedFile);
                            //   final imgFile = File(croppedFile.path);

                            //   setState(() {
                            //     imageURI = imgFile;
                            //   });
                            //   Navigator.pop(context);
                            // }
                          },
                        )
                      ],
                    ));
              });
        },
        child: const Icon(Icons.camera),
      ),
    );
  }
}
