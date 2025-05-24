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
                image: AssetImage("assets/pictures/backin.jpg"),
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
                                  width: 300,
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
                                  width: 300,
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
                  const SizedBox(height: 50),
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
