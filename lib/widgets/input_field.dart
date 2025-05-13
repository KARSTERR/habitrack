import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final void Function(String)? onChanged;
  final FocusNode? nextFocus;
  final Color? suffixIconColor;

  const InputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.nextFocus,
    this.suffixIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onEditingComplete:
            onEditingComplete ??
            (nextFocus != null
                ? () => FocusScope.of(context).requestFocus(nextFocus)
                : null),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon:
              prefixIcon is IconData
                  ? Icon(prefixIcon as IconData)
                  : prefixIcon,
          suffixIcon:
              suffixIcon is IconData
                  ? Icon(suffixIcon as IconData, color: suffixIconColor)
                  : suffixIcon,
          suffixIconColor: suffixIconColor,
        ),
      ),
    );
  }
}
