import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/Dialogs.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class Rating4Customer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Rating4CustomerState();
  }
}

class Rating4CustomerState extends State<Rating4Customer> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  double shopRate, riderRate;
  TextEditingController shopComment = TextEditingController();
  TextEditingController riderComment = TextEditingController();

  @override
  Widget build(BuildContext context) {
    shopComment.text = "";
    riderComment.text = "";
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) =>
            Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().darkColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                actions: [
                  Container(
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _saveRating(context.read<AppDataModel>());
                            },
                            child: Style()
                                .textSizeColor('บันทึก', 14, Colors.white),
                            style: ElevatedButton.styleFrom(
                                primary: Style().darkColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
                // leading: IconButton(
                //     icon: Icon(
                //       Icons.menu,
                //       color: Style().darkColor,
                //     ),
                //     onPressed: () {}),
                title: Style().textDarkAppbar('ให้คะแนน'),
              ),
              body: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [buildShopRating(), buildRiderRating()],
                  ),
                ),
              ),
            ));
  }

  buildShopRating() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 8, top: 8, right: 10, left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(28),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Style().textBlackSize("ให้คะแนนร้านค้า ", 14),
              Icon(
                FontAwesomeIcons.store,
                size: 20,
                color: Style().darkColor,
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                  onRatingUpdate: (rating) {
                    print(rating);
                    shopRate = rating;
                  },
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              style: TextStyle(
                  fontFamily: "prompt", fontSize: 16, color: Style().textColor),
              decoration: InputDecoration(
                  hintText: 'ความคิดเห็น',
                  hintStyle: TextStyle(
                      fontFamily: "prompt", fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Color.fromRGBO(243, 244, 247, 1)),
              controller: shopComment,

            ),
          )
        ],
      ),
    );
  }

  buildRiderRating() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 8, top: 8, right: 10, left: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(28),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Style().textBlackSize("ให้คะแนน Rider  ", 14),
                Icon(
                  FontAwesomeIcons.motorcycle,
                  size: 20,
                  color: Style().darkColor,
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RatingBar.builder(
                  itemSize: 30,
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                  onRatingUpdate: (rating) {
                    print(rating);
                    riderRate = rating;
                  },
                ),
              ],
            ),
          ),
          Container(
            child: TextField(
              style: TextStyle(
                  fontFamily: "prompt", fontSize: 16, color: Style().textColor),
              decoration: InputDecoration(
                  hintText: 'ความคิดเห็น',
                  hintStyle: TextStyle(
                      fontFamily: "prompt", fontSize: 14, color: Colors.grey),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Color.fromRGBO(243, 244, 247, 1)),
              controller: riderComment,

            ),
          )
        ],
      ),
    );
  }

  _saveRating(AppDataModel appDataModel) async {
    print(appDataModel.ratingOrderId);
    if (shopRate != null && riderRate != null) {
      var result = await Dialogs().confirm(
          context,
          "ให้คะแนน",
          "ยืนยันการให้คะแนนร้านค้า และ Rider",
          Icon(
            FontAwesomeIcons.question,
            color: Style().darkColor,
          ));
      if (result == true) {
        await db
            .collection('rating')
            .doc(appDataModel.ratingOrderId)
            .get()
            .then((value) {
          if (value.data() != null) {
            db.collection('rating').doc(appDataModel.ratingOrderId).update({
              "orderId": appDataModel.ratingOrderId,
              "shopId": appDataModel.ratingShopId,
              "shopRate": shopRate.toString(),
              "shopComment": shopComment.text,
              "riderId": appDataModel.ratingRiderId,
              "riderRate": riderRate.toString(),
              "riderComment": riderComment.text,
              "customerId": appDataModel.profileUid,
            }).then((value) async {
              await Dialogs().information(
                  context,
                  Style().textBlackSize("สำเร็จ", 14),
                  Style().textBlackSize("ให้คะแนนสำเร็จ", 14));
              Navigator.pop(context, true);
            });
          } else {
            print("Add");
            db.collection('rating').doc(appDataModel.ratingOrderId).set({
              "orderId": appDataModel.ratingOrderId,
              "shopId": appDataModel.ratingShopId,
              "shopRate": shopRate.toString(),
              "shopComment": shopComment.text,
              "riderId": appDataModel.ratingRiderId,
              "riderRate": riderRate.toString(),
              "riderComment": riderComment.text,
              "customerId": appDataModel.profileUid,
            }).then((value) async {
              await Dialogs().information(
                  context,
                  Style().textBlackSize("สำเร็จ", 14),
                  Style().textBlackSize("ให้คะแนนสำเร็จ", 14));
              Navigator.pop(context, true);
            });
          }
        }).catchError((onError) {

        });
      }
    } else {
    await  Dialogs().information(context, Style().textBlackSize('ข้อมูลไม่ครบ', 14),
          Style().textBlackSize('โปรดให้คะแนนร้านค้า และ Rider', 14));
    }
  }
}
