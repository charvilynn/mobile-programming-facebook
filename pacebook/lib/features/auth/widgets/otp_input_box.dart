import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Widget 7 (Aaron): 6-digit OTP input with auto-focus between boxes
class OtpInputBox extends StatefulWidget {
  final int length;
  final void Function(String otp) onCompleted;

  const OtpInputBox({
    super.key,
    this.length = 6,
    required this.onCompleted,
  });

  @override
  State<OtpInputBox> createState() => _OtpInputBoxState();
}

class _OtpInputBoxState extends State<OtpInputBox> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (i) => SizedBox(
        width: 46,
        height: 56,
        child: TextFormField(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (val) => _onChanged(i, val),
          style: AppTypography.h2.copyWith(color: AppColors.cyan),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: AppColors.bgCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.cyan, width: 2),
            ),
          ),
        ),
      )),
    );
  }
}