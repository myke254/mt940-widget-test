
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDialog extends StatefulWidget {
  const MyDialog(
      {Key? key,
        required this.downloadUrl,
        required this.file,
        required this.selectedFields,
        required this.fileUrl,
        required this.singleDate,
        required this.firstDate,
        required this.lastDate,
        required this.openingBalance,
        required this.closingBalance,
        required this.closingAvailableBalance,
        required this.name,
        required this.credit,
        required this.debit,
        required this.range})
      : super(key: key);
  final String downloadUrl;
  final File file;
  final List selectedFields;
  final String fileUrl;
  final bool singleDate;
  final String firstDate;
  final String lastDate;
  final bool openingBalance;
  final bool closingBalance;
  final bool closingAvailableBalance;
  final String name;
  final bool credit;
  final bool debit;
  final bool range;

  @override
  State<MyDialog> createState() => _MyDialogState();
}
String fileName="";
class _MyDialogState extends State<MyDialog> {
  Map<String, dynamic> data = {};
  String type = 'all';
  String get = "all";
  String path = '';
  double? filSize;
  double? rcvd;
  Dio dio = Dio();

  Future<Map<String, dynamic>> converter(format) async {
    var url = Uri.parse(widget.fileUrl);

//var testurl = Uri.parse("https://firebasestorage.googleapis.com/v0/b/jazia-51e09.appspot.com/o/mt940%2Ftvgh.txt?alt=media&token=98471a5c-8a2e-4c9a-b44d-d1af4b6fe9e7");

var postData = {
      "url": url.toString(),
      "sender": widget.name+DateTime.now().toString().split(" ").last.split('.').last,
      "fields": widget.selectedFields,
      "date": widget.singleDate ? widget.firstDate : "",
      "format": format,
      "type": type,
      "openingbalance": widget.openingBalance,
      "closingbalance": widget.closingBalance,
      "closingAvailableBalance": widget.closingAvailableBalance,
      "get": get,
      "range": widget.range
          ? !widget.singleDate
          ? {"start": widget.firstDate, "end": widget.lastDate}
          : {"start": "", "end": ""}
          : {"start": "", "end": ""}
    };
    if (kDebugMode) {
      print(postData);
    }
    if (kDebugMode) {
      print(jsonEncode(postData));
    }
   try {
      final response = await dio.post(
          "https://mt940-test.azurewebsites.net/mt940",
          data: jsonEncode(postData));
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          loading = false;
          data = response.data;
          fileName = data['url'].toString().split('/').last;
        });

        if (kDebugMode) {
          print(response.data);
        }
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: 'an error occurred');
      }
    }on DioError catch(error){
      print(error.message);

     Navigator.of(context).pop();
    showDialog(
    context: context,
    builder: (context) {
    return CupertinoAlertDialog(
    content:  Text(error.response!.statusCode == 403?
    "you provided an invalid mt940 format please try again with another file":"something went wrong"),
    actions: [
    TextButton(
    onPressed: () => Navigator.of(context).pop(),
    child: const Text('exit'))
    ],
    );
    });

    }



    return data;
  }



  checkType() {
    setState(() {
      if ((widget.credit && widget.debit)||(!widget.credit && !widget.debit)) {
        type = "all";
      } else if (widget.credit && !widget.debit) {
        type = "Cr";
      } else {
        type = "Dr";
      }
    });
  }

  checkGet() {
    setState(() {
      if (widget.singleDate && !widget.range) {
        get = 'date';
      } else if (!widget.singleDate && widget.range) {
        get = "range";
      } else {
        get = "all";
      }
    });
  }
  Future<void> openFile() async {
    await OpenFile.open(path).then((value) {
      if (kDebugMode) {
        print(value.message);
      }
    });
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

  bool loading = false;
  double progress = 0;
  late SharedPreferences preferences;
  Future<bool> saveFile(String url, String fileName) async {
    preferences = await SharedPreferences.getInstance();
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.manageExternalStorage)||await _requestPermission(Permission.storage)) {
          directory = await getExternalStorageDirectory();
          String newPath = "";
          if (kDebugMode) {
            print(directory);
          }
          List<String> paths = directory!.path.split("/");
          for (int x = 1; x < paths.length; x++) {
            String folder = paths[x];
            if (folder != "Android") {
              newPath += "/" + folder;
            } else {
              break;
            }
          }
          newPath = newPath + "/mt940s";
          directory = Directory(newPath);

          preferences.setString('directory', newPath);
          if (kDebugMode) {
            print(preferences.getString('directory'));
          }
        } else {
          return false;
        }
      } else {
        if (await _requestPermission(Permission.manageExternalStorage)) {
          directory = await getTemporaryDirectory();
        } else {
          return false;
        }
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        await dio.download(url, saveFile.path,
            options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),
            onReceiveProgress: (value1, value2) {

              setState(() {
                path = saveFile.path;
                progress = ((value1 / value2)*100);
              });
              if (kDebugMode) {
                print(value2);
              }
            });
        // if (Platform.isIOS) {
        //   await ImageGallerySaver.saveFile(saveFile.path,
        //       isReturnPathOfIOS: true);
        // }
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }


  @override
  void initState() {
    checkGet();
    checkType();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      content:loading?const Center(child: CupertinoActivityIndicator(),): Column(
        children: data.isEmpty
            ?  [
          Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                Text(widget.file.path.toString().split('/').last),
              )),
          const Text('choose which format you want to receive your file')
        ]
            : [
          const Text('Here is your file'),
          Text(
              fileName
            // data['url'].toString().split('/').last
          ),
        ],
      ),
      actions: data.isEmpty
          ? loading?[

      ]:[
        TextButton(
            onPressed: () {
              converter('pdf');
              setState(() {
                loading = true;
              });
            },
            child: const Text('Pdf')),
        TextButton(
            onPressed: () {
              converter('excel');
              setState(() {
                loading = true;
              });
            },
            child: const Text('Excel'))
      ]
          : [
        path.isEmpty
            ?TextButton(
            onPressed: () {
              saveFile(data['url'],fileName);
              //downloadFile(data['url'],fileName);
              // download(data['url'],
              //     data['url'].toString().split('/').last);
            },
            child: const Text('download now'))
            : TextButton(
            onPressed: () {
              openFile().then((value) => Navigator.of(context).pop());
              // OpenFile.open(pth);
            },
            child: const Text('open'))
      ],
    );
  }
}
