import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/ratingModel.dart';
import 'package:hro/utility/style.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ShopReviewPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ShopReviewState();
  }
}

class ShopReviewState extends State<ShopReviewPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                title: Style()
                    .textSizeColor("รีวิวร้านค้า", 16, Style().darkColor),
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
                  child: Column(
                    children: [
                      buildSumRating(context.read<AppDataModel>()),
                      Container(
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 0.3, color: Colors.grey),
                          ),
                        ),
                      ),
                      showRatingAndComment(context.read<AppDataModel>())
                    ],
                  ),
                ),
              ),
            ));
  }

  buildSumRating(AppDataModel appDataModel) {
    List<int> sumRatingAll = [0, 0, 0, 0, 0];
    appDataModel.shopRatingList.forEach((element) {
      double ratingNow = double.parse(element.shopRate);
      if (ratingNow == 1.0) {
        sumRatingAll[0] += 1;
      } else if (ratingNow == 2.0) {
        sumRatingAll[1] += 1;
      } else if (ratingNow == 3.0) {
        sumRatingAll[2] += 1;
      } else if (ratingNow == 4.0) {
        sumRatingAll[3] += 1;
      } else if (ratingNow == 5.0) {
        sumRatingAll[4] += 1;
      }
    });

    print(sumRatingAll);

    return Container(
      margin: EdgeInsets.all(3),
      child: StaggeredGridView.countBuilder(
          shrinkWrap: true,
          primary: false,
          crossAxisCount: 5,
          staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          padding: EdgeInsets.only(top: 0),
          itemCount: sumRatingAll.length,
          itemBuilder: (BuildContext context, int index) {
            print("index = " + index.toString());
            double initialRating = double.parse((index + 1).toString());
            return Container(
                width: 60,
                margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(28),
                      blurRadius: 5,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: [
                    RatingBar.builder(
                      ignoreGestures: true,
                      itemSize: 10,
                      initialRating: initialRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: index + 1,
                      itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                    Style().textSizeColor(
                        sumRatingAll[index].toString(), 12, Style().darkColor),
                  ],
                ));
          }),
    );
  }

  showRatingAndComment(AppDataModel appDataModel) {
    List<RatingListModel> ratingListModel;
    ratingListModel = appDataModel.shopRatingList;

    return Container(
      child: Column(
        children: ratingListModel.mapIndexed((int index, element) {


          var date = DateTime.fromMillisecondsSinceEpoch(int.parse(element.orderId));
          var formattedDate = DateFormat('dd/MM/yyyy').format(date);

          double shopRate = double.parse(element.shopRate);
          int initialRating = shopRate.toInt();
          return Container(
              margin: EdgeInsets.only(left: 20, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(children: [Style().textBlackSize(formattedDate, 12)],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RatingBar.builder(
                        ignoreGestures: true,
                        itemSize: 20,
                        initialRating: shopRate,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: initialRating,
                        itemPadding: EdgeInsets.symmetric(horizontal: 0.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                      Style().textBlackSize(" " + element.shopRate, 12)
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Style().textBlackSize(element.shopComment, 14)],
                  ), Container(
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 0.3, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ));
        }).toList(),
      ),
    );
  }
}
