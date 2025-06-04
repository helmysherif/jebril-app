import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:provider/provider.dart';
import '../models/Sheikh_Info.dart';
import '../widgets/custom_app_bar.dart';
import 'more.dart';
class SheikhInfoScreen extends StatelessWidget {
  static const String routeName = "Sheikh-info";
  const SheikhInfoScreen({super.key});
  Future<SheikhInfo> loadSheikhInfo() async {
    final String response = await rootBundle.loadString('assets/sheikh_info.json');
    final data = await json.decode(response);
    return SheikhInfo.fromJson(data);
  }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    LangsProvider langsProvider = Provider.of<LangsProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xfff5f5f5),
      appBar: CustomAppBar(
        label: localizations.sheikhInfo,
        onPressed: () {
          Navigator.of(context).pushReplacementNamed(More.routeName);
      }),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height:50),
              Image.asset(
                "assets/images/sheikh_img.png",
                width:MediaQuery.of(context).size.width * 0.6
              ),
              FutureBuilder<SheikhInfo>(
                future: loadSheikhInfo(),
                builder: (context , snapshot){
                  if(snapshot.hasData){
                    final info = snapshot.data!;
                    final textContent = langsProvider.language == 'ar'
                        ? info.arabicInfo
                        : info.englishInfo;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal:20 , vertical:20),
                      child: Column(
                        children: [
                          // Display Arabic info with line breaks
                          Text(
                            textContent.replaceAll('\n', '\n\n'),
                            style: GoogleFonts.cairo(
                              fontSize:18,
                              fontWeight:FontWeight.w600,
                            ),
                            textScaler: const TextScaler.linear(1.0),
                            textAlign:TextAlign.justify,
                          ),
                        ],
                      ),
                    );
                  }else if (snapshot.hasError) {
                    return Text("Error loading data");
                  }
                  return CircularProgressIndicator();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
