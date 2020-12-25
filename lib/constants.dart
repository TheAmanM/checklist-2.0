import 'package:flutter/material.dart';

Color mainColor = Color(0xFF0066F1);
Color accentColor = Color(0xFF4903ff);

Color backColor = Color(0xFF0E121B);
Color lightBackColor = Color(0xFF171C26);
Color lightModeBackColor =
    Color(0xFFFCFCFC); //Color(0xFFEDEFFE); //Color(0xFFE4E8F1);
Color lightModeLightBackColor = Color(0xFFECEBF0); //Color(0xFFD9DEE8);

double appVersion = 1.01;

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
/* 
Color getColor(int num) {
  return 0.2126 * Color(num).red +
              0.7152 * Color(num).red +
              0.0722 * Color(num).blue <
          240
      ? Colors.white
      : Colors.black;
}
 */

Color getRealColor(int color) {
  double brightness = (0.21 * Color(color).red) +
      (0.72 * Color(color).green) +
      (0.07 * Color(color).blue);
  //print('$color => ${brightness.round()}');
  return brightness > 170 ? Colors.black : Colors.white;
}

class CustomSwitch extends StatelessWidget {
  final bool isDarkMode;
  final Function onTap;
  final bool value;

  CustomSwitch({
    this.isDarkMode,
    this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (isDarkMode) {
      return Switch(
        value: value,
        onChanged: onTap,
      );
    } else {
      return Switch(
        value: value,
        onChanged: onTap,
        activeColor: mainColor,
        activeTrackColor: mainColor.withOpacity(0.5),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.grey[300],
      );
    }
  }
}

Switch getCustomSwitch(bool isDarkMode, void Function(bool) onTap, bool value) {
  return isDarkMode
      ? Switch(
          value: value,
          onChanged: onTap,
          activeColor: mainColor,
          activeTrackColor: mainColor.withOpacity(0.5),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey[300],
        )
      : Switch(
          value: value,
          onChanged: onTap,
          activeColor: mainColor,
          activeTrackColor: mainColor.withOpacity(0.5),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey[300],
        );
}

double backArrowSize = 20.0;

/*
  1.00)
    Added lists, list items and folders. 
    Added main menu, users menu and settings dialog. 
    Added Info and Help menus. 
    Added export data option. 
    Added update callback. 

  1.01)
    Added list security (reading, changing name, editing items, changing folder, marking items as incomplete and deleting lists). 
    Fixed login / registration bug. 
    Set second tab as default (opens users lists instead of all lists). 

  1.02)
    Organized help, update and feature history pages on home page. (Admin menu)
    Fixed settings menu. 
    Patched bug: Permission to mark all items as incomplete and delete list not working. 
    User is now allowed to see current folder in which list is in within the menu. 
*/
