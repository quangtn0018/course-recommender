import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'home_page.dart';
import '../models/course.dart';
import '../util/authentication.dart';
import '../util/get_courses.dart';

class AddCoursesPage extends StatefulWidget {
  static String tag = 'add-courses-page';
  @override
  _AddCoursesPageState createState() => _AddCoursesPageState();
}

class _AddCoursesPageState extends State<AddCoursesPage> {
  final List<Course> _courses = GetCourses().generateCSCoursesList();
  final Authentication _auth = Authentication();
  String _userUID;
  Map<String, Course> _selectedCourses = Map<String, Course>();

  @override
  void initState() {
    super.initState();
    _auth.firebaseAuth.currentUser().then((FirebaseUser user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed(LoginPage.tag);
      } else {
        _userUID = user.uid;
      }
    });
  }

  Future<Null> _addCoursesToDB() async {
    final userCoursesRef =
        FirebaseDatabase.instance.reference().child('users/$_userUID/courses');
    Map<String, dynamic> newVal = Map<String, dynamic>();

    _selectedCourses.forEach((key, value) {
      newVal[key] = value.toJson();
    });

    userCoursesRef.update(newVal);
  }

  Future<Null> _askedToSaveCourses() async {
    await showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              'Add Selected Courses?',
            ),
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Cancel',
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      _addCoursesToDB().then((_) =>
                          Navigator.popAndPushNamed(context, HomePage.tag));
                    },
                    child: Text(
                      'Submit',
                    ),
                  )
                ],
              )
            ],
          );
        });
  }

  void _handleListTileOnChanged(bool checkboxVal, int index) {
    if (!checkboxVal) {
      _selectedCourses.remove(_courses[index].name);
    } else {
      _selectedCourses[_courses[index].name] = _courses[index];
    }

    setState(() {
      _courses[index].toggleSelected();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Courses'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: _selectedCourses.length > 0 ? _askedToSaveCourses : null,
          )
        ],
      ),
      body: ListView.builder(
          itemCount: _courses.length,
          itemBuilder: (context, index) {
            return Column(children: <Widget>[
              CheckboxListTile(
                  title: Text('${_courses[index].name}'),
                  subtitle: Text('${_courses[index].title}'),
                  value: _courses[index].selected,
                  onChanged: (bool checkboxVal) {
                    _handleListTileOnChanged(checkboxVal, index);
                  }),
              Divider(
                height: 1.0,
              )
            ]);
          }),
    );
  }
}
