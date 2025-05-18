import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/login_page.dart';
import 'widgets.dart';
import 'shoppingCart_page.dart';

class ProductsVewPage extends StatefulWidget {
  final String type;

  ProductsVewPage({super.key, required this.type});
  @override
  State<ProductsVewPage> createState() => _ProductsVewPageState();
}

class _ProductsVewPageState extends State<ProductsVewPage> {
  late List _products;
  late List _filteredProducts;

  @override
  void initState() {
    super.initState();
    _products = Products.where((pr) => pr["type"] == widget.type).toList();
    _filteredProducts = _products;
  }

  void _onChangeSherch(String query) {
    setState(() {
      if (query.isNotEmpty) {
        _filteredProducts =
            _products
                .where(
                  (pr) => pr["name"].toString().toLowerCase().contains(query),
                )
                .toList();
      } else {
        _filteredProducts = _products;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MainBackGrondInDecoration(),
      child: Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                TextCreator(
                  'FlutterStore',
                  fontsize: 25,
                  style: FontWeight.bold,
                  fontFamily: "Automali",
                ),

                SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextFildCreator(
                      "جستجو",
                      onChanged: _onChangeSherch,
                      borderColor: AppColor.DarkTransparent,
                      inputTextFontsize: 14,
                      inputTextFontFamily: "Roboto",
                    ),
                  ),
                ),
              ],
            ),
          ),

          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),

        backgroundColor: Colors.transparent,

        body: Container(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(16, 30, 16, 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 3 / 5,
            ),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, i) {
              final produc = _filteredProducts[i];
              return ProductDisplay(
                context,
                int.parse(produc["ProductsID"]),
                produc["name"],
                int.parse(produc["price"]),
                produc["picPatch"],
                widget.type,
                widget.type == "mobile"
                    ? [
                      IconPrInfo(
                        Icons.account_tree_outlined,
                        jsonDecode(produc["specVew"])["cpu"],
                      ),
                      IconPrInfo(
                        Icons.battery_0_bar_outlined,
                        jsonDecode(produc["specVew"])["battery"],
                      ),
                      IconPrInfo(
                        Icons.android,
                        jsonDecode(produc["specVew"])["android"],
                      ),
                      IconPrInfo(
                        Icons.camera,
                        jsonDecode(produc["specVew"])["camera"],
                      ),
                    ]
                    : widget.type == "laptop"
                    ? [
                      IconPrInfo(
                        Icons.account_tree_outlined,
                        jsonDecode(produc["specVew"])["cpu"],
                      ),
                      IconPrInfo(
                        Icons.graphic_eq_outlined,
                        jsonDecode(produc["specVew"])["graphic"],
                      ),
                      IconPrInfo(
                        Icons.memory,
                        jsonDecode(produc["specVew"])["ram"],
                      ),
                      IconPrInfo(
                        Icons.storage_rounded,
                        jsonDecode(produc["specVew"])["storage"],
                      ),
                    ]
                    : [],
                buttonText: "+",
                onpress: () async {
                  if (currentUser.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    return;
                  }
                  Map order = cart.firstWhere(
                    (ord) =>
                        produc["ProductsID"].toString() ==
                        ord["ProductID"].toString(),
                    orElse: () => {},
                  );

                  if (order.isEmpty) {
                    var t = await http.post(
                      Url,
                      body: {
                        "state": "setorder",
                        "product_id": produc["ProductsID"].toString(),
                        "user_id": currentUser["UsersID"].toString(),
                      },
                    );
                    print(t.body);
                  } else if (order["count"].toString() == "4") {
                    alert(context, "شما به حداکثر تعداد قابل سفارش رسیدید.");
                  } else {
                    int count = int.parse(order["count"]) + 1;
                    await http.post(
                      Url,
                      body: {
                        "state": "upcountorder",
                        "count": count.toString(),
                        "OrdersID": order["OrdersID"],
                      },
                    );
                  }

                  await setCart();
                  setState(() {});
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (currentUser.isEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartPage()),
            );
          },
          backgroundColor: AppColor.BackForeColor2,
          hoverColor: AppColor.BackForeColor0,

          child: Icon(Icons.shopping_bag_outlined, color: AppColor.TextColor),
        ),
      ),
    );
  }
}
