import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'login_page.dart';
import 'add_courses_page.dart';
import '../util/authentication.dart';
import '../models/course.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Authentication _auth = Authentication();
  List<Course> _savedCourses;
  bool _isEditMode;
  String _userUID;

  @override
  void initState() {
    super.initState();

    _isEditMode = false;
    _savedCourses = List<Course>();
    _auth.firebaseAuth.currentUser().then((FirebaseUser user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed(LoginPage.tag);
      } else {
        _userUID = user.uid;
        fetchUserCourses();
      }
    });
  }

  @override
  void dispose() {
    final userCoursesRef =
        FirebaseDatabase.instance.reference().child('users/$_userUID/courses');
    userCoursesRef.onChildAdded.listen(_onCourseAdded).cancel();
    super.dispose();
  }

  void fetchUserCourses() {
    final userCoursesRef =
        FirebaseDatabase.instance.reference().child('users/$_userUID/courses');
    userCoursesRef.onChildAdded.listen(_onCourseAdded);
  }

  void _onCourseAdded(Event event) {
    setState(() {
      _savedCourses.add(Course.fromSnapshot(event.snapshot));
    });
  }

  void _toggleIsEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  void _handleLogout() async {
    await _auth.signOutWithGoogle();
    Navigator.of(context).pushNamed(LoginPage.tag);
  }

  void _navToAddCourses() {
    _isEditMode = false;
    Navigator.of(context).pushNamed(AddCoursesPage.tag);
  }

  Future<Null> _removeCourseFromDB(String courseName) async {
    final userCourseRef = FirebaseDatabase.instance
        .reference()
        .child('users/${_userUID}/courses/$courseName');

    await userCourseRef.remove();
  }

  void _removeCourseFromList(int index) {
    setState(() {
      _savedCourses.remove(_savedCourses[index]);
    });
  }

  Future<Null> _askedToRemoveCourse(int index) async {
    await showDialog<Null>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(
              'Remove Selected Course?',
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
                      _removeCourseFromDB(_savedCourses[index].name);
                      _removeCourseFromList(index);
                      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          _toggleIsEditMode();
        },
      ),
      appBar: AppBar(
        title: Text('My Courses'),
        automaticallyImplyLeading: false,
        leading:
            IconButton(icon: Icon(Icons.exit_to_app), onPressed: _handleLogout),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navToAddCourses,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: _savedCourses.length,
        itemBuilder: (context, index) {
          return Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: ExpansionTile(
                key: PageStorageKey<String>(_savedCourses[index].name),
                title: ListTile(
                  title: Text('${_savedCourses[index].name}'),
                  subtitle: Text(
                    '${_savedCourses[index].title}',
                  ),
                  leading: _isEditMode
                      ? IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () {
                            _askedToRemoveCourse(index);
                          },
                        )
                      : null,
                ),
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(17.0, 0.0, 20.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 5.0,
                        ),
                        Text('Units: ${_savedCourses[index].units}'),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text('Prerequisite'),
                        SizedBox(
                          height: 3.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text('${_savedCourses[index].prereq}')),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text('Description'),
                        SizedBox(
                          height: 3.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text('${_savedCourses[index].description}')),
                      ],
                    ),
                  )
                ],
              ));
        },
      ),
    );
  }
}
