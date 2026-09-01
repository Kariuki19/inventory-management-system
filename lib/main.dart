import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/demo_mode_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'core/services/offline_service.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/inventory/services/inventory_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.init();
  await OfflineService.initialize();
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => DemoModeProvider()),
      ],
      child: Consumer2<ThemeProvider, DemoModeProvider>(
        builder: (context, themeProvider, demoModeProvider, child) {
          // Initialize InventoryService with DemoModeProvider
          InventoryService.setDemoModeProvider(demoModeProvider);

          return MaterialApp(
            title: 'StockSense',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
