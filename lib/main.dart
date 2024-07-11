import 'package:flutter/material.dart';
import 'package:vazifa21/location_service.dart';
import 'package:vazifa21/yandex_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationService.checkPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: YandexMapScreen(),
    );
  }
}