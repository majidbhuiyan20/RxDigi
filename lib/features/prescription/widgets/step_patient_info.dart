import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/core/data/models/patient_model.dart';
import 'package:prescripto/core/data/repositories/patient_repository.dart';
import 'package:prescripto/features/prescription/provider/prescription_provider.dart';

class StepPatientInfo extends ConsumerStatefulWidget {
  const StepPatientInfo({super.key});

  @override
  ConsumerState<StepPatientInfo> createState() => _StepPatientInfoState();
}

class _StepPatientInfoState extends ConsumerState<StepPatientInfo> {
  final PatientRepository _patientRepository = PatientRepository();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Controllers for new patient form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedGender = 'Male';

  List<PatientModel> _searchResults = [];
  bool _isSearching = false;
  bool _isNewPatient = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(prescriptionProvider);
      if (state.patient != null) {
        setState(() {
          _isNewPatient = state.patient!.id == null;
          _nameController.text = state.patient!.name;
          _ageController.text = state.patient!.age?.toString() ?? '';
          _phoneController.text = state.patient!.phone ?? '';
          _selectedGender = state.patient!.gender ?? 'Male';
        });
      }
    });
  }

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _patientRepository.searchPatients(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _selectPatient(PatientModel patient) {
    ref.read(prescriptionProvider.notifier).setPatient(patient);
    setState(() {
      _isNewPatient = false;
      _nameController.text = patient.name;
      _ageController.text = patient.age?.toString() ?? '';
      _phoneController.text = patient.phone ?? '';
      _selectedGender = patient.gender ?? 'Male';
      _searchResults = [];
      _searchController.clear();
    });
  }

  void _updatePatientState() {
    if (_formKey.currentState!.validate()) {
      final currentPatient = ref.read(prescriptionProvider).patient;
      final patient = PatientModel(
        id: currentPatient?.id, // CRITICAL: Preserve the ID so it links to existing patient
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        gender: _selectedGender,
        phone: _phoneController.text,
      );
      ref.read(prescriptionProvider.notifier).setPatient(patient);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPatient = ref.watch(prescriptionProvider).patient;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isNewPatient) ...[
            Text(
              'Search Patient',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search by phone or name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = _searchResults[index];
                    return ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${p.phone ?? "No phone"} • ${p.age ?? "?"}y • ${p.gender}'),
                      onTap: () => _selectPatient(p),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isNewPatient ? 'New Patient Details' : 'Selected Patient Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor),
              ),
              if (!_isNewPatient)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isNewPatient = true;
                      _nameController.clear();
                      _ageController.clear();
                      _phoneController.clear();
                      ref.read(prescriptionProvider.notifier).reset();
                    });
                  },
                  child: const Text('Change Patient'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            onChanged: _updatePatientState,
            child: Column(
              children: [
                _buildTextField(
                  controller: _nameController,
                  label: 'Patient Name *',
                  hint: 'Enter full name',
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildTextField(
                        controller: _ageController,
                        label: 'Age *',
                        hint: 'e.g. 35',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gender *', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedGender,
                                isExpanded: true,
                                items: ['Male', 'Female', 'Other']
                                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (v) {
                                  setState(() => _selectedGender = v!);
                                  _updatePatientState();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '01XXXXXXXXX',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
