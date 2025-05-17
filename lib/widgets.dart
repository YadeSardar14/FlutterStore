import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_store/about_store.dart';
import 'package:mobile_store/main_page.dart';
import 'package:mobile_store/products_page.dart';
import 'package:mobile_store/shoppingCart_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Defaults

String host = "http://127.0.0.1/fluttershop/index.php";
Uri Url = Uri.parse(host);

List Products = List.empty();

Map currentUser =
    {}; // {  "UsersID": "1",  "username": "mk1404",  "password": "mk1234",  "name": " محمد کریمی",};

List cart = List.empty();
num cost = 0;
num purCost = 0;
List Purchases =
    []; //[{cost: 305590000, date: 2025-05-15 00:18:23.510, code: 546356556, orders: [{ProductID: 2, count: 1, price: 15790000}, {ProductID:3, count: 3, price: 12600000}, {ProductID: 1, count: 3, price: 84000000}]}]

class AppColor {
  static const Color BackColor = Color.fromARGB(255, 255, 207, 162);
  static const Color ForeColor = Color.fromARGB(255, 247, 119, 0);
  static const Color DarkTransparent = Color.fromARGB(55, 83, 40, 0);

  static const Color TextColor = Colors.white;

  static Color BackForeColor0 = ForeColor.withValues(alpha: 170);
  static Color BackForeColor1 = ForeColor.withValues(alpha: 130);
  static Color BackForeColor2 = ForeColor.withValues(alpha: 90);

  static Color BackColor0 = BackColor.withValues(alpha: 160);
  static Color BackColor1 = BackColor.withValues(alpha: 110);
  static Color BackColor2 = BackColor.withValues(alpha: 60);
  static Color BackColor3 = BackColor.withValues(alpha: 30);

  static Color DarkTransparent1 = DarkTransparent.withValues(alpha: 140);
}

BoxDecoration MainBackGrondDecoration() {
  return BoxDecoration(
    // color: BackColor,
    image: DecorationImage(
      image: AssetImage("./assets/pictures/back.jpg"),
      fit: BoxFit.cover,
    ),
  );
}

BoxDecoration MainBackGrondInDecoration() {
  return BoxDecoration(
    // color: BackColor,
    image: DecorationImage(
      image: AssetImage("./assets/pictures/backin.jpg"),
      fit: BoxFit.cover,
    ),
  );
}

List<Map<String, dynamic>> Categorys = [
  {
    "picPatch": "assets/pictures/mobile.png",
    "text": "گــــوشــــی مــوبـــایــل",
    "nextPage": ProductsVewPage(type: "mobile"),
  },
  {
    "picPatch": "assets/pictures/laptop.png",
    "text": "لــــــــــپ تـــــــــاپ",
    "nextPage": ProductsVewPage(type: "laptop"),
  },
];

Future setProducts() async {
  var response = await http.post(Url, body: {"state": "getproducts"});
  if (response.statusCode == 200) {
    Products = json.decode(response.body) as List;
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
        cost +=
            int.parse(
              Products.firstWhere(
                (p) =>
                    p["ProductsID"].toString() == ord["ProductID"].toString(),
              )["price"],
            ) *
            int.parse(ord["count"].toString());
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
  fontsize = 22,
  fontsizedown = 12,
  style = FontWeight.bold,
  previoustext = "",
}) {
  return Row(
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
  );
}

Widget IconPrInfo(
  icon,
  text, {
  color = Colors.white,
  fontsize = 10,
  fontstyle,
  iconsize = 18,
  margin = 5,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color, size: iconsize),
      SizedBox(height: margin),
      TextCreator(text, color: color, fontsize: fontsize, style: fontstyle),
    ],
  );
}

Widget TextCreator(
  String text, {
  double fontsize = 16,
  Color color = AppColor.ForeColor,
  Color background = const Color.fromARGB(0, 0, 0, 0),
  FontWeight? style = FontWeight.normal,
  String fontFamily = "Samin",
}) {
  return Text(
    text,
    style: TextStyle(
      fontSize: fontsize,
      color: color,
      fontFamily: fontFamily,
      inherit: false,
      fontWeight: style,
      backgroundColor: background,
    ),
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
      color:inputTextColor,
      fontSize: inputTextFontsize,
      fontWeight: inputTextStyle,
      fontFamily: inputTextFontFamily,
    ),
  );
}

Widget ButtonCreator(
  text,
  onPressed, {
  fontsize = 18,
  fontstyle = FontWeight.bold,
  fontcolor = AppColor.TextColor,
  height,
  width = double.infinity,
  padding = const EdgeInsets.all(15),
  Color? color,
  radius = 14,
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
      child: TextCreator(
        text,
        fontsize: fontsize,
        style: fontstyle,
        color: fontcolor,
      ),
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
                  color: textColor,
                  fontsize: 40,
                  fontFamily: "Vazir",
                  style: FontWeight.bold,
                ),
              ),
            ),

            Expanded(child: Image(image: AssetImage(picPatch))),
          ],
        ),
      ),
    ),
  );
}

Widget ProductDisplay(
  BuildContext context,
  int id,
  String name,
  int price,
  String picPach,
  String type,
  List<Widget> specifications, {
  onpress,
  buttonText = "+",
  Color? backgroundColor,
  frontColor = AppColor.TextColor,
}) {
  backgroundColor = AppColor.DarkTransparent1;
  String? newTextButton = buttonText;

  Map order = cart.firstWhere(
    (ord) => id.toString() == ord["ProductID"].toString(),
    orElse: () => {},
  );

  if (order.isNotEmpty) {
    newTextButton = buttonText + "  " + order["count"].toString();
  }

  return Container(
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 35,vertical: 50),
            child: Image(image: AssetImage(picPach), fit: BoxFit.cover),
          ),
        ),

        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(5, 0, 5, 10),

            child: TextCreator(
              name,
              color: frontColor,
              fontsize:  name.length>19 ? 19 * (19/name.length) : 20,
              style: FontWeight.bold,
            ),
          ),
        ),

        Expanded(
          child: Container(
            margin: EdgeInsets.fromLTRB(15, 5, 15, 10),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: specifications,
            ),
          ),
        ),

        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonCreator(
                  newTextButton,
                  onpress,
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                ),
                PriceShow(
                  price,
                  fontsize: type == "laptop" ? 18 : 19,
                  color: frontColor,
                  style: FontWeight.normal,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10,),
      ],
    ),
  );
}

Widget DrawerMenu(BuildContext context, {int maunPageIdex = 2}) {
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
            Navigator.push(
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
              MaterialPageRoute(builder: (context) => Main(currentindex: 2)),
            );
          }
        }),

        SizedBox(height: 10),

        MenuCard('سبدخرید', Icons.shopping_bag_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        }),

        SizedBox(height: 10),

        MenuCard('خرید های من', Icons.shopping_bag, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Main(carttabindex: 1, currentindex: 1),
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
          cost = 0;
          purCost = 0;

          Navigator.push(
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
