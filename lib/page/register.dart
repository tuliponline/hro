import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RegisterState();
  }
}

class RegisterState extends State<RegisterPage> {
  String name, email, password, rePassword;

  bool showPass1 = false;
  bool showPass2 = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Style().darkColor,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ),
              body: Container(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: appDataModel.screenW * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Style()
                                    .titleH2("สมัครใช้งานโดยใช้ Email ของคุณ"),
                                Style().textLight(
                                    "Email ของคุณต้องใช้งานได้ เราจะส่งข้อมูลเพื่อยืนยันตัวตน โปรดกรอกข้อมูลให้ครบทุกช่อง"),
                              ],
                            )),
                        buildName(appDataModel),
                        buildEmail(appDataModel),
                        buildPassword(appDataModel),
                        buildRePassword(appDataModel),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          width: appDataModel.screenW * 0.9,
                          child: ElevatedButton(
                            onPressed: () {
                              if ((name?.isEmpty ?? true) ||
                                  (email?.isEmpty ?? true) ||
                                  (password?.isEmpty ?? true) ||
                                  (rePassword?.isEmpty ?? true)) {
                                print("fill have null");
                              } else {
                                if (password == rePassword) {
                                  registerFirebase();
                                } else {
                                  print("Password not match");
                                }
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Style().titleH3('ถัดไป'),
                                Icon(Icons.arrow_forward)
                              ],
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: Style().primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }

  Future<Null> registerFirebase() async {
    await Firebase.initializeApp().then((value) async {
      print('Connect Firebase Success');
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        print('UID=' + value.user.uid.toString());
        await value.user.updateProfile(displayName: name).then((value2) =>
            Navigator.pushNamedAndRemoveUntil(
                context, '/home-page', (route) => false));
      }).catchError((onError) {
        print(onError.message);
      });
    });
  }

  Container buildName(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 17),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.person,
              color: Style().primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            hintText: "ชื่อ-สกุล",
            hintStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt')),
        onChanged: (value) => name = value.trim(),
      ),
    );
  }

  Container buildEmail(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 17),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.email,
              color: Style().primaryColor,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            hintText: "Email",
            hintStyle: TextStyle(fontSize: 12)),
        onChanged: (value) => email = value.trim(),
      ),
    );
  }

  Container buildPassword(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        obscureText: (showPass1 == false) ? true : false,
        style: TextStyle(fontSize: 17),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: Style().primaryColor,
            ),
            suffixIcon: IconButton(
                icon: (showPass1 == true)
                    ? Icon(
                        Icons.visibility_off,
                        color: Style().labelColor,
                      )
                    : Icon(Icons.visibility, color: Style().labelColor),
                onPressed: () {
                  (showPass1 == true) ? showPass1 = false : showPass1 = true;
                  setState(() {});
                }),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            hintText: "รหัสผ่าน",
            hintStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt')),
        onChanged: (value) => password = value.trim(),
      ),
    );
  }

  Container buildRePassword(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        obscureText: (showPass2 == false) ? true : false,
        style: TextStyle(fontSize: 17),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: Style().primaryColor,
            ),
            suffixIcon: IconButton(
                icon: (showPass2 == true)
                    ? Icon(
                        Icons.visibility_off,
                        color: Style().labelColor,
                      )
                    : Icon(Icons.visibility, color: Style().labelColor),
                onPressed: () {
                  (showPass2 == true) ? showPass2 = false : showPass2 = true;
                  setState(() {});
                }),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            hintText: "ยืนยันรหัสผ่านอีกครั้ง",
            hintStyle: TextStyle(fontSize: 10, fontFamily: 'Prompt')),
        onChanged: (value) => rePassword = value.trim(),
      ),
    );
  }
}
