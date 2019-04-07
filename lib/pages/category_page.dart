import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import '../service/service_method.dart';
import '../model/category.dart';
import '../model/category_goods_list.dart';

import '../provide/child_category.dart';
import '../provide/category_goods_list.dart';

Future getGoodsList(
  String categoryId, {
  String categorySubId = '',
  int page = 1,
}) =>
    request(
      'getMallGoods',
      formData: {
        'categoryId': categoryId,
        'categorySubId': categorySubId,
        'page': page
      },
    );

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
        Map res = json.decode(val.toString());
        CategoryModel category = CategoryModel.fromJson(res);
        setState(() {
          categoryList = category.data;
        });
        Provide.value<ChildCategory>(context).getChildCategory(
            categoryList[0].bxMallSubDto, categoryList[0].mallCategoryId);
        _getGoodsList();
      });

  void _getGoodsList() async {
    try {
      String categoryId = Provide.value<ChildCategory>(context).categoryId;
      String res = await getGoodsList(categoryId);
      Map data = json.decode(res.toString());
      CategoryGoodsListModel goods = CategoryGoodsListModel.fromJson(data);
      Provide.value<CategoryGoodsProvide>(context).getGoodsList(goods.data);
    } catch (e) {
      return print('[ERROR]:====>$e');
    }
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
          Provide.value<ChildCategory>(context)
              .getChildCategory(childList, categoryId);
          _getGoodsList();
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
                  _rightInwell(index, childCategory.childCategoryList[index]),
            ),
      ),
    );
  }

  Widget _rightInwell(int index, BxMallSubDto item) => InkWell(
        onTap: () {
          String subId = item.mallSubId;
          Provide.value<ChildCategory>(context).changeChildIndex(index, subId);
          _getGoodsList();
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(15), 0, ScreenUtil().setWidth(15), 0),
          child: Center(
            child: Text(
              item.mallSubName,
              style: TextStyle(
                fontSize: ScreenUtil().setSp(28),
                color: index == Provide.value<ChildCategory>(context).childIndex
                    ? Colors.pink
                    : Colors.black,
              ),
            ),
          ),
        ),
      );
  void _getGoodsList() async {
    try {
      String categoryId = Provide.value<ChildCategory>(context).categoryId;
      String subId = Provide.value<ChildCategory>(context).subId;
      String categorySubId = subId != "00" ? subId : "";
      String res = await getGoodsList(categoryId, categorySubId: categorySubId);
      Map data = json.decode(res.toString());
      CategoryGoodsListModel goods = CategoryGoodsListModel.fromJson(data);

      bool isNoMore = goods.data == null;
      List<CategoryGoodsData> goodsList = isNoMore ? [] : goods.data;

      Provide.value<CategoryGoodsProvide>(context).getGoodsList(goodsList);
    } catch (e) {
      return print('[ERROR]:====>$e');
    }
  }
}

class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  GlobalKey<RefreshFooterState> _footerkey = GlobalKey<RefreshFooterState>();

  ScrollController scrollController = ScrollController();

  void _getMoreGoodsList() async {
    try {
      Provide.value<ChildCategory>(context).addPage();
      String categoryId = Provide.value<ChildCategory>(context).categoryId;
      String categorySubId = Provide.value<ChildCategory>(context).subId;
      int page = Provide.value<ChildCategory>(context).page;
      String res = await getGoodsList(categoryId,
          categorySubId: categorySubId, page: page);
      Map data = json.decode(res.toString());
      CategoryGoodsListModel goods = CategoryGoodsListModel.fromJson(data);
      bool isNoMore = goods.data == null;
      List<CategoryGoodsData> goodsList = isNoMore ? [] : goods.data;
      if (isNoMore) {
        Provide.value<ChildCategory>(context).changeNoMore('没有更多了');
      } else {
        Provide.value<CategoryGoodsProvide>(context).getMoreList(goodsList);
      }
    } catch (e) {
      return print('[ERROR]:====>$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Provide<CategoryGoodsProvide>(
        builder: (context, child, data) {
          try {
            if ( Provide.value<ChildCategory>(context).page == 1) {
              scrollController.jumpTo(0.0);
            }
          } catch (e) {
            print('进入页面第一次初始化$e');
          }
          if (data.goodList.isNotEmpty) {
            return Container(
              width: ScreenUtil().setWidth(570),
              child: EasyRefresh(
                refreshFooter: ClassicsFooter(
                  key: _footerkey,
                  bgColor: Colors.white,
                  textColor: Colors.pink,
                  moreInfoColor: Colors.pink,
                  noMoreText: Provide.value<ChildCategory>(context).noMoreText,
                  moreInfo: '加载中',
                  loadReadyText: '上拉加载...',
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: data.goodList.length,
                  itemBuilder: (context, index) =>
                      _listWidget(data.goodList, index),
                ),
                loadMore: () {
                  _getMoreGoodsList();
                },
              ),
            );
          } else {
            return Center(
              child: Text('暂时没有数据！'),
            );
          }
        },
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
