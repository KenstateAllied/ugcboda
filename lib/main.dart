import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:ride_share/controllers/network_controller.dart';
import 'package:ride_share/routes.dart';
import 'package:ride_share/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(
    widgetsBinding: WidgetsFlutterBinding.ensureInitialized(),
  );

  await dotenv.load(fileName: ".env");

  Get.put(NetworkController());

  FlutterNativeSplash.remove();

  runApp(const GoRideApp());
}

class GoRideApp extends StatelessWidget {
  const GoRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: GoRideAppTheme.lightTheme,
      darkTheme: GoRideAppTheme.darkTheme,
      getPages: routes,
      initialRoute: '/login',
    );
  }
}