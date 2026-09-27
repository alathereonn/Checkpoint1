import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GameSearchBar extends StatelessWidget {
  const GameSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      cursorColor: AppColors.primary,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      decoration: const InputDecoration(
        hintText: 'Search games...',
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
        contentPadding: EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
