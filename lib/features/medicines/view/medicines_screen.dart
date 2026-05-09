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
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
      _loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Medicines Directory', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: AppColors.topHeaderColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding:  EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration:  BoxDecoration(
              color: AppColors.topHeaderColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search brand, generic or manufacturer...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon:  Icon(Icons.search, color: AppColors.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:  BorderSide(color: AppColors.primaryColor, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _medicines.isEmpty && _isLoading
                ?  Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : _medicines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication_outlined, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('No medicines found', 
                              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                        itemCount: _medicines.length + (_hasMore ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _medicines.length) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(color: AppColors.primaryColor),
                              ),
                            );
                          }

                          final med = _medicines[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      color: _getFormColor(med.dosageForm),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    med.name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 17,
                                                      color: Color(0xFF2D3142),
                                                    ),
                                                  ),
                                                ),
                                                if (med.dosageForm != null)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: _getFormColor(med.dosageForm).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      med.dosageForm!,
                                                      style: TextStyle(
                                                        color: _getFormColor(med.dosageForm),
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              med.genericName ?? "No generic name",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.straighten, size: 14, color: Colors.grey.shade400),
                                                const SizedBox(width: 4),
                                                Text(
                                                  med.strength ?? "N/A",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Icon(Icons.business, size: 14, color: Colors.grey.shade400),
                                                const SizedBox(width: 4),
                                                Text(
                                                  med.manufacturer != null && med.manufacturer!.length > 20 
                                                    ? "${med.manufacturer!.substring(0, 18)}..." 
                                                    : med.manufacturer ?? "Unknown",
                                                  style: TextStyle(
                                                    color: Colors.grey.shade500,
                                                    fontSize: 12,
                                                  ),
                                                ),
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
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getFormColor(String? form) {
    if (form == null) return Colors.blue;
    final f = form.toLowerCase();
    if (f.contains('tablet')) return const Color(0xFF6C63FF);
    if (f.contains('capsule')) return const Color(0xFFFF6584);
    if (f.contains('syrup')) return const Color(0xFF4CAF50);
    if (f.contains('injection')) return const Color(0xFFFF9800);
    if (f.contains('drop')) return const Color(0xFF03A9F4);
    return AppColors.primaryColor;
  }
}
