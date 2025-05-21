import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/default_value.dart';
import 'package:mobile_store/products_page.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late bool _loading = true;

  void _onSearchChanged(String query) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (query.isNotEmpty) {
      List filteredProducts =
          Products.where(
            (item) => item["name"].toString().toLowerCase().contains(
              query.toLowerCase(),
            ),
          ).toList();
      if (filteredProducts.isNotEmpty) {
        _overlayEntry = _createOverlayEntry(filteredProducts);
        Overlay.of(context).insert(_overlayEntry!);
      }
    }
  }

  OverlayEntry _createOverlayEntry(List ProductsList) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: 35,
            right: 70,

            top: offset.dy + 60,

            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(-95, 75),
              child: Material(
                color: const Color.fromARGB(199, 255, 218, 184),
                elevation: 4.0,

                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                  shrinkWrap: true,
                  itemCount: ProductsList.length,
                  itemBuilder: (context, index) {
                    Map product = ProductsList[index];
                    return Card(
                      color: const Color.fromARGB(197, 255, 255, 255),
                      margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Padding(
                          padding: EdgeInsets.symmetric(vertical: 3),
                          child: Image(
                            image:
                                product["picPatchType"] == "URL"
                                    ? NetworkImage(product["picPatch"])
                                    : AssetImage(product["picPatch"]),
                          ),
                        ),
                        title: TextCreator(
                          fontsize: 14,
                          product["name"],
                          style: FontWeight.bold,
                          color: const Color.fromARGB(103, 0, 7, 112),
                        ),
                        trailing: PriceShow(
                          int.parse(product["price"]),
                          fontsize: 14,
                          color: const Color.fromARGB(255, 57, 24, 114),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }

  Future _SetCategories() async {
    var response = (await http.post(Url, body: {"state": "getcategories"}));
    if (response.statusCode == 200) {
      Categorys = jsonDecode(response.body);
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _SetCategories();
  }

  @override
  Widget build(BuildContext context) {
    setProducts();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        _overlayEntry?.remove();
        _overlayEntry = null;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Expanded(
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 0, 20),
                    child: SizedBox(
                      height: 40,

                      child: TextFildCreator(
                        "جستجو در فلاتر",
                        onChanged: _onSearchChanged,
                        borderColor: AppColor.DarkTransparent,
                        inputTextFontsize: 14,
                        inputTextFontFamily: "Roboto",
                      ),
                    ),
                  ),
                ),
              ),

              TextCreator(
                'FlutterStore',
                fontsize: 25,
                style: FontWeight.bold,
                fontFamily: "Automali",
              ),
              SizedBox(width: 25),
            ],
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),

        drawer: DrawerMenu(context, maunPageIdex: 0),
        drawerEnableOpenDragGesture: true,
        onDrawerChanged: (isOpened) {
          if (isOpened) {
            FocusScope.of(context).unfocus();
            _overlayEntry?.remove();
            _overlayEntry = null;
          }
        },

        body:
            _loading
                ? SpinKitThreeBounce(color: AppColor.BackColor, size: 30)
                : Container(
                  child: GridView.builder(
                    padding: EdgeInsets.all(35),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 7 / 4,
                        ),
                    itemCount: Categorys.length,
                    itemBuilder: (context, i) {
                      Map item = Categorys[i];
                      return CategoryDisplay(
                        item["picPatch"],
                        picPatchType: item["picPatchType"],
                        text: item["name"],
                        onpress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ProductsVewPage(type: item["type"]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
