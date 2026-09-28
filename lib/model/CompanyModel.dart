class CompanyModel {
  final dynamic id;
  final dynamic email;
  final dynamic name;
  final dynamic type;
  final dynamic phone;
  final dynamic location;
  dynamic photo;

  CompanyModel({
    required this.id,
    required this.email,
    required this.type,
    required this.phone,
    required this.name,
    this.location,
    this.photo,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id'] as dynamic,
      email: json['email'] as dynamic,
      type: json['type'] as dynamic,
      phone: json['phone'] as dynamic,
      name: json['name'] as dynamic,
      location: json['location'] as dynamic,
      photo: json['photo'] as dynamic,
    );
  }
}
