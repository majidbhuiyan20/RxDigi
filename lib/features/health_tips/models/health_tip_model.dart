class HealthTipModel {
  final String id;
  final String category;
  final String categoryBn;
  final String icon;
  final String color;
  final String titleEn;
  final String titleBn;
  final String summaryEn;
  final String summaryBn;
  final List<String> keyPointsEn;
  final List<String> keyPointsBn;
  final List<String> doListEn;
  final List<String> doListBn;
  final List<String> dontListEn;
  final List<String> dontListBn;
  final String disclaimerEn;
  final String disclaimerBn;

  HealthTipModel({
    required this.id,
    required this.category,
    required this.categoryBn,
    required this.icon,
    required this.color,
    required this.titleEn,
    required this.titleBn,
    required this.summaryEn,
    required this.summaryBn,
    required this.keyPointsEn,
    required this.keyPointsBn,
    required this.doListEn,
    required this.doListBn,
    required this.dontListEn,
    required this.dontListBn,
    required this.disclaimerEn,
    required this.disclaimerBn,
  });

  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    return HealthTipModel(
      id: json['id'] as String,
      category: json['category'] as String,
      categoryBn: json['category_bn'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      titleEn: json['title_en'] as String,
      titleBn: json['title_bn'] as String,
      summaryEn: json['summary_en'] as String,
      summaryBn: json['summary_bn'] as String,
      keyPointsEn: List<String>.from(json['key_points_en'] ?? []),
      keyPointsBn: List<String>.from(json['key_points_bn'] ?? []),
      doListEn: List<String>.from(json['do_list_en'] ?? []),
      doListBn: List<String>.from(json['do_list_bn'] ?? []),
      dontListEn: List<String>.from(json['dont_list_en'] ?? []),
      dontListBn: List<String>.from(json['dont_list_bn'] ?? []),
      disclaimerEn: json['disclaimer_en'] as String,
      disclaimerBn: json['disclaimer_bn'] as String,
    );
  }

  String getTitle(bool isBn) => isBn ? titleBn : titleEn;
  String getCategory(bool isBn) => isBn ? categoryBn : category;
  String getSummary(bool isBn) => isBn ? summaryBn : summaryEn;
  List<String> getKeyPoints(bool isBn) => isBn ? keyPointsBn : keyPointsEn;
  List<String> getDos(bool isBn) => isBn ? doListBn : doListEn;
  List<String> getDonts(bool isBn) => isBn ? dontListBn : dontListEn;
  String getDisclaimer(bool isBn) => isBn ? disclaimerBn : disclaimerEn;
}
