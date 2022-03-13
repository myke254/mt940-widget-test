import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Mt940FirebaseFunc {
  Future<String> uploadandSaveimage(mFileImage) async {
    // requestpermissions();
    String downloadurlvalue = "";
    String uniqueid = DateTime.now().microsecondsSinceEpoch.toString();
    if (mFileImage == null) {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //  content: const Text("Unable to pick the File please Try again")));
    } else {
      // String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

      final Reference storageReference =

          FirebaseStorage.instance.ref().child("Mt940");
      // print(mFileImage['originalPath'].toString());

      UploadTask uploadTask = storageReference
          .child("file$uniqueid.txt")
          .putFile(mFileImage);

      downloadurlvalue = await (await uploadTask).ref.getDownloadURL();
    }
    return downloadurlvalue;
  }
}
