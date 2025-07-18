import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:varsight/config/routes.dart';
import 'package:varsight/core/utils/storage.dart';
import 'package:varsight/features/personalization/notifiers/theme_notifier.dart';
import 'package:varsight/config/themes.dart';

Future<void> main() async {
  // Ensure that Flutter is initialized before running the app
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Native Splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize local storage
  await JLocalStorage.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Remove the native splash screen after initialization
  FlutterNativeSplash.remove();

  runApp(const ProviderScope(child: VarSightApp()));
}

class VarSightApp extends ConsumerWidget {
  const VarSightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/auth',
      routes: AppRoutes.routes,
    );
  }
}
