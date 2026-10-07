import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../core/data/models/medicine_model.dart';
import '../../../core/data/providers/medicine_provider.dart';
import '../../medicine_reminder/view/add_reminder_sheet.dart';

class MedicineSubstituteSheet extends ConsumerStatefulWidget {
  final MedicineModel medicine;

  const MedicineSubstituteSheet({
    super.key,
    required this.medicine,
  });

  static Future<void> show(BuildContext context, MedicineModel medicine) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineSubstituteSheet(medicine: medicine),
    );
  }

  @override
  ConsumerState<MedicineSubstituteSheet> createState() => _MedicineSubstituteSheetState();
}

class _MedicineSubstituteSheetState extends ConsumerState<MedicineSubstituteSheet> {
  List<MedicineModel> _substitutes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubstitutes();
  }

  Future<void> _fetchSubstitutes() async {
    final med = widget.medicine;
    if (med.genericName == null || med.genericName!.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final repo = ref.read(medicineRepositoryProvider);
    final results = await repo.getGenericSubstitutes(
      genericName: med.genericName!,
      dosageForm: med.dosageForm ?? 'Tablet',
      strength: med.strength,
      currentMedicineId: med.id,
    );

    if (mounted) {
      setState(() {
        _substitutes = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final med = widget.medicine;
    final basePrice = med.price;

    // Find cheapest substitute
    MedicineModel? cheapestSub;
    double maxSavingsPercent = 0.0;
    if (_substitutes.isNotEmpty) {
      final validPrices = _substitutes.where((s) => s.price != null && s.price! > 0).toList();
      if (validPrices.isNotEmpty) {
        cheapestSub = validPrices.first; // already sorted ASC by price
        if (basePrice != null && basePrice > 0 && cheapestSub.price != null && cheapestSub.price! < basePrice) {
          maxSavingsPercent = ((basePrice - cheapestSub.price!) / basePrice) * 100;
        }
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header with close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(PhosphorIconsRegular.tag, color: AppColors.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'ঔষধের বিবরণ ও বিকল্প' : 'Medicine Details & Substitutes',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isBn ? 'সস্তা বিকল্প ও সরকারি অনুমোদিত মূল্য' : 'Compare prices & find cheaper brands',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 20),

          // Content body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // 1. Current Medicine Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.08),
                        Colors.blue.shade50.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  med.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                                if (med.dosageForm != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      med.dosageForm!,
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Price badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Text(
                              med.formattedPrice,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${isBn ? "উপাদান:" : "Generic:"} ${med.genericName ?? "N/A"}',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (med.strength != null && med.strength!.isNotEmpty)
                            Text(
                              '${isBn ? "মাত্রা:" : "Strength:"} ${med.strength!}  •  ',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                          Expanded(
                            child: Text(
                              med.manufacturer ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      if (med.packaging != null && med.packaging!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            med.packaging!,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Savings Highlight (If cheaper substitute found)
                if (cheapestSub != null && maxSavingsPercent > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.savings_outlined, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn
                                    ? 'সর্বোচ্চ ${maxSavingsPercent.toInt()}% টাকা সাশ্রয়ের সুযোগ!'
                                    : 'Save up to ${maxSavingsPercent.toInt()}% on alternatives!',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF166534)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isBn
                                    ? '${cheapestSub.name} (${cheapestSub.manufacturer}) এর প্রতি পিসের দাম মাত্র ${cheapestSub.formattedPrice}'
                                    : '${cheapestSub.name} (${cheapestSub.manufacturer}) is only ${cheapestSub.formattedPrice}',
                                style: TextStyle(fontSize: 11.5, color: Colors.green.shade800),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 3. Substitutes Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'বিকল্প ব্র্যান্ডসমূহ (সস্তা থেকে বেশি)' : 'Alternative Brands (Lowest Price First)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    if (!_isLoading)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_substitutes.length} ${isBn ? "টি" : "items"}',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Substitutes List
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_substitutes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(PhosphorIconsRegular.magnifyingGlass, size: 36, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          isBn ? 'অন্য কোনো বিকল্প ব্র্যান্ড পাওয়া যায়নি' : 'No other substitute brand found',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBn
                              ? 'একই ফর্মুলা ও পাওয়ারের অন্য কোনো কোম্পানি বর্তমানে তালিকাভুক্ত নেই।'
                              : 'No alternative brands match the exact generic, strength and dosage form.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                else
                  ..._substitutes.map((sub) {
                    final isCheaper = basePrice != null && sub.price != null && sub.price! < basePrice;
                    final savingsAmount = (basePrice != null && sub.price != null) ? (basePrice - sub.price!) : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCheaper ? const Color(0xFF86EFAC) : Colors.grey.shade200,
                          width: isCheaper ? 1.4 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Form icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCheaper ? const Color(0xFFDCFCE7) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              PhosphorIconsRegular.pill,
                              color: isCheaper ? const Color(0xFF16A34A) : Colors.blueGrey,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Brand Name & Manufacturer
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      sub.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    if (sub.strength != null && sub.strength!.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        sub.strength!,
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  sub.manufacturer ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                ),
                                if (isCheaper) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${savingsAmount.toStringAsFixed(2)} ৳ ${isBn ? "সাশ্রয়" : "cheaper"}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Price Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                sub.formattedPrice,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: isCheaper ? const Color(0xFF16A34A) : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  AddReminderSheet.show(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(PhosphorIconsRegular.alarm, size: 12, color: AppColors.primaryColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        isBn ? 'রিমাইন্ডার' : 'Reminder',
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

