import 'package:flutter/material.dart';
import 'presentation/screens/map_screen.dart';
import 'presentation/theme/app_theme.dart';

class PlaceArchiveApp extends StatelessWidget {
  const PlaceArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '장소 기억 아카이브',
      theme: AppTheme.light,
      home: const MapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
