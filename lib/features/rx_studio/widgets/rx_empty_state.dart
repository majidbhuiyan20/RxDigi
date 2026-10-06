import 'package:flutter/material.dart';

class RxEmptyState extends StatelessWidget {
  final bool isBn;

  const RxEmptyState({super.key, required this.isBn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            isBn ? 'কোনো প্রেসক্রিপশন পাওয়া যায়নি' : 'No prescriptions yet',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'প্রথম প্রেসক্রিপশন তৈরি করতে নিচের "নতুন প্রেসক্রিপশন" বাটনে চাপুন।'
                : 'Start by creating your first clinical prescription.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
