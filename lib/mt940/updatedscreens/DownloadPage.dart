import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mt940/services/upload_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'MainPage.dart';

class DownloadPage extends StatefulWidget {
  final TargetPlatform? platform;

  DownloadPage({Key? key, this.platform}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool get wantKeepAlive => true;
  bool isloading = false;
  File? file;
  String? selectedValue;
  List<String> items = [
    'Pdf',
    'Excell',
  ];
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
        actions: [
          TextButton(
            onPressed: () {
              // Route route =
              //     MaterialPageRoute(builder: (C) => AdminLoginScreen());
              // Navigator.pushReplacement(context, route);
            },
            child: const Text(
              "Please Select Your Format and Download",
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
                Icons.download,
                color: Colors.white,
                size: 100,
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  isExpanded: true,
                  hint: Row(
                    children: const [
                      Icon(
                        Icons.list,
                        size: 16,
                        color: Colors.yellow,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Text(
                          'Select Format to Download',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value as String;
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_forward_ios_outlined,
                  ),
                  iconSize: 14,
                  iconEnabledColor: Colors.yellow,
                  iconDisabledColor: Colors.grey,
                  buttonHeight: 50,
                  buttonWidth: 160,
                  buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                  buttonDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black26,
                    ),
                    color: Colors.redAccent,
                  ),
                  buttonElevation: 2,
                  itemHeight: 40,
                  itemPadding: const EdgeInsets.only(left: 14, right: 14),
                  dropdownMaxHeight: 200,
                  dropdownWidth: 200,
                  dropdownPadding: null,
                  dropdownDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.redAccent,
                  ),
                  dropdownElevation: 8,
                  scrollbarRadius: const Radius.circular(40),
                  scrollbarThickness: 6,
                  scrollbarAlwaysShow: true,
                  offset: const Offset(-20, 0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: TextButton(
                    onPressed: () async {
                      await loadtoDisk();
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
                    },
                    child: isloading
                        ? Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Text("Converting Please Wait...."),
                                CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          )
                        : const Text(
                            "Download",
                            style: TextStyle(fontSize: 20, color: Colors.white),
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

  Future loadtoDisk() async {
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
