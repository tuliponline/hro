import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Style {
  Color primaryColor = Color(0xff2bceb6);
  Color lightColor = Color(0xff6fffe8);
  Color darkColor = Color(0xff009c86);

  Color secondColor = Color(0xffffc648);
  Color secondLightColor = Color(0xfffff97a);
  Color secondDarkColor = Color(0xffc8960b);

  Color textColor = Color(0xff3c3f41);
  Color labelColor = Color(0xffa4a4a4);
  Color whiteColor = Color(0xfff0f0f0);

  Color facebookColor = Color(0xff3A5998);
  Color googleColor = Color(0xffFFFFFF);
  Color emailColor = Color(0xff606060);

  Color shopPrimaryColor = Color(0xffef6191);
  Color shopLightColor = Color(0xffff93c1);
  Color shopDarkColor = Color(0xffb92c64);

  Color drivePrimaryColor = Color(0xffff8a65);
  Color driveLightColor = Color(0xffffbb93);
  Color driveDarkColor = Color(0xffc75b39);




  Widget showLogo() => Image.asset('assets/images/hroLogo.png');

  Widget titleH0(String string) => Text(
        string,
        style: TextStyle(fontSize: 40, fontFamily: 'Prompt', color: textColor),
      );

  Widget titleH1Big(String string) => Text(
        string,
        style: TextStyle(
          fontSize: 60,
          fontFamily: 'Prompt',
          color: emailColor,
        ),
      );

  Widget titleH1(String string) => Text(
        string,
        style: TextStyle(fontSize: 30, fontFamily: 'Prompt', color: textColor),
      );

  Widget titleH2(String string) => Text(
        string,
        style: TextStyle(fontSize: 18, fontFamily: 'Prompt', color: textColor),
      );

  Widget titleH3(String string) => Text(
        string,
        style: TextStyle(fontSize: 16, fontFamily: 'Prompt', color: textColor),
      );

  Widget titleH3Grey(String string) => Text(
        string,
        style:
            TextStyle(fontSize: 16, fontFamily: 'Prompt', color: Colors.grey),
      );

  Widget textLight(String string) => Text(
        string,
        style: TextStyle(fontSize: 16, fontFamily: 'Prompt', color: labelColor),
      );

  Widget textPrimary(String string) => Text(
        string,
        style: TextStyle(
          fontSize: 16,
          fontFamily: 'Prompt',
          color: primaryColor,
        ),
      );

  Widget textDark(String string) => Text(
        string,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Prompt',
          color: darkColor,
        ),
      );

  Widget textDarkAppbar(String string) => Text(
        string,
        style: TextStyle(
          fontSize: 18,
          fontFamily: 'Prompt',
          color: darkColor,
        ),
      );

  Widget textWhite(String string) => Text(
        string,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Prompt',
          color: Colors.white,
        ),
      );

  Widget textBlack54(String string) => Text(
        string,
        style: TextStyle(
          fontSize: 14,
          fontFamily: 'Prompt',
          color: Colors.black54,
        ),
      );

  Widget textBlackSmall(String string) => Text(
        string,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Prompt',
          color: Colors.black54,
        ),
      );

  Widget textWhiteSize(String string, double size) => Text(
        string,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'Prompt',
          color: Colors.white,
        ),
      );

  Widget textBlackSize(String string, double size) => Text(
        string,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'Prompt',
          color: textColor,
        ),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      );

  Widget textSizeColor(String string, double size, Color color) => Text(
        string,
        style: TextStyle(
          fontSize: size,
          fontFamily: 'Prompt',
          color: color,
        ),
        softWrap: true,
        overflow: TextOverflow.ellipsis,
      );

  Widget circularProgressIndicator (Color color) => Center(child: CircularProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(color)),);

  Style();
}
