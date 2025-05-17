import 'package:flutter/material.dart';
import 'widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  
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

                  child: TextFildCreator(
                    "جستجو در فلاتر",
                    borderColor: AppColor.DarkTransparent,
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
















