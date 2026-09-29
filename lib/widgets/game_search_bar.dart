import 'package:checkpoint/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GameSearchBar extends StatefulWidget {
  const GameSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onSubmitted,
    required this.scale,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final double scale;

  @override
  State<GameSearchBar> createState() => _GameSearchBarState();
}

class _GameSearchBarState extends State<GameSearchBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() => setState(() {});

  double s(double value) => value * widget.scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: s(52),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(
          color: _focusNode.hasFocus ? AppColors.primary : AppColors.border,
          width: _focusNode.hasFocus ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(s(14)),
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: s(12), right: s(12)),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: s(24),
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: TextStyle(fontSize: s(14)),
              decoration: InputDecoration(
                hintText: 'Search games...',
                hintStyle: TextStyle(
                  color: AppColors.mutedText,
                  fontSize: s(14),
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: s(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
