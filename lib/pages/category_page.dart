import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return InkWell(
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(25),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
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
      onTap: () {},
    );
  }

  void _getCategory() async {
    await request('getCategory').then((val) {
      var res = json.decode(val.toString());
      CategoryModel category = CategoryModel.fromJson(res);
      setState(() {
        list = category.data;
      });
    });
  }
}
