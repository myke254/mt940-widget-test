// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'mt940/Functions/Firebasefunc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
var fileUrl ="";


  File? file;
  var type ="all";
  var all = false;
  var transid = false;
  var credit = false;
  var debit = false;
  bool description = false;
  var openingbalance = false;
  var closingbalance = false;
  var transactionDescription = false;
 List selectedFields = ["code","isCredit","currency","amount","customerReference"];


String downloadUrl ="";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('mt940'),
        ),
        floatingActionButton: FloatingActionButton.extended(onPressed: (){
          fileUrl.isNotEmpty?showDialog(context: context, builder: (context){
            return MyDialog(downloadUrl: downloadUrl, file: file!,selectedFields:selectedFields, fileUrl: fileUrl,);
          }):Fluttertoast.showToast(msg: "no file uploaded");
         print(fileUrl);
         //Fluttertoast.showToast(msg: fileUrl);
        }, label: Text('Continue')),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    Text('create a configurable statement from an mt940 file'),
              ),
              TextButton.icon(
                onPressed: () async{
                  loadfromDisk().then((value) async{
                    if (file != null) {
                        setState(() {
                         // isloading = true;
                        });
                        var result =
                            await Mt940FirebaseFunc().uploadandSaveimage(file);
                        setState(() {
                          print(result);
                            fileUrl=result;
                         // isloading = false;
                         // textuploadeddownloadurl = result;
                         // file = null;
                        });
                       
                      }
                  });
                },
                icon: const Icon(CupertinoIcons.doc_text),
                label:  Text(file==null?'attach an mt940 statement':file!.path.toString().split('/').last),
              ),
              CheckboxListTile(
                value: all,
                onChanged: (value) {
                  setState(() {
                    all = value!;
                    transid = value;
                    credit = value;
                    debit = value;
                    openingbalance = value;
                    closingbalance = value;
                    transactionDescription = value;
                    selectedFields=!value?["code","isCredit","currency","amount","customerReference"]:["id","code","fundsCode","isCredit","isExpense","currency","description","amount","valueDate","customerReference"];

                  });
                },
                title: Text('Get all columns'),
                subtitle: Text(
                    'this will return a pdf or excel document with all available fields'),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('select custom fields'),
              ),
              Wrap(children: [
                Row(
                  children: [
                    Checkbox(
                        value: transid,
                        onChanged: (value) {
                          setState(() {
                            transid = value!;
                            if(all||!value){
                              all=false;
                              selectedFields =["code","isCredit","currency","amount","customerReference"];
                            }
                           value? selectedFields.add('id'):selectedFields.remove('id');
                          });
                          print(selectedFields);
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('transaction id'),
                    )
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        value: description,
                        onChanged: (value) {
                          setState(() {
                            description = value!;
                            if(all||!value){
                              all=false;
                              selectedFields =["code","isCredit","currency","amount","customerReference"];
                            }
                           value? selectedFields.add('description'):selectedFields.remove('description');
                          });
                          print(selectedFields);
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('transaction description'),
                    )
                  ],
                ),
                // Row(
                //   children: [
                //     Checkbox(
                //         value: credit,
                //         onChanged: (value) {
                //           setState(() {
                //             credit = value!;
                //             if(all||!value){
                //               all=false;
                //             }
                //             type= value?debit?'all':'credit':'all';
                //           });
                          
                //         }),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Text('credit'),
                //     )
                //   ],
                // ),
                // Row(
                //   children: [
                //     Checkbox(
                //         value: debit,
                //         onChanged: (value) {
                //           setState(() {
                //             debit = value!;
                //             if(all||!value){
                //               all=false;
                //             }
                //             type= value?credit?'all':'debit':'all';
                //           });
                //         }),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Text('debit'),
                //     )
                //   ],
                // ),
                Row(
                  children: [
                    Checkbox(
                        value: openingbalance,
                        onChanged: (value) {
                          setState(() {
                            openingbalance = value!;
                            if(all||!value){
                              all=false;
                            }
                          });
                          print(selectedFields);
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('opening balance'),
                    )
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        value: closingbalance,
                        onChanged: (value) {
                          setState(() {
                            closingbalance = value!;
                            if(all||!value){
                              all=false;
                            }
                          });
                          print(selectedFields);
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Closing Balance'),
                    )
                  ],
                )
              ])

              //Column(children: fields.map((e) => CheckboxListTile(value: false, onChanged: (value){},title: Text(e),)).toList(),)
            ]));
  }
}
class MyDialog extends StatefulWidget {
  const MyDialog({ Key? key, required this.downloadUrl, required this.file, required this.selectedFields,required this.fileUrl  }) : super(key: key);
final String downloadUrl;
final File file;
final List selectedFields;
final String fileUrl;
  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  
 Map<String, dynamic> data = {};

  Future<Map<String, dynamic>> converter(format) async {
   
    var url = Uri.parse(widget.fileUrl);
    var dio = Dio();

    //print(url);
    var postData = {
      "url": url.toString(),
      "sender": "Swift-mt940",
      "fields": widget.selectedFields,
      "date": "2021-08-03",
      "format": format,
      "type": "Cr",
      "openingbalance": true,
      "closingbalance": true,
      "get": "all",
      "range": {"start": "2021-07-03", "end": "2021-07-03"}
    };
    if (kDebugMode) {
      print(jsonEncode(postData));
    }
    final response = await dio.post("https://645e-41-89-229-17.ngrok.io/mt940",
        data: jsonEncode(postData));

    if (response.statusCode == 200) {
      setState(() {
        data = response.data;
      });

      if (kDebugMode) {
        print(response.data);
      }
    } else {
      print('error');
    }

    return data;
  }
 var pth ="";
Future download2(Dio dio, String url, String savePath) async {
 
    try {
      Response response = await dio.get(
        data['url'],
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      //print(response.headers['']);
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
     //pth= raf.path;
      raf.writeFromSync(response.data);
      await raf.close();

    } catch (e) {
      print(e);
    }
  // return pth;
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      print((received / total * 100).toStringAsFixed(0) + "%");
    }
  }

download(url,name) async {
  var dio = Dio();
  var tempDir = await getTemporaryDirectory();
                  String fullPath = tempDir.path + "/$name'";
                  print('full path ${fullPath}');
setState(() {
  pth = fullPath;
});
                  download2(dio, url, fullPath);
}


  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
              content:widget.downloadUrl.isEmpty? Column(
                  children:data.isEmpty? [
                    Card(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(widget.file.path.toString().split('/').last),
                    )),
                    Text('choose which format you want to receive your file')]:[
                      Text('Here is your file'),
                      Text(data['url'].toString().split('/').last)
                    ],
              ):Center(child: CircularProgressIndicator()),
              actions:data.isEmpty? [
                TextButton(onPressed: (){
                  converter('pdf');

                }, child: Text('Pdf')),
                TextButton(onPressed: (){
                   converter('excel');
                }, child: Text('Excel'))
              ]:[
              pth.isEmpty?  TextButton(onPressed: (){
                  download(data['url'],data['url'].toString().split('/').last);
                }, child: Text('download now')):TextButton(onPressed: (){
                  OpenFile.open(pth);
                }, child: Text('open'))
              ],
            );
  }
}