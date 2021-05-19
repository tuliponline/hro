import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/dialog.dart';
import 'package:hro/utility/regexText.dart';
import 'package:hro/utility/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ProfileState();
  }
}

class ProfileState extends State<ProfilePage> {



  var _nameController = TextEditingController();
  var _phoneController = TextEditingController();
  var _emailController = TextEditingController();
  FocusNode myFocusNode = new FocusNode();
  bool checkNameRegX = false;
  bool checkEmailRegX = false;
  bool checkPhoneRegX = false;
  bool setDataStatus = false;
  File file;

  bool loading = true;

  final picker = ImagePicker();

  String photoUrl;

  _setDataProfile(AppDataModel appDataModel) {
    _nameController.text = appDataModel.profileName;
    _phoneController.text = appDataModel.profilePhone;
    _emailController.text = appDataModel.profileEmail;

    checkNameRegX = textLengthRegex(_nameController.text, 8);
    checkPhoneRegX = phoneRegex(_phoneController.text);
    checkEmailRegX = emailRegex(_emailController.text);

    setDataStatus = true;
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    if (setDataStatus == false) _setDataProfile(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: (loading == true)
                  ? null
                  : AppBar(
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
              body: (loading == true)
                  ? Style().circularProgressIndicator(Style().darkColor)
                  : Container(
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Stack(children: [
                                Container(
                                  margin: EdgeInsets.only(top: 48),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                ),
                                Align(
                                    alignment: Alignment.topCenter,
                                    child: SizedBox(
                                      child: CircleAvatar(
                                        radius: 40.0,
                                        backgroundColor: Style().primaryColor,
                                        child: CircleAvatar(
                                          child: InkWell(
                                            onTap: () {
                                              chooseImage(ImageSource.camera);
                                            },
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 12.0,
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  size: 15.0,
                                                  color: Color(0xFF404040),
                                                ),
                                              ),
                                            ),
                                          ),
                                          radius: 38.0,
                                          backgroundColor: Colors.white,
                                          backgroundImage: (file == null)
                                              ? (appDataModel.profilePhotoUrl
                                                          ?.isEmpty ??
                                                      true)
                                                  ? AssetImage(
                                                      'assets/images/person-icon.png')
                                                  : NetworkImage(appDataModel
                                                      .profilePhotoUrl)
                                              : FileImage(file),
                                        ),
                                      ),
                                    )),
                              ]),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Style().textBlackSize(
                                    appDataModel.profileName, 14),
                              ),
                              buildUser(context.read<AppDataModel>()),
                              buildPhone(context.read<AppDataModel>()),
                              buildEmail(context.read<AppDataModel>()),
                              Container(
                                width: appDataModel.screenW * 0.9,
                                child: Container(
                                  width: 150,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          (checkEmailRegX &&
                                                  checkNameRegX &&
                                                  checkPhoneRegX)
                                              ?
                                          updateProfile(
                                                  context.read<AppDataModel>())

                                              : normalDialog(
                                                  context,
                                                  'ข้อมูลไม่ถูกต้อง',
                                                  'โปรดตรวจสอบข้อมูล');
                                        },
                                        child: Style().titleH3('บันทึก'),
                                        style: ElevatedButton.styleFrom(
                                            primary: Style().primaryColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5))),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
            ));
  }

  Container buildUser(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            suffixIcon: (checkNameRegX == true)
                ? Icon(
                    FontAwesomeIcons.solidCheckCircle,
                    color: Colors.green,
                  )
                : Icon(
                    FontAwesomeIcons.solidTimesCircle,
                    color: Colors.red,
                  ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            labelText: "ชื่อ",
            labelStyle: TextStyle(
                fontFamily: "prompt",
                fontSize: 14,
                color:
                    (checkNameRegX == true) ? Style().darkColor : Colors.red)),
        controller: new TextEditingController.fromValue(new TextEditingValue(
            text: _nameController.text,
            selection: new TextSelection.collapsed(
                offset: _nameController.text.length))),
        onChanged: (value) {
          setState(() {
            _nameController.text = value;
            checkNameRegX = textLengthRegex(_nameController.text, 8);
          });
        },
      ),
    );
  }

  Container buildPhone(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            suffixIcon: (checkPhoneRegX == true)
                ? Icon(
                    FontAwesomeIcons.solidCheckCircle,
                    color: Colors.green,
                  )
                : Icon(
                    FontAwesomeIcons.solidTimesCircle,
                    color: Colors.red,
                  ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            labelText: "หมายเลขโทรศัพท์",
            labelStyle: TextStyle(
                fontFamily: "prompt",
                fontSize: 14,
                color:
                    (checkPhoneRegX == true) ? Style().darkColor : Colors.red)),
        controller: new TextEditingController.fromValue(new TextEditingValue(
            text: _phoneController.text,
            selection: new TextSelection.collapsed(
                offset: _phoneController.text.length))),
        onChanged: (value) {
          setState(() {
            _phoneController.text = value;
            checkPhoneRegX = phoneRegex(_phoneController.text);
          });
        },
      ),
    );
  }

  Container buildEmail(AppDataModel appDataModel) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: appDataModel.screenW * 0.9,
      height: 40,
      child: TextField(
        style: TextStyle(fontSize: 14),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            suffixIcon: (checkEmailRegX == true)
                ? Icon(
                    FontAwesomeIcons.solidCheckCircle,
                    color: Colors.green,
                  )
                : Icon(
                    FontAwesomeIcons.solidTimesCircle,
                    color: Colors.red,
                  ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Style().labelColor)),
            labelText: "Email",
            labelStyle: TextStyle(
                fontFamily: "prompt",
                fontSize: 14,
                color:
                    (checkEmailRegX == true) ? Style().darkColor : Colors.red)),
        controller: new TextEditingController.fromValue(new TextEditingValue(
            text: _emailController.text,
            selection: new TextSelection.collapsed(
                offset: _emailController.text.length))),
        onChanged: (value) {
          setState(() {
            _emailController.text = value;
            emailRegex(_emailController.text);
          });
        },
      ),
    );
  }

  Future<void> chooseImage(ImageSource imageSource) async {
    final pickedFile = await picker.getImage(
        source: imageSource, maxWidth: 800, maxHeight: 800);
    setState(() {
      if (pickedFile != null) {
        file = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<Null> updateProfile(AppDataModel appDataModel) async {
    setState(() {
      loading = true;
    });
photoUrl = appDataModel.profilePhotoUrl;
    final FirebaseAuth auth = await FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    // here you write the codes to input the data into firestore

      if (user != null) {
        if (file != null) {
          Random random = Random();
          int i = random.nextInt(100000);
          final _firebaseStorage = FirebaseStorage.instance;
          var snapshot = await _firebaseStorage
              .ref()
              .child('profile_picture/profile$i.jpg')
              .putFile(file);
          var downloadUrl = await snapshot.ref.getDownloadURL();
          photoUrl = downloadUrl;
          appDataModel.profilePhotoUrl = photoUrl;
        }
        await user
            .updateProfile(
                displayName: _nameController.text, photoURL: photoUrl)
            .then((value2)  async{

          print("CheckDataTest");

          var apiUrl = Uri.parse(appDataModel.server + '/users/update');
          print('update url = ' + apiUrl.toString());
          var responseUpdateUser = await http.put(
            (apiUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'uid': appDataModel.profileUid,
              'name': _nameController.text,
              'phone': _phoneController.text,
              'email': _emailController.text,
              'photo_url': photoUrl,
            }),
          );
          if (responseUpdateUser.statusCode == 200){
            normalDialog(
                context, 'บันทึกสำเร็จ', 'ข้อมูลได้ถูกบันทึกเรียบร้อยแล้ว');
            setState(() {
              appDataModel.profileName = _nameController.text;
              appDataModel.profilePhone = _phoneController.text;
              file = null;
              loading = false;
            });
          }else{
            normalDialog(
                context, 'ผิดพลาด', 'เกิดข้อผิดพลาดโปรดลองใหม่อีกครั้ง');
            print(responseUpdateUser.body.toString());
            print(responseUpdateUser.statusCode.toString());
          }


        });
      } else {
        print("non Login");
      }
    ;
  }
}
