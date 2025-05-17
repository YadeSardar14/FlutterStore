import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/home_page.dart';
import 'package:mobile_store/info_page.dart';
import 'package:mobile_store/login_page.dart';
import 'package:mobile_store/shoppingCart_page.dart';
import 'package:mobile_store/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Main extends StatefulWidget {
  final int currentindex;
  final int carttabindex;

  const Main({super.key, this.currentindex = 0, this.carttabindex = 0});

  @override
  State<Main> createState() => _MainPage();
}

class _MainPage extends State<Main> {
  late int _currentindex;
  List MainPages = List.empty();

  _CheckInitUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("UserID") && currentUser.isEmpty) {
      String? UserID = await prefs.getString("UserID");
      final response = await http.post(
        Url,
        body: {"state": "checkuser", "with": "UserID", "user_id": UserID},
      );

      if (response.statusCode == 200) {
        currentUser = jsonDecode(response.body)[0];
      }

      await setProducts();
      await setCart();
      await setPurchases();
    }
  }

  @override
  void initState() {
    super.initState();
    _CheckInitUser();
    MainPages = [
      HomePage(),
      CartPage(tabIndex: widget.carttabindex),
      InfoPage(),
    ];
    _currentindex = widget.currentindex;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main',
      locale: const Locale("fa"),
      supportedLocales: const [Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(primarySwatch: Colors.amber, fontFamily: "Samim"),
      home: Container(
        decoration: MainBackGrondInDecoration(),
        child: Scaffold(
          backgroundColor: const Color.fromARGB(99, 255, 255, 255),

          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColor.TextColor,
            unselectedItemColor: const Color.fromARGB(158, 0, 0, 0),
            fixedColor: const Color.fromARGB(158, 0, 0, 0),

            items: [
              BottomNavigationBarItem(
                icon: Icon(
                  _currentindex == 0 ? Icons.home : Icons.home_outlined,
                ),
                label: 'خانه',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _currentindex == 1
                      ? Icons.shopping_bag
                      : Icons.shopping_bag_outlined,
                ),
                label: 'سبد خرید',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  _currentindex == 2 ? Icons.person : Icons.person_outline,
                ),
                label: 'فلاتر من',
              ),
            ],
            currentIndex: _currentindex,
            onTap: (index) {
              if ((index == 2 || index == 1) && currentUser.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                return;
              }
              setState(() {
                _currentindex = index;
              });
            },
          ),

          body: MainPages[_currentindex],
        ),
      ),
    );
  }
}
