import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

import '../service/service_method.dart';
import '../model/category.dart';
import '../model/category_goods_list.dart';

import '../provide/child_category.dart';
import '../provide/category_goods_list.dart';

class CategoryPage extends StatefulWidget {
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品分类'),
      ),
      body: Container(
        child: Row(
          children: <Widget>[
            LeftCategoryNav(),
            Column(
              children: <Widget>[
                RightCategoryNav(),
                CategoryGoodsList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LeftCategoryNav extends StatefulWidget {
  @override
  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List categoryList = [];
  int listIndex = 0;

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  void _getCategory() => request('getCategory').then((val) {
        var res = json.decode(val.toString());
        CategoryModel category = CategoryModel.fromJson(res);
        setState(() {
          categoryList = category.data;
        });
        Provide.value<ChildCategory>(context)
            .getChildCategory(categoryList[0].bxMallSubDto);
        _getGoodsList(categoryId: categoryList[0].mallCategoryId);
      });

  void _getGoodsList({String categoryId}) {
    Map data = {
      'categoryId': categoryId == null ? '4' : categoryId,
      'CategorySubId': '',
      'page': 1
    };
    request('getMallGoods', formData: data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goods = CategoryGoodsListModel.fromJson(data);
      Provide.value<CategoryGoodsProvide>(context).getGoodsList(goods.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            width: 1,
            color: Colors.black12,
          ),
        ),
      ),
      child: ListView.builder(
        itemCount: categoryList.length,
        itemBuilder: (context, index) {
          return _leftInWell(index);
        },
      ),
    );
  }

  Widget _leftInWell(int index) => InkWell(
        onTap: () {
          setState(() {
            listIndex = index;
          });
          List childList = categoryList[index].bxMallSubDto;
          String categoryId = categoryList[index].mallCategoryId;
          Provide.value<ChildCategory>(context).getChildCategory(childList);
          _getGoodsList(categoryId: categoryId);
        },
        child: Container(
          height: ScreenUtil().setHeight(100),
          padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(25),
          ),
          decoration: BoxDecoration(
            color: (index == listIndex)
                ? Color.fromRGBO(236, 236, 236, 1.0)
                : Colors.white,
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: Colors.black12,
              ),
            ),
          ),
          child: Align(
            alignment: FractionalOffset.centerLeft,
            child: Text(
              categoryList[index].mallCategoryName,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
          ),
        ),
      );
}

class RightCategoryNav extends StatefulWidget {
  @override
  _RightCategoryNavState createState() => _RightCategoryNavState();
}

class _RightCategoryNavState extends State<RightCategoryNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setWidth(80),
      width: ScreenUtil().setWidth(570),
      decoration: BoxDecoration(
        color: Colors.white,
        border: BorderDirectional(
          bottom: BorderSide(
            width: 1,
            color: Colors.black12,
          ),
        ),
      ),
      child: Provide<ChildCategory>(
        builder: (context, child, childCategory) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategory.childCategoryList.length,
              itemBuilder: (content, index) =>
                  _rightInwell(childCategory.childCategoryList[index]),
            ),
      ),
    );
  }

  Widget _rightInwell(BxMallSubDto item) => InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(15), 0, ScreenUtil().setWidth(15), 0),
          child: Center(
            child: Text(
              item.mallSubName,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
              ),
            ),
          ),
        ),
      );
}

class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Provide<CategoryGoodsProvide>(
        builder: (context, child, data) => Container(
              width: ScreenUtil().setWidth(570),
              child: ListView.builder(
                itemCount: data.goodList.length,
                itemBuilder: (context, index) =>
                    _listWidget(data.goodList, index),
              ),
            ),
      ),
    );
  }

  Widget _listWidget(List<CategoryGoodsData> goodsList, int index) => InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(
            top: 5.0,
            bottom: 5.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                width: 1.0,
                color: Colors.black12,
              ),
            ),
          ),
          child: Row(
            children: <Widget>[
              _goodsImage(goodsList, index),
              Column(
                children: <Widget>[
                  _goodsName(goodsList, index),
                  _goodsPrice(goodsList, index),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _goodsImage(List<CategoryGoodsData> goodsList, int index) => Container(
        width: ScreenUtil().setWidth(200),
        child: Image.network(goodsList[index].image),
      );

  Widget _goodsName(List<CategoryGoodsData> goodsList, int index) => Container(
        padding: EdgeInsets.all(5.0),
        width: ScreenUtil().setWidth(370),
        child: Text(
          goodsList[index].goodsName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: ScreenUtil().setSp(28),
          ),
        ),
      );

  Widget _goodsPrice(List<CategoryGoodsData> goodsList, int index) => Container(
        width: ScreenUtil().setWidth(370),
        margin: EdgeInsets.only(
          top: 20.0,
        ),
        child: Row(
          children: <Widget>[
            Text(
              '价格：￥${goodsList[index].presentPrice}',
              style: TextStyle(
                color: Colors.pink,
                fontSize: ScreenUtil().setSp(30),
              ),
            ),
            Text(
              '￥${goodsList[index].oriPrice}',
              style: TextStyle(
                color: Colors.black26,
                decoration: TextDecoration.lineThrough,
                fontSize: ScreenUtil().setSp(22),
              ),
            ),
          ],
        ),
      );
}
