import 'package:flutter/material.dart';
import 'package:yum_quick/src/core/theme/app_theme.dart';

import 'router.dart';

class YumQuickApp extends StatelessWidget {
  const YumQuickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'YumQuick Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
