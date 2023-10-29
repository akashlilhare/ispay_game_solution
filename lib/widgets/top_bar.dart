
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 appBar( List<Widget> action,{required String title, required BuildContext context, }){
  return AppBar(
    title: Text(title,style: TextStyle(color: Colors.black),),
    iconTheme: IconThemeData(color: Colors.black),
    actions: action,
    elevation: .5,
  );
}


