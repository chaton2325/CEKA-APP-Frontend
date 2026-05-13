import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_strings.dart';
import '../widgets/auth_brand_header.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(_emailController.text, _passwordController.text);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('invalidCredentials')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: PopupMenuButton<AppLanguage>(
                    tooltip: context.tr('language'),
                    icon: const Icon(Icons.language_rounded),
                    onSelected: (language) =>
                        context.read<LanguageProvider>().setLanguage(language),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: AppLanguage.fr,
                        child: Text(context.tr('french')),
                      ),
                      PopupMenuItem(
                        value: AppLanguage.en,
                        child: Text(context.tr('english')),
                      ),
                    ],
                  ),
                ),
                AuthBrandHeader(semanticLabel: context.tr('cekaLogo')),
                const SizedBox(height: 28),
                Text(
                  context.tr('welcomeBack'),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('loginSubtitle'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: colorScheme.secondary),
                ),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: context.tr('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? context.tr('enterEmail') : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: context.tr('password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) =>
                      value!.isEmpty ? context.tr('enterPassword') : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    ),
                    child: Text(
                      context.tr('forgotPassword'),
                      style: TextStyle(color: colorScheme.secondary),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                auth.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: Text(context.tr('login')),
                      ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('noAccount'),
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: Text(
                        context.tr('register'),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
