import 'package:firebase_database/firebase_database.dart';

class Course {
    final String name;
    final String title;
    final String description;
    final String prereq;
    final String units;
    bool selected;
    
    Course({
        this.name,
        this.title,
        this.description,
        this.prereq,
        this.units,
        this.selected = false,
    }) : assert(name != null),
        assert(title != null),
        assert(description != null),
        assert(prereq != null),
        assert(units != null);

    Map<String, dynamic> toJson() {
        return {
            'name': name,
            'title': title,
            'description': description,
            'prereq': prereq,
            'units': units,
            'selected': selected
        };
    }

    Course.fromSnapshot(DataSnapshot snapshot) 
        : name = snapshot.value['name'],
        title = snapshot.value['title'],
        description = snapshot.value['description'],
        prereq = snapshot.value['prereq'],
        units = snapshot.value['units'],
        selected = snapshot.value['selected'];
                                                

    void toggleSelected() => selected = !selected;
}
