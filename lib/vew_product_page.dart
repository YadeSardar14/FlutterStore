import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/default_value.dart';
import 'package:mobile_store/login_page.dart';
import 'package:mobile_store/widgets.dart';

class ProductDetailSheet extends StatefulWidget {
  final Map product;
  const ProductDetailSheet(this.product, {super.key});
  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheet();
}

class _ProductDetailSheet extends State<ProductDetailSheet> {
  bool loadingNetworkPic = true;

  bool isAddProcessing = false;

  late int countInCart;

  late bool available = true;

  void AddToCard() async {
    if (currentUser.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    if (isAddProcessing) return;

    setState(() {
      isAddProcessing = true;
    });

    try {
      Map order = cart.firstWhere(
        (ord) =>
            widget.product["ProductsID"].toString() ==
            ord["ProductID"].toString(),
        orElse: () => {},
      );

      if (order.isEmpty) {
        await http.post(
          Url,
          body: {
            "state": "setorder",
            "product_id": widget.product["ProductsID"].toString(),
            "user_id": currentUser["UsersID"].toString(),
          },
        );
      } else if (order["count"].toString() == "4") {
        return;
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
    } catch (e) {
      print("Error: $e");
    } finally {
      await setCart();
      setState(() {
        available =
            cart.firstWhere(
              (ord) =>
                  widget.product["ProductsID"].toString() ==
                  ord["ProductID"].toString(),
              orElse: () => null,
            )?["available"] ??
            (int.parse(widget.product["inventory"]) > 0);
        countInCart = int.parse(
          cart.firstWhere(
            (ord) =>
                widget.product["ProductsID"].toString() ==
                ord["ProductID"].toString(),
            orElse: () => <String, dynamic>{"count": "0"},
          )["count"],
        );
        isAddProcessing = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    available =
        cart.firstWhere(
          (ord) =>
              widget.product["ProductsID"].toString() ==
              ord["ProductID"].toString(),
          orElse: () => null,
        )?["available"] ??
        (int.parse(widget.product["inventory"]) > 0);

    countInCart = int.parse(
      cart.firstWhere(
        (ord) =>
            widget.product["ProductsID"].toString() ==
            ord["ProductID"].toString(),
        orElse: () => <String, dynamic>{"count": "0"},
      )["count"],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map spec = jsonDecode(widget.product["specVew"]);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder:
          (_, controller) => Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pictures/backp.jpg"),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Center(
                        child: Hero(
                          tag: widget.product["ProductsID"].toString(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                widget.product["picPatchType"] == "URL"
                                    ? SizedBox(
                                      width:
                                          widget.product["type"] == "laptop"
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.8
                                              : widget.product["type"] ==
                                                  "mobile"
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.7
                                              : 0,
                                      height:
                                          widget.product["type"] == "laptop"
                                              ? 200
                                              : widget.product["type"] ==
                                                  "mobile"
                                              ? 300
                                              : 0,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              widget.product["type"] == "laptop"
                                                  ? 10
                                                  : widget.product["type"] ==
                                                      "mobile"
                                                  ? 20
                                                  : 0,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (loadingNetworkPic)
                                              Center(
                                                child: SpinKitFadingCube(
                                                  color:
                                                      AppColor.DarkTransparent0,
                                                  size: 25,
                                                ),
                                              ),
                                            Image.network(
                                              widget.product["picPatch"],
                                              fit: BoxFit.cover,
                                              width:
                                                  widget.product["type"] ==
                                                          "laptop"
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.9
                                                      : widget.product["type"] ==
                                                          "mobile"
                                                      ? MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.7
                                                      : 0,

                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  if (loadingNetworkPic) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          if (mounted) {
                                                            setState(() {
                                                              loadingNetworkPic =
                                                                  false;
                                                            });
                                                          }
                                                        });
                                                  }
                                                  return child;
                                                }
                                                return Center(
                                                  child: SpinKitFadingCube(
                                                    color:
                                                        AppColor
                                                            .DarkTransparent0,
                                                    size: 25,
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(Icons.error),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    : Image.asset(
                                      widget.product["picPatch"],
                                      fit: BoxFit.cover,
                                      width:
                                          widget.product["type"] == "laptop"
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.7
                                              : widget.product["type"] ==
                                                  "mobile"
                                              ? MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.5
                                              : 0,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextCreator(
                        widget.product["name"],
                        style: FontWeight.bold,
                        fontsize: 30,
                        color: AppColor.DarkTransparent1,
                      ),
                      const SizedBox(height: 10),
                      Divider(color: AppColor.DarkTransparent1, thickness: 1.5),
                      const SizedBox(height: 50),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children:
                              widget.product["type"] == "mobile"
                                  ? [
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.account_tree_outlined,
                                        spec["cpu"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),

                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.android,
                                        spec["android"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.smartphone,
                                        spec["size"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.battery_0_bar_outlined,
                                        spec["battery"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.camera,
                                        spec["camera"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                  ]
                                  : widget.product["type"] == "laptop"
                                  ? [
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.account_tree_outlined,
                                        spec["cpu"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.developer_board,
                                        spec["graphic"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.monitor,
                                        jsonDecode(
                                          widget.product["specVew"],
                                        )["displaysize"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.memory,
                                        spec["ram"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                    Expanded(
                                      child: IconPrInfo(
                                        Icons.storage_rounded,
                                        spec["storage"],
                                        color: AppColor.DarkTransparent1,
                                        fontsize: 13,
                                      ),
                                    ),
                                  ]
                                  : [],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(14),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(45, 0, 0, 0),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child:
                        available
                            ? Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Expanded(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: AddToCard,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColor.BackForeColor2,

                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                              ),
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                10,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                  ),
                                              elevation: 2,
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex: 3,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: AddToCard,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColor.BackForeColor2,
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    countInCart == 0 ||
                                                            isAddProcessing
                                                        ? 4
                                                        : 2,
                                              ),
                                              shape:
                                                  const RoundedRectangleBorder(),
                                              elevation: 2,
                                            ),

                                            child:
                                                isAddProcessing
                                                    ? SpinKitThreeBounce(
                                                      color: AppColor.BackColor,

                                                      size: 20,
                                                    )
                                                    : TextCreator(
                                                      countInCart == 0
                                                          ? 'افزودن به سبد خرید'
                                                          : countInCart
                                                              .toString(),

                                                      style: FontWeight.bold,
                                                      fontsize:
                                                          countInCart == 0
                                                              ? 13
                                                              : 17,
                                                      color: Colors.white,
                                                    ),
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex: 1,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              if (currentUser.isEmpty) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            LoginPage(),
                                                  ),
                                                );
                                                return;
                                              }
                                              if (isAddProcessing) return;
                                              setState(() {
                                                isAddProcessing = true;
                                              });
                                              try {
                                                Map order = cart.firstWhere(
                                                  (ord) =>
                                                      widget
                                                          .product["ProductsID"]
                                                          .toString() ==
                                                      ord["ProductID"]
                                                          .toString(),
                                                );

                                                if (int.parse(
                                                      order["count"].toString(),
                                                    ) >
                                                    1) {
                                                  int count =
                                                      int.parse(
                                                        order["count"],
                                                      ) -
                                                      1;
                                                  await http.post(
                                                    Url,
                                                    body: {
                                                      "state": "upcountorder",
                                                      "count": count.toString(),
                                                      "OrdersID":
                                                          order["OrdersID"],
                                                    },
                                                  );
                                                } else {
                                                  await http.post(
                                                    Url,
                                                    body: {
                                                      "state": "removeorder",
                                                      "OrdersID":
                                                          order["OrdersID"],
                                                    },
                                                  );
                                                }
                                              } catch (e) {
                                                print("Error: $e");
                                              } finally {
                                                await setCart();
                                                setState(() {
                                                  countInCart = int.parse(
                                                    cart.firstWhere(
                                                      (ord) =>
                                                          widget
                                                              .product["ProductsID"]
                                                              .toString() ==
                                                          ord["ProductID"]
                                                              .toString(),
                                                      orElse:
                                                          () =>
                                                              <String, dynamic>{
                                                                "count": "0",
                                                              },
                                                    )["count"],
                                                  );
                                                  isAddProcessing = false;
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColor.BackForeColor2,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 3,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                              ),
                                              elevation: 2,
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: PriceShow(
                                      int.parse(widget.product["price"]),
                                      fontsize: 20,
                                      color: AppColor.DarkTransparent1,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Center(
                              child: TextCreator(
                                "اتمام موجودی",
                                fontsize: 20,
                                color: AppColor.DarkTransparent0,
                                fontFamily: "Samin",
                                style: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
