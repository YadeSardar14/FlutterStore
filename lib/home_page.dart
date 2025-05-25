import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_store/default_value.dart';
import 'package:mobile_store/products_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<Map> localCategories = [];

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
        _overlayEntry = CreateOverlayEntryForSherch(
          context,
          _layerLink,
          filteredProducts,
          remove: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
        );
        Overlay.of(context).insert(_overlayEntry!);
      }
    }
  }

  Future _setCategories() async {
    if (Categorys.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final savedTime = prefs.getInt("timeOfCatSave");

      if (savedTime == null) {
        await setCategories();
        await updateCategories();
        await prefs.setInt(
          "timeOfCatSave",
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        final now = DateTime.now().millisecondsSinceEpoch;
        final differenceInHours = (now - savedTime) / (1000 * 60 * 60);

        if (differenceInHours > 24) {
          await setCategories();
          await updateCategories();
          await prefs.setInt(
            "timeOfCatSave",
            DateTime.now().millisecondsSinceEpoch,
          );
        } else {
          Categorys = await getCategories();
        }
      }
    }

    setState(() {
      localCategories = List<Map>.from(Categorys);
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _setCategories();
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
                : GridView.builder(
                  padding: EdgeInsets.all(35),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
