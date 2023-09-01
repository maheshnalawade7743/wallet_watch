import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:wallet_watch/screens/home_page.dart';

import 'hive_database/hive_database.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await HiveDb().createBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage()
    );
  }
}
