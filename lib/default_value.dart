import 'dart:ui';
import 'package:flutter/material.dart';

//Defaults

// String host = "http://192.168.183.54/fluttershop/index.php";
// String host = "http://127.0.0.1/fluttershop/index.php";
// String host = "https://mk14.kesug.com/fluttershop/index.php";


String host = "https://testforflutterwebserver.onrender.com";

Uri Url = Uri.parse(host);

List Products = List.empty(growable: true);

Map currentUser = {};
// {  "UsersID": "1",  "username": "mk1404",  "password": "mk1234",  "name": " محمد کریمی",};

List cart = List.empty(growable: true);
// [{OrdersID: 105, ProductID: 2, count: 4}, {OrdersID: 103, ProductID: 18, count: 2}, {OrdersID: 110, ProductID: 17, count: 1}]

num cost = 0;
num purCost = 0;

List Purchases = List.empty(growable: true);
//[{cost: 305590000, date: 2025-05-15 00:18:23.510, code: 546356556, orders: [{ProductID: 2, count: 1, price: 15790000}, {ProductID:3, count: 3, price: 12600000}, {ProductID: 1, count: 3, price: 84000000}]}]



List Categorys = List.empty(growable: true);
//  = [
//   {
//     "picPatch": "assets/pictures/mobile.png",
//     "picPatchType" : "asset",
//     "text": "گــــوشــــی\nمــوبـــایــل",
//     "nextPage": ProductsVewPage(type: "mobile"),
//   },
//   {
//     "picPatch": "assets/pictures/laptop.png",
//     "picPatchType" : "asset",
//     "text": "لــــــــــپ\nتـــــــــاپ",
//     "nextPage": ProductsVewPage(type: "laptop"),
//   },
// ];


List asetsFile = [
  "assets/pictures/back.jpg",
  "assets/pictures/backin.jpg",
  "assets/pictures/mobile.png",
  "assets/pictures/laptop.png",
  "assets/pictures/logo.png",
  "assets/pictures/logo1.png",
  "assets/pictures/welcome.png",
  "assets/pictures/products/xiaomi-15.png",
  "assets/pictures/products/xiaomi-redmi-note-14s.png",
  "assets/pictures/products/xiaomi-redmi-14r.png",
  "assets/pictures/products/xiaomi-14t-pro.png",
  "assets/pictures/products/samsung-galaxy-z-flip5-5g.png",
  "assets/pictures/products/asus-tuf-gaming-f15-fx507ze.png",
  "assets/pictures/products/microsoft-surface-pro-9.png",
  "assets/pictures/products/asus-rog-strix-g16.png",
  // "asset: assets/fonts/Samim.ttf",
  // "asset: assets/fonts/Automali.ttf",
  // "asset: assets/fonts/Dhaniel.ttf",
  // "asset: assets/fonts/Beirut.ttf",
  // "asset: assets/fonts/Vazir.ttf",
  // "asset: assets/fonts/Roboto.ttf",
];


class AppColor {
  static const Color BackColor = Color.fromARGB(255, 255, 207, 162);
  static const Color ForeColor = Color.fromARGB(255, 247, 119, 0);
  static const Color DarkTransparent = Color.fromARGB(230, 77, 37, 0);

  static const Color TextColor = Colors.white;

  static Color BackForeColor0 = ForeColor.withOpacity(0.2);
  static Color BackForeColor1 = ForeColor.withOpacity(0.3);
  static Color BackForeColor2 = ForeColor.withOpacity(0.5);

  static Color BackColor0 = BackColor.withOpacity(0.2);
  static Color BackColor1 = BackColor.withOpacity(0.3);
  static Color BackColor2 = BackColor.withOpacity(0.4);
  static Color BackColor3 = BackColor.withOpacity(0.5);

  static Color DarkTransparent0 = DarkTransparent.withOpacity(0.2);
  static Color DarkTransparent1 = DarkTransparent.withOpacity(0.45);
  static Color DarkTransparent2 = DarkTransparent.withOpacity(0.6);
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


BoxDecoration MainBackGrondpDecoration() {
  return BoxDecoration(
    // color: BackColor,
    image: DecorationImage(
      image: AssetImage("./assets/pictures/backp.jpg"),
      fit: BoxFit.cover,
    ),
  );
}


