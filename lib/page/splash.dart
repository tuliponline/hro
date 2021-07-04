
import 'package:flutter/material.dart';
import 'package:hro/page/frist.dart';
import 'package:hro/utility/style.dart';
import 'package:splash_screen_view/SplashScreenView.dart';


class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}
class _SplashPageState extends State<SplashPage> {

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute:FirstPage(),
      duration: 500,
      imageSize: 70,
      imageSrc: "assets/images/hroLogoThai.png",
      text: "อากาศเดลิเวอรี่",
      textType: TextType.ScaleAnimatedText,
      textStyle: TextStyle(
        fontSize: 30.0,color: Style().darkColor,fontFamily: "Prompt",
      ),
      backgroundColor: Colors.white,
    );
  }
}
