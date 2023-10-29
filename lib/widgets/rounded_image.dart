import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:shimmer/shimmer.dart';
class RoundedImageNetwork extends StatelessWidget {
  final String imagePath;
  final double size;

  const RoundedImageNetwork(
      {Key? key, required this.size, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
         showDialog(context: context, builder: (_){
          return Dialog(child:
              CachedNetworkImage(
                height: MediaQuery.of(context).size.height*.35,
                fit: BoxFit.fill,
                imageUrl: imagePath,
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    Shimmer.fromColors(
                      baseColor: Theme.of(context).scaffoldBackgroundColor, highlightColor:Colors.grey.shade900, child: Container(),),

              ));
        });
      },
      child: Container(
        height: size,
        width: size,
        child:   ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          child: CachedNetworkImage(
           fit: BoxFit.cover,
            imageUrl: imagePath,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
            Shimmer.fromColors(
              baseColor: Theme.of(context).scaffoldBackgroundColor, highlightColor:Colors.grey.shade900, child: Container(),),

          ),
        ),
        decoration: BoxDecoration(


            borderRadius: BorderRadius.all(Radius.circular(size)),
            color: Colors.black),
      ),
    );
  }
}

class RoundedImageFile extends StatelessWidget {
  final PlatformFile image;
  final double size;

  const RoundedImageFile({Key? key, required this.image, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover, image: FileImage(File(image.path!))),
          borderRadius: BorderRadius.all(Radius.circular(size)),
          color: Colors.black),
    );
  }
}
