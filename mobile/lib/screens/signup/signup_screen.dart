import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/back_header.dart';

/// Account creation step of the signup flow.
///
/// Per Plan-implementation-FitnessPro.md, payment is delegated entirely to
/// RevenueCat's native paywall SDK (Phase 3) — this screen intentionally
/// does not include a manual card-entry step, even though the HTML design
/// reference shows one. Only account creation (name/email/password) is
/// built here; RevenueCat's purchase flow will follow this screen once the
/// SDK is integrated.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.isNotEmpty && _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  Future<void> _submit() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacementNamed('/quiz');
    } else {
      final colors = FPColorScheme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Une erreur est survenue.'),
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
            title: 'Créer un compte',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Rejoignez des milliers d'athlètes qui transforment leur corps.",
                    style: TextStyle(color: colors.muted2, fontSize: 13),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(color: colors.text),
                    decoration: _inputDecoration(colors, 'Prénom et nom'),
                  ),
                  const SizedBox(height: 12),
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
                              'Continuer →',
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
