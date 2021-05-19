import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hro/model/AppDataModel.dart';
import 'package:hro/utility/style.dart';
import 'package:provider/provider.dart';

class ShopPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ShopState();
  }
}

class ShopState extends State<ShopPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppDataModel>(
        builder: (context, appDataModel, child) => Scaffold(
              appBar: AppBar(
                iconTheme: IconThemeData(color: Style().shopPrimaryColor),
                backgroundColor: Colors.white,
                bottomOpacity: 0.0,
                elevation: 0.0,
                // leading: IconButton(
                //     icon: Icon(
                //       Icons.menu,
                //       color: Style().darkColor,
                //     ),
                //     onPressed: () {}),
                title: Style()
                    .textSizeColor('ร้านค้า', 18, Style().shopPrimaryColor),
                actions: [
                  IconButton(
                      icon: Icon(
                        FontAwesomeIcons.commentAlt,
                        color: Style().shopPrimaryColor,
                      ),
                      onPressed: () {}),
                  IconButton(
                      icon: Icon(
                       FontAwesomeIcons.cogs,
                        color: Style().shopPrimaryColor,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/shopSetup-page");
                      }),
                ],
              ),
              body: Container(
                color: Colors.grey.shade200,
                child: Center(
                  child: ListView(
                    children: [
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            child: buildShopMenu(),
                          ),
                          //buildPopularProduct(),
                          //buildPopularShop((context.read<AppDataModel>()))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Row buildShopMenu() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: 110,
          decoration: new BoxDecoration(
              color: Style().shopPrimaryColor,
              borderRadius: new BorderRadius.circular(5)),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  FontAwesomeIcons.clock,
                  color: Colors.white,
                  size: 25,
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Style().textWhiteSize('ออเดอร์', 14),
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: (){
            Navigator.pushNamed(context, "/menu-page");
          },
          child: Container(
            width: 110,
            decoration: new BoxDecoration(
                color: Style().shopPrimaryColor,
                borderRadius: new BorderRadius.circular(5)),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Icon(
                    FontAwesomeIcons.clipboardList,
                    color: Colors.white,
                    size: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Style().textWhiteSize('สินค้า', 14),
                  )
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }
}
