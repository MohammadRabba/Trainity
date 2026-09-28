class OppoModel {
  final dynamic id;
  final dynamic company_id;
  final dynamic company_name;
  final dynamic description;
  dynamic nOfStudent;
  dynamic registeredS;
  dynamic name;
  final dynamic supervisor_id;
  final dynamic startDate;
  final dynamic enddate;
  dynamic location;
  final List<dynamic> conditions;
  final List<dynamic> languages;
  OppoModel({
    required this.id,
    required this.company_id,
    required this.company_name,
    required this.name,
    required this.description,
    required this.supervisor_id,
    required this.location,
    required this.startDate,
    required this.enddate,
    required this.languages,
    required this.conditions,
    required this.nOfStudent,
    required this.registeredS,
  });

  factory OppoModel.fromJson(Map<String, dynamic> json) {
    return OppoModel(
        id: json['id'] as dynamic,
        company_id: json['company_id'] as dynamic,
        company_name: json['company_name'] as dynamic,
        name: json['name'] as dynamic,
        description: json['description'] as dynamic,
        supervisor_id: json['supervisor_id'] as dynamic,
        nOfStudent: json['nOfStudent'] as dynamic,
        registeredS: json['registeredS'] as dynamic,
        location: json['location'] as dynamic,
        startDate: json['startdate'] as dynamic,
        enddate: json['enddate'] as dynamic,
        languages: json['Languages'] as dynamic,
        conditions: json['conditions'] as dynamic);
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': company_id,
      'company_name': company_name,
      'name': name,
      'description': description,
      'supervisor_id': supervisor_id,
      'nOfStudent': nOfStudent,
      'registeredS': registeredS,
      'location': location,
      'startDate': startDate,
      'enddate': enddate,
      'languages': languages,
      'conditions': conditions,
    };
  }
}
