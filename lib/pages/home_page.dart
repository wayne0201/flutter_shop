import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../service/service_method.dart';

class HomePage extends StatefulWidget {
  final Widget child;

  HomePage({Key key, this.child}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  int page = 1;
  List<Map> hotGoodsList = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    print('[log]:HomePage');
    _getHotGoods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var formData = {
      'lon': '115.02932',
      'lat': '35.76189',
    };
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: Text('百姓生活+'),
          ),
          body: FutureBuilder(
            future: request('homePageContent', formData: formData),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = json.decode(snapshot.data.toString());
                Map _date = data['data'];
                List<Map> swiper = (_date['slides'] as List).cast();
                List<Map> navgatorList = (_date['category'] as List).cast();
                List<Map> recommendList = (_date['recommend'] as List).cast();
                List<Map> floor1 = (_date['floor1'] as List).cast();
                List<Map> floor2 = (_date['floor2'] as List).cast();
                List<Map> floor3 = (_date['floor3'] as List).cast();
                String adPicture = _date['advertesPicture']['PICTURE_ADDRESS'];
                String leaderPhone = _date['shopInfo']['leaderPhone'];
                String leaderImage = _date['shopInfo']['leaderImage'];
                String floor1Title = _date['floor1Pic']['PICTURE_ADDRESS'];
                String floor2Title = _date['floor2Pic']['PICTURE_ADDRESS'];
                String floor3Title = _date['floor3Pic']['PICTURE_ADDRESS'];
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SwiperDiy(
                        swiperDateList: swiper,
                      ),
                      TopNavigator(
                        navigatorList: navgatorList,
                      ),
                      AdBanner(
                        adPicture: adPicture,
                      ),
                      LeaderPhone(
                        leaderImage: leaderImage,
                        leaderPhone: leaderPhone,
                      ),
                      Recommend(
                        recommendList: recommendList,
                      ),
                      FloorTitle(prctureAddress: floor1Title),
                      FloorContent(
                        floorGoodList: floor1,
                      ),
                      FloorTitle(prctureAddress: floor2Title),
                      FloorContent(
                        floorGoodList: floor2,
                      ),
                      FloorTitle(prctureAddress: floor3Title),
                      FloorContent(
                        floorGoodList: floor3,
                      ),
                      _hotGoods(),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    '加载中...',
                  ),
                );
              }
            },
          )),
    );
  }

  void _getHotGoods() {
    var formData = {
      'page': page,
    };
    request('homePageBelowConten', formData: formData).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['data'] as List).cast();
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  Widget _hotTitle() => Container(
        margin: EdgeInsets.only(top: 10.0),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Text('火爆专区'),
      );

  Widget _wrapList() {
    if (hotGoodsList.isNotEmpty) {
      List<Widget> listWidget = hotGoodsList.map((val) {
        return InkWell(
          onTap: () {},
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                Image.network(
                  val['image'],
                  width: ScreenUtil().setWidth(370),
                ),
                Text(
                  val['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: ScreenUtil().setSp(26),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "￥${val['mallPrice']}",
                    ),
                    Text(
                      "￥${val['price']}",
                      style: TextStyle(
                        color: Colors.black26,
                        decoration: TextDecoration.lineThrough,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Text('');
    }
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[_hotTitle(), _wrapList()],
      ),
    );
  }
}

// 首页轮播组件
class SwiperDiy extends StatelessWidget {
  final List swiperDateList;

  SwiperDiy({Key key, this.swiperDateList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext content, int index) {
          return Image.network(
            "${swiperDateList[index]['image']}",
            fit: BoxFit.fill,
          );
        },
        itemCount: swiperDateList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context, item) {
    return InkWell(
      onTap: () {
        print("点击了导航");
      },
      child: Column(
        children: <Widget>[
          Image.network(
            item["image"],
            width: ScreenUtil().setWidth(95),
          ),
          Text(
            item["mallCategoryName"],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (navigatorList.length > 10) {
      navigatorList.removeRange(10, navigatorList.length);
    }
    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.all(5.0),
        children: navigatorList.map((item) {
          return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
}

class AdBanner extends StatelessWidget {
  final String adPicture;

  AdBanner({Key key, this.adPicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(
        adPicture,
      ),
    );
  }
}

class LeaderPhone extends StatelessWidget {
  final String leaderImage;
  final String leaderPhone;

  LeaderPhone({Key key, this.leaderImage, this.leaderPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async {
    String url = 'tel:$leaderPhone';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'url不能进行访问！';
    }
  }
}

class Recommend extends StatelessWidget {
  final List recommendList;

  Recommend({Key key, this.recommendList}) : super(key: key);

  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 0, 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.black12,
          ),
        ),
      ),
      child: Text(
        '商品推荐',
        style: TextStyle(color: Colors.pink),
      ),
    );
  }

  Widget _item(index) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(
              width: 1,
              color: Colors.black12,
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Image.network(
              recommendList[index]['image'],
            ),
            Text(
              "￥${recommendList[index]['mallPrice']}",
            ),
            Text(
              "￥${recommendList[index]['mallPrice']}",
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recommedList() {
    return Container(
      height: ScreenUtil().setHeight(330),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommendList.length,
        itemBuilder: (context, index) {
          return _item(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(410),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommedList(),
        ],
      ),
    );
  }
}

class FloorTitle extends StatelessWidget {
  final String prctureAddress;

  FloorTitle({Key key, this.prctureAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Image.network(prctureAddress),
    );
  }
}

class FloorContent extends StatelessWidget {
  final List floorGoodList;

  FloorContent({Key key, this.floorGoodList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherGoods(),
        ],
      ),
    );
  }

  Widget _firstRow() {
    return Row(
      children: <Widget>[
        _goodItem(floorGoodList[0]),
        Column(
          children: <Widget>[
            _goodItem(floorGoodList[1]),
            _goodItem(floorGoodList[2]),
          ],
        ),
      ],
    );
  }

  Widget _otherGoods() {
    return Row(
      children: <Widget>[
        _goodItem(floorGoodList[3]),
        _goodItem(floorGoodList[4]),
      ],
    );
  }

  Widget _goodItem(Map goods) {
    return Container(
      width: ScreenUtil().setWidth(375),
      child: InkWell(
        onTap: () {
          print('点击了楼层商品');
        },
        child: Image.network(goods['image']),
      ),
    );
  }
}
