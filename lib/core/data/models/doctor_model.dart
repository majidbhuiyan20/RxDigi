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
  final String? collegeName;
  final String? passingYear;
  final String clinicName;
  final String address;
  final String? roomNumber;
  final String? phoneNumber;
  final String? serialNumber1;
  final String? serialNumber2;
  final String? startTime;
  final String? endTime;
  final String? offDays;
  final String? position;
  final String? department;

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
    this.collegeName,
    this.passingYear,
    required this.clinicName,
    required this.address,
    this.roomNumber,
    this.phoneNumber,
    this.serialNumber1,
    this.serialNumber2,
    this.startTime,
    this.endTime,
    this.offDays,
    this.position,
    this.department,
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
      'collegeName': collegeName,
      'passingYear': passingYear,
      'clinicName': clinicName,
      'address': address,
      'roomNumber': roomNumber,
      'phoneNumber': phoneNumber,
      'serialNumber1': serialNumber1,
      'serialNumber2': serialNumber2,
      'startTime': startTime,
      'endTime': endTime,
      'offDays': offDays,
      'position': position,
      'department': department,
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
      collegeName: map['collegeName'],
      passingYear: map['passingYear'],
      clinicName: map['clinicName'] ?? '',
      address: map['address'] ?? '',
      roomNumber: map['roomNumber'],
      phoneNumber: map['phoneNumber'],
      serialNumber1: map['serialNumber1'],
      serialNumber2: map['serialNumber2'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      offDays: map['offDays'],
      position: map['position'],
      department: map['department'],
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
    String? collegeName,
    String? passingYear,
    String? clinicName,
    String? address,
    String? roomNumber,
    String? phoneNumber,
    String? serialNumber1,
    String? serialNumber2,
    String? startTime,
    String? endTime,
    String? offDays,
    String? position,
    String? department,
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
      collegeName: collegeName ?? this.collegeName,
      passingYear: passingYear ?? this.passingYear,
      clinicName: clinicName ?? this.clinicName,
      address: address ?? this.address,
      roomNumber: roomNumber ?? this.roomNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      serialNumber1: serialNumber1 ?? this.serialNumber1,
      serialNumber2: serialNumber2 ?? this.serialNumber2,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      offDays: offDays ?? this.offDays,
      position: position ?? this.position,
      department: department ?? this.department,
    );
  }
}
