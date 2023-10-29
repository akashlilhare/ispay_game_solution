import '../widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class CustomListTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isActivity;
  final Function onTap;

  const CustomListTile(
      {Key? key,
      required this.height,
      required this.title,
      required this.subtitle,
      required this.imagePath,
      required this.isActive,
      required this.isActivity,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: RoundedStatusIndicator(
        isActive: isActive,
        size: height / 2,
        imagePath: imagePath,
        key: UniqueKey(),
      ),
      title: Text(
        title  ,
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w500, fontSize: 18),
      ),
      subtitle:isActivity?
          Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Typing",
                  style: TextStyle(color: Colors.black54),
                ),
                SpinKitThreeBounce(
                  color: Colors.black54,
                  size: 10,
                )
              ],
            )
          : Row(
            children: [
              Flexible(
                child: Text(
                    subtitle,maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.black54),
                  ),
              ),
            ],
          ),
    );
  }
}

class CustomListViewTile extends StatelessWidget {
  final String title;
  final DateTime dateTime;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  const CustomListViewTile(
      {Key? key,
      required this.title,
      required this.dateTime,
      required this.imagePath,
      required this.isActive,
      required this.onTap,
      required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String time= DateFormat.yMMMMEEEEd().format(dateTime);
    return ListTile(
      trailing: isSelected ?  Icon(Icons.check,color: Theme.of(context).primaryColor,) : null,
      onTap: () => onTap(),
      minVerticalPadding: 2,
      leading: RoundedStatusIndicator(
        size: 42,
        key: UniqueKey(),
        imagePath: imagePath,
        isActive: isActive,
      ),
      title: Text(title,style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Colors.black),),
      subtitle:  Text(time,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.black54),),
    );
  }
}
