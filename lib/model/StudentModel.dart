class StudentModel {
  final dynamic id;
  dynamic email;
  final dynamic name;
  final dynamic type;
  final dynamic phone;
  final dynamic status;
  final dynamic studentId;
  final dynamic photo;
  dynamic gpa;
  dynamic algorithm;
  dynamic database;
  dynamic datastructure;

  StudentModel(
      {this.id,
      required this.email,
      this.type,
      required this.phone,
      required this.name,
      required this.status,
      this.photo,
      required this.studentId,
      this.gpa,
      this.algorithm,
      this.database,
      this.datastructure});

  factory StudentModel.fromJson(Map<String, dynamic> json, String id) {
    return StudentModel(
        id: json['id'] as dynamic,
        email: json['email'] as dynamic,
        type: json['type'] as dynamic,
        phone: json['phone'] as dynamic,
        name: json['name'] as dynamic,
        studentId: json['email'].toString().split('@').first,
        photo: json['photo'] as dynamic,
        gpa: json['GPA'] as dynamic,
        algorithm: json['Algorithm'] as dynamic,
        database: json['DataBase'] as dynamic,
        datastructure: json['Structure'] as dynamic,
        status: json['status'] as dynamic);
  }
}
