import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mt940/mt940/Functions/Firebasefunc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'MainPage.dart';

class Uploadpage extends StatefulWidget {
  Uploadpage({Key? key}) : super(key: key);

  @override
  _UploadpageState createState() => _UploadpageState();
}

class _UploadpageState extends State<Uploadpage> {
  bool get wantKeepAlive => true;
  bool isloading = false;
  File? file;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return //file == null
        //  ?
        displayAdminHomeScreen();

    //  : displayAdminUploadFormScreen();
  }

  displayAdminHomeScreen() {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.pink, Colors.lightGreenAccent],
              begin: FractionalOffset(0, 0),
              end: FractionalOffset(1, 0),
              stops: [0, 1],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        leading: IconButton(
            onPressed: () {
              // Route route = MaterialPageRoute(builder: (c) => Home());
              // Navigator.pushReplacement(context, route);
            },
            icon: const Icon(
              Icons.border_color,
              color: Colors.white,
            )),
        actions: [
          TextButton(
            onPressed: () {
              // Route route =
              //     MaterialPageRoute(builder: (C) => AdminLoginScreen());
              // Navigator.pushReplacement(context, route);
            },
            child: const Text(
              "Upload your MT940 File to View",
              style: TextStyle(
                  color: Colors.pink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: getAdminHomeScreenBody(),
    );
  }

  getAdminHomeScreenBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink, Colors.lightGreenAccent],
          begin: FractionalOffset(0, 0),
          end: FractionalOffset(1, 0),
          stops: [0, 1],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.document_scanner_outlined,
                color: Colors.white,
                size: 200,
              ),
              file != null
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          file!.path.toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: TextButton(
                    onPressed: () async {
                      await loadfromDisk();
                      if (file != null) {
                        setState(() {
                          isloading = true;
                        });
                        var result =
                            await Mt940FirebaseFunc().uploadandSaveimage(file);
                        setState(() {
                          isloading = false;
                          textuploadeddownloadurl = result;
                          file = null;
                        });
                        Route route =
                            MaterialPageRoute(builder: (context) => MainPage());
                        Navigator.push(context, route);
                      }

                      // takeImage(context);
                      // Route route = MaterialPageRoute(
                      //     builder: (context) => const Addnewproductpage());
                      // Navigator.push(context, route);
                    },
                    child: isloading
                        ? Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text("Converting Please Wait...."),
                                const CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          )
                        : const Text(
                            "Load File From Device",
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 20),
              //   child: Container(
              //     decoration: const BoxDecoration(
              //         color: Colors.green,
              //         borderRadius: BorderRadius.all(Radius.circular(30))),
              //     child: TextButton(
              //       onPressed: () {
              //         // Route route = MaterialPageRoute(
              //         //     builder: (context) => const OtherHome());
              //         // Navigator.push(context, route);
              //       },
              //       child: const Text(
              //         "Proceed To Customization",
              //         style: TextStyle(fontSize: 20, color: Colors.white),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  takeImage(context) {
    showDialog(
        context: context,
        builder: (con) {
          return const SimpleDialog(
            title: Text(
              "Item Image",
              style: TextStyle(
                color: Colors.green,
              ),
            ),
          );
        });
  }

  Future requestPermisssion() async {
    var storagestatus = await Permission.storage.status;
    var externalstorage = await Permission.manageExternalStorage.status;

    if (storagestatus.isDenied || externalstorage.isDenied) {
      await Permission.storage.request().then((value) async {
        if (value.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      });
      // await Permission.sms.request();
    }
  }

  Future loadfromDisk() async {
    await requestPermisssion();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result != null) {
      File givenfile = File(result.files.single.path!);
      setState(() {
        file = givenfile;
      });
    } else {
      Fluttertoast.showToast(msg: "Please Pick Again");
    }
  }
}

String textuploadeddownloadurl = "";
