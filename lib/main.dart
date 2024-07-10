import 'package:flutter/material.dart';
import 'package:yandex_map/screens/home_screen.dart';
import 'package:yandex_map/services/geolocator_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GeolocatorService.init();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}