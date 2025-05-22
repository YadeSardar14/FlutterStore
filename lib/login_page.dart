import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/default_value.dart';
import 'package:mobile_store/main_page.dart';
import 'package:mobile_store/signin_page.dart';
import 'widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loadng = false;

  Future<void> checkUser(BuildContext context) async {
    if (_username.text.length < 4 || _password.text.length < 4) {
      alert(context, 'نام کاربری و پسورد باید حداقل 4 کاراکتر باشند.');
    } else {
      setState(() {
        _loadng = true;
      });
      final response = await http.post(
        Url,
        body: {
          "state": "checkuser",
          "with": "password",
          "username": _username.text.toString(),
          "password": _password.text.toString(),
        },
      );

      if (response.statusCode == 200) {
        if (jsonDecode(response.body)[0]["status"] != "notmatch") {
          currentUser = jsonDecode(response.body)[0];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("UserID", currentUser["UsersID"].toString());

          await setProducts();
          await setCart();
          await setPurchases();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Main()),
          );
        } else {
          alert(context, 'نام کاربری یا رمز اشتباه است!');
        }
      } else {
        alert(context, "مشکلی پیش آمده لطفا کمی بعد امتحان کنید.");
      }
      setState(() {
        _loadng = false;
      });
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage("assets/pictures/welcome.png"),
                      height: 200,
                    ),
                    TextCreator(
                      'FlutterStore',
                      fontsize: 30,
                      style: FontWeight.bold,
                      fontFamily: "Automali",
                    ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: TextFildCreator(
                        'نام کاربری',
                        regfilter: r'[a-zA-Z0-9]',
                        controller: _username,
                        hintText: 'نام کاربری خود را وارد کنید',
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                      child: TextFildCreator(
                        'رمز عبور',
                        controller: _password,
                        hide: true,
                        hintText: 'رمز عبور خود را وارد کنید',
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 25, 70, 20),
                      child: ButtonCreator(
                        _loadng
                            ? SpinKitThreeBounce(
                              color: AppColor.BackColor,
                              size: 25,
                            )
                            : 'ورود',
                        () => checkUser(context),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(70, 0, 70, 20),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            TextCreator(
                              'حساب کاربری ندارید؟',
                              style: FontWeight.bold,
                              color: AppColor.BackForeColor2,
                            ),
                            InkWell(
                              child: TextCreator(
                                ' ثبت نام کنید.',
                                fontsize: 14,
                                style: FontWeight.bold,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SigninPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
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
