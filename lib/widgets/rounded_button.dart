import '../widgets/rounded_image.dart';
import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Widget child;
  final double height;
  final double width;
  final Function onPressed;

  const RoundedButton(
      {Key? key,
      required this.child,
      required this.height,
      required this.width,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
            primary: Color.fromRGBO(0, 82, 218, 1.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)))),
        child:child
      ),
    );
  }
}

class RoundedStatusIndicator extends RoundedImageNetwork {
  final bool isActive;

  const RoundedStatusIndicator({
    required Key key,
    required double size,
    required String imagePath,
    required this.isActive,
  }) : super(
          key: key,
          size: size,
          imagePath: imagePath,
        );

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight,
      children: [
        super.build(context),
        Container(
          height: size *  0.20,
          width:  size * 0.20,
          decoration: BoxDecoration(
            color: isActive? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(size)
          ),
        )
      ],
    );
  }
}
