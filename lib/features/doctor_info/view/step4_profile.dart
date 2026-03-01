import 'package:flutter/material.dart';

class Step4Profile extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step4Profile({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Step 4 - Profile",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}