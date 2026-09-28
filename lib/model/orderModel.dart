class OrderModel {
  final dynamic id;
  final dynamic company_id;
  final dynamic oppo_id;
  final dynamic status;
  final dynamic user_id;
  final dynamic name;
  final dynamic description;
  final dynamic student_name;
  final dynamic nOfstudent;
  dynamic registeredS;
  final dynamic supervisorId;
  final dynamic matching;

  OrderModel({
    required this.id,
    required this.company_id,
    required this.oppo_id,
    required this.status,
    required this.user_id,
    required this.name,
    required this.description,
    required this.student_name,
    required this.nOfstudent,
    required this.supervisorId,
    required this.matching,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as dynamic,
      company_id: json['company_id'] as dynamic,
      oppo_id: json['oppo_id'] as dynamic,
      status: json['status'] as dynamic,
      user_id: json['user_id'] as dynamic,
      name: json['name'] as dynamic,
      description: json['description'] as dynamic,
      student_name: json['student_name'] as dynamic,
      nOfstudent: json['nOfstudent'] as dynamic,
      supervisorId: json['supervisor_id'] as dynamic,
      matching: json['Matching'] as dynamic,
    );
  }
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as dynamic,
      company_id: map['company_id'] as dynamic,
      oppo_id: map['oppo_id'] as dynamic,
      status: map['status'] as dynamic,
      user_id: map['user_id'] as dynamic,
      name: map['name'] as dynamic,
      description: map['description'] as dynamic,
      student_name: map['student_name'] as dynamic,
      nOfstudent: map['nOfstudent'] as dynamic,
      supervisorId: map['supervisor_id'] as dynamic,
      matching: map['Matching'] as dynamic,
    );
  }
}
