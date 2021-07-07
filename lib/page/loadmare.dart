import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/productsModel.dart';
import 'package:hro/utility/fetcProduct.dart';
import 'package:provider/provider.dart';

class ListScreen extends StatefulWidget {
  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<ProductsModel> _pairList=[] ;

  final _itemFetcher = fetchProduct;

  bool _isLoading = true;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _hasMore = true;
    _loadMore(context.read<AppDataModel>());
  }

  // Triggers fecth() and then add new items or change _hasMore flag
  void _loadMore( AppDataModel appDataModel) {
    _isLoading = true;
    _itemFetcher(appDataModel.allProductsData).then((value) => {
          if (value.isEmpty)
            {
              setState(() {
                _isLoading = false;
                _hasMore = false;
              })
            }
          else
            {
              setState(() {
                _isLoading = false;
                _pairList.addAll(value);
              })
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              body: Scaffold(

                body: SingleChildScrollView(
                  child: Container(
                    child: StaggeredGridView.countBuilder(

                      shrinkWrap: true,
                      primary: false,
                      crossAxisCount: 4,
                      itemCount: 8,
                      itemBuilder: (BuildContext context, int index) => new Container(
                          color: Colors.green,
                          child: new Center(
                            child: new CircleAvatar(
                              backgroundColor: Colors.white,
                              child: new Text('$index'),
                            ),
                          )),
                      staggeredTileBuilder: (int index) =>
                      new StaggeredTile.count(2, index.isEven ? 2 : 1),
                      mainAxisSpacing: 4.0,
                      crossAxisSpacing: 4.0,
                    ),
                  ),
                ),
              ),
            ));
  }
}
