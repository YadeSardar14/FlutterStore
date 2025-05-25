import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/default_value.dart';

import 'package:mobile_store/vew_product_page.dart';

import 'package:shamsi_date/shamsi_date.dart';
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
  bool _payProcessing = false;
  bool isRemProcessing = false;
  late int indexRemProcessing;
  int cartShowLentgh = cart.length;
  late final _date = Jalali.now().formatter;

  late List ordersID;
  late List orders;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.tabIndex,
    );

    ordersID = cart.map((ord) => ord["ProductID"].toString()).toList();
    orders =
        Products.where(
          (p) => ordersID.contains(p["ProductsID"].toString()),
        ).toList();
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
              labelColor: AppColor.DarkTransparent2,
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
                                      child: ButtonCreator(
                                        _payProcessing
                                            ? SpinKitThreeBounce(
                                              color: AppColor.BackColor,
                                              size: 25,
                                            )
                                            : "پرداخت",
                                        () async {
                                          if (_payProcessing) return;
                                          setState(() {
                                            _payProcessing = true;
                                          });

                                          List validCart = [];

                                          for (var item in cart) {
                                            Map Product = Products.firstWhere(
                                              (p) =>
                                                  item["ProductID"]
                                                      .toString() ==
                                                  p["ProductsID"].toString(),
                                            );

                                            if (item["available"] ||
                                                int.parse(item["count"]) ==
                                                    int.parse(
                                                      Product["inventory"],
                                                    )) {
                                              validCart.add(item);
                                            }
                                          }

                                          List ords =
                                              validCart.map((ord) {
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

                                          var purRes = await http.post(
                                            Url,
                                            body: {
                                              "state": "setpurchases",
                                              "cost": cost.toString(),
                                              "userid":
                                                  currentUser["UsersID"]
                                                      .toString(),
                                              "date":
                                                  '${_date.d} ${_date.mN} ${_date.yyyy}',
                                              "time": DateFormat(
                                                'HH:mm',
                                              ).format(DateTime.now()),
                                              "code":
                                                  Random()
                                                      .nextInt(900000000)
                                                      .toString(),
                                              "orders": jsonEncode(ords),
                                            },
                                          );
                                          await setPurchases();
                                          if (purRes.statusCode == 200) {
                                            await http.post(
                                              Url,
                                              body: {
                                                "state": "setinventory",
                                                "orders": jsonEncode(validCart),
                                              },
                                            );
                                          }

                                          alert(
                                            context,
                                            "سفارش شما با موفقیت ثبت شد.",
                                          );

                                          for (var ord in cart) {
                                            await http.post(
                                              Url,
                                              body: {
                                                "state": "removeorder",
                                                "OrdersID": ord["OrdersID"],
                                              },
                                            );
                                          }

                                          setState(() {
                                            cart.clear();
                                            _payProcessing = false;
                                          });
                                        },
                                        fontstyle: FontWeight.bold,
                                      ),
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
                            final produc = orders[i];
                            final Map spec = jsonDecode(produc["specVew"]);
                            final ord = cart.firstWhere(
                              (ord) =>
                                  produc["ProductsID"].toString() ==
                                  ord["ProductID"].toString(),
                            );
                            bool available =
                                (ord["available"] ||
                                    int.parse(produc["inventory"]) ==
                                        int.parse(ord["count"]));

                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder:
                                      (context) => ProductDetailSheet(produc),
                                );
                              },

                              child: ProductDisplay(
                                int.parse(produc["ProductsID"]),
                                produc["name"],
                                int.parse(produc["price"]),
                                produc["picPatch"],
                                produc["type"],
                                produc["type"] == "mobile"
                                    ? [
                                      IconPrInfo(
                                        Icons.account_tree_outlined,
                                        spec["cpu"],
                                      ),
                                      IconPrInfo(
                                        Icons.battery_0_bar_outlined,
                                        spec["battery"],
                                      ),
                                      IconPrInfo(
                                        Icons.android,
                                        spec["android"],
                                      ),
                                      IconPrInfo(Icons.camera, spec["camera"]),
                                    ]
                                    : produc["type"] == "laptop"
                                    ? [
                                      IconPrInfo(
                                        Icons.account_tree_outlined,
                                        spec["cpu"],
                                      ),
                                      IconPrInfo(
                                        Icons.graphic_eq_outlined,
                                        spec["graphic"],
                                      ),
                                      IconPrInfo(Icons.memory, spec["ram"]),
                                      IconPrInfo(
                                        Icons.storage_rounded,
                                        spec["storage"],
                                      ),
                                    ]
                                    : [],
                                picPatchType: produc["picPatchType"],
                                buttonText: "✘",
                                available: available,
                                isAddProcessing:
                                    isRemProcessing && i == indexRemProcessing,
                                onpress: () async {
                                  if (isRemProcessing) return;
                                  setState(() {
                                    isRemProcessing = true;
                                    indexRemProcessing = i;
                                  });
                                  try {
                                    Map order = cart.firstWhere(
                                      (ord) =>
                                          produc["ProductsID"].toString() ==
                                          ord["ProductID"].toString(),
                                    );

                                    if (int.parse(order["count"].toString()) >
                                        1) {
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
                                  } catch (e) {
                                    print("Error: $e");
                                  } finally {
                                    await setCart();
                                    setState(() {
                                      orders =
                                          Products.where(
                                            (p) => cart
                                                .map(
                                                  (ord) =>
                                                      ord["ProductID"]
                                                          .toString(),
                                                )
                                                .contains(
                                                  p["ProductsID"].toString(),
                                                ),
                                          ).toList();
                                      isRemProcessing = false;
                                    });
                                  }
                                },
                              ),
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
                                          "${order['date']} - ${order["time"].substring(0, 5)}",
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children:
                                                  order['orders'].take(3).map<
                                                    Widget
                                                  >((ord) {
                                                    final produc =
                                                        Products.firstWhere(
                                                          (p) =>
                                                              ord["ProductID"] ==
                                                              p["ProductsID"],
                                                        );
                                                    return Flexible(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 4.0,
                                                            ),
                                                        child:
                                                            produc["picPatchType"] ==
                                                                    "URL"
                                                                ? Image.network(
                                                                  produc["picPatch"],
                                                                  width: 35,
                                                                  height: 35,
                                                                )
                                                                : Image.asset(
                                                                  produc["picPatch"],
                                                                  width: 35,
                                                                  height: 35,
                                                                ),
                                                      ),
                                                    );
                                                  }).toList(),
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
