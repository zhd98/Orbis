import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive is only used to persist a couple of primitive settings values,
  // so no generated type adapters are required.
  await Hive.initFlutter();
  await SettingsService.init();

  runApp(const ProviderScope(child: IgnisApp()));
}
