import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/medicine_model.dart';
import 'package:rxdigi/core/data/repositories/medicine_repository.dart';

class MedicinesScreen extends ConsumerStatefulWidget {
  const MedicinesScreen({super.key});

  @override
  ConsumerState<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends ConsumerState<MedicinesScreen> {
  final MedicineRepository _repository = MedicineRepository();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  List<MedicineModel> _medicines = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 30;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _offset = 0;
      _medicines = [];
      _hasMore = true;
    });

    await _repository.loadMedicinesFromCsv();
    await _fetchMedicines();
  }

  Future<void> _fetchMedicines() async {
    if (!_hasMore) return;

    final newData = await _repository.getMedicinesPaged(
      limit: _limit,
      offset: _offset,
      query: _searchQuery,
    );

    if (mounted) {
      setState(() {
        _medicines.addAll(newData);
        _isLoading = false;
        _offset += _limit;
        if (newData.length < _limit) {
          _hasMore = false;
        }
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        setState(() => _isLoading = true);
        _fetchMedicines();
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
        _loadInitialData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Medicine Directory',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {
              // Future: Add filtering by category/dosage form
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Search Bar Header
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
                      hintText: 'Search brand, generic or company...',
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
            child: _medicines.isEmpty && _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : _medicines.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                        itemCount: _medicines.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _medicines.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildMedicineCard(_medicines[index]);
                        },
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
            child: Icon(Icons.search_off_outlined, size: 80, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 24),
          Text(
            'No medicines found',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade800, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with a different keyword',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineModel med) {
    final Color accentColor = _getFormColor(med.dosageForm);
    
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(width: 6, color: accentColor),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_getFormIcon(med.dosageForm), color: accentColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          
                          // Name and Form
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    letterSpacing: -0.5,
                                    color: Color(0xFF1A1C1E),
                                  ),
                                ),
                                if (med.dosageForm != null)
                                  Text(
                                    med.dosageForm!.toUpperCase(),
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      
                      // Details
                      _buildInfoRow(Icons.science_outlined, 'Generic', med.genericName ?? "N/A"),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildInfoRow(Icons.bolt_outlined, 'Strength', med.strength ?? "N/A")),
                          Expanded(child: _buildInfoRow(Icons.factory_outlined, 'Company', med.manufacturer ?? "N/A")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF42474E),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getFormIcon(String? form) {
    if (form == null) return Icons.medication;
    final f = form.toLowerCase();
    if (f.contains('tab') || f.contains('cap')) return Icons.medication;
    if (f.contains('syp') || f.contains('susp')) return Icons.medical_services_outlined;
    if (f.contains('inj')) return Icons.vaccines;
    if (f.contains('drop')) return Icons.opacity;
    if (f.contains('cream') || f.contains('oint')) return Icons.clean_hands;
    return Icons.medication;
  }

  Color _getFormColor(String? form) {
    if (form == null) return const Color(0xFF64748B); // Slate
    final f = form.toLowerCase();
    if (f.contains('tab') || f.contains('cap')) return const Color(0xFF6366F1); // Indigo
    if (f.contains('syp') || f.contains('susp')) return const Color(0xFF0EA5E9); // Sky
    if (f.contains('inj')) return const Color(0xFFF43F5E); // Rose
    if (f.contains('drop')) return const Color(0xFF10B981); // Emerald
    if (f.contains('cream') || f.contains('oint')) return const Color(0xFFF59E0B); // Amber
    return AppColors.primaryColor;
  }
}
