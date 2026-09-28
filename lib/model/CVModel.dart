class CVModel {
  final List<dynamic> perference;
  final dynamic cvFile;
  final location;
  dynamic url;
  CVModel(
      {required this.perference,
      this.url,
      this.location,
      required this.cvFile});

  factory CVModel.fromJson(Map<String, dynamic> json) {
    return CVModel(
        perference: json['perferences'] as dynamic,
        cvFile: json['cv'] as dynamic,
        url: json['url'] as dynamic);
  }
}
