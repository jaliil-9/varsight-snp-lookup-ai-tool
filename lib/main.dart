import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:varsight/config/routes.dart';
import 'package:varsight/core/utils/storage.dart';
import 'package:varsight/features/personalization/notifiers/theme_notifier.dart';
import 'package:varsight/core/utils/error.dart';
import 'package:varsight/config/themes.dart';

Future<void> main() async {
  // Ensure that Flutter is initialized before running the app
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Native Splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    // Load environment variables
    await dotenv.load(fileName: ".env");

    // Capture Supabase environment variables with validation
    final String? supabaseUrl = dotenv.env['SUPABASE_URL'];
    final String? supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception(
        'Missing required environment variables: SUPABASE_URL or SUPABASE_ANON_KEY',
      );
    }

    // Initialize local storage
    await JLocalStorage.init();

    // Initialize Supabase
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

    // Remove the native splash screen after initialization
    FlutterNativeSplash.remove();

    runApp(const ProviderScope(child: VarSightApp()));
  } catch (e) {
    // Log the error for debugging
    debugPrint('App initialization failed: $e');

    // Show error to user instead of crashing
    FlutterNativeSplash.remove();
    ErrorUtils.showErrorSnackBar(ErrorUtils.getErrorMessage(e), title: 'App Initialization Failed');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to initialize app'),
                const SizedBox(height: 8),
                Text('Error: $e', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
      navigatorKey: Get.key,
      initialRoute: '/auth',
      routes: AppRoutes.routes,
    );
  }
}
