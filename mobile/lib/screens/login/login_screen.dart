import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/back_header.dart';

/// Login screen for returning users (e.g. after a reinstall) — the
/// counterpart to SignupScreen. On success this goes straight to
/// '/dashboard', skipping the paywall/quiz/onboarding flow that only
/// applies to brand-new accounts.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

    final success = await authProvider.login(_emailController.text, _passwordController.text);

    if (!mounted) return;

    if (success) {
      final userId = authProvider.user?.id;
      if (userId != null) {
        await subscriptionProvider.login(userId.toString());
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      final colors = FPColorScheme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Identifiants incorrects.'),
          backgroundColor: colors.red.withValues(alpha: 0.13),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Column(
        children: [
          BackHeader(
            title: 'Se connecter',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Content de te revoir !',
                    style: TextStyle(color: colors.muted2, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _emailController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: colors.text),
                    decoration: _inputDecoration(colors, 'Adresse e-mail'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    onChanged: (_) => setState(() {}),
                    obscureText: true,
                    style: TextStyle(color: colors.text),
                    decoration: _inputDecoration(colors, 'Mot de passe'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_canSubmit && !authProvider.isLoading) ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: authProvider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: colors.bg),
                            )
                          : Text(
                              'Se connecter →',
                              style: TextStyle(color: colors.bg, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(FPColorScheme colors, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.muted2),
      filled: true,
      fillColor: colors.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.accent),
      ),
    );
  }
}
