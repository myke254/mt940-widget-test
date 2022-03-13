import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'dart:io' as io;

class MyFiles extends StatefulWidget {
  const MyFiles({Key? key}) : super(key: key);

  @override
  _MyFilesState createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> {
  io.Directory? directory;
  List file = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listOfFiles();
  }

  // Make New Function
  void _listOfFiles() async {
    //directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      directory = io.Directory("/storage/emulated/0/mt940s");
      file = io.Directory("/storage/emulated/0/mt940s").listSync();
    });
  }

  Future<void> openFile(fileName) async {
    await OpenFile.open("/storage/emulated/0/mt940s/" + fileName).then((value) {
      if (kDebugMode) {
        print(value.message);
      }
    });
  }

  Future<void> deleteFile(fileName) async {
    await io.File("/storage/emulated/0/mt940s/" + fileName)
        .delete()
        .then((value) {
      if (kDebugMode) {
        print(value);
      }
      setState(() {
        file = io.Directory("/storage/emulated/0/mt940s").listSync();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Statements"),
      ),
      body: (directory!.existsSync())
          ? file.isEmpty
              ? const Center(
                  child: Text("no files available"),
                )
              : ListView.separated(
                  itemCount: file.length,
                  itemBuilder: (BuildContext context, int index) {
                    String fileName =
                        file[index].toString().split('/').last.split("'").first;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: ListTile(
                        onTap: () {
                          openFile(fileName);
                        },
                        leading: Image.asset(
                          file[index].toString().contains('pdf')
                              ? 'assets/pdf.png'
                              : 'assets/excel.png',
                          height: 40,
                          width: 40,
                        ),
                        title: Text(fileName),
                        trailing: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      content: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: [
                                          Text('Are you sure you want to delete $fileName?'),
                                          const SizedBox(width: 10,),
                                          const Icon(
                                            CupertinoIcons.exclamationmark_triangle,
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text("cancel")),
                                        TextButton(
                                            onPressed: () {
                                              deleteFile(fileName).then((value) => Navigator.of(context).pop());
                                            },
                                            child: const Text(
                                              "delete",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ))
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(CupertinoIcons.delete)),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(
                      indent: 40,
                      endIndent: 40,
                    );
                  },
                )
          : const Center(
              child: Text('empty directory'),
            ),
    );
  }
}
