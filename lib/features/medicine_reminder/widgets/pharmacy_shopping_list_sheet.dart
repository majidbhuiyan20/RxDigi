import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/app_colors.dart';
import '../models/medicine_reminder_model.dart';
import '../provider/medicine_reminder_provider.dart';

class PharmacyShoppingListSheet extends ConsumerStatefulWidget {
  final bool isBn;

  const PharmacyShoppingListSheet({super.key, required this.isBn});

  static void show(BuildContext context, bool isBn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PharmacyShoppingListSheet(isBn: isBn),
    );
  }

  @override
  ConsumerState<PharmacyShoppingListSheet> createState() => _PharmacyShoppingListSheetState();
}

class _PharmacyShoppingListSheetState extends ConsumerState<PharmacyShoppingListSheet> {
  final Map<int, bool> _selectedMedIds = {};
  final Map<int, int> _quantityToBuy = {};

  String _generateShareText(List<MedicineReminderModel> meds) {
    final isBn = widget.isBn;
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());
    final selected = meds.where((m) => m.id != null && (_selectedMedIds[m.id!] ?? false)).toList();

    final buffer = StringBuffer();
    buffer.writeln(isBn ? '📋 RxDigi • ফার্মেসি ক্রয়ের তালিকা' : '📋 RxDigi • Pharmacy Purchase Order');
    buffer.writeln('📅 $now\n');

    if (selected.isEmpty) {
      buffer.writeln(isBn ? 'কোনো ঔষধ নির্বাচিত নেই।' : 'No medicines selected.');
    } else {
      for (int i = 0; i < selected.length; i++) {
        final m = selected[i];
        final qty = _quantityToBuy[m.id!] ?? 10;
        final strength = m.dosageStrength.isNotEmpty ? ' ${m.dosageStrength}' : '';
        buffer.writeln('${i + 1}. ${m.medicineName}$strength (${m.dosageForm}) — $qty ${isBn ? "টি" : "units"}');
      }
    }

    buffer.writeln('\n' + (isBn ? 'অনুগ্রহ করে দ্রুত ডেলিভারি বা প্রাপ্যতা নিশ্চিত করুন। ধন্যবাদ!' : 'Please confirm availability and total price. Thank you!'));
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = widget.isBn;
    final remindersAsync = ref.watch(allRemindersProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: remindersAsync.when(
        data: (reminders) {
          final activeMeds = reminders.where((r) => r.isActive).toList();

          // Initialize selections once
          for (final m in activeMeds) {
            if (m.id != null) {
              if (!_selectedMedIds.containsKey(m.id!)) {
                // Pre-select low stock or out of stock items
                _selectedMedIds[m.id!] = m.isLowStock || m.isOutOfStock || !m.hasStockTracking;
              }
              if (!_quantityToBuy.containsKey(m.id!)) {
                _quantityToBuy[m.id!] = 10;
              }
            }
          }

          final selectedCount = activeMeds.where((m) => m.id != null && (_selectedMedIds[m.id!] ?? false)).length;

          return Column(
            children: [
              // Pull Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(PhosphorIconsFill.shoppingCart, color: AppColors.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'ফার্মেসি কেনাকাটার তালিকা' : 'Pharmacy Shopping Order',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            isBn ? '$selectedCount টি ঔষধ নির্বাচিত' : '$selectedCount medicines selected',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIconsRegular.x, size: 20, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),

              // Meds Selector List
              Expanded(
                child: activeMeds.isEmpty
                    ? Center(
                        child: Text(
                          isBn ? 'কোনো সক্রিয় ঔষধ নেই' : 'No active prescriptions',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: activeMeds.length,
                        itemBuilder: (context, idx) {
                          final med = activeMeds[idx];
                          final id = med.id ?? idx;
                          final isSelected = _selectedMedIds[id] ?? false;
                          final qty = _quantityToBuy[id] ?? 10;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF0FDFA) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
                                width: isSelected ? 1.4 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppColors.primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedMedIds[id] = val ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${med.medicineName} ${med.dosageStrength}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            med.dosageForm,
                                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                          ),
                                          if (med.hasStockTracking) ...[
                                            const SizedBox(width: 8),
                                            Text(
                                              med.isOutOfStock
                                                  ? (isBn ? '• স্টক শেষ' : '• Out of stock')
                                                  : (isBn ? '• বাকি: ${med.currentStock}' : '• Left: ${med.currentStock}'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: med.isOutOfStock ? Colors.red : Colors.orange.shade800,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Quantity Stepper
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(PhosphorIconsBold.minus, size: 14),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                      onPressed: () {
                                        if (qty > 1) {
                                          setState(() => _quantityToBuy[id] = qty - 5 > 1 ? qty - 5 : 1);
                                        }
                                      },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        '$qty',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(PhosphorIconsBold.plus, size: 14),
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                      onPressed: () {
                                        setState(() => _quantityToBuy[id] = qty + 5);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Bottom Action Buttons (Copy & Share WhatsApp)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Copy to Clipboard
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: selectedCount == 0
                            ? null
                            : () {
                                final text = _generateShareText(activeMeds);
                                Clipboard.setData(ClipboardData(text: text));
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isBn ? 'লিস্টটি ক্লিপবোর্ডে কপি করা হয়েছে 📋' : 'List copied to clipboard 📋'),
                                    backgroundColor: AppColors.primaryColor,
                                  ),
                                );
                              },
                        icon: const Icon(PhosphorIconsRegular.copy, size: 17),
                        label: Text(isBn ? 'কপি করুন' : 'Copy List'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: const BorderSide(color: Color(0xFF0F766E)),
                          foregroundColor: const Color(0xFF0F766E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Share WhatsApp / Order
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: selectedCount == 0
                            ? null
                            : () {
                                final text = _generateShareText(activeMeds);
                                Share.share(
                                  text,
                                  subject: isBn ? 'ঔষধ ক্রয়ের অর্ডার লিস্ট' : 'Medicine Purchase Order',
                                );
                              },
                        icon: const Icon(PhosphorIconsFill.shareNetwork, size: 18, color: Colors.white),
                        label: Text(
                          isBn ? 'ফার্মেসিতে পাঠান' : 'Share Order',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

