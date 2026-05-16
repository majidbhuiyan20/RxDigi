import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/core/data/models/patient_model.dart';
import 'package:prescripto/core/data/providers/patient_provider.dart';
import 'package:prescripto/features/patients/view/patient_details_screen.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.toLowerCase();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Patient Directory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Modern Search Bar Header (Matched with Medicine Directory)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search patient name or phone...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      prefixIcon: const Icon(Icons.search, color: Colors.white70),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.white70),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 4),
                    child: Row(
                      children: [
                        Text(
                          'Results for ',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                        Text(
                          '"$_searchQuery"',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            child: patientsAsync.when(
              data: (patients) {
                final filteredPatients = patients.where((patient) {
                  return patient.name.toLowerCase().contains(_searchQuery) ||
                      (patient.phone?.contains(_searchQuery) ?? false);
                }).toList();

                if (filteredPatients.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    return _buildPatientCard(filteredPatients[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_off_outlined, size: 80, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'No patients found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade800, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
              ? 'Your patient list is currently empty' 
              : 'Try searching with a different name or phone',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PatientDetailsScreen(patient: patient),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: Color(0xFF1A1C1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.cake_outlined, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${patient.age ?? 'N/A'} yrs • ${patient.gender ?? 'N/A'}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                      if (patient.phone != null && patient.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              patient.phone!,
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
