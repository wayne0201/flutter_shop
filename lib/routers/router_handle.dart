import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import '../pages/details_page.dart';

Handler detailsHendler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    String goodId = params['id'].first;
    print('index details goodId is $goodId');
    return DetailsPage(goodId);
  },
);


