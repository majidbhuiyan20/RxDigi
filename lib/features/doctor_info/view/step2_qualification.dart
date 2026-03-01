import 'package:flutter/material.dart';

class Step2Qualification extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2Qualification({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Step 2 - Qualification",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}