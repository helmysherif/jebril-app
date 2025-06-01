import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:provider/provider.dart';
import '../models/AudioResponse.dart';
import '../providers/quran_data_provider.dart';
import '../widgets/custom_app_bar.dart';
import 'home.dart';

class Prayers extends StatefulWidget {
  static const String routeName = "prayers";

  const Prayers({super.key});

  @override
  State<Prayers> createState() => _PrayersState();
}

class _PrayersState extends State<Prayers> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  AudioResponse? prayersData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      getPrayersData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getPrayersData() async {
    try{
      setState(() {
        isLoading = true;
      });
      QuranDataProvider quranDataProvider =
      Provider.of<QuranDataProvider>(context, listen: false);
      prayersData = quranDataProvider.getFilteredQuranData("prayers", 0);
      // if (prayersData.subcategories.isEmpty) {
      //   throw Exception("No subcategories found");
      // }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch(e){
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint("Error loading prayers data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("_tabController.length => ${_tabController.length}");
    // if (isLoading || _tabController.length == 0) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    AudioProvider audioProvider = Provider.of<AudioProvider>(context);
    LangsProvider langsProvider = Provider.of<LangsProvider>(context);
    // if (isLoading || prayersData.subcategories.length == 0) {
    //   return const Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }
    if (isLoading || prayersData == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return DefaultTabController(
      length: prayersData?.subcategories.length ?? 0,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color(0xfff5f5f5),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          toolbarHeight: 100,
          title: Text(
              // "${audioProvider2.isRadioPlaying}",
              langsProvider.language == 'en'
                  ? prayersData!.enTitle ?? ""
                  : prayersData!.arTitle ?? "",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                  fontSize: 23,
                  color: const Color(0xff484848),
                  fontWeight: FontWeight.w600),
              textScaler: const TextScaler.linear(1.0)),
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_sharp, color: Color(0xff484848)),
            onPressed: () {
              audioProvider.changeIsRadioPlaying(false);
              Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
            },
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(85),
            child: Container(
              color: Color(0xfff5f5f5),
              padding: EdgeInsets.all(20),
              child: TabBar(
                // controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorPadding: EdgeInsets.zero,
                // labelPadding: EdgeInsets.zero,
                labelColor: Color(0xff014A43),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xff014A43),
                textScaler: const TextScaler.linear(1.0),
                dividerHeight: 2,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Color(0xff014A43), // Indicator color
                  ),
                  insets: EdgeInsets.zero,
                  // borderRadius:BorderRadius.circular(10)
                ),
                labelStyle: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
                tabs: prayersData!.subcategories.map((subcategory) {
                  return Tab(
                    text: langsProvider.language == 'en'
                        ? subcategory.enTitle
                        : subcategory.arTitle,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        body: isLoading || prayersData == null ? Center(child: CircularProgressIndicator()) : TabBarView(
          children: prayersData!.subcategories.map((subcategory) {
            return Center(
              child: Text(
                'Content for ${langsProvider.language == 'en' ? subcategory.enTitle : subcategory.arTitle}',
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
