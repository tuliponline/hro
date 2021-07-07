import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/model/productsModel.dart';



  // This async function simulates fetching results from Internet, etc.
  Future<List<ProductsModel>> fetchProduct(List<ProductsModel> productModel) async {
    print("fetcpriductModel "+productModel.length.toString());

    final _count = 5;
    final _itemsPerPage = 5;
    int _currentPage = 0;


    final list = <WordPair>[];
    final n = min(_itemsPerPage, _count - _currentPage * _itemsPerPage);

    List<String> ranProductList = [];
    List<ProductsModel> ranProductModel;

    print("n = " + n.toString());

    await Future.delayed(Duration(seconds: 3), () {
      for (int i = 0; i < n; i++) {

        var randomItem = (productModel..shuffle()).first;
        bool sameData = false;
        ranProductList.forEach((element) {
          if (element == jsonEncode(randomItem)) sameData = true;
        });
        if (sameData == false) {
          ranProductList.add(jsonEncode(randomItem));
          i++;
        }
      }
      String rowData = ranProductList.toString();
      ranProductModel = productsModelFromJson(rowData);
    });
    _currentPage++;
    return ranProductModel;
  }
