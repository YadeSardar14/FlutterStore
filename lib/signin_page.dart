import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/main_page.dart';
import 'widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _password0 = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _number = TextEditingController();

  Future<void> checkAndSaveUser(BuildContext context) async {
    if (_name.text.isEmpty || _number.text.isEmpty) {
      alert(context, "لطفا تمام فیلد هارا پر کنید.");
      return;
    } else if (_number.text.length != 11) {
      alert(context, 'لطفا یک شماره معتبر وارد کنید.');
      return;
    } else if (_username.text.length < 4 || _password0.text.length < 4) {
      alert(context, 'نام کاربری و پسورد باید حداقل 4 کاراکتر باشند.');
      return;
    } else {
      var res = await http.post(
        Url,
        body: {
          "state": "checkuser",
          "with": "username",
          "username": _username.text.toString(),
        },
      );

      if (jsonDecode(res.body)[0]["status"] != "notmatch") {
        alert(
          context,
          "این نام کاربری قبلا انتخاب شده است لطفا یک نام‌کاربری دیگر وارد کنید.",
        );
      } else if (_password.text != _password0.text) {
        alert(context, "تاییدیه رمز عبور باهم مطابقت ندارند.");
      } else if (res.statusCode == 200) {
        var res = await http.post(
          Url,
          body: {
            "state": "setuser",
            "name": _name.text.toString(),
            "number": _number.text.toString(),
            "username": _username.text.toString(),
            "password": _password.text.toString(),
          },
        );

        if (res.statusCode == 200) {
          currentUser = {
            "name": _name.text.toString(),
            "number": _number.text.toString(),
            "username": _username.text.toString(),
          };

          final UserID = await http.post(
            Url,
            body: {
              "state": "get_userID_with_username",
              "username": _username.text.toString(),
            },
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            "UserID",
            jsonDecode(UserID.body)[0]["UsersID"].toString(),
          );

          setProducts();
          setCart();
          setPurchases();

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Main()),
          );
        }
      } else {
        alert(context, "مشکلی پیش آمده لطفا کمی بعد امتحان کنید.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MainBackGrondDecoration(),
      child: Scaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(20),
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextCreator(
                      'FlutterStore',
                      fontsize: 35,
                      style: FontWeight.bold,
                      fontFamily: "Automali",
                    ),

                    const SizedBox(height: 25),
                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: TextFildCreator(
                        ' نام و نام خانوادگی',
                        controller: _name,
                        hintText: 'نام و نام خانوادگی خود را وارد کنید',
                        regfilter: r'^[آ-ی\s]+$',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: TextFildCreator(
                        'شماره همراه',
                        regfilter: r'[0-9]',
                        controller: _number,
                        hintText: 'شماره تلفن خود را وارد کنید',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: TextFildCreator(
                        'نام کاربری',
                        regfilter: r'[a-zA-Z0-9]',
                        controller: _username,
                        hintText: 'یک نام کاربری برای خود وارد کنید',
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: TextFildCreator(
                        'رمز عبور',
                        controller: _password0,
                        hide: true,
                        hintText: 'یک رمز عبور برای خود وارد کنید',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: TextFildCreator(
                        'تکرار رمز عبور',
                        controller: _password,
                        hide: true,
                        hintText: 'رمز عبور خود را دوباره وارد کنید',
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 25, 70, 20),
                      child: ButtonCreator(
                        'ثبت نام',
                        () => checkAndSaveUser(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
