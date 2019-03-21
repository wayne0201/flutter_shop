import 'dart:convert';
import 'package:flutter/material.dart';
import '../service/service_method.dart';

class CategoryPage extends StatefulWidget {

  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    _getCategory();
    return Container(
      child: Center(
        child: Text('12344'),
      )
    );
  }

  void _getCategory() async{
    await request('getCategory').then((val) {
      var data = json.decode(val.toString());
      print(data);
    });
  }
}
