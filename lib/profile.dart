import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/user.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

Widget buildProfilePage(BuildContext context, SnappingSheetController ctrl) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                CircleAvatar(
                    backgroundImage: Provider.of<User>(context).img.image,
                    radius: 42)
              ],
            ),
            Column(
              children: [
                Text(Provider.of<User>(context).name,
                    style: TextStyle(fontSize: 16)),
                ElevatedButton(
                    onPressed: () => _handleAvatarChange(context),
                    child: Text("Change Avatar"))
              ],
            )
          ],
        ),
      ),
    ),
  );
}

_handleAvatarChange(context) async {
  FilePickerResult? res = await FilePicker.platform.pickFiles();
  if (res == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('No image selected')));
  } else {
    File file = File(res.files.single.path!);
    FirebaseStorage.instance
        .ref('images/' + Provider.of<User>(context, listen: false).name)
        .putFile(file)
        .then((_) =>
            Provider.of<User>(context, listen: false).fetchProfilePicFromDB());
  }
}
