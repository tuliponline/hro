import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/page/register.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hro/utility/style.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginPage> {
  String user, password;
  bool showPassword = false;
  var myController = TextEditingController();

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
        body: SafeArea(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Container(
                // color: Colors.green,
                width: appDataModel.screenW * 0.9,
                child: Container(
                  // color: Colors.orange,
                  child: ListView(
                    children: [
                      Column(
                        children: [
                          Container(
                              width: appDataModel.screenW * 0.9,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Style().titleH2(
                                      "ยินดีต้อนรับ! เข้าใช้งานด้วย Email ของคุณ"),
                                  Style().textLight(
                                      "หากคุณยังไม่เคยใช้งาน กดที่ 'สมัครใช้งาน' เพื่อลงทะเบียนและเข้าใช้งาน"),
                                ],
                              )),
                          buildUser(appDataModel),
                          buildPassword(appDataModel),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: appDataModel.screenW * 0.9,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  child: Style().textDark("สมัครใช้งาน"),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/register-page');
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if ((user?.isEmpty ?? true) ||
                                        (password?.isEmpty ?? true)) {
                                      print("user or password not input");
                                    } else {
                                      checkAuThen();
                                    }
                                  },
                                  child: Row(children: [Style().titleH3('เข้าใช้งาน'), Icon(Icons.arrow_forward)],),
                                  style: ElevatedButton.styleFrom(
                                      primary: Style().primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5))),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildUser(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 20),
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
        onChanged: (value) => user = value.trim(),
      ),
    );
  }

  Container buildPassword(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 17),
        obscureText: (showPassword == false) ? true : false,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.lock,
              color: Style().primaryColor,
            ),
            suffixIcon: IconButton(
                icon: (showPassword == true)
                    ? Icon(
                        Icons.visibility_off,
                        color: Style().labelColor,
                      )
                    : Icon(Icons.visibility, color: Style().labelColor),
                onPressed: () {
                  (showPassword == true)
                      ? showPassword = false
                      : showPassword = true;
                  setState(() {});
                }),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            hintText: "รหัสผ่าน",
            hintStyle: TextStyle(fontSize: 10,fontFamily: 'Prompt')),
        onChanged: (value) => password = value.trim(),
      ),
    );
  }

  Container buildLogo(AppDataModel appDataModel) => Container(
        child: Style().showLogo(),
        width: appDataModel.screenW * 0.2,
      );

  Future<Null> checkAuThen() async {
    print(user+password);

    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: user, password: password)
          .then((value) => Navigator.pushNamedAndRemoveUntil(
              context, '/home-page', (route) => false))
          .catchError((errorValue) => print(errorValue.message));
    });
  }
}
