import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/loading_indicator.dart';
import '../models/course.dart';

class RecommendedCoursesPage extends StatelessWidget {
  final String userUID;
  RecommendedCoursesPage(this.userUID);

  Future<List<Course>> _fetchRecommendedCourses() async {
    final apiUrl =
        "http://quangtn0018.pythonanywhere.com/api/recommended-courses/$userUID";
    final response = await http.get(apiUrl);
    final responseJson = json.decode(response.body);
    List<Course> result = List<Course>();
    for (var course in responseJson) {
      result.add(Course.fromJson(course));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recommended Courses')),
      body: Center(
        child: FutureBuilder<List<Course>>(
          future: _fetchRecommendedCourses(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Card(
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: ExpansionTile(
                        key: PageStorageKey<String>(snapshot.data[index].name),
                        title: ListTile(
                          title: Text('${snapshot.data[index].name}'),
                          subtitle: Text(
                            '${snapshot.data[index].title}',
                          ),
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
                                Text('Units: ${snapshot.data[index].units}'),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Text('Prerequisite'),
                                SizedBox(
                                  height: 3.0,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child:
                                        Text('${snapshot.data[index].prereq}')),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Text('Description'),
                                SizedBox(
                                  height: 3.0,
                                ),
                                Padding(
                                    padding: EdgeInsets.only(left: 5.0),
                                    child: Text(
                                        '${snapshot.data[index].description}')),
                              ],
                            ),
                          )
                        ],
                      ));
                },
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // By default, show a loading spinner
            return LoadingIndicator();
          },
        ),
      ),
    );
  }
}
