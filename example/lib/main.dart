import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_image_cropper_plus/flutter_image_cropper_plus_library.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flutterImageCropperPlusPlugin = ImageCropperPlus();

  File? _croppedFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              _imageCard(),
              ElevatedButton(
                onPressed: () {
                  _pickAndCropImage();
                },
                child: const Text('Crop Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageCard() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _image(),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          _menu(),
        ],
      ),
    );
  }

  Widget _image() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    if (_croppedFile != null) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 0.8 * screenWidth,
          maxHeight: 0.7 * screenHeight,
        ),
        child: Image.file(_croppedFile!),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _menu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () {
            _clear();
          },
          backgroundColor: Colors.redAccent,
          tooltip: 'Delete',
          child: const Icon(Icons.delete),
        ),
      ],
    );
  }

  Future<void> _pickAndCropImage() async {
    var imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      cropImage(imageFile.path);
    }
  }

  void _clear() {
    setState(() {
      _croppedFile = null;
    });
  }

  Future<void> cropImage(String imagePath) async {
    final croppedFile = await _flutterImageCropperPlusPlugin.cropImage(
      sourcePath: imagePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust your attachment',
          toolbarColor: const Color(0xFF607D8B),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
          title: 'Adjust your attachment',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _croppedFile = File(croppedFile.path);
      });
    }
  }
}
