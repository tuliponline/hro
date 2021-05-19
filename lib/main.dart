import 'package:flutter/material.dart';
import 'package:hro/page/frist.dart';
import 'package:hro/page/home.dart';
import 'package:hro/page/login.dart';
import 'package:hro/page/menu.dart';
import 'package:hro/page/profile.dart';
import 'package:hro/page/register.dart';
import 'package:hro/page/shop.dart';
import 'package:hro/page/shopSetup.dart';
import 'package:hro/page/splash.dart';
import 'package:provider/provider.dart';
import 'model/AppDataModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


String initialRoute = '/splash-page';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) async {

      runApp(MyApp());

  });
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   // setProfile(context.read<AppDataModel>());
    return Provider(
      create: (_) => AppDataModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'เฮาะ',
        routes: {
          '/register-page': (context) => RegisterPage(),
          '/login-page': (context) => LoginPage(),
          '/first-page': (context) => FirstPage(),
          '/home-page': (context) => HomePage(),
          '/splash-page': (context) => SplashPage(),
          '/profile-page': (context) => ProfilePage(),
          '/shop-page': (context) => ShopPage(),
          "/shopSetup-page": (context) => ShopSetupPage(),
          "/menu-page": (context) => MenuPage(),

        },
        initialRoute: initialRoute,
      ),
    );
  }
}
