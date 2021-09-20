import 'package:autosplash/models/category_tag.dart';
import 'package:autosplash/models/color_tag.dart';
import 'package:autosplash/screens/search/search_screen.dart';
import 'package:flutter/material.dart';

import 'category_tile.dart';
import 'color_tile.dart';

class CategoriesTab extends StatelessWidget {
  // final DatabaseService _database = new DatabaseService();
  List<CategoryTag> categories = List();
  List<ColorTag> colors = List();
  CategoriesTab(this.colors, this.categories);
  TextEditingController searchController = new TextEditingController();

  // getCategories() async {
  //   categories = await _database.getCategories;
  //   categories.addAll(await _database.getCategories);
  //   categories.addAll(await _database.getCategories);
  //   categories.addAll(await _database.getCategories);
  // }

  // getColors() async {
  //   colors = await _database.getColors;
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   getCategories();
  //   getColors();
  // }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Color(0xfff5f8fd),
              borderRadius: BorderRadius.circular(30),
            ),
            margin: EdgeInsets.symmetric(horizontal: 24),
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      // Close Keyboard
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            search: searchController.text,
                          ),
                        ),
                      );
                    },
                    decoration: InputDecoration(
                        hintText: "Search", border: InputBorder.none),
                  ),
                ),
                InkWell(
                    onTap: () {
                      // Close Keyboard
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            search: searchController.text,
                          ),
                        ),
                      );
                    },
                    child: Container(child: Icon(Icons.search)))
              ],
            ),
          ),
          SizedBox(height: 20),
          // Container(
          //   alignment: Alignment.centerLeft,
          //   padding: EdgeInsets.only(left: 24, right: 24),
          //   height: 30,
          //   child: Text(
          //     'Colors',
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 15,
          //       fontWeight: FontWeight.w500,
          //       fontFamily: 'Overpass',
          //     ),
          //   ),
          // ),
          Container(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                itemCount: colors.length,
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                // physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(
                            search: colors[index].name,
                          ),
                        ),
                      );
                    },
                    child: ColorTile(
                      imgUrl: colors[index].imgUrl,
                      name: colors[index].name,
                    ),
                  );
                }),
          ),

          SizedBox(height: 20),
          // Container(
          //   alignment: Alignment.centerLeft,
          //   padding: EdgeInsets.only(left: 24, right: 24),
          //   height: 30,
          //   child: Text(
          //     'Categories',
          //     style: TextStyle(
          //       color: Colors.black,
          //       fontSize: 15,
          //       fontWeight: FontWeight.w500,
          //       fontFamily: 'Overpass',
          //     ),
          //   ),
          // ),
          Container(
              child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1.75,
                  ),
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(
                              search: categories[index].name,
                            ),
                          ),
                        );
                      },
                      child: CategoryTile(
                        imgUrl: categories[index].imageUrl,
                        name: categories[index].name,
                      ),
                    );
                  })),
        ],
      ),
    );
  }
}
