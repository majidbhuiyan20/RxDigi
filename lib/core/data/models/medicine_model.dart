class MedicineModel {
  final int? id;
  final String name;
  final String? genericName;
  final String? manufacturer;
  final String? strength;
  final String? dosageForm;
  final double? price;

  MedicineModel({
    this.id,
    required this.name,
    this.genericName,
    this.manufacturer,
    this.strength,
    this.dosageForm,
    this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'strength': strength,
      'dosageForm': dosageForm,
      'price': price,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'],
      name: map['name'] ?? '',
      genericName: map['genericName'],
      manufacturer: map['manufacturer'],
      strength: map['strength'],
      dosageForm: map['dosageForm'],
      price: map['price'],
    );
  }

  factory MedicineModel.fromCsv(List<String> values) {
    // CSV format: brand id, brand name, type, slug, dosage form, generic, strength, manufacturer, package container, Package Size
    return MedicineModel(
      name: values.isNotEmpty ? values[1].trim() : '',  // brand name
      genericName: values.length > 5 ? (values[5].trim().isEmpty ? null : values[5].trim()) : null,  // generic
      manufacturer: values.length > 7 ? (values[7].trim().isEmpty ? null : values[7].trim()) : null,  // manufacturer
      strength: values.length > 6 ? (values[6].trim().isEmpty ? null : values[6].trim()) : null,  // strength
      dosageForm: values.length > 4 ? (values[4].trim().isEmpty ? null : values[4].trim()) : null,  // dosage form
      price: null,
    );
  }

  MedicineModel copyWith({
    int? id,
    String? name,
    String? genericName,
    String? manufacturer,
    String? strength,
    String? dosageForm,
    double? price,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      price: price ?? this.price,
    );
  }
}
