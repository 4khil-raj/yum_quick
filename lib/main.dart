import 'package:flutter/material.dart';

import 'src/app/app.dart';
import 'src/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  runApp(const YumQuickApp());
}
