import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile_store/default_value.dart';
import 'package:mobile_store/main_page.dart';
import 'package:mobile_store/test.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'App',
      locale: const Locale("fa"),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColor.BackForeColor1,
              selectionHandleColor: AppColor.ForeColor,
        ),
        fontFamily: "Samim",
      ),
      
      home: Main(),
    );
  }
}

void main() {
  runApp(const App());
}
