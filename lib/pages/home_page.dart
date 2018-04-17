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
  _HomePageState createState() =>  _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Authentication _auth = Authentication();
  List<Course> _savedCourses;

  @override
  void initState() {
    super.initState();

    _savedCourses = List<Course>();
    _auth.firebaseAuth.currentUser().then((FirebaseUser user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed(LoginPage.tag);
      } else {
        // TODO fetchUserCourses
        final userCoursesRef = FirebaseDatabase.instance.reference().child('users/${user.uid}/courses');
        userCoursesRef.onChildAdded.listen(_onCourseAdded);
        userCoursesRef.onChildRemoved.listen(_onCourseRemoved);
      }
    });
  }
  void _onCourseAdded(Event event) {
    setState(() {
       _savedCourses.add(Course.fromSnapshot(event.snapshot));
    });
  }

  void _onCourseRemoved(Event event) {
    // TODO implement remove ??
    // setState(() {
    //    _savedCourses.remove(Course.fromSnapshot(event.snapshot));
    // });
  }

  void _handleLogout() async {
    await _auth.signOutWithGoogle();
    Navigator.of(context).pushNamed(LoginPage.tag);
  }

  void _navToAddCourses() {
    Navigator.of(context).pushNamed(AddCoursesPage.tag);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Courses'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: _handleLogout
        ),
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
          return ListTile(
            title: Text('${_savedCourses[index].name}'),
            subtitle: Text('${_savedCourses[index].title}'),
            trailing: IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  // TODO go to course info page
                },
              ),
          );
        },
      ),
    );
  }
}
