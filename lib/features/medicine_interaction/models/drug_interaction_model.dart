import '../../medicine_reminder/models/medicine_reminder_model.dart';

/// Clinical severity level of the drug interaction
enum InteractionSeverity {
  /// Major / Severe: Potentially life-threatening, high risk of internal bleed,
  /// cardiac arrhythmias, or severe organ toxicity. Avoid combination or close doctor review.
  severe,

  /// Moderate: Absorption interference, chelation, or reduced therapeutic efficacy.
  /// Typically managed by spacing administration times (e.g. 2 to 4 hours apart).
  moderate,

  /// Duplicate Therapy: Two or more medications containing identical active ingredients
  /// or same pharmacological therapeutic class, leading to accidental overdose.
  duplicate,

  /// Minor: Mild interaction, dietary consideration, or minor sedation.
  minor,
}

extension InteractionSeverityExtension on InteractionSeverity {
  String get labelEn {
    switch (this) {
      case InteractionSeverity.severe:
        return 'Severe Risk';
      case InteractionSeverity.moderate:
        return 'Timing Conflict (Spacing Required)';
      case InteractionSeverity.duplicate:
        return 'Duplicate Therapy (Overdose Risk)';
      case InteractionSeverity.minor:
        return 'Minor Caution';
    }
  }

  String get labelBn {
    switch (this) {
      case InteractionSeverity.severe:
        return 'উচ্চ ঝুঁকি (জরুরি সতর্কতা)';
      case InteractionSeverity.moderate:
        return 'সময়ের ব্যবধান আবশ্যক (২ ঘণ্টা গ্যাপ)';
      case InteractionSeverity.duplicate:
        return 'একই উপাদানের দ্বৈত ড্রাগ (ওভারডোজ ঝুঁকি)';
      case InteractionSeverity.minor:
        return 'সাধারণ সতর্কতা';
    }
  }
}

/// Clinical Rule definition for Drug-to-Drug Interactions
class DrugInteractionRule {
  final String id;
  final List<String> drugAKeys;
  final List<String> drugBKeys;
  final InteractionSeverity severity;
  final String titleBn;
  final String titleEn;
  final String mechanismBn;
  final String mechanismEn;
  final String riskBn;
  final String riskEn;
  final String managementBn;
  final String managementEn;
  final bool requiresTimeGap;
  final int recommendedGapHours;
  final bool isDuplicate;

  const DrugInteractionRule({
    required this.id,
    required this.drugAKeys,
    required this.drugBKeys,
    required this.severity,
    required this.titleBn,
    required this.titleEn,
    required this.mechanismBn,
    required this.mechanismEn,
    required this.riskBn,
    required this.riskEn,
    required this.managementBn,
    required this.managementEn,
    this.requiresTimeGap = false,
    this.recommendedGapHours = 2,
    this.isDuplicate = false,
  });
}

/// Concrete detected interaction between two user medications
class DetectedInteraction {
  final String id;
  final MedicineReminderModel reminderA;
  final MedicineReminderModel reminderB;
  final String genericA;
  final String genericB;
  final DrugInteractionRule rule;
  final bool hasTimeCollision;
  final List<String> collidingSlots;

  const DetectedInteraction({
    required this.id,
    required this.reminderA,
    required this.reminderB,
    required this.genericA,
    required this.genericB,
    required this.rule,
    required this.hasTimeCollision,
    required this.collidingSlots,
  });

  InteractionSeverity get severity => rule.severity;
  bool get requiresTimeGap => rule.requiresTimeGap;
  int get recommendedGapHours => rule.recommendedGapHours;
}

/// Overall health evaluation report for patient's medication regimen
class DrugInteractionReport {
  final List<DetectedInteraction> interactions;

  const DrugInteractionReport({
    required this.interactions,
  });

  int get totalCount => interactions.length;

  int get severeCount => interactions
      .where((i) => i.severity == InteractionSeverity.severe)
      .length;

  int get moderateCount => interactions
      .where((i) => i.severity == InteractionSeverity.moderate)
      .length;

  int get duplicateCount => interactions
      .where((i) => i.severity == InteractionSeverity.duplicate)
      .length;

  int get timeCollisionCount =>
      interactions.where((i) => i.hasTimeCollision).length;

  bool get hasSevereRisk => severeCount > 0;
  bool get hasCollisions => interactions.isNotEmpty;
  bool get isCleanAndSafe => interactions.isEmpty;
}

