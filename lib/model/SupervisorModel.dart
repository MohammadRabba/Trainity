class SupervisorModel {
  final dynamic id;
  dynamic email;
  final dynamic name;
  final dynamic type;
  final dynamic phone;
  final dynamic image;
  dynamic address;

  SupervisorModel({
    this.id,
    required this.email,
    this.type,
    required this.phone,
    required this.name,
    this.image,
    this.address,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    return SupervisorModel(
      id: json['id'] as dynamic,
      email: json['email'] as dynamic,
      type: json['type'] as dynamic,
      phone: json['phone'] as dynamic,
      name: json['name'] as dynamic,
      image: json['image'] as dynamic,
      address: json['address'] as dynamic ?? "",
    );
  }
}
