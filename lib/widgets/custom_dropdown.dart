import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/Subcategories.dart';
import '../providers/langs_provider.dart';
class CustomDropdown extends StatelessWidget {
  List<Subcategories> value;
  List<Subcategories> items;
  final Function(Subcategories) onPressed;
  CustomDropdown({super.key , required this.onPressed , required this.items , required this.value});
  @override
  Widget build(BuildContext context) {
    LangsProvider langProvider = Provider.of<LangsProvider>(context);
    return DropdownButton<Subcategories>(
      value:value.isNotEmpty ? value[0] : null,
      elevation: 0,
      underline: const SizedBox.shrink(),
      icon: const SizedBox.shrink(),
      iconSize: 30,
      isExpanded: true,
      borderRadius: BorderRadius.circular(10),
      dropdownColor:Colors.white,
      items: items.map<DropdownMenuItem<Subcategories>>(
              (Subcategories value) {
            return DropdownMenuItem<Subcategories>(
              value: value,
              child: Text(
                  langProvider.language == 'ar' ? value.arTitle : value.enTitle ?? "",
                  style: GoogleFonts.cairo(
                      fontSize: 15,
                      color: const Color(0xff484848),
                      fontWeight: FontWeight.w600),
                  textScaler: const TextScaler.linear(1.0)
              ),
            );
          }).toList(),
      onChanged: (Subcategories? sura) async {
        if(sura != null){
          onPressed(sura);
        }
      },
      selectedItemBuilder: (BuildContext context) {
        return items.map((Subcategories value) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                    langProvider.language == 'ar' ? value.arTitle : value.enTitle ?? "",
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        color: const Color(0xff484848),
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textScaler: const TextScaler.linear(1.0)
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 30,
              ),
            ],
          );
        }).toList();
      },
    );
  }
}
