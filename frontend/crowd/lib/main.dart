import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<Home> {
  File? image;
  final _picker = ImagePicker();
  bool showSpinner = false;

  Future getImage()async{
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile != null){
      image = File(pickedFile.path);
      setState(() {

      });
    }else{
      print("Image didn't uploaded properly");
    }
  }

  Future<void> uploadImage()async{
    setState(() {
      showSpinner = true;
    });
    var stream = http.ByteStream(image!.openRead());
    stream.cast();
    var length = await image!.length();
    print(length);

    // Sending Request
    var headers = {
      'content-Disposition': 'attachment; filename="image.jpg"',
      'Content-Type': 'multipart/form-data'
    };
    var request = http.MultipartRequest('POST', Uri.parse('http://192.168.1.7:8000/upload/'));
    request.files.add(await http.MultipartFile('file', stream, length,
        filename: basename(image!.path)));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 202) {
      print("Image Uploaded successfully");
      print(await response.stream.bytesToString());
    }
    else {
      print("Image Upload Failed");
      print(response.reasonPhrase);
    }

    setState(() {
      showSpinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text("Crowd Detection App"),
          centerTitle: true,
          backgroundColor: Colors.grey[850],
          elevation: 0.0,
        ),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (){
                getImage();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library,
                    color: Colors.white70,
                  ),
                  const SizedBox(
                    width: 20.0,
                  ),
                  Container(
                    child: image == null ? const Center(
                      child: Text(
                        "Pick an image",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ) : Center(
                      child: Image.file(
                        File(image!.path).absolute,
                        height: 200.0,
                        width: 200.0,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: (){
                uploadImage();
                },
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(color: Colors.red)
                      )
                  )
              ),
              child: Text(
                  "Upload".toUpperCase(),
                  style: const TextStyle(fontSize: 14)
              ),
            ),

          ],
        ),
      ),
    );
  }
}
