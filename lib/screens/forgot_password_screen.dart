import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../utils/app_strings.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final response = await Provider.of<AuthProvider>(context, listen: false).apiService.forgotPassword(_emailController.text);
    setState(() => _isLoading = false);

    if (response.statusCode == 200 && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(email: _emailController.text),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('sendCodeFailed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('forgotPasswordTitle'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(context.tr('forgotPasswordHelp')),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: context.tr('email')),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isLoading
                  ? Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.primary,
                      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    )
                  : ElevatedButton(onPressed: _submit, child: Text(context.tr('sendCode'))),
            ),
          ],
        ),
      ),
    );
  }
}
