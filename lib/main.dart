import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_family_app/screens/shopping_chart/shopping_chart_screen.dart';
import 'package:my_family_app/screens/user/add_name_screen.dart';
import 'package:my_family_app/services/user_service.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as ofa;
import 'package:page_transition/page_transition.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';
import 'screens/user/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseDatabase.instance.setPersistenceEnabled(true); //prova3
  await loadUsers();
  tz.initializeTimeZones();
  ofa.OpenFoodAPIConfiguration.userAgent = ofa.UserAgent(name: 'my_family_app');
  ofa.OpenFoodAPIConfiguration.globalLanguages = [
    ofa.OpenFoodFactsLanguage.ENGLISH,
    ofa.OpenFoodFactsLanguage.ITALIAN
  ];
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;

  @override
  void initState() {
    user = FirebaseAuth.instance.currentUser;
    super.initState();
  }

  Widget checkUserAuth() {
    if (user == null) {
      return const LoginScreen();
    } else if (user!.displayName == null || user!.displayName == '') {
      return const AddNameScreen();
    } else {
      return const ShoppingChartScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muu App',
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.3),
      ),
      supportedLocales: const [
        Locale.fromSubtags(languageCode: 'it', countryCode: 'IT'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeListResolutionCallback: (locales, supportedLocales) {
        if (locales == null) {
          return const Locale('it', 'IT');
        }

        for (Locale locale in locales) {
          if (supportedLocales.contains(locale)) {
            return locale;
          }
        }

        return const Locale('it', 'IT');
      },
      locale: const Locale.fromSubtags(languageCode: 'it', countryCode: 'IT'),
      debugShowCheckedModeBanner: false,
      home: AnimatedSplashScreen(
        duration: 5000,
        splash: DecoratedBox(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(120),
                border: Border(
                  left: BorderSide(color: Colors.green.shade800, width: 4),
                  top: BorderSide(color: Colors.green.shade800, width: 8),
                  right: BorderSide(color: Colors.green.shade800, width: 4),
                )),
            child: Image.asset(
              'assets/splash_screen.png',
            )),
        splashIconSize: 200,
        splashTransition: SplashTransition.rotationTransition,
        curve: Curves.bounceInOut,
        animationDuration: const Duration(milliseconds: 5000),
        pageTransitionType: PageTransitionType.fade,
        nextScreen: checkUserAuth(),
      ),
    );
  }
}
