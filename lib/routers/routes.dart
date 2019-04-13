import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import './router_handle.dart';

class Routes {
  static String root = '/';
  static String detailPage = '/detail';
  static void configureRoutes(Router router) {
    router.notFoundHandler = new Handler(
      handlerFunc: (BuildContext context, Map<String, List<String>> parmas) {
        print('ERROR=====> ROUTE WAS NOT FONUND!!!!!!');
      }
    );
    router.define(detailPage, handler: detailsHendler);
  }
}