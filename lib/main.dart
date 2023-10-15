import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:click_here/util/routes.dart';
import 'screens/404.page.dart';
import 'util/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'util/shared_pref.dart';
final Preferences preferences = Preferences();

void main() async {
  var devices = ["549107B3A7C8DF71194212B66749AA36"];
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  bool data = await preferences.checkIfDataExists();
  await MobileAds.instance.initialize();

  RequestConfiguration requestConfiguration = RequestConfiguration(testDeviceIds: devices);
  MobileAds.instance.updateRequestConfiguration(requestConfiguration);
  runApp( MyApp(dataExist: data,));
}

class MyApp extends StatelessWidget {
  final bool dataExist;
  const MyApp({super.key, required this.dataExist});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: dataExist? '/home' : '/',
        routes: routes_,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const Page404()
            );
        },
        
      );
  }
}