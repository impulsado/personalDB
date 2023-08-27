import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:personaldb/constants/theme.dart';

class PhotoUploader extends StatefulWidget {
  final TextEditingController controller1;
  final TextEditingController controller2;
  final Color? appBarBackgroundColor;

  const PhotoUploader({
    required this.controller1,
    required this.controller2,
    this.appBarBackgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PhotoUploaderState createState() => _PhotoUploaderState();
}

class _PhotoUploaderState extends State<PhotoUploader> {
  final List<File?> _images = [null, null];
  final List<String?> _imageNames = ["", ""];

  @override
  void initState() {
    super.initState();

    if (widget.controller1.text.isNotEmpty) {
      _images[0] = File(widget.controller1.text);
      _imageNames[0] = path.basename(widget.controller1.text);
    }

    if (widget.controller2.text.isNotEmpty) {
      _images[1] = File(widget.controller2.text);
      _imageNames[1] = path.basename(widget.controller2.text);
    }
  }


  Future<void> _pickImage(int index) async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String assetsFolderPath = "${appDocDir.path}/assets";
      final fileName = path.basename(pickedFile.path);
      final savedImagePath = "$assetsFolderPath/$fileName";
      final savedImage = await File(pickedFile.path).copy(savedImagePath);

      setState(() {
        _images[index] = savedImage;
        _imageNames[index] = fileName;
      });

      if (index == 0) {
        widget.controller1.text = savedImagePath;
      } else {
        widget.controller2.text = savedImagePath;
      }
    }
  }

  Future<void> _deleteImage(int index) async {
    if (_images[index] != null) {
      await _images[index]!.delete();
      setState(() {
        _images[index] = null;
        _imageNames[index] = "";
      });

      if (index == 0) {
        widget.controller1.text = "";
      } else {
        widget.controller2.text = "";
      }
    }
  }

  void _showImageFullScreen(File imageFile) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            Scaffold(
              appBar: AppBar(
                backgroundColor: widget.appBarBackgroundColor,
                elevation: 0,
                title: Text(
                  path.basename(imageFile.path),
                  style: headingStyle(color: Colors.black),
                ),
                leading: IconButton(
                  icon: const Icon(
                      Icons.arrow_back_ios_new, color: Colors.black),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: Center(
                child: Image.file(imageFile),
              ),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Photos", style: subHeadingStyle(color: Colors.black)),
        const SizedBox(height: 10),
        ..._buildImageBoxes(),
      ],
    );
  }

  List<Widget> _buildImageBoxes() {
    List<Widget> boxes = [];
    for (int index = 0; index < 2; index++) {
      File? image = _images[index];
      if (image != null || (index == 0) || (index == 1 && _images[0] != null)) {
        boxes.add(
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  if (image != null) {
                    _showImageFullScreen(image);
                  } else {
                    _pickImage(index);
                  }
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: image == null
                      ? const Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Upload a photo", style: TextStyle(color: Colors.grey)),
                    ),
                  )
                      : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.image, color: Colors.grey),
                        Expanded(
                          child: Text(
                            _imageNames[index] ?? "",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () => _deleteImage(index),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        );
      }
    }
    return boxes;
  }
}