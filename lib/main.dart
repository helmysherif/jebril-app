import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jebril_app/providers/Audio_provider.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/providers/quran_data_provider.dart';
import 'package:jebril_app/providers/sura_details_provider.dart';
import 'package:jebril_app/screens/Sheikh_info_screen.dart';
import 'package:jebril_app/screens/home.dart';
import 'package:jebril_app/screens/more.dart';
import 'package:jebril_app/screens/prayers.dart';
import 'package:jebril_app/screens/quran_narratives.dart';
import 'package:jebril_app/screens/quran_screen.dart';
import 'package:jebril_app/screens/social_media_screen.dart';
import 'package:jebril_app/screens/splash_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jebril_app/screens/tarawih.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LangsProvider()),
        ChangeNotifierProvider(create: (context) => SuraDetailsProvider()),
        ChangeNotifierProvider(create: (context) => AudioProvider()),
        ChangeNotifierProvider(create: (context) => QuranDataProvider()),
        Provider<RouteObserver<ModalRoute>>(create: (context) => RouteObserver<ModalRoute>())
        // Add more providers here as needed
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<LangsProvider>(context);
    return SafeArea(
      child: MaterialApp(
        navigatorObservers: [
          Provider.of<RouteObserver<ModalRoute>>(context),
        ],
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('ar'), // Arabic
        ],
        locale:Locale(provider.language),
        routes: {
          SplashScreen.routeName: (context) => const SplashScreen(),
          HomeScreen.routeName : (context) => HomeScreen(),
          QuranScreen.routeName : (context) => const QuranScreen(),
          QuranNarratives.routeName : (context) => const QuranNarratives(),
          Tarawih.routeName : (context) => const Tarawih(),
          Prayers.routeName : (context) => const Prayers(),
          More.routeName : (context) => const More(),
          SocialMediaScreen.routeName : (context) => const SocialMediaScreen(),
          SheikhInfoScreen.routeName : (context) => const SheikhInfoScreen()
        },
        initialRoute:SplashScreen.routeName,
      ),
    );
  }
}