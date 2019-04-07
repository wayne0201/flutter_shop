import 'package:flutter/material.dart';
import 'package:provide/provide.dart';

import './provide/counter.dart';
import './provide/child_category.dart';
import './provide/category_goods_list.dart';

import './pages/index_page.dart';

void main() {
  Counter counter = Counter();
  ChildCategory childCategory = ChildCategory();
  CategoryGoodsProvide categoryGoodsProvide = CategoryGoodsProvide();

  Providers providers = Providers();

  providers
    ..provide(Provider<Counter>.value(counter))
    ..provide(Provider<ChildCategory>.value(childCategory))
    ..provide(Provider<CategoryGoodsProvide>.value(categoryGoodsProvide));

  runApp(ProviderNode(providers: providers, child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: '百姓生活',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.pink,
        ),
        home: IndexPage(),
      ),
    );
  }
}
