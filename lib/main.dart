import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait by default
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    navigationBarColor: VeilwatchColors.surface,
    navigationBarIconBrightness: Brightness.light,
  ));

  // Init local storage
  await LocalStorageService().init();

  runApp(const ProviderScope(child: VeilwatchApp()));
}

class VeilwatchApp extends StatelessWidget {
  const VeilwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Veilwatch',
      debugShowCheckedModeBanner: false,
      theme: VeilwatchTheme.dark,
      routerConfig: appRouter,
    );
  }
}
