import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/medicine_model.dart';
import 'package:rxdigi/core/data/models/medicine_in_prescription_model.dart';
import 'package:rxdigi/core/data/repositories/medicine_repository.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

class StepMedicines extends ConsumerStatefulWidget {
  const StepMedicines({super.key});

  @override
  ConsumerState<StepMedicines> createState() => _StepMedicinesState();
}

class _StepMedicinesState extends ConsumerState<StepMedicines> {
  final MedicineRepository _medicineRepository = MedicineRepository();
  final TextEditingController _searchController = TextEditingController();
  List<MedicineModel> _searchResults = [];
  bool _isSearching = false;

  void _onSearch(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await _medicineRepository.searchMedicines(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _showAddMedicineDialog(MedicineModel medicine) {
    String dose = '1+0+1';
    String duration = '5 days';
    String instruction = 'After meal';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medicine.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${medicine.genericName} • ${medicine.dosageForm}', style: TextStyle(color: Colors.grey.shade600)),
              const Divider(height: 24),
              
              const Text('Dose (Frequency)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildChips(['1+0+0', '1+0+1', '1+1+1', '0+0+1', 'Every 8 hours'], dose, (val) => setModalState(() => dose = val)),
              
              const SizedBox(height: 16),
              const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildChips(['3 days', '5 days', '7 days', '14 days', '1 month'], duration, (val) => setModalState(() => duration = val)),

              const SizedBox(height: 16),
              const Text('Instruction', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildChips(['After meal', 'Before meal', 'With meal', 'Empty stomach'], instruction, (val) => setModalState(() => instruction = val)),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.rxPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final medInRx = MedicineInPrescription.fromMedicineModel(
                      medicine,
                      dose: dose,
                      duration: duration,
                      instruction: instruction,
                    );
                    ref.read(prescriptionProvider.notifier).addMedicine(medInRx);
                    Navigator.pop(context);
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                  child: const Text('Add to Prescription', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChips(List<String> items, String selected, Function(String) onSelect) {
    return Wrap(
      spacing: 8,
      children: items.map((item) {
        bool isSelected = item == selected;
        return ChoiceChip(
          label: Text(item),
          selected: isSelected,
          onSelected: (_) => onSelect(item),
          selectedColor: AppColors.rxPrimaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: isSelected ? AppColors.rxPrimaryColor : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? AppColors.rxPrimaryColor : Colors.grey.shade300),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addedMedicines = ref.watch(prescriptionProvider).medicines;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'Search Medicine (Napa, Azithro...)',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        if (_searchResults.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final med = _searchResults[index];
                return ListTile(
                  title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${med.genericName} • ${med.dosageForm}'),
                  trailing: Icon(Icons.add_circle_outline, color: AppColors.rxPrimaryColor),
                  onTap: () => _showAddMedicineDialog(med),
                );
              },
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addedMedicines.length,
              itemBuilder: (context, index) {
                final med = addedMedicines[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text('${med.medicineName} ${med.strength ?? ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('${med.dose} · ${med.instruction} · ${med.duration}', style: TextStyle(color: AppColors.rxPrimaryColor, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      onPressed: () => ref.read(prescriptionProvider.notifier).removeMedicine(index),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
