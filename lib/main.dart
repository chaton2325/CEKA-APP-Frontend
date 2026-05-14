import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/language_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PostProvider>(
          create: (context) => PostProvider(Provider.of<AuthProvider>(context, listen: false).apiService),
          update: (context, auth, previous) => PostProvider(auth.apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) => NotificationProvider(Provider.of<AuthProvider>(context, listen: false).apiService),
          update: (context, auth, previous) => NotificationProvider(auth.apiService),
        ),
      ],
      child: Consumer2<AuthProvider, LanguageProvider>(
        builder: (context, auth, language, _) {
          return MaterialApp(
            title: 'CEKA APP',
            key: ValueKey(language.languageCode),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1B8F4D),
                primary: const Color(0xFF1B8F4D),
                onPrimary: Colors.white,
                secondary: const Color(0xFF2E7D32),
                onSecondary: Colors.white,
                tertiary: const Color(0xFF1565C0),
                surface: const Color(0xFFF8FBF9),
                onSurface: const Color(0xFF102118),
                surfaceContainerHighest: const Color(0xFFE8F1EB),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8FBF9),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF8FBF9),
                foregroundColor: Color(0xFF102118),
                elevation: 0,
                centerTitle: false,
                titleTextStyle: TextStyle(
                  color: Color(0xFF102118),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF1B8F4D), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8F4D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: const Color(0xFF1B8F4D).withOpacity(0.1),
                labelTextStyle: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1B8F4D));
                  }
                  return TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600);
                }),
                iconTheme: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const IconThemeData(color: Color(0xFF1B8F4D), size: 26);
                  }
                  return IconThemeData(color: Colors.grey.shade600, size: 24);
                }),
              ),
            ),
            home: auth.isAuthenticated ? const HomeScreen() : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
