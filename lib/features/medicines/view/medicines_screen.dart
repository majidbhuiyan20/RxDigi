import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../core/data/models/medicine_model.dart';
import '../../../core/data/repositories/medicine_repository.dart';
import 'medicine_substitute_sheet.dart';

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
    _debounce = Timer(const Duration(milliseconds: 250), () {
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
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        title: Text(
          isBn ? 'ঔষধের ডিরেক্টরি ও দাম' : 'Medicine Index & Prices',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Modern Search Bar Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F766E),
                  Color(0xFF0D9488),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: isBn
                          ? 'ঔষধ, উপাদান বা কোম্পানির নাম খুঁজুন...'
                          : 'Search brand, generic or company...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass, color: Colors.white),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBn
                      ? '💡 যেকোনো ঔষধে ট্যাপ করে খুচরা মূল্য এবং অন্যান্য কোম্পানির সস্তা বিকল্প দেখুন।'
                      : '💡 Tap any medicine to view retail price & compare cheaper generic alternatives.',
                  style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),

          Expanded(
            child: _medicines.isEmpty && _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
                : _medicines.isEmpty
                    ? _buildEmptyState(isBn)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                        itemCount: _medicines.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _medicines.length) {
                            return _buildLoadingIndicator();
                          }
                          return _buildMedicineCard(_medicines[index], isBn);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isBn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(PhosphorIconsRegular.magnifyingGlass, size: 64, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            isBn ? 'কোনো ঔষধ পাওয়া যায়নি' : 'No medicines found',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            isBn ? 'অন্য কোনো বানান দিয়ে অনুসন্ধান করে দেখুন' : 'Try searching with a different brand or generic keyword',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.2),
      ),
    );
  }

  Widget _buildMedicineCard(MedicineModel med, bool isBn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => MedicineSubstituteSheet.show(context, med),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Icon Container
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.pill,
                        color: AppColors.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name, Form, and Price
                    Expanded(
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    if (med.dosageForm != null) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          med.dosageForm!,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Price Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  med.formattedPrice,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            med.genericName ?? "N/A",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.blueGrey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1),
                ),

                // Strength & Company + Substitute Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${med.strength ?? ""} • ${med.manufacturer ?? ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          isBn ? 'সস্তা বিকল্প দেখুন' : 'Compare Substitutes',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(PhosphorIconsRegular.caretRight, size: 14, color: AppColors.primaryColor),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
