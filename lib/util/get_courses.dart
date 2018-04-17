import '../models/course.dart';
import '../constants/courses.dart';

class GetCourses {
  static final GetCourses _singleton = new GetCourses._internal();

  factory GetCourses() {
    return _singleton;
  }

  GetCourses._internal();

  List<Course> generateCSCoursesList() {
    List<Course> result = List<Course>();

    courses.forEach((_, value) {
      result.add(Course(
          name: value.name,
          title: value.title,
          description: value.description,
          prereq: value.prereq,
          units: value.units));
    });

    return result;
  }
}
