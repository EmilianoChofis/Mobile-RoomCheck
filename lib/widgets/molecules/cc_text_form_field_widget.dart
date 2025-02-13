import 'package:flutter/material.dart';
import 'package:mobile_clean_check/core/theme/color_schemes.dart';
import 'package:mobile_clean_check/core/theme/text_themes.dart';

class CcTextFormFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? label;
  final String hint;
  final Icon icon;
  final int? maxLines;
  final bool readOnly;
  final String? Function(String?)? validator;

  const CcTextFormFieldWidget({
    required this.controller,
    required this.keyboardType,
    this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.readOnly = false,
    this.validator,
    super.key,
  });

  @override
  State<CcTextFormFieldWidget> createState() => _CcTextFormFieldWidgetState();
}

class _CcTextFormFieldWidgetState extends State<CcTextFormFieldWidget> {
  final primaryColor = ColorSchemes.primary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(
            widget.label!,
            style: TextThemes.lightTextTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            prefixIcon: widget.icon,
            hintText: widget.hint,
          ),
          readOnly: widget.readOnly,
          validator: widget.validator,
        ),
      ],
    );
  }
}
