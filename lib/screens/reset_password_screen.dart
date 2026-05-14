import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/auth_provider.dart';
import '../utils/app_strings.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_codeController.text.isEmpty || _newPasswordController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final response = await Provider.of<AuthProvider>(context, listen: false).apiService.resetPassword(
      widget.email,
      _codeController.text,
      _newPasswordController.text,
    );
    setState(() => _isLoading = false);

    if (response.statusCode == 200 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('passwordResetSuccess'))));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.tr('passwordResetFailed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('resetPassword'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('${context.tr('resetSentTo')} ${widget.email}'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: context.tr('resetCode')),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(labelText: context.tr('newPassword')),
              obscureText: true,
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
                  : ElevatedButton(onPressed: _submit, child: Text(context.tr('resetPassword'))),
            ),
          ],
        ),
      ),
    );
  }
}
