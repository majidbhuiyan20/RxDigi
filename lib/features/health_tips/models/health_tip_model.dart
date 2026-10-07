class HealthTipModel {
  final String id;
  final String category;
  final String categoryBn;
  final String bodyPart;
  final String icon;
  final String color;
  final String readTime;
  final bool isTrending;
  final String titleEn;
  final String titleBn;
  final String summaryEn;
  final String summaryBn;
  final String quickHackEn;
  final String quickHackBn;
  final String mythBusterEn;
  final String mythBusterBn;
  final String homeRemedyEn;
  final String homeRemedyBn;
  final List<String> keyPointsEn;
  final List<String> keyPointsBn;
  final List<String> doListEn;
  final List<String> doListBn;
  final List<String> dontListEn;
  final List<String> dontListBn;
  final String whenToSeeDoctorEn;
  final String whenToSeeDoctorBn;
  final String disclaimerEn;
  final String disclaimerBn;

  HealthTipModel({
    required this.id,
    required this.category,
    required this.categoryBn,
    this.bodyPart = 'general',
    required this.icon,
    required this.color,
    this.readTime = '১ মিনিট',
    this.isTrending = false,
    required this.titleEn,
    required this.titleBn,
    required this.summaryEn,
    required this.summaryBn,
    this.quickHackEn = '',
    this.quickHackBn = '',
    this.mythBusterEn = '',
    this.mythBusterBn = '',
    this.homeRemedyEn = '',
    this.homeRemedyBn = '',
    required this.keyPointsEn,
    required this.keyPointsBn,
    required this.doListEn,
    required this.doListBn,
    required this.dontListEn,
    required this.dontListBn,
    this.whenToSeeDoctorEn = '',
    this.whenToSeeDoctorBn = '',
    required this.disclaimerEn,
    required this.disclaimerBn,
  });

  factory HealthTipModel.fromJson(Map<String, dynamic> json) {
    return HealthTipModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'General Health',
      categoryBn: json['category_bn'] as String? ?? 'সাধারণ স্বাস্থ্য',
      bodyPart: json['body_part'] as String? ?? 'general',
      icon: json['icon'] as String? ?? 'heartbeat',
      color: json['color'] as String? ?? '#2563EB',
      readTime: json['read_time'] as String? ?? '১ মিনিট',
      isTrending: json['is_trending'] as bool? ?? false,
      titleEn: json['title_en'] as String? ?? '',
      titleBn: json['title_bn'] as String? ?? '',
      summaryEn: json['summary_en'] as String? ?? '',
      summaryBn: json['summary_bn'] as String? ?? '',
      quickHackEn: json['quick_hack_en'] as String? ?? '',
      quickHackBn: json['quick_hack_bn'] as String? ?? '',
      mythBusterEn: json['myth_buster_en'] as String? ?? '',
      mythBusterBn: json['myth_buster_bn'] as String? ?? '',
      homeRemedyEn: json['home_remedy_en'] as String? ?? '',
      homeRemedyBn: json['home_remedy_bn'] as String? ?? '',
      keyPointsEn: List<String>.from(json['key_points_en'] ?? []),
      keyPointsBn: List<String>.from(json['key_points_bn'] ?? []),
      doListEn: List<String>.from(json['do_list_en'] ?? []),
      doListBn: List<String>.from(json['do_list_bn'] ?? []),
      dontListEn: List<String>.from(json['dont_list_en'] ?? []),
      dontListBn: List<String>.from(json['dont_list_bn'] ?? []),
      whenToSeeDoctorEn: json['when_to_see_doctor_en'] as String? ?? '',
      whenToSeeDoctorBn: json['when_to_see_doctor_bn'] as String? ?? '',
      disclaimerEn: json['disclaimer_en'] as String? ?? 'Consult a certified doctor for medical diagnosis.',
      disclaimerBn: json['disclaimer_bn'] as String? ?? 'এটি সাধারণ স্বাস্থ্য সচেতনতামূলক তথ্য, রেজিস্টার্ড চিকিৎসকের প্রেসক্রিপশনের বিকল্প নয়।',
    );
  }

  String getTitle(bool isBn) => isBn ? (titleBn.isNotEmpty ? titleBn : titleEn) : (titleEn.isNotEmpty ? titleEn : titleBn);
  String getCategory(bool isBn) => isBn ? (categoryBn.isNotEmpty ? categoryBn : category) : (category.isNotEmpty ? category : categoryBn);
  String getSummary(bool isBn) => isBn ? (summaryBn.isNotEmpty ? summaryBn : summaryEn) : (summaryEn.isNotEmpty ? summaryEn : summaryBn);
  String getQuickHack(bool isBn) => isBn ? quickHackBn : (quickHackEn.isNotEmpty ? quickHackEn : quickHackBn);
  String getMythBuster(bool isBn) => isBn ? mythBusterBn : (mythBusterEn.isNotEmpty ? mythBusterEn : mythBusterBn);
  String getHomeRemedy(bool isBn) => isBn ? homeRemedyBn : (homeRemedyEn.isNotEmpty ? homeRemedyEn : homeRemedyBn);
  List<String> getKeyPoints(bool isBn) => isBn ? keyPointsBn : (keyPointsEn.isNotEmpty ? keyPointsEn : keyPointsBn);
  List<String> getDos(bool isBn) => isBn ? doListBn : (doListEn.isNotEmpty ? doListEn : doListBn);
  List<String> getDonts(bool isBn) => isBn ? dontListBn : (dontListEn.isNotEmpty ? dontListEn : dontListBn);
  String getWhenToSeeDoctor(bool isBn) => isBn ? whenToSeeDoctorBn : (whenToSeeDoctorEn.isNotEmpty ? whenToSeeDoctorEn : whenToSeeDoctorBn);
  String getDisclaimer(bool isBn) => isBn ? disclaimerBn : disclaimerEn;
}
