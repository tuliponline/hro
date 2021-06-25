import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/utility/regexText.dart';
import 'package:hro/utility/style.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class Dialogs {
  var _textFildControlor = TextEditingController();

  bool monday;

  inputDialog(BuildContext context, Text title, String hinText) {
    _textFildControlor.text = "";
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title,
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: hinText,hintStyle: TextStyle(fontFamily: 'Prompt',fontSize: 14)),
                    controller: _textFildControlor,
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                   Navigator.pop(context,[false,'cancel']);
                  },
                  child: Text('ยกเลิก')),FlatButton(
                  onPressed: () {
                    if (_textFildControlor.text.length > 0) {
                      Navigator.pop(context, [true,_textFildControlor.text]);
                    } else {
                      Toast.show("โปรดกรอกข้อมูล", context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                    }
                  },
                  child: Text('ตกลง'))
            ],
          );
        });
  }
  inputPhoneDialog(BuildContext context, Text title, String hinText) {
    _textFildControlor.text = "";
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title,
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: hinText,hintStyle: TextStyle(fontFamily: 'Prompt',fontSize: 14)),
                    controller: _textFildControlor,
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context,'cancel');
                  },
                  child: Text('ยกเลิก')),FlatButton(
                  onPressed: () {
                    if (phoneRegex(_textFildControlor.text)) {
                      Navigator.pop(context, _textFildControlor.text);
                    } else {
                      Toast.show("หมายเลขไม่ถูกต้อง", context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                    }
                  },
                  child: Text('ตกลง'))
            ],
          );
        });
  }

  TimeOpenDialog(BuildContext context, Text title, String hinText) {
    _textFildControlor.text = "";
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title,
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  RadioListTile(value: monday, groupValue: monday, onChanged: (value){

                  })
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context,'cancel');
                  },
                  child: Text('ยกเลิก')),FlatButton(
                  onPressed: () {
                    if (phoneRegex(_textFildControlor.text)) {
                      Navigator.pop(context, _textFildControlor.text);
                    } else {
                      Toast.show("หมายเลขไม่ถูกต้อง", context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER);
                    }
                  },
                  child: Text('ตกลง'))
            ],
          );
        });
  }

  information(BuildContext context, Text title, Text description) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title,
            content: SingleChildScrollView(
              child: ListBody(
                children: [description],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: () => _confirmResult(true, context),
                  child: Text('ตกลง')),
              // FlatButton(
              //     onPressed: () => _confirmResult(false, context),
              //     child: Text('ยกเลิก'))
            ],
          );
        });
  }

  waiting(BuildContext context, String title, String description) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: [Text(description)],
              ),
            ),
          );
        });
  }

  _confirmResult(bool isYes, BuildContext context) {
    Navigator.pop(context, isYes);
  }

  confirm(BuildContext context, String title, String description, Widget icon) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Style().textSizeColor(title, 16, Style().textColor),
            content: SingleChildScrollView(
              child: Row(
                children: [
                  icon

                  // Icon(
                  //   Icons.delete,
                  //   color: Colors.blue,
                  //   semanticLabel:
                  //   'Text to announce in accessibility modes',
                  ,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: ListBody(
                        children: [Style().textSizeColor(description, 14, Style().textColor),],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
              onPressed: () => _confirmResult(false, context),
          child: Style().textSizeColor('ยกเลิก', 14, Colors.blueAccent),),

              FlatButton(
                onPressed: () => _confirmResult(true, context),
                child: Style().textSizeColor('ตกลง', 14, Colors.blueAccent),),
            ],
          );
        });
  }

  changOrderStatus(BuildContext context, String title, String description,
      Widget icon1, Widget icon2, Widget text1, Widget text2,String status) {
    _textFildControlor.text = '';
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Column(children: [icon1,text1],),Icon(FontAwesomeIcons.arrowRight),Column(children: [icon2,text2],)],),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 10),
                  //   child: Text(description),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top:8),
                    child: TextField(
                      controller: _textFildControlor,
                      decoration: (status == '3')? InputDecoration(hintText: 'Track Number'): InputDecoration(hintText: 'comment'),
                    ),
                  )
                ],
              ),
            ),
            actions: [
              FlatButton(
                  onPressed: (){
                    if(status == '3'){
                      if(_textFildControlor.text.length > 0){
                        Navigator.pop(context, ['YES', _textFildControlor.text]);
                      }else{ Toast.show('โปรดกรอก Track Number', context,
                          duration: Toast.LENGTH_SHORT, gravity: Toast.CENTER); }
                    }else{
                      Navigator.pop(context, ['YES', _textFildControlor.text]);
                    }

                  },
                  child: Text('ตกลง')),
              FlatButton(
                  onPressed: (){
                    Navigator.pop(context, ['NO', _textFildControlor.text]);
                  },
                  child: Text('ยกเลิก'))
            ],
          );
        });
  }
}
