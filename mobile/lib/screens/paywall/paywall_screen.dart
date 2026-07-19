import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../core/constants/colors.dart';
import '../../providers/subscription_provider.dart';

/// Presents RevenueCat's native paywall as soon as this screen mounts.
///
/// [onSubscribed] fires when the user successfully purchases or already had
/// an active entitlement restored — call sites decide what "unlocked"
/// navigation looks like. [onSkip] fires on cancel/error/close, letting the
/// caller decide whether the paywall is skippable (e.g. during a free-trial
/// onboarding flow) or must be retried.
class PaywallScreen extends StatefulWidget {
  final VoidCallback onSubscribed;
  final VoidCallback onSkip;

  const PaywallScreen({
    super.key,
    required this.onSubscribed,
    required this.onSkip,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _presenting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _presentPaywall());
  }

  Future<void> _presentPaywall() async {
    if (_presenting) return;
    setState(() {
      _presenting = true;
      _error = null;
    });

    try {
      final result = await RevenueCatUI.presentPaywall(
        displayCloseButton: true,
      );

      if (!mounted) return;

      switch (result) {
        case PaywallResult.purchased:
        case PaywallResult.restored:
          await Provider.of<SubscriptionProvider>(
            context,
            listen: false,
          ).refreshCustomerInfo();
          if (!mounted) return;
          widget.onSubscribed();
        case PaywallResult.cancelled:
        case PaywallResult.notPresented:
          widget.onSkip();
        case PaywallResult.error:
          setState(() {
            _presenting = false;
            _error = "Une erreur est survenue lors de l'affichage de l'offre.";
          });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _presenting = false;
        _error = "Une erreur est survenue lors de l'affichage de l'offre.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: Center(
        child: _error != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.muted2, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _presentPaywall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                      ),
                      child: Text(
                        'Réessayer',
                        style: TextStyle(color: colors.bg),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        'Continuer sans abonnement',
                        style: TextStyle(color: colors.muted),
                      ),
                    ),
                  ],
                ),
              )
            : CircularProgressIndicator(color: colors.accent),
      ),
    );
  }
}
