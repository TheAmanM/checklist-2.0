import 'package:flutter/material.dart';

Color mainColor = Color(0xFF0066F1);
Color accentColor = Color(0xFF4903ff);
Color backColor = Color(0xFF0E121B);
Color lightBackColor = Color(0xFF171C26);

class CheckListTile extends StatelessWidget {
  String title;
  Function onPress = () {};
  Color backgroundColor;
  Color primaryColor;
  Color inkColor;
  List<BoxShadow> boxShadow;

  CheckListTile({
    this.title,
    this.onPress,
    this.backgroundColor,
    this.primaryColor,
    this.inkColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        onTap: onPress,
        child: Container(
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              //boxShadow: boxShadow,
              //borderRadius: BorderRadius.circular(20),
              color: backgroundColor,
            ),
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(color: primaryColor),
            )),
      ),
    );
  }
}

Color getColor(int num) {
  return 0.2126 * Color(num).red +
              0.7152 * Color(num).red +
              0.0722 * Color(num).blue <
          240
      ? Colors.white
      : Colors.black;
}
