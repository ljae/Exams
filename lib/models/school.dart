class School {
  final String id;
  final String school_name;
  final String school_name_only;
  final String location;

  School({
    required this.id,
    required this.school_name,
    required this.school_name_only,
    required this.location,
  });

  factory School.fromMap(Map<String, dynamic> map, String id) {
    return School(
      id: id,
      school_name: map['school_name'] ?? '',
      school_name_only: map['school_name_only'] ?? '',
      location: map['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school_name': school_name,
      'school_name_only': school_name_only,
      'location': location,
    };
  }
  
  @override
  String toString() => '$school_name ($location)';
}
