class MedicineModel {
  final int? id;
  final String name;
  final String? genericName;
  final String? manufacturer;
  final String? strength;
  final String? dosageForm;
  final double? price;
  final String? packaging;

  MedicineModel({
    this.id,
    required this.name,
    this.genericName,
    this.manufacturer,
    this.strength,
    this.dosageForm,
    this.price,
    this.packaging,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'genericName': genericName,
      'manufacturer': manufacturer,
      'strength': strength,
      'dosageForm': dosageForm,
      'price': price,
      'packaging': packaging,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      genericName: map['genericName'] as String?,
      manufacturer: map['manufacturer'] as String?,
      strength: map['strength'] as String?,
      dosageForm: map['dosageForm'] as String?,
      price: (map['price'] as num?)?.toDouble(),
      packaging: map['packaging'] as String?,
    );
  }

  static double? parsePrice(String? pkg) {
    if (pkg == null || !pkg.contains('৳')) return null;
    final regex = RegExp(r'৳\s*([0-9]{1,3}(?:,[0-9]{3})*(?:\.[0-9]{1,2})?|[0-9]+(?:\.[0-9]{1,2})?)');
    final match = regex.firstMatch(pkg);
    if (match != null) {
      final clean = match.group(1)?.replaceAll(',', '');
      if (clean != null) {
        return double.tryParse(clean);
      }
    }
    return null;
  }

  factory MedicineModel.fromCsv(List<String> values) {
    // CSV format: brand id, brand name, type, slug, dosage form, generic, strength, manufacturer, package container, Package Size
    final pkg = values.length > 8 && values[8].trim().isNotEmpty ? values[8].trim() : null;
    return MedicineModel(
      name: values.isNotEmpty ? values[1].trim() : '',
      genericName: values.length > 5 ? (values[5].trim().isEmpty ? null : values[5].trim()) : null,
      manufacturer: values.length > 7 ? (values[7].trim().isEmpty ? null : values[7].trim()) : null,
      strength: values.length > 6 ? (values[6].trim().isEmpty ? null : values[6].trim()) : null,
      dosageForm: values.length > 4 ? (values[4].trim().isEmpty ? null : values[4].trim()) : null,
      price: parsePrice(pkg),
      packaging: pkg,
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
    String? packaging,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      genericName: genericName ?? this.genericName,
      manufacturer: manufacturer ?? this.manufacturer,
      strength: strength ?? this.strength,
      dosageForm: dosageForm ?? this.dosageForm,
      price: price ?? this.price,
      packaging: packaging ?? this.packaging,
    );
  }

  String get formattedPrice {
    if (price == null || price == 0) return 'মূল্য উপলব্ধ নয়';
    final pStr = price! % 1 == 0 ? price!.toInt().toString() : price!.toStringAsFixed(2);
    return '৳ $pStr';
  }
}
