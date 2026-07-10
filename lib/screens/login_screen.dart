import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../utils/app_strings.dart';
import '../widgets/animated_bubbles_background.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/language_switcher.dart';
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
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.surface,
                    colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
          const AnimatedBubblesBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: LanguageSwitcher(),
                    ),
                    const SizedBox(height: 20),
                    AuthBrandHeader(semanticLabel: context.tr('cekaLogo'))
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: -0.08, end: 0, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1)),
                    const SizedBox(height: 28),
                    Text(
                      context.tr('welcomeBack'),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 450.ms).slideX(
                      begin: -0.06,
                      end: 0,
                      curve: Curves.easeOutCubic,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('loginSubtitle'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: colorScheme.secondary),
                    ).animate().fadeIn(delay: 220.ms, duration: 450.ms).slideX(
                      begin: -0.06,
                      end: 0,
                      curve: Curves.easeOutCubic,
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
                    ).animate().fadeIn(delay: 300.ms, duration: 450.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      curve: Curves.easeOutCubic,
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) =>
                          value!.isEmpty ? context.tr('enterPassword') : null,
                    ).animate().fadeIn(delay: 370.ms, duration: 450.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      curve: Curves.easeOutCubic,
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
                    ).animate().fadeIn(delay: 430.ms, duration: 400.ms),
                    const SizedBox(height: 32),
                    SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: auth.isLoading
                              ? Shimmer.fromColors(
                                  baseColor: colorScheme.primary,
                                  highlightColor: colorScheme.primary
                                      .withOpacity(0.5),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: _login,
                                  child: Text(context.tr('login')),
                                ),
                        )
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 450.ms)
                        .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
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
                    ).animate().fadeIn(delay: 570.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
