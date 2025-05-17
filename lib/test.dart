import 'package:flutter/material.dart';
import 'widgets.dart';

class HomePagee extends StatefulWidget {
  const HomePagee({super.key});
  @override
  State<HomePagee> createState() => _HomePageeState();
}

class _HomePageeState extends State<HomePagee> {
  // کنترل‌کننده برای فیلد متنی
  final TextEditingController _searchController = TextEditingController();

  // لیست اصلی همه‌ی دسته‌بندی‌ها
  List<Map<String, dynamic>> allCategories = [
    {"text": "موبایل", "picPatch": "assets/phone.png"},
    {"text": "لپ‌تاپ", "picPatch": "assets/laptop.png"},
    {"text": "هدفون", "picPatch": "assets/headphone.png"},
    {"text": "ساعت هوشمند", "picPatch": "assets/watch.png"},
  ];

  // لیستی که نتایج فیلترشده را نگه‌می‌دارد
  List<Map<String, dynamic>> filteredCategories = [];

  // OverlayEntry برای نمایش نتایج پاپ‌آپ
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    filteredCategories = allCategories; // در ابتدا همه موارد نمایش داده شوند
  }

  // این متد هنگام تایپ کردن در فیلد جستجو صدا زده می‌شود
  void _onSearchChanged(String query) {
    // نتایج را فیلتر می‌کنیم
    filteredCategories =
        allCategories
            .where(
              (item) => item["text"].toString().toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();

    // اگر پاپ‌آپ قبلاً باز شده بود، آن را حذف می‌کنیم
    _overlayEntry?.remove();

    // اگر فیلد جستجو خالی نبود، پاپ‌آپ جدید را می‌سازیم
    if (query.isNotEmpty) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }



  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder:
          (context) => Positioned(
            left: 35,
            right: 60,

            top: offset.dy + 65,

            child: Material(
              color: const Color.fromARGB(62, 107, 52, 0),
              elevation: 4.0,

              borderRadius: BorderRadius.circular(12),
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                shrinkWrap: true,
                itemCount: Products.length,
                itemBuilder: (context, index) {
                  Map product = Products[index];
                  return Card(
                    color: const Color.fromARGB(197, 255, 255, 255),
                    margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Image(image: AssetImage(product["picPatch"])),
                      ),
                      title: TextCreator(
                        product["name"],
                        style: FontWeight.bold,
                        color: const Color.fromARGB(141, 0, 10, 145),
                      ),
                      trailing: PriceShow(int.parse(product["price"])),
                    ),
                  );
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setProducts();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 30, 0, 20),

                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    obscureText: false,

                    decoration: InputDecoration(
                      labelText: "labelText",
                      hintText: "hintText",
                      hintStyle: TextStyle(fontSize: 16),
                      filled: true,
                      hoverColor: const Color.fromARGB(255, 255, 202, 152),
                      fillColor: const Color.fromARGB(178, 255, 208, 163),

                      labelStyle: TextStyle(color: AppColor.ForeColor),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 172, 83, 0),
                          width: 1.5,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 194, 94, 0),
                          width: 1.5,
                        ),
                      ),
                    ),

                    onTap: _createOverlayEntry,
                    cursorColor: AppColor.DarkTransparent,
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

      body: Container(
        padding: EdgeInsets.all(35),
        child: GridView.builder(
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
              text: item["text"],
              onpress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item["nextPage"]),
                );
              },
            );
          },
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
