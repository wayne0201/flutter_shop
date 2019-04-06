import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

import '../provide/child_category.dart';
import '../service/service_method.dart';
import '../model/category.dart';
import '../model/categoryGoodsList.dart';

class CategoryPage extends StatefulWidget {
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categoryList = [];

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
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('商品分类'),
      ),
      body: Container(
        child: Row(
          children: <Widget>[
            LeftCategoryNav(categoryList: categoryList),
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
  final List categoryList;

  LeftCategoryNav({Key key, this.categoryList}) : super(key: key);

  @override
  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  int listIndex = 0;
  @override
  Widget build(BuildContext context) {
    List categoryList = widget.categoryList;
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
          return _leftInWell(categoryList, index);
        },
      ),
    );
  }

  Widget _leftInWell(List categoryList, int index) {
    bool click = (index == listIndex);
    return InkWell(
      onTap: () {
        setState(() {
          listIndex = index;
        });
        List childList = categoryList[index].bxMallSubDto;
        Provide.value<ChildCategory>(context).getChildCategory(childList);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(25),
        ),
        decoration: BoxDecoration(
          color: click ? Color.fromRGBO(236, 236, 236, 1.0) : Colors.white,
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
              itemBuilder: (content, index) {
                return _rightInwell(childCategory.childCategoryList[index]);
              },
            ),
      ),
    );
  }

  Widget _rightInwell(BxMallSubDto item) {
    return InkWell(
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
}

class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  List goodsList = [];

  @override
  void initState() {
    _getGoodsList();
    super.initState();
  }

  void _getGoodsList() {
    Map data = {'categoryId': '4', 'CategorySubId': '', 'page': 1};
    request('getMallGoods', formData: data).then((val) {
      var data = json.decode(val.toString());
      CategoryGoodsListModel goods = CategoryGoodsListModel.fromJson(data);
      setState(() {
        goodsList = goods.data;
      });
    });
  }

  @override
  Widget build(BuildContext context) => Expanded(
        flex: 1,
        child: Container(
          width: ScreenUtil().setWidth(570),
          color: Colors.black54,
          child: ListView.builder(
            itemCount: goodsList.length,
            itemBuilder: (context, index) => _listWidget(index),
          ),
        ),
      );

  Widget _listWidget(int index) => InkWell(
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
              _goodsImage(index),
              Column(
                children: <Widget>[
                  _goodsName(index),
                  _goodsPrice(index),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _goodsImage(int index) => Container(
        width: ScreenUtil().setWidth(200),
        child: Image.network(goodsList[index].image),
      );

  Widget _goodsName(int index) => Container(
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

  Widget _goodsPrice(int index) => Container(
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
