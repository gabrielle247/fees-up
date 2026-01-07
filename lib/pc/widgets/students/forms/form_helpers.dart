import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';

class FormHelpers {
  static Widget buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text,
          style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500)),
    );
  }

  static Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
    bool isNumber = false,
    bool readOnly = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: validator ?? (val) => val == null || val.isEmpty ? 'Required' : null,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surfaceGrey,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
        prefixText: prefix,
        prefixStyle: const TextStyle(
            color: AppColors.textWhite, fontWeight: FontWeight.bold),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.textWhite54, size: 20)
            : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: AppColors.textWhite54, size: 20))
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.surfaceLightGrey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: AppColors.primaryBlue, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static Widget buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLightGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surfaceGrey,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textWhite54),
          isExpanded: true,
          style: const TextStyle(color: AppColors.textWhite),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  static Widget buildDatePicker(
      BuildContext context, DateTime initial, Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(1990),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                  primary: AppColors.primaryBlue,
                  onPrimary: AppColors.textWhite,
                  surface: AppColors.surfaceGrey),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceLightGrey),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(initial),
                style: const TextStyle(color: AppColors.textWhite)),
            const Icon(Icons.calendar_today_outlined,
                size: 18, color: AppColors.textWhite54),
          ],
        ),
      ),
    );
  }

  static Widget buildCheckbox({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(color: AppColors.textWhite),
      ),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primaryBlue
            : Colors.transparent,
      ),
      side: const BorderSide(color: AppColors.divider),
      contentPadding: EdgeInsets.zero,
    );
  }
}
