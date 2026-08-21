import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_theme.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const TvStreamApp());
}

class TvStreamApp extends StatelessWidget {
  const TvStreamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TV Stream',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const Directionality(
          textDirection: TextDirection.rtl, child: HomePage()),
    );
  }
}
