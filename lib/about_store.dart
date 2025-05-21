import 'package:flutter/material.dart';
import 'package:mobile_store/default_value.dart';
import 'widgets.dart';


class AboutPage extends StatefulWidget {
  // final Function(int) ChangeI;

  // const InfoPage({super.key, required this.ChangeI});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MainBackGrondDecoration(),
      child: Scaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        appBar: AppBar(backgroundColor: Colors.transparent),
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
                    const Image(
                      image: AssetImage("assets/pictures/welcome.png"),
                      height: 200,
                    ),

                    InfoCard(
                      title: "شروع فعالیت",
                      value: "1404/2/26",
                      icon: Icons.date_range,
                    ),
                    InfoCard(
                      title: "تلگرام",
                      value: "Yade_Sradar",
                      icon: Icons.telegram,
                    ),
                    InfoCard(
                      title: "توسعه دهنده",
                      value: "محمد کریمی",
                      icon: Icons.developer_mode_rounded,
                    ),
                    InfoCard(
                      title: "استاد",
                      value: "محمدرضا شمس",
                      icon: Icons.school,
                    ),
                    InfoCard(
                      title: "موضوع",
                      value: "پروژه نهایی",
                      icon: Icons.topic,
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
