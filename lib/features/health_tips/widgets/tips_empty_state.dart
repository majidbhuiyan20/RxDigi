import 'package:flutter/material.dart';

class TipsEmptyState extends StatelessWidget {
  final bool isBn;

  const TipsEmptyState({super.key, required this.isBn});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            isBn ? 'কোনো টিপস পাওয়া যায়নি' : 'No health tips found',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
