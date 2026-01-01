import 'package:flutter/material.dart';
import 'package:tool4all/pages/search_page.dart';
import 'package:tool4all/pages/tutorials_page.dart';
import 'package:tool4all/pages/support_page.dart';
void main() => runApp(MaterialApp(
  initialRoute: '/search',
  routes: {
    '/search' : (context) => search_page(),
    '/tutorials' : (context) => tutorials_page(),
    '/support': (context) => support_page(),
  },
));