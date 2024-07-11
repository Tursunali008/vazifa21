import 'package:flutter/material.dart';
import 'package:vazifa21/geolocatr_service.dart';
import 'package:vazifa21/yandex_map_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GeolocatorService.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}