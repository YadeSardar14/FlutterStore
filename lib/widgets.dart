import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/about_store.dart';
import 'package:mobile_store/default_value.dart';
import 'package:mobile_store/login_page.dart';
import 'package:mobile_store/main_page.dart';
import 'package:mobile_store/shoppingCart_page.dart';
import 'package:mobile_store/vew_product_page.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

Future setProducts() async {
  var response = await http.post(
    Url,
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: {"state": "getproducts"},
  );

  if (response.statusCode == 200) {
    Products = json.decode(response.body) as List;

    Products.sort((a, b) {
      int invA = int.parse(a["inventory"].toString());
      int invB = int.parse(b["inventory"].toString());

      if (invA == 0 && invB != 0) return 1;
      if (invA != 0 && invB == 0) return -1;
      return 0;
    });
    return 1;
  } else {
    return 0;
  }
}

Future setCategories() async {
  var response = await http.post(Url, body: {"state": "getcategories"});

  if (response.statusCode == 200) {
    Categorys = jsonDecode(response.body) as List;
    return 1;
  } else {
    return 0;
  }
}

Future setCart() async {
  var response = await http.post(
    Url,
    body: {
      "state": "getusercart",
      "user_id": currentUser["UsersID"].toString(),
    },
  );
  if (response.statusCode == 200) {
    cart = jsonDecode(response.body);

    if (cart.isNotEmpty) {
      cost = 0;
      for (Map ord in cart) {
        int inventory = int.parse(
          Products.firstWhere(
            (p) => p["ProductsID"].toString() == ord["ProductID"].toString(),
          )["inventory"],
        );
        ord["available"] = inventory > int.parse(ord["count"]);
        if (ord["available"] || inventory == int.parse(ord["count"])) {
          cost +=
              int.parse(
                Products.firstWhere(
                  (p) =>
                      p["ProductsID"].toString() == ord["ProductID"].toString(),
                )["price"],
              ) *
              int.parse(ord["count"].toString());
        }
      }
    } else {
      cost = 0;
    }
    return 1;
  } else {
    return 0;
  }
}

Future setPurchases() async {
  var response = await http.post(
    Url,
    body: {
      "state": "getpurchases",
      "user_id": currentUser["UsersID"].toString(),
    },
  );

  if (response.statusCode == 200) {
    Purchases = jsonDecode(response.body);

    if (Purchases.isNotEmpty) {
      purCost = Purchases.fold(0, (sum, ord) {
        ord["orders"] = jsonDecode(ord["orders"]);
        return sum + int.parse(ord["cost"]);
      });
      return 1;
    } else {
      return 0;
    }
  }
}

Future<Database> getDatabase() async {
  final path = join(await getDatabasesPath(), 'mydata.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''CREATE TABLE categories 
        ("categorieID" INTEGER PRIMARY KEY AUTOINCREMENT,
         "name" TEXT NOT NULL, "picPatch" TEXT NOT NULL,
         "picPatchType" TEXT NOT NULL,
         "type" TEXT NOT NULL);''');
    },
  );
}

Future<void> updateCategories() async {
  final db = await getDatabase();
  await db.transaction((txn) async {
    await txn.delete('categories');
    final batch = txn.batch();
    for (var cat in Categorys) {
      batch.insert('categories', cat);
    }
    await batch.commit(noResult: true);
  });
}

Future<List<Map<String, dynamic>>> getCategories() async {
  final db = await getDatabase();
  final List<Map<String, dynamic>> result = await db.query('categories');
  return result;
}

void alert(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

String priceFormater(int price) {
  List format = [];
  var data = price.toString().split("").reversed.toList();
  // ignore: unused_local_variable
  for (int i = 1; i <= data.length; i++) {
    format.add(data[i - 1]);
    if (i % 3 == 0 && i < data.length) {
      format.add(",");
    }
  }
  return format.reversed.join("");
}

Widget PriceShow(
  int price, {
  Color color = AppColor.ForeColor,
  double fontsize = 22,
  double fontsizedown = 12,
  FontWeight style = FontWeight.bold,
  String previoustext = "",
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextCreator(
          previoustext + priceFormater(price),
          style: style,
          color: color,
          fontsize: fontsize,
        ),

        SizedBox(width: 5),

        TextCreator(
          "تومان ",
          color: color.withValues(alpha: 80),
          fontsize: fontsizedown,
          style: style,
        ),
      ],
    ),
  );
}

Widget IconPrInfo(
  IconData icon,
  String text, {
  Color color = Colors.white,
  double fontsize = 10,
  FontWeight? fontstyle,
  double iconsize = 18,
  double margin = 5,
}) {
  return FittedBox(
    fit: BoxFit.scaleDown,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: iconsize),
          SizedBox(height: margin),
          TextCreator(text, color: color, fontsize: fontsize, style: fontstyle),
        ],
      ),
    ),
  );
}

Widget TextCreator(
  String text, {
  double fontsize = 16,
  Color color = AppColor.ForeColor,
  Color background = const Color.fromARGB(0, 0, 0, 0),
  FontWeight? style = FontWeight.normal,
  String fontFamily = "Vazir",
  int? maxline,
}) {
  return AutoSizeText(
    text,
    maxLines: maxline,
    overflow: TextOverflow.ellipsis,
    softWrap: true,
    style: TextStyle(
      fontSize: fontsize,
      color: color,
      fontFamily: fontFamily,
      inherit: false,
      fontWeight: style,
      backgroundColor: background,
    ),
    minFontSize: 8,
    stepGranularity: 1,
  );
}

Widget TextFildCreator(
  String labelText, {
  String? hintText,
  TextEditingController? controller,
  onChanged,
  bool hide = false,
  String regfilter = r'.',
  Color? hoverColor,
  Color? color,
  Color borderColor = AppColor.ForeColor,
  Color labelColor = const Color.fromARGB(255, 70, 70, 70),
  double radius = 14,
  double hintFontSize = 12,
  FontWeight inputTextStyle = FontWeight.bold,
  double inputTextFontsize = 16,
  Color inputTextColor = const Color.fromARGB(106, 7, 7, 7),
  String inputTextFontFamily = "Samin",
}) {
  color = AppColor.BackForeColor0;
  // ignore: deprecated_member_use
  hoverColor = AppColor.ForeColor.withOpacity(0.3);

  return TextField(
    controller: controller,
    onChanged: onChanged,
    obscureText: hide,
    cursorColor: const Color.fromARGB(117, 0, 0, 0),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(regfilter))],
    decoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      hintStyle: TextStyle(fontSize: hintFontSize),
      filled: true,
      hoverColor: hoverColor,
      fillColor: color,

      labelStyle: TextStyle(color: labelColor),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: borderColor, width: 1.5),
      ),
    ),

    style: TextStyle(
      color: inputTextColor,
      fontSize: inputTextFontsize,
      fontWeight: inputTextStyle,
      fontFamily: inputTextFontFamily,
    ),
  );
}

Widget ButtonCreator(
  text,
  onPressed, {
  double fontsize = 18,
  FontWeight fontstyle = FontWeight.bold,
  Color fontcolor = AppColor.TextColor,
  double? height,
  double width = double.infinity,
  EdgeInsetsGeometry padding = const EdgeInsets.all(15),
  Color? color,
  double radius = 14,
}) {
  color = color ?? AppColor.BackForeColor2;

  return SizedBox(
    width: width,
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: padding,
        backgroundColor: color,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      child:
          text is String
              ? TextCreator(
                text,
                fontsize: fontsize,
                style: fontstyle,
                color: fontcolor,
              )
              : text,
    ),
  );
}

Widget InfoCard({required String title, required value, IconData? icon}) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    child: ListTile(
      leading:
          icon != null
              ? Icon(icon, color: const Color.fromARGB(164, 171, 162, 255))
              : null,
      title: TextCreator(
        title,
        style: FontWeight.bold,
        color: const Color.fromARGB(141, 0, 10, 145),
      ),
      trailing:
          value.runtimeType == String
              ? TextCreator(
                value,
                style: FontWeight.bold,
                color: AppColor.ForeColor,
              )
              : value,
    ),
  );
}

Widget CategoryDisplay(
  String picPatch, {
  onpress,
  String picPatchType = "asset",
  String text = "",
  double height = 200,
  Color? background,
  double radius = 10,
  Color textColor = AppColor.TextColor,
}) {
  background = const Color.fromARGB(61, 110, 35, 0);
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onpress,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 50, 20),
                child: TextCreator(
                  text,
                  maxline: 2,
                  color: textColor,
                  fontsize: 40,
                  fontFamily: "Vazir",
                  style: FontWeight.bold,
                ),
              ),
            ),

            Expanded(
              child: Image(
                image:
                    picPatchType == "URL"
                        ? NetworkImage(picPatch)
                        : AssetImage(picPatch),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class ProductDisplay extends StatefulWidget {
  final int id;
  final String name;
  final int price;
  final String picPatch;
  final String type;
  final List<Widget> specifications;
  final Function? onpress;
  final bool available;
  final String picPatchType;
  final dynamic buttonText;
  final bool isAddProcessing;
  final Color? backgroundColor;
  final Color frontColor;

  ProductDisplay(
    this.id,
    this.name,
    this.price,
    this.picPatch,
    this.type,
    this.specifications, {
    this.onpress,
    super.key,
    this.available = true,
    this.picPatchType = "asset",
    this.buttonText = "+",
    this.isAddProcessing = false,
    this.frontColor = AppColor.TextColor,
    Color? backgroundColor,
  }) : backgroundColor = backgroundColor ?? AppColor.DarkTransparent1;

  @override
  State<ProductDisplay> createState() => _ProductDisplay();
}

class _ProductDisplay extends State<ProductDisplay> {
  @override
  Widget build(BuildContext context) {
    String? newTextButton = widget.buttonText;
    bool loadingNetworkPic = true;

    Map order = cart.firstWhere(
      (ord) => widget.id.toString() == ord["ProductID"].toString(),
      orElse: () => {},
    );

    if (order.isNotEmpty) {
      newTextButton = "${widget.buttonText}  ${order["count"].toString()}";
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Hero(
                tag: widget.id.toString(),
                child:
                    widget.picPatchType == "URL"
                        ? Stack(
                          alignment: Alignment.center,
                          children: [
                            if (loadingNetworkPic)
                              Center(
                                child: SpinKitFadingCube(
                                  color: AppColor.DarkTransparent0,
                                  size: 25,
                                ),
                              ),

                            Image.network(
                              widget.picPatch,
                              fit: BoxFit.cover,

                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  if (loadingNetworkPic) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() {
                                              loadingNetworkPic = false;
                                            });
                                          }
                                        });
                                  }
                                  return child;
                                }

                                return Center(
                                  child: SpinKitFadingCube(
                                    color: AppColor.DarkTransparent0,
                                    size: 25,
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.error),
                            ),
                          ],
                        )
                        : Image.asset(widget.picPatch, fit: BoxFit.cover),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),

              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: TextCreator(
                  widget.name,
                  color: widget.frontColor,
                  fontsize: 20, //name.length>19 ? 19 * (19/name.length) : 19,
                  style: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(8, 5, 8, 8),

              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: widget.specifications,
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),

              child:
                  widget.available
                      ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: ButtonCreator(
                              widget.isAddProcessing
                                  ? SpinKitThreeBounce(
                                    color: AppColor.BackColor,
                                    size: 12,
                                  )
                                  : newTextButton,
                              widget.onpress,
                              fontsize: 14,
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                            ),
                          ),

                          Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: PriceShow(
                                  widget.price,
                                  fontsize: widget.type == "laptop" ? 19 : 20,
                                  color: widget.frontColor,
                                  style: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : Center(
                        child: TextCreator(
                          "اتمام موجودی",
                          fontsize: 20,
                          color: widget.frontColor.withOpacity(0.5),
                          fontFamily: "Samin",
                          style: FontWeight.bold,
                        ),
                      ),
            ),
          ),
          SizedBox(height: widget.type == "mobile" ? 22 : 10),
        ],
      ),
    );
  }
}

Widget DrawerMenu(
  BuildContext context, {
  int maunPageIdex = 2,
  VoidCallback? onOpen,
}) {
  onOpen?.call();
  return Drawer(
    backgroundColor: const Color.fromARGB(26, 255, 224, 224),
    child: ListView(
      padding: EdgeInsets.all(5),
      children: [
        DrawerHeader(
          decoration: MainBackGrondDecoration(),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextCreator(
              'FlutterStore',
              fontsize: 30,
              style: FontWeight.bold,
              fontFamily: "Automali",
            ),
          ),
        ),

        MenuCard('خانه', Icons.home_outlined, () {
          if (maunPageIdex == 0) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Main(currentindex: 0)),
            );
          }
        }),

        SizedBox(height: 10),

        MenuCard('پروفایل', Icons.person_outlined, () {
          if (maunPageIdex == 2) {
            Navigator.pop(context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        currentUser.isEmpty
                            ? LoginPage()
                            : Main(currentindex: 2),
              ),
            );
          }
        }),

        SizedBox(height: 10),

        MenuCard('سبدخرید', Icons.shopping_bag_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => currentUser.isEmpty ? LoginPage() : CartPage(),
            ),
          );
        }),

        SizedBox(height: 10),

        MenuCard('خرید های من', Icons.shopping_bag, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      currentUser.isEmpty
                          ? LoginPage()
                          : Main(carttabindex: 1, currentindex: 1),
            ),
          );
        }),

        SizedBox(height: 10),

        MenuCard('درباره ما', Icons.info_outline, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutPage()),
          );
        }),

        SizedBox(height: 10),

        MenuCard('خروج از خساب کاربری', Icons.logout, () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          currentUser.clear();
          cart.clear();
          Purchases.clear();
          cost = 0;
          purCost = 0;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Main()),
          );
        }),
      ],
    ),
  );
}

Widget MenuCard(
  String title,
  IconData icon,
  GestureTapCallback ontab, {
  double height = 70,
}) {
  return ListTile(
    leading: Icon(icon, color: const Color.fromARGB(148, 56, 0, 88)),
    title: TextCreator(
      title,
      style: FontWeight.bold,
      color: const Color.fromARGB(213, 0, 13, 83),
    ),

    onTap: ontab,

    tileColor: const Color.fromARGB(209, 255, 240, 226),
    minTileHeight: height,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}

OverlayEntry CreateOverlayEntryForSherch(
  BuildContext context,
  LayerLink link,
  List ProductsList, {
  remove,
  add,
}) {
  RenderBox renderBox = context.findRenderObject() as RenderBox;
  Offset offset = renderBox.localToGlobal(Offset.zero);

  return OverlayEntry(
    builder:
        (context) => Positioned(
          left: 35,
          right: 70,

          top: offset.dy + 60,

          child: CompositedTransformFollower(
            link: link,
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
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      remove();
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder:
                            (context) => ProductDetailSheet(product: product),
                      );
                    },

                    child: Card(
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
                    ),
                  );
                },
              ),
            ),
          ),
        ),
  );
}
