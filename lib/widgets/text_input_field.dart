import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/langs_provider.dart';
class TextInputField extends StatefulWidget {
  final Function(String) getInputValue;
  final TextEditingController controller;
  TextInputField({super.key , required this.getInputValue , required this.controller});
  @override
  State<TextInputField> createState() => _TextInputFieldState();
}
class _TextInputFieldState extends State<TextInputField> {
  String textValue = '';

  @override
  Widget build(BuildContext context) {
    var langProvider = Provider.of<LangsProvider>(context);
    final isArabic = langProvider.language == 'ar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
          controller: widget.controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          decoration: InputDecoration(
            hintText: "البحث عن سورة",
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
            hintStyle: GoogleFonts.cairo(
              color: Colors.grey,
              fontSize: 17,
              fontWeight:FontWeight.w500
            ),
            border: InputBorder.none,
            suffixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
              size:27,
            ),
          ),
          onChanged: (text) => widget.getInputValue(text)
      ),
    );
  }
}
