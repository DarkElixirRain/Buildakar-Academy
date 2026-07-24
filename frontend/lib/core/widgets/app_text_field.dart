import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/theme_provider.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? error;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final VoidCallback? onToggleObscure;
  final VoidCallback? onChanged;
  final bool showPasswordRequirements;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;

  const AppTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.error,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.onToggleObscure,
    this.onChanged,
    this.showPasswordRequirements = false,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.getTextColor(brightness),
            ),
          ),
          const SizedBox(height: 8),
          _buildInputField(isDark, brightness),
          if (error != null) _buildErrorText,
          if (showPasswordRequirements &&
              controller.text.isNotEmpty &&
              error == null)
            _buildPasswordRequirements(brightness, isDark),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isDark, Brightness brightness) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackgroundElement
            : AppColors.lightBackgroundElement,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: error != null
              ? const Color(0xFFEF4444)
              : AppColors.getBackgroundSelectedColor(brightness),
          width: error != null ? 2 : 1,
        ),
        boxShadow: [
          if (error == null)
            BoxShadow(
              color: isDark
                  ? Colors.transparent
                  : Colors.grey.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Icon(
                prefixIcon,
                size: 20,
                color: error != null
                    ? const Color(0xFFEF4444)
                    : AppColors.getTextSecondaryColor(brightness),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              obscureText: obscureText,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textInputAction: textInputAction,
              style: TextStyle(
                color: AppColors.getTextColor(brightness),
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: AppColors.getTextSecondaryColor(brightness),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: prefixIcon != null ? 10 : 14,
                  vertical: 14,
                ),
              ),
              onChanged: (text) {
                if (onChanged != null) onChanged!();
              },
              onSubmitted: (_) {
                if (onSubmitted != null) onSubmitted!();
              },
            ),
          ),
          if (onToggleObscure != null)
            IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.getTextSecondaryColor(brightness),
              ),
              onPressed: onToggleObscure,
              padding: const EdgeInsets.only(right: 8),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget get _buildErrorText => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        const Icon(Icons.error_outline, size: 14, color: Color(0xFFEF4444)),
        const SizedBox(width: 4),
        Text(
          error!,
          style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
        ),
      ],
    ),
  );

  Widget _buildPasswordRequirements(Brightness brightness, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _buildRequirement(
            'At least 8 characters',
            controller.text.length >= 8,
          ),
          _buildRequirement(
            'At least one uppercase letter',
            RegExp(r'(?=.*[A-Z])').hasMatch(controller.text),
          ),
          _buildRequirement(
            'At least one lowercase letter',
            RegExp(r'(?=.*[a-z])').hasMatch(controller.text),
          ),
          _buildRequirement(
            'At least one number',
            RegExp(r'(?=.*\d)').hasMatch(controller.text),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
