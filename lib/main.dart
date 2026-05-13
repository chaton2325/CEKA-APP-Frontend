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
                secondary: const Color(0xFF37624A),
                surface: const Color(0xFFF2F7F3),
                surfaceVariant: const Color(0xFFE3EFE7),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.black,
              ),
              scaffoldBackgroundColor: const Color(0xFFF2F7F3),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF2F7F3),
                foregroundColor: Color(0xFF102118),
                elevation: 0,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFF102118),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF795548)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8F4D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
