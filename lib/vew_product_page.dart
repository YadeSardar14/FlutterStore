import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_store/default_value.dart';
import 'package:mobile_store/widgets.dart';

class ProductDetailSheet extends StatelessWidget {
  final Map product;

  const ProductDetailSheet({required this.product});

  
  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                
                children: [
                  Center(
                    child: Hero(
                      tag: product["ProductsID"],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child:
                            product["picPatchType"] == "URL"
                                ? Image.network(
                                  product["picPatch"],
                                  fit: BoxFit.cover,
                                  width:  product["type"] == "laptop"? 300 : product["type"] == "mobile"? 230 : 0,
                                  loadingBuilder:
                                      (ctx, child, progress) =>
                                          progress == null
                                              ? child
                                              : SizedBox(
                                                width: 200,
                                                height: 200,
                                                child: Center(
                                                  child: SpinKitFadingCube(
                                                    color:
                                                        AppColor
                                                            .DarkTransparent0,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                  errorBuilder:
                                      (_, __, ___) =>
                                          Icon(Icons.error, size: 48),
                                )
                                : Image.asset(
                                  product["picPatch"],
                                  fit: BoxFit.cover,
                                  width: product["type"] == "laptop"? 300 : product["type"] == "mobile"? 230 : 0,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextCreator(
                    product["name"],
                    style: FontWeight.bold,
                    fontsize: 30,
                    color: AppColor.DarkTransparent1,
                  ),
                  const SizedBox(height: 10),
                   TextCreator(
                    "____________________________________________________________",
                    style: FontWeight.bold,
                    fontsize: 15,
                    color: AppColor.DarkTransparent1,
                  ),
                  const SizedBox(height: 50),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 35),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: product["type"] == "mobile"
                                ? [
                                  IconPrInfo(
                                    Icons.account_tree_outlined,
                                    jsonDecode(product["specVew"])["cpu"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                  IconPrInfo(
                                    Icons.battery_0_bar_outlined,
                                    jsonDecode(product["specVew"])["battery"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                  IconPrInfo(
                                    Icons.android,
                                    jsonDecode(product["specVew"])["android"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                  IconPrInfo(
                                    Icons.camera,
                                    jsonDecode(product["specVew"])["camera"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                ]
                                : product["type"] == "laptop"
                                ? [
                                  IconPrInfo(
                                    Icons.account_tree_outlined,
                                    jsonDecode(product["specVew"])["cpu"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                  IconPrInfo(
                                    Icons.graphic_eq_outlined,
                                    jsonDecode(product["specVew"])["graphic"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                  IconPrInfo(
                                    Icons.memory,
                                    jsonDecode(product["specVew"])["ram"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                  IconPrInfo(
                                    Icons.storage_rounded,
                                    jsonDecode(product["specVew"])["storage"],color: AppColor.DarkTransparent1,fontsize: 13,
                                  ),
                                ]
                                : [],),
                  ),
                  // PriceShow(
                  //     int.parse(product["price"]),
                  //     fontsize: 30,
                  //     color: AppColor.DarkTransparent1,
                  //   ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
    );
  }
}
