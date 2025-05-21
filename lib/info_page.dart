import 'package:flutter/material.dart';
import 'package:mobile_store/default_value.dart';
import 'widgets.dart';


class InfoPage extends StatefulWidget {
  // final Function(int) ChangeI;

  // const InfoPage({super.key, required this.ChangeI});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MainBackGrondDecoration(),
      child: Scaffold(
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        appBar: AppBar(backgroundColor: Colors.transparent),
        drawer: DrawerMenu(context,maunPageIdex: 2),
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
                      title: "نام کاربر",
                      value: currentUser["name"],
                      icon: Icons.person,
                    ),
                    InfoCard(
                      title: "امتیاز شما",
                      value: "${purCost ~/ 102400}",
                      icon: Icons.star,
                    ),
                    InfoCard(
                      title: "تعدادسفارش",
                      value: "${Purchases.length}",
                      icon: Icons.shopping_bag,
                    ),
                    InfoCard(
                      title: "مبلغ کل",
                      value: PriceShow(purCost as int, fontsize: 16),
                      icon: Icons.attach_money,
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
