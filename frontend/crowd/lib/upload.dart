import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'global.dart';


class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? image;
  final _picker = ImagePicker();
  bool showSpinner = false;
  bool fileNotUploaded = true;
  String successMessage = "";
  MaterialAccentColor successColor = Colors.lightGreenAccent;
  Icon successIcon = Icon(Icons.meeting_room_outlined);

  SnackBar showException(String firstMessage, String message, final bgColor, int d){
    final SnackBar snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 0.0),
        height: 90.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(18.0)),
          color: bgColor,
        ),
        child: Column(
            children: [
              Text(
                firstMessage.toString(),
                style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Text(
                message.toString(),
                style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ]
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      duration: Duration(seconds: d),
    );
    return snackBar;
  }

  Future updateModal()async{
    setState(() {
      fileNotUploaded = true;
      successMessage = "Cross Pressed";
    });
  }

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
    try {
      var stream = http.ByteStream(image!.openRead());
      stream.cast();
      var length = await image!.length();
      print(length);
      var fileName = basename(image!.path);
      print(fileName.toLowerCase());

      if(fileName.toLowerCase().contains("jpg") || fileName.toLowerCase().contains("jpeg")){
        // Sending Request
        var headers = {
          'content-Disposition': 'attachment; filename="image.jpg"',
          'Content-Type': 'multipart/form-data'
        };
        var request = http.MultipartRequest(
            'POST', Uri.parse('https://cf47-122-161-76-158.in.ngrok.io/upload/'));
        request.files.add(await http.MultipartFile('file', stream, length,
            filename: basename(image!.path)));
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 202) {
          print("Image Uploaded successfully");
          Map<String,dynamic> data = jsonDecode(await response.stream.bytesToString());
          print(data);
          if(data['availablity'] == 'Green'){
            successMessage = "Not Crowded !!";
            successColor = Colors.greenAccent;
            successIcon = Icon(Icons.meeting_room_outlined);
          }else if(data['availablity'] == 'Yellow'){
            successMessage = "Ah ! Light Crowded !!";
            successColor = Colors.yellowAccent;
            successIcon = Icon(Icons.meeting_room_rounded);
          }else if(data['availablity'] == 'Blue'){
            successMessage = "Seems like Crowd is there !";
            successColor = Colors.redAccent;
            successIcon = Icon(Icons.no_meeting_room_outlined);
          }else{
            successMessage = "Too Much Crowded !!";
            successColor = Colors.redAccent;
            successIcon = Icon(Icons.no_meeting_room);
          }
          fileNotUploaded = false;

          SnackBar snackBar = showException("Hurrah !!", "File Uploaded Successfully", Colors.green[900], 1);
          snackbarKey.currentState?.showSnackBar(snackBar);
        }
        else {
          print("Image Upload Failed");
          print(response.reasonPhrase);
          SnackBar snackBar = showException("Oh Snaps !!", response.reasonPhrase.toString(), Colors.deepOrangeAccent, 2);
          snackbarKey.currentState?.showSnackBar(snackBar);
        }
      }
      else{
        throw Exception("Wrong file format");
      }

    }on Exception catch (exception) {
      print("Exception Happened");
      print(exception.toString());
      SnackBar snackBar = showException("Oh Snaps !!", exception.toString(), Colors.redAccent, 2);
      snackbarKey.currentState?.showSnackBar(snackBar);
    } catch (e) {
      print("error happened");
      print(e);
      SnackBar snackBar = showException("Error !!", e.toString(), Colors.redAccent, 2);
      snackbarKey.currentState?.showSnackBar(snackBar);
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
          title: const Text("Metro Crowd Detection"),
          centerTitle: true,
          backgroundColor: Colors.grey[850],
          elevation: 0.0,
        ),

        body: Column(

          children: [
            const Expanded(
              flex: 1,
              child: SizedBox(
                height: 20.0,
              ),
            ),
            Expanded(
              flex: 1,
              child: fileNotUploaded ? Container() : Container(
                padding: const EdgeInsets.all(20.0),
                height: 100.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(18.0)),
                  color: successColor,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          color: Colors.grey[900],
                        ),
                        const SizedBox(
                          width: 30.0,
                        ),
                        Text(
                          successMessage.toString(),
                        )
                      ],
                    ),
                    Positioned.fill(
                      top: -40,
                      right: -20,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          child: IconButton(
                            constraints: BoxConstraints(
                              minHeight: 100,
                            ),
                            iconSize: 20,
                            icon: const Icon(
                              Icons.close_rounded,
                            ),
                            color: Colors.grey[900],
                            onPressed: () {
                              updateModal();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
                flex: 1,
                child: SizedBox(
                  height: 20.0,
                ),
            ),
            Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
          )],
        ),
      ),
    );
  }
}
