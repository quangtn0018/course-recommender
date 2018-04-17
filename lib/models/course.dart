import 'package:firebase_database/firebase_database.dart';

class Course {
    final String name;
    final String title;
    final String description;
    final String prereq;
    final String units;
    bool selectedForAdding;
    
    Course({
        this.name,
        this.title,
        this.description,
        this.prereq,
        this.units,
        this.selectedForAdding = false,
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
            'units': units
        };
    }

    Course.fromSnapshot(DataSnapshot snapshot) 
        : name = snapshot.value['name'],
        title = snapshot.value['title'],
        description = snapshot.value['description'],
        prereq = snapshot.value['prereq'],
        units = snapshot.value['units'];
                                                

    void toggleSelectedForAdding() => selectedForAdding = !selectedForAdding;
}
