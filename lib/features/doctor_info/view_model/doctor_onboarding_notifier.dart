import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/data/models/doctor_model.dart';
import '../../../core/data/providers/doctor_provider.dart';

class DoctorOnboardingState {
  final String? title;
  final String? fullName;
  final String? gender;
  final String? bmdcRegNo;
  final String? mobile;
  final String? email;
  final List<String> degrees;
  final String? specialization;
  final String? subSpecialization;
  final String? experience;
  final String? collegeName;
  final String? passingYear;
  final String? clinicName;
  final String? address;
  final String? roomNumber;
  final String? phoneNumber;
  final String? serialNumber1;
  final String? serialNumber2;
  final String? startTime;
  final String? endTime;
  final List<String> offDays;
  final String? position;
  final String? department;
  final String? signaturePath;
  final String? clinicLogoPath;

  DoctorOnboardingState({
    this.title,
    this.fullName,
    this.gender,
    this.bmdcRegNo,
    this.mobile,
    this.email,
    this.degrees = const [],
    this.specialization,
    this.subSpecialization,
    this.experience,
    this.collegeName,
    this.passingYear,
    this.clinicName,
    this.address,
    this.roomNumber,
    this.phoneNumber,
    this.serialNumber1,
    this.serialNumber2,
    this.startTime,
    this.endTime,
    this.offDays = const [],
    this.position,
    this.department,
    this.signaturePath,
    this.clinicLogoPath,
  });

  DoctorOnboardingState copyWith({
    String? title,
    String? fullName,
    String? gender,
    String? bmdcRegNo,
    String? mobile,
    String? email,
    List<String>? degrees,
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
    List<String>? offDays,
    String? position,
    String? department,
    String? signaturePath,
    String? clinicLogoPath,
  }) {
    return DoctorOnboardingState(
      title: title ?? this.title,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      bmdcRegNo: bmdcRegNo ?? this.bmdcRegNo,
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
      signaturePath: signaturePath ?? this.signaturePath,
      clinicLogoPath: clinicLogoPath ?? this.clinicLogoPath,
    );
  }

  DoctorModel toModel() {
    return DoctorModel(
      title: title,
      fullName: fullName ?? '',
      gender: gender,
      bmdcRegNo: bmdcRegNo,
      mobile: mobile ?? '',
      email: email ?? '',
      degrees: degrees.join(', '),
      specialization: specialization,
      subSpecialization: subSpecialization,
      experience: experience,
      collegeName: collegeName,
      passingYear: passingYear,
      clinicName: clinicName ?? '',
      address: address ?? '',
      roomNumber: roomNumber,
      phoneNumber: phoneNumber,
      serialNumber1: serialNumber1,
      serialNumber2: serialNumber2,
      startTime: startTime,
      endTime: endTime,
      offDays: offDays.join(', '),
      position: position,
      department: department,
      signaturePath: signaturePath,
      clinicLogoPath: clinicLogoPath,
    );
  }
}

class DoctorOnboardingNotifier extends StateNotifier<DoctorOnboardingState> {
  DoctorOnboardingNotifier() : super(DoctorOnboardingState());

  void updateState(DoctorOnboardingState newState) {
    state = newState;
  }

  void updateField({
    String? title,
    String? fullName,
    String? gender,
    String? bmdcRegNo,
    String? mobile,
    String? email,
    List<String>? degrees,
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
    List<String>? offDays,
    String? position,
    String? department,
    String? signaturePath,
    String? clinicLogoPath,
  }) {
    state = state.copyWith(
      title: title,
      fullName: fullName,
      gender: gender,
      bmdcRegNo: bmdcRegNo,
      mobile: mobile,
      email: email,
      degrees: degrees,
      specialization: specialization,
      subSpecialization: subSpecialization,
      experience: experience,
      collegeName: collegeName,
      passingYear: passingYear,
      clinicName: clinicName,
      address: address,
      roomNumber: roomNumber,
      phoneNumber: phoneNumber,
      serialNumber1: serialNumber1,
      serialNumber2: serialNumber2,
      startTime: startTime,
      endTime: endTime,
      offDays: offDays,
      position: position,
      department: department,
      signaturePath: signaturePath,
      clinicLogoPath: clinicLogoPath,
    );
  }

  Future<void> saveDoctor(WidgetRef ref) async {
    final repository = ref.read(doctorRepositoryProvider);
    
    String? finalSignaturePath = state.signaturePath;
    String? finalLogoPath = state.clinicLogoPath;

    final appDir = await getApplicationDocumentsDirectory();

    if (state.signaturePath != null && !state.signaturePath!.contains(appDir.path)) {
      final file = File(state.signaturePath!);
      if (await file.exists()) {
        final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}${p.extension(state.signaturePath!)}';
        final savedFile = await file.copy(p.join(appDir.path, fileName));
        finalSignaturePath = savedFile.path;
      }
    }

    if (state.clinicLogoPath != null && !state.clinicLogoPath!.contains(appDir.path)) {
      final file = File(state.clinicLogoPath!);
      if (await file.exists()) {
        final fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}${p.extension(state.clinicLogoPath!)}';
        final savedFile = await file.copy(p.join(appDir.path, fileName));
        finalLogoPath = savedFile.path;
      }
    }

    final doctorModel = state.toModel().copyWith(
      signaturePath: finalSignaturePath,
      clinicLogoPath: finalLogoPath,
    );

    await repository.insert(doctorModel);
    ref.invalidate(latestDoctorProvider);
  }
}

final doctorOnboardingProvider =
    StateNotifierProvider<DoctorOnboardingNotifier, DoctorOnboardingState>((ref) {
  return DoctorOnboardingNotifier();
});
