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
  final Authentication _auth = Authentication();
  final _searchTextFieldController = TextEditingController();
  List<Course> _filteredCourses;
  List<Course> _courses;
  Map<String, Course> _selectedCourses;
  String _userUID;
  bool _isAddMode;
  bool _isSearchMode;

  @override
  void initState() {
    super.initState();

    initCourses();
    _filteredCourses = List<Course>();
    _isSearchMode = false;
    _searchTextFieldController.addListener(_handleSearchTextFieldOnChange);
    _selectedCourses = Map<String, Course>();
    _isAddMode = false;
    _auth.firebaseAuth.currentUser().then((FirebaseUser user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed(LoginPage.tag);
      } else {
        _userUID = user.uid;
      }
    });
  }

  @override
  void dispose() {
    _searchTextFieldController.removeListener(_handleSearchTextFieldOnChange);
    _searchTextFieldController.dispose();

    super.dispose();
  }

  void _displaySearchBar() {
    _filteredCourses = _courses.sublist(0);

    setState(() {
      _isSearchMode = true;
    });
  }

  void _hideSearchBar() {
    _clearSearchTextField();
    _filteredCourses.clear();

    setState(() {
      _isSearchMode = false;   
    });
  }

  void _clearSearchTextField() {
    _searchTextFieldController.clear();
  }

  void _handleSearchTextFieldOnChange() {
    _filterSearches();
  }

  void _filterSearches() {
    List<Course> filteredCourses = List<Course>();

    _courses.forEach((Course course) {
      if (course.name.toLowerCase().contains(_searchTextFieldController.text.trim().toLowerCase())) {
        filteredCourses.add(course);
      }
    });   

    setState(() {
      _filteredCourses = filteredCourses;
    });
  }

  void initCourses() {
    _courses = GetCourses().generateCSCoursesList();
  }

  void clearSelectedCourses() {
    _selectedCourses.clear();
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

  void _handleCheckboxOnChanged(bool checkboxVal, int index) {
    if (!checkboxVal) {
      _selectedCourses.remove(_courses[index].name);
    } else {
      _selectedCourses[_courses[index].name] = _courses[index];
    }

    setState(() {
      _courses[index].toggleSelected();
    });
  }

  void _toggleIsAddMode() {
    setState(() {
      _isAddMode = !_isAddMode;

      if (!_isAddMode) {
        clearSelectedCourses();
        initCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextField searchTextField = TextField(
      controller: _searchTextFieldController,
      decoration: InputDecoration(
        hintText: 'Search',
      ),
    );

    final AppBar appBar = AppBar(
        title: _isSearchMode ? 
          searchTextField
          : Text('Add Courses'),
        leading: _isSearchMode ? 
            IconButton(icon: Icon(Icons.arrow_back), onPressed: _hideSearchBar) : null, 
        actions: _isSearchMode ? 
          <Widget> [
            IconButton(icon: Icon(Icons.clear), onPressed: _clearSearchTextField)
          ] : <Widget>[
                IconButton(icon:Icon(Icons.search), onPressed: _displaySearchBar),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: _toggleIsAddMode
                ),
                IconButton(
                  icon: Icon(Icons.save_alt),
                  onPressed: _selectedCourses.length > 0 ? _askedToSaveCourses : null,
                )
              ],
    );

    final ListView filteredListView = ListView.builder(
        itemCount: _filteredCourses.length,
        itemBuilder: (context, index) {
          return Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: ExpansionTile(
                key: PageStorageKey<String>(_filteredCourses[index].name),
                title: ListTile(
                  title: Text('${_filteredCourses[index].name}'),
                  subtitle: Text(
                    '${_filteredCourses[index].title}',
                  ),
                  leading: _isAddMode
                      ? Checkbox(
                          value: _filteredCourses[index].selected,
                          onChanged: (bool checkboxVal) {
                            _handleCheckboxOnChanged(checkboxVal, index);
                          })
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
                        Text('Units: ${_filteredCourses[index].units}'),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text('Prerequisite'),
                        SizedBox(
                          height: 3.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text('${_filteredCourses[index].prereq}')),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text('Description'),
                        SizedBox(
                          height: 3.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text('${_filteredCourses[index].description}')),
                      ],
                    ),
                  )
                ],
              ));
        },
      );

    final ListView defaultListView = ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          return Card(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: ExpansionTile(
                key: PageStorageKey<String>(_courses[index].name),
                title: ListTile(
                  title: Text('${_courses[index].name}'),
                  subtitle: Text(
                    '${_courses[index].title}',
                  ),
                  leading: _isAddMode
                      ? Checkbox(
                          value: _courses[index].selected,
                          onChanged: (bool checkboxVal) {
                            _handleCheckboxOnChanged(checkboxVal, index);
                          })
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
                        Text('Units: ${_courses[index].units}'),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text('Prerequisite'),
                        SizedBox(
                          height: 3.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text('${_courses[index].prereq}')),
                        SizedBox(
                          height: 20.0,
                        ),
                        Text('Description'),
                        SizedBox(
                          height: 3.0,
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text('${_courses[index].description}')),
                      ],
                    ),
                  )
                ],
              ));
        },
      );

    return Scaffold(
      appBar: appBar,
      body: _isSearchMode ? filteredListView : defaultListView
    );
  }
}
