import 'package:flutter/material.dart';

class Step1Introduction extends StatelessWidget {
  final VoidCallback onNext;

  const Step1Introduction({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Step 1 - Introduction",
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}