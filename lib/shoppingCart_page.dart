import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'widgets.dart';
import 'package:intl/intl.dart';

class CartPage extends StatefulWidget {
  final int tabIndex;
  const CartPage({super.key, this.tabIndex = 0});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.tabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MainBackGrondInDecoration(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 0,
            bottom: TabBar(
              controller: _tabController,
              tabs: <Widget>[Tab(text: 'سبد خرید'), Tab(text: 'خرید های قبلی')],
              labelColor:AppColor.DarkTransparent2,
              indicatorColor: AppColor.DarkTransparent,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              cart.isNotEmpty
                  ? Scaffold(
                    backgroundColor: Colors.transparent,
                    bottomNavigationBar:
                        cart.isNotEmpty
                            ? BottomAppBar(
                              color: const Color.fromARGB(104, 255, 255, 255),
                              shadowColor: AppColor.DarkTransparent0,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        110,
                                        0,
                                        5,
                                        0,
                                      ),
                                      child: ButtonCreator("پرداخت", () async {
                                        List orders =
                                            cart.map((ord) {
                                              return {
                                                "ProductID": ord["ProductID"],
                                                "count": ord["count"],
                                                "price":
                                                    Products.firstWhere(
                                                      (p) =>
                                                          ord["ProductID"] ==
                                                          p["ProductsID"],
                                                    )["price"],
                                              };
                                            }).toList();
                                        await http.post(
                                          Url,
                                          body: {
                                            "state": "setpurchases",
                                            "cost": cost.toString(),
                                            "userid":
                                                currentUser["UsersID"]
                                                    .toString(),
                                            "date": DateFormat(
                                              'yyyy-MM-dd',
                                            ).format(DateTime.now()),
                                            "time": DateFormat(
                                              'HH:mm',
                                            ).format(DateTime.now()),
                                            "code":
                                                Random()
                                                    .nextInt(900000000)
                                                    .toString(),
                                            "orders": jsonEncode(orders),
                                          },
                                        );
                                        await setPurchases();
                                        alert(
                                          context,
                                          "سفارش شما با موفقیت ثبت شد.",
                                        );

                                        cart.forEach((ord) async {
                                          await http.post(
                                            Url,
                                            body: {
                                              "state": "removeorder",
                                              "OrdersID": ord["OrdersID"],
                                            },
                                          );
                                        });

                                        setState(() {
                                          cart.clear();
                                        });
                                        
                                      }, fontstyle: FontWeight.bold),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: PriceShow(cost as int, fontsize: 22),
                                  ),
                                ],
                              ),
                            )
                            : null,

                    body: Center(
                      child: Container(
                        child: GridView.builder(
                          padding: EdgeInsets.fromLTRB(20, 35, 20, 35),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 3 / 5,
                              ),
                          itemCount: cart.length,
                          itemBuilder: (context, i) {
                            List ordersID =
                                cart
                                    .map((ord) => ord["ProductID"].toString())
                                    .toList();
                            List orders =
                                Products.where(
                                  (p) => ordersID.contains(
                                    p["ProductsID"].toString(),
                                  ),
                                ).toList();

                            final produc = orders[i];

                            return ProductDisplay(
                              context,
                              int.parse(produc["ProductsID"]),
                              produc["name"],
                              int.parse(produc["price"]),
                              produc["picPatch"],
                              produc["type"],
                              produc["type"] == "mobile"
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
                                  : produc["type"] == "laptop"
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
                              buttonText: "✘",
                              onpress: () async {
                                Map order = cart.firstWhere(
                                  (ord) =>
                                      produc["ProductsID"].toString() ==
                                      ord["ProductID"].toString(),
                                );

                                if (int.parse(order["count"].toString()) > 1) {
                                  int count = int.parse(order["count"]) - 1;
                                  await http.post(
                                    Url,
                                    body: {
                                      "state": "upcountorder",
                                      "count": count.toString(),
                                      "OrdersID": order["OrdersID"],
                                    },
                                  );
                                } else {
                                  await http.post(
                                    Url,
                                    body: {
                                      "state": "removeorder",
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
                    ),
                  )
                  : Center(child: Text('سبد خرید خالی است')),

              //------------------------------------
              Purchases.isNotEmpty
                  ? Scaffold(
                    body: Container(
                      child: GridView.builder(
                        padding: EdgeInsets.all(35),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 1,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 16,
                              childAspectRatio: 3 / 1,
                            ),
                        itemCount: Purchases.length,
                        itemBuilder: (context, i) {
                          Map order = Purchases[i];
                        
                          return InkWell(
                            onTap: () {},
                             
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              color: AppColor.DarkTransparent0,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,

                                        child: TextCreator(
                                          'کد سفارش  ${order['code']}',
                                          fontsize: 14,
                                          color: const Color.fromARGB(
                                            211,
                                            255,
                                            255,
                                            255,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: TextCreator(
                                          "${order['date']}       -       ${order["time"].substring(0, 5)}",
                                          fontsize: 12,
                                          color: const Color.fromARGB(
                                            146,
                                            255,
                                            255,
                                            255,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children:
                                                  order['orders'].take(3)
                                                      .map<Widget>(
                                                        (ord) =>  Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal: 4.0,
                                                                  ),
                                                              child: Image.asset(
                                                                Products.firstWhere(
                                                                  (p) =>
                                                                      ord["ProductID"] ==
                                                                      p["ProductsID"],
                                                                )["picPatch"],
                                                                width: 35,
                                                                height: 35,
                                                              ),
                                                            
                                                          ),
                                                        
                                                      )
                                                      .toList(),
                                            ),
                                          ),

                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: PriceShow(
                                                int.parse(order["cost"]),
                                                fontsize: 18,
                                                fontsizedown: 12,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                  )
                  : Center(child: Text('هنوز خریدی نکرده‌اید')),
            ],
          ),
        ),
      ),
    );
  }
}
