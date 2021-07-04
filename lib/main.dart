import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hro/page/addProduct.dart';
import 'package:hro/page/adminPage.dart';
import 'package:hro/page/allProducts.dart';
import 'package:hro/page/driverSetup.dart';
import 'package:hro/page/drivers.dart';
import 'package:hro/page/editProduct.dart';
import 'package:hro/page/frist.dart';
import 'package:hro/page/home.dart';
import 'package:hro/page/login.dart';
import 'package:hro/page/menu.dart';
import 'package:hro/page/order2driver.dart';
import 'package:hro/page/orderDetail.dart';
import 'package:hro/page/orderList.dart';
import 'package:hro/page/orderShow.dart';
import 'package:hro/page/profile.dart';
import 'package:hro/page/register.dart';
import 'package:hro/page/shop.dart';
import 'package:hro/page/shopSetup.dart';
import 'package:hro/page/showProduct.dart';
import 'package:hro/page/splash.dart';
import 'package:hro/page/store.dart';
import 'package:hro/page/testGps.dart';
import 'package:provider/provider.dart';
import 'model/AppDataModel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';


// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//
//   print("Handling a background message: ${message.messageId}");
// }


String initialRoute = '/splash-page';

Future<Null> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
        title: 'เฮาะ อากาศเดลิเวอรี่',
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
          "/driver-page": (context) => DriversPage(),
          "/driverSetup-page": (context) => DriverSetupPage(),
          "/showProduct-page": (context) => ShowProductPage(),
          "/orderDetail-page": (context) => OrderDetailPage(),
          "/store-page": (context) => StorePage(),
          "/testGps-page": (context) => TestGpsPage(),
          "/orderList-page": (context) => OrderListPage(),
          "/orderShow-page": (context) => OrderShowPage(),
          "/order2driver-page": (context) => Order2DriverPage(),
          "/allProduct-page": (context) => AllProductsPage(),
          "/admin-page": (context) => AdminPage(),
          "/addProduct-page": (context) => AddProductPage(),
          "/editProduct-page": (context) => EditProductPage(),




        },
        initialRoute: initialRoute,
      ),
    );
  }
}
