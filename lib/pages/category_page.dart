import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';

import '../provide/child_category.dart';
import '../service/service_method.dart';
import '../model/category.dart';

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
  List list = [];
  int listIndex = 0;

  @override
  void initState() {
    _getCategory();
    super.initState();
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
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _leftInWell(index);
        },
      ),
    );
  }

  Widget _leftInWell(int index) {
    bool click = (index == listIndex);
    
    return InkWell(
      onTap: () {
        setState(() {
          listIndex = index;
        });
        List childList = list[index].bxMallSubDto;
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
            list[index].mallCategoryName,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(28),
            ),
          ),
        ),
      ),
    );
  }

  void _getCategory() async {
    await request('getCategory').then((val) {
      var res = json.decode(val.toString());
      CategoryModel category = CategoryModel.fromJson(res);
      setState(() {
        list = category.data;
      });
      Provide.value<ChildCategory>(context).getChildCategory(list[0].bxMallSubDto);
    });
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
          bottom: BorderSide(width: 1, color: Colors.black12),
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
