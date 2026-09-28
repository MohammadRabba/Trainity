import 'package:Trainity/component/Settings.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Trainity/authentication/beforBegin.dart';
import 'package:Trainity/language/lang_controller.dart';

import 'language/lang.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  initializeNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (context) => DarkModeProvider(),
      child: const Test(),
    ),
  );
}

Future<void> requirePermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings =
      await messaging.requestPermission(alert: true, sound: true, badge: true);
}

Future<void> initializeNotifications() async {
  await requirePermission();

  String defaultIcon = 'resource://drawable/logo2';

  await AwesomeNotifications().initialize(
    defaultIcon,
    [
      NotificationChannel(
        channelKey: 'Basic_channel',
        channelName: 'Basic Notifications',
        enableVibration: true,
        channelDescription: 'Basic description',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      )
    ],
  );
}

class Test extends StatefulWidget {
  const Test({super.key});
  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  void initState() {
    inialization();
    super.initState();
  }

  Future<void> inialization() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    checkdark = prefs.getBool('darkMode') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    print(checkdark);
    inialization();
    Get.put(langauge_manager());
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: checkdark ? ThemeMode.dark : ThemeMode.light,
      locale: Get.deviceLocale,
      translations: lang(),
      home: const WelcomePage(),
    );
  }
}
