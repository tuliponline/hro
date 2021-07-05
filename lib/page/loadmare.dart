import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:loadmore/loadmore.dart';
import 'package:provider/provider.dart';

class LoadMorePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoadMoreState();
  }
}

class LoadMoreState extends State<LoadMorePage> {
  int get count => list.length;
  List<int> list = [];
  int productLength;
  bool getData = false;
  List<ProductsModel> ranProductModel;


  void load() {
    print("load");
    setState(() {
      int showCount = 10;
      int leftCount = (productLength - list.length) ;
      if ( leftCount > 10){
        list.addAll(List.generate(showCount, (v) => v));
      }else{
        list.addAll(List.generate((leftCount), (v) => v));
      }
      print("data count = ${list.length}");
      print("productCount = $productLength");
      getData = true;
    });
  }



  _getAllProduct(AppDataModel appDataModel) async {
    await FirebaseFirestore.instance
        .collection('products')
        .where('product_status', isEqualTo: '1')
        .get()
        .then((value) async {
      List<DocumentSnapshot> templist;
      List list = new List();
      templist = value.docs;
      list = templist.map((DocumentSnapshot docSnapshot) {
        return docSnapshot.data();
      }).toList();
      var jsonData = jsonEncode(list);
      //print('allProductJsonData' + jsonData.toString());
      ranProductModel = productsModelFromJson(jsonData);
      productLength = ranProductModel.length;
      load();
    });
  }

  // appDataModel.storeProductsData

  @override
  Widget build(BuildContext context) {
    if (getData == false) _getAllProduct(context.read<AppDataModel>());
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              body: Container(
                child: RefreshIndicator(
                  child: LoadMore(
                    isFinish: count >= productLength,
                    onLoadMore: _loadMore,
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Text("product $index" +
                                ranProductModel[index].productName),
                            Container(
                              child: Text(list[index].toString() +
                                  "count =" +
                                  productLength.toString()),
                              height: 40.0,
                              color: Colors.greenAccent,
                              alignment: Alignment.center,
                            ),
                            Container(
                                width: 150,
                                height: 150,
                                child: Image.network(
                                    ranProductModel[index].productPhotoUrl))
                          ],
                        );
                      },
                      itemCount: count,
                    ),
                    whenEmptyLoad: false,
                    delegate: DefaultLoadMoreDelegate(),
                    textBuilder: DefaultLoadMoreTextBuilder.english,
                  ),
                  onRefresh: _refresh,
                ),
              ),
            ));
  }

  Future<bool> _loadMore() async {
    print("onLoadMore");
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return true;
  }

  Future<void> _refresh() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    list.clear();
    load();
  }
}
