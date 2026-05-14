import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/medicine_model.dart';
import 'package:rxdigi/core/data/models/medicine_in_prescription_model.dart';
import 'package:rxdigi/core/data/repositories/medicine_repository.dart';
import 'package:rxdigi/core/data/repositories/favorite_medicine_repository.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

final favoriteMedicinesProvider = FutureProvider<List<MedicineModel>>((ref) {
  return FavoriteMedicineRepository().getFavorites();
});

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

  void _showAddMedicineDialog(MedicineModel? medicine) {
    String name = medicine?.name ?? '';
    String generic = medicine?.genericName ?? '';
    String dosageForm = medicine?.dosageForm ?? '';
    String strength = medicine?.strength ?? '';
    String dose = '1+0+1';
    String duration = '5 days';
    String instruction = 'After meal';
    bool isFavorite = false;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: medicine == null
                          ? const Text('Add Custom Medicine', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                          : Text(medicine.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: () {
                        setModalState(() => isFavorite = !isFavorite);
                      },
                    ),
                  ],
                ),
                if (medicine == null) ...[
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => name = v,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Medicine Name *',
                      hintText: 'e.g. Napa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => generic = v,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: 'Generic', hintText: 'Paracetamol', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => dosageForm = v,
                          decoration: const InputDecoration(labelText: 'Form', hintText: 'Tab/Cap/Syr', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (v) => strength = v,
                    decoration: const InputDecoration(labelText: 'Strength', hintText: '500mg / 5ml', border: OutlineInputBorder()),
                  ),
                ] else ...[
                  Text('${medicine.genericName} • ${medicine.dosageForm} • ${medicine.strength}', style: TextStyle(color: Colors.grey.shade600)),
                ],
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
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      if (name.isEmpty) return;
                      
                      final med = medicine ?? MedicineModel(
                        name: name,
                        genericName: generic,
                        dosageForm: dosageForm,
                        strength: strength,
                      );

                      if (isFavorite) {
                        await FavoriteMedicineRepository().addFavorite(med);
                        ref.invalidate(favoriteMedicinesProvider);
                      }

                      final medInRx = MedicineInPrescription(
                        medicineName: med.name,
                        genericName: med.genericName ?? '',
                        dosageForm: med.dosageForm ?? '',
                        strength: med.strength ?? '',
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
          selectedColor: AppColors.primaryColor.withOpacity(0.1),
          labelStyle: TextStyle(color: isSelected ? AppColors.primaryColor : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? AppColors.primaryColor : Colors.grey.shade300),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addedMedicines = ref.watch(prescriptionProvider).medicines;
    final favoritesAsync = ref.watch(favoriteMedicinesProvider);

    return Column(
      children: [
        // Search Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search Medicine...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        }) 
                      : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showAddMedicineDialog(null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Custom'),
              ),
            ],
          ),
        ),

        // Result Area
        Expanded(
          child: Stack(
            children: [
              // Default View: Favorites + Added Medicines
              Column(
                children: [
                  favoritesAsync.when(
                    data: (favorites) {
                      if (favorites.isEmpty) return const SizedBox.shrink();
                      return SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final med = favorites[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(med.name),
                                backgroundColor: AppColors.primaryColor.withOpacity(0.05),
                                onPressed: () => _showAddMedicineDialog(med),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text('ADDED MEDICINES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: addedMedicines.isEmpty
                      ? const Center(child: Text('No medicines added yet', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: addedMedicines.length,
                          itemBuilder: (context, index) {
                            final med = addedMedicines[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Text('${med.medicineName} ${med.strength ?? ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${med.dose} · ${med.duration}', style: TextStyle(color: AppColors.primaryColor)),
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
              ),

              // Search Overlay
              if (_searchResults.isNotEmpty)
                Container(
                  color: const Color(0xFFF8F9FD),
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final med = _searchResults[index];
                      return ListTile(
                        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${med.genericName} • ${med.dosageForm}'),
                        trailing: Icon(Icons.add_circle_outline, color: AppColors.primaryColor),
                        onTap: () => _showAddMedicineDialog(med),
                      );
                    },
                  ),
                ),
              
              if (_isSearching)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }
}
