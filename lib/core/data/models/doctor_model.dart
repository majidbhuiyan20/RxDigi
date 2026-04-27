class DoctorModel {
  final int? id;
  final String? title;
  final String fullName;
  final String? gender;
  final String? bmdcRegNo;
  final String? nationalId;
  final String mobile;
  final String email;
  final String? degrees;
  final String? specialization;
  final String? subSpecialization;
  final String? experience;
  final String clinicName;
  final String address;
  final String? phoneNumber;
  final String? startTime;
  final String? endTime;

  DoctorModel({
    this.id,
    this.title,
    required this.fullName,
    this.gender,
    this.bmdcRegNo,
    this.nationalId,
    required this.mobile,
    required this.email,
    this.degrees,
    this.specialization,
    this.subSpecialization,
    this.experience,
    required this.clinicName,
    required this.address,
    this.phoneNumber,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'fullName': fullName,
      'gender': gender,
      'bmdcRegNo': bmdcRegNo,
      'nationalId': nationalId,
      'mobile': mobile,
      'email': email,
      'degrees': degrees,
      'specialization': specialization,
      'subSpecialization': subSpecialization,
      'experience': experience,
      'clinicName': clinicName,
      'address': address,
      'phoneNumber': phoneNumber,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      id: map['id'],
      title: map['title'],
      fullName: map['fullName'] ?? '',
      gender: map['gender'],
      bmdcRegNo: map['bmdcRegNo'],
      nationalId: map['nationalId'],
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
      degrees: map['degrees'],
      specialization: map['specialization'],
      subSpecialization: map['subSpecialization'],
      experience: map['experience'],
      clinicName: map['clinicName'] ?? '',
      address: map['address'] ?? '',
      phoneNumber: map['phoneNumber'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }

  DoctorModel copyWith({
    int? id,
    String? title,
    String? fullName,
    String? gender,
    String? bmdcRegNo,
    String? nationalId,
    String? mobile,
    String? email,
    String? degrees,
    String? specialization,
    String? subSpecialization,
    String? experience,
    String? clinicName,
    String? address,
    String? phoneNumber,
    String? startTime,
    String? endTime,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      bmdcRegNo: bmdcRegNo ?? this.bmdcRegNo,
      nationalId: nationalId ?? this.nationalId,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      degrees: degrees ?? this.degrees,
      specialization: specialization ?? this.specialization,
      subSpecialization: subSpecialization ?? this.subSpecialization,
      experience: experience ?? this.experience,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}
