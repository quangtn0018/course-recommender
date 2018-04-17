import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/add_courses_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) =>  LoginPage(),
    HomePage.tag: (context) =>  HomePage(),
    AddCoursesPage.tag: (context) =>  AddCoursesPage(),
  };

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Course Recommender',
      home:  LoginPage(),
      routes: routes
    );
  }
}
