import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jebril_app/providers/langs_provider.dart';
import 'package:jebril_app/providers/sura_details_provider.dart';
import 'package:jebril_app/screens/home.dart';
import 'package:jebril_app/screens/quran_screen.dart';
import 'package:jebril_app/screens/splash_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LangsProvider()),
        ChangeNotifierProvider(create: (context) => SuraDetailsProvider()),
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
          QuranScreen.routeName : (context) => QuranScreen()
        },
        initialRoute:SplashScreen.routeName,
      ),
    );
  }
}