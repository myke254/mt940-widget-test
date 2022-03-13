// ignore_for_file: prefer_const_constructors, avoid_print

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mt940/screens/statements.dart';
import 'package:mt940/widgets/mydialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/upload_task.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String fileUrl = "";
  bool range = false;
  File? file;
  String type = "all";
  bool singleDate = false;
  bool all = false;
  bool transid = false;
  bool credit = false;
  bool debit = false;
  bool description = false;
  bool openingbalance = false;
  bool closingbalance = false;
  bool closingAvailableBalance = false;
  bool transactionDescription = false;
  List selectedFields = [
    "code",
    "customerReference",
    "amount",
    "currency",
    "isCredit",
    "isExpense",
  ];

  String downloadUrl = "";
  Future requestPermission() async {
    var storagestatus = await Permission.storage.status;
    var externalstorage = await Permission.manageExternalStorage.status;

    if (storagestatus.isDenied || externalstorage.isDenied) {
      await Permission.storage.request().then((value) async {
        if (value.isGranted) {
          await Permission.manageExternalStorage.request();
        }
      });

    }
  }

  Future loadFromDisk() async {
    await requestPermission();
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
bool isloading=false;
  DateTime? startDate;
  DateTime? lastDate;
  TextEditingController controller = TextEditingController();
  late SharedPreferences preferences;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('mt940'),
          actions: [
            IconButton(
                onPressed: () async {
                  preferences = await SharedPreferences.getInstance();
                  if (preferences.getString('directory') == null ||
                      preferences.getString('directory')!.isEmpty) {
                    Fluttertoast.showToast(msg: 'no directory found');
                  } else {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyFiles()));
                  }
                },
                icon: Icon(CupertinoIcons.doc_person))
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              if (fileUrl.isNotEmpty) {
                if (singleDate && startDate == null) {
                  Fluttertoast.showToast(msg: 'please select a date');
                } else if (!singleDate &&
                    range &&
                    (startDate == null || lastDate == null)) {
                  Fluttertoast.showToast(
                      msg: 'first date and last date are required');
                } else {
                  if (controller.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg:
                        'provide a name to accompany with your document name');
                  } else {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return MyDialog(
                            range: range,
                            credit: credit,
                            debit: debit,
                            firstDate: startDate == null
                                ? ""
                                : startDate.toString().substring(0, 10),
                            lastDate: lastDate == null
                                ? ""
                                : lastDate.toString().substring(0, 10),
                            singleDate: singleDate,
                            downloadUrl: downloadUrl,
                            file: file!,
                            name: controller.text,
                            selectedFields: selectedFields,
                            fileUrl: fileUrl,
                            closingAvailableBalance: closingAvailableBalance,
                            closingBalance: closingbalance,
                            openingBalance: openingbalance,
                          );
                        });
                  }
                }
              }
              //  else if(controller.text.isEmpty){
              //    Fluttertoast.showToast(msg: 'please add name');
              //  }
              else {
                Fluttertoast.showToast(msg: "no file uploaded");
              }

              print(fileUrl);
              //Fluttertoast.showToast(msg: fileUrl);
            },
            label: Text('Continue')),
        body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'create a configurable statement from an mt940 file'),
                ),
                TextButton.icon(
                  onPressed: () async {
                   isloading?Fluttertoast.showToast(msg: 'please wait'): loadFromDisk().then((value) async {
                      if (file != null) {
                        setState(() {
                         isloading = true;
                        });
                        await Mt940FirebaseFunc().uploadandSaveimage(file).then((url){
                          setState(() {
                            print(url);
                            fileUrl = url;
                            isloading = false;
                            // textuploadeddownloadurl = result;
                            // file = null;
                          });
                        });

                      }
                    });
                  },
                  icon: const Icon(CupertinoIcons.doc_text),
                  label:isloading?CupertinoActivityIndicator(): Text(file == null
                      ? 'attach an mt940 statement'
                      : file!.path.toString().split('/').last),
                ),
                CheckboxListTile(
                  value: all,
                  onChanged: (value) {
                    setState(() {
                      all = value!;
                      transid = value;
                      credit = value;
                      debit = value;
                      description = value;
                      openingbalance = value;
                      closingbalance = value;
                      closingAvailableBalance = value;
                      transactionDescription = value;
                      range = false;
                      selectedFields = !value
                          ? [
                        "code",
                        "customerReference",
                        "amount",
                        "currency",
                        "isCredit",
                        "isExpense",
                      ]
                          : [
                        "id",
                        "code",
                        "valueDate",
                        "fundsCode",
                        "amount",
                        "currency",
                        "description",
                        "isCredit",
                        "isExpense",
                        "customerReference"
                      ];
                    });
                  },
                  title: Text('Get all columns'),
                  subtitle: Text(
                      'this will return a pdf or excel document with all available fields'),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(

                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2.0),
                        ),
                        hintText: "provide a name to attach to your statement",
                        prefixIcon: Icon(CupertinoIcons.doc_text)),
                    controller: controller,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('select custom fields'),
                ),
                Row(
                  children: [
                    Checkbox(
                        value: range,
                        onChanged: (value) {
                          setState(() {
                            range = value!;
                          });
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('get transactions from date '),
                          Text("(leave unchecked to receive all transactions)")
                        ],
                      ),
                    )
                  ],
                ),
                range
                    ? Row(
                  children: [
                    Checkbox(
                        value: singleDate,
                        onChanged: (value) {
                          setState(() {
                            singleDate = value!;
                          });
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('pick a single date'),
                    )
                  ],
                )
                    : SizedBox(),
                !range
                    ? SizedBox()
                    : !singleDate
                    ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "First Date: ${startDate == null ? "pick start date" : startDate.toString().substring(0, 10)}",
                        style: GoogleFonts.monda(color: Colors.blue),
                      ),
                      Text(
                          "Last Date: ${lastDate == null ? "pick last date" : lastDate.toString().substring(0, 10)}",
                          style:
                          GoogleFonts.monda(color: Colors.blue)),
                    ],
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Date: ${startDate == null ? "pick date" : startDate.toString().substring(0, 10)}',
                      style: GoogleFonts.monda(color: Colors.blue)),
                ),
                range
                    ? TextButton.icon(
                    label: Text('pick date'),
                    onPressed: () async {
                      // setState(() {});
                      await showDatePicker(
                          helpText: !singleDate
                              ? 'Pick First Date 📅'
                              : 'Select Date',
                          context: context,
                          firstDate: DateTime(2000),
                          initialDate: DateTime.now(),
                          lastDate: DateTime.now(),
                          currentDate: DateTime.now(),
                          useRootNavigator: false)
                          .then((firstDate) {
                        if (firstDate != null) {
                          setState(() {
                            startDate = firstDate;
                          });
                          Fluttertoast.showToast(
                              msg: startDate.toString().substring(0, 10));
                          if (!singleDate) {
                            showDatePicker(
                                helpText: 'Pick Last Date 📅',
                                context: context,
                                firstDate: DateTime(2000),
                                initialDate: DateTime.now(),
                                lastDate: DateTime.now(),
                                currentDate: DateTime.now(),
                                useRootNavigator: false)
                                .then((endDate) {
                              if (int.parse(startDate
                                  .toString()
                                  .substring(0, 10)
                                  .split('-')
                                  .join('')) >
                                  int.parse(endDate
                                      .toString()
                                      .substring(0, 10)
                                      .split('-')
                                      .join(''))) {
                                setState(() {
                                  lastDate = endDate;
                                });
                                Fluttertoast.showToast(
                                    msg: startDate
                                        .toString()
                                        .substring(0, 10));
                                Fluttertoast.showToast(
                                    msg: lastDate
                                        .toString()
                                        .substring(0, 10));
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'start date must be more recent');
                              }
                            });
                          }
                        }
                      });
                    },
                    icon: Icon(
                      CupertinoIcons.calendar,
                      size: 35,
                    ))
                    : SizedBox(),
                Wrap(children: [
                  Row(
                    children: [
                      Checkbox(
                          value: transid,
                          onChanged: (value) {
                            setState(() {
                              transid = value!;
                              if (all || !value) {
                                all = false;
                                selectedFields = [
                                  "code",
                                  "customerReference",
                                  "amount",
                                  "currency",
                                  "isCredit",
                                  "isExpense",
                                ];
                              }
                              value
                                  ? selectedFields.add('id')
                                  : selectedFields.remove('id');
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
                              if (all || !value) {
                                all = false;
                                selectedFields = [
                                  "code",
                                  "customerReference",
                                  "amount",
                                  "currency",
                                  "isCredit",
                                  "isExpense",
                                ];
                              }
                              value
                                  ? selectedFields.add('description')
                                  : selectedFields.remove('description');
                            });
                            print(selectedFields);
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('transaction description'),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: credit,
                          onChanged: (value) {
                            setState(() {
                              credit = value!;
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('credit'),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: debit,
                          onChanged: (value) {
                            setState(() {
                              debit = value!;
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('debit'),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: openingbalance,
                          onChanged: (value) {
                            setState(() {
                              openingbalance = value!;
                              if (all || !value) {
                                all = false;
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
                              if (all || !value) {
                                all = false;
                              }
                            });
                            print(selectedFields);
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Closing Balance'),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: closingAvailableBalance,
                          onChanged: (value) {
                            setState(() {
                              closingAvailableBalance = value!;
                              if (all || !value) {
                                all = false;
                              }
                            });
                            print(selectedFields);
                          }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Closing Available Balance'),
                      )
                    ],
                  )
                ])

                //Column(children: fields.map((e) => CheckboxListTile(value: false, onChanged: (value){},title: Text(e),)).toList(),)
              ]),
        ));
  }
}
