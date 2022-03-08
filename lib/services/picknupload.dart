import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class PicknUpload{

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
    File file = File('');
    await requestPermisssion();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result != null) {
      File givenfile = File(result.files.single.path!);
     
        file = givenfile;
      
    } else {
      Fluttertoast.showToast(msg: "Please Pick Again");
    }
    return file;
  }

   Future<String> uploadandSaveimage(mFileImage) async {
    // requestpermissions();
    String downloadurlvalue = "";
    String uniqueid = DateTime.now().microsecondsSinceEpoch.toString();
    if (mFileImage == null) {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //  content: const Text("Unable to pick the File please Try again")));
    } else {
      // String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

      final Reference storagereference =
          FirebaseStorage.instance.ref().child("Mt940");
      // print(mFileImage['originalPath'].toString());

      UploadTask uploadTask = storagereference
          .child("file$uniqueid.txt")
          .putFile(mFileImage);

      downloadurlvalue = await (await uploadTask).ref.getDownloadURL();
    }
    return downloadurlvalue;
  }
}
