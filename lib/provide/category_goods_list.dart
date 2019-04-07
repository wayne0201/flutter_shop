import 'package:flutter/material.dart';
import '../model/category_goods_list.dart';


class CategoryGoodsProvide with ChangeNotifier{
  List<CategoryGoodsData> _goodList = [];
  List<CategoryGoodsData> get goodList => _goodList;

  getGoodsList(List<CategoryGoodsData> list) {
    _goodList = list;
    notifyListeners();
  }

  getMoreList(List<CategoryGoodsData> list) {
    _goodList.addAll(list);
    notifyListeners();
  }
}