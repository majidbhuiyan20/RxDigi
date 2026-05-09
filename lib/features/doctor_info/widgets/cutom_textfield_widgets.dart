import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
class CustomTextFieldWidgets extends StatelessWidget {
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const CustomTextFieldWidgets({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.onChanged,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(
          prefixIcon, // your icon here
          color: AppColors.textGreyColor,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: AppColors.textGreyColor.withOpacity(0.7),
          fontSize: 16,
        ),

        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
      ),
    );
  }
}
