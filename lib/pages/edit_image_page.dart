import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:uuid/uuid.dart';

class EditImagePage extends StatefulWidget {
  final String image;

  const EditImagePage({super.key, required this.image});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  final _imageKey = GlobalKey<ImagePainterState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send),
        onPressed: () async {
          Uint8List? byteArray = await _imageKey.currentState?.exportImage();
          if (byteArray == null) {
            return;
          }

          return Navigator.pop(context, byteArray);
        },
      ),
      body: SafeArea(
        child: ImagePainter.network(
          widget.image,
          key: _imageKey,
          scalable: true,
          initialStrokeWidth: 3,
          textDelegate: TextDelegate(),
          initialColor: Colors.red,
          initialPaintMode: PaintMode.circle,
          onClear: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
