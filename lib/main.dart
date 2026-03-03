import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';

import 'ui/home_screen.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, 
      defaultDevice: Devices.ios.iPhone11ProMax,
      devices: [
        Devices.ios.iPhone11ProMax,
      ],
      builder: (context) => const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      debugShowCheckedModeBanner: false,
      title: 'AI Schedule Generator',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo, 
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),

      home: const HomeScreen(), 
    );
  }
}