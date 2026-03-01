import 'package:flutter/material.dart';

class Step3Effort extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3Effort({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Step 3 - Effort",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}