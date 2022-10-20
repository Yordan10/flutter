import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? image;

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imageTemporary = File(image.path);

      setState(() {
        this.image = imageTemporary;
      });
      // await saveFilePermanently(imageTemporary);
    } on PlatformException catch (e) {
      debugPrint(' Hvanah ei toq problem dokato vzimam snimka + $e');
    }
  }

  // Future saveFilePermanently(File image) async {
  //   if (this.image == null) {
  //     return;
  //   } else {
  //     final image = this.image;
  //     final directory = await getApplicationDocumentsDirectory();
  //     final fileName = basename(image!.path);
  //     // final image = File('${directory.path}/$fileName');
  //     print('vlizam ${this.image}');

  //     await image.copy('${}/$fileName');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: [
            image != null
                ? Image.file(
                    image!,
                    width: 350,
                    height: 350,
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    'https://s2.coinmarketcap.com/static/img/coins/200x200/5225.png'),
            customButton(
                title: 'Pick form gallery',
                icon: Icons.image_outlined,
                onclick: () => getImage(ImageSource.gallery)),
            customButton(
                title: 'Pick from Camera',
                icon: Icons.camera_alt_outlined,
                onclick: () => getImage(ImageSource.camera)),
          
          ],
        )),
      ),
    );
  }
}


Widget customButton(
    {required String title,
    required IconData icon,
    required VoidCallback onclick}) {
  return SizedBox(
    width: 300,
    child: ElevatedButton(
        onPressed: onclick,
        child: Row(
          children: [Icon(icon), const SizedBox(width: 20), Text(title)],
        )),
  );
}
