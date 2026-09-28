class UsersModel {
  final dynamic id;
  final dynamic email;
  final dynamic name;
  final dynamic phone;
  final dynamic type;

  UsersModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.type,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['id'] as dynamic,
      email: json['email'] as dynamic,
      name: json['name'] as dynamic,
      phone: json['phone'] as dynamic,
      type: json['type'] as dynamic,
    );
  }
}
