import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';

/// Premier écran affiché (section 44) : Splash → Onboarding → Dashboard.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _proceed());
  }

  Future<void> _proceed() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final onboardingDone = ref.read(progressControllerProvider).onboardingCompleted;
    context.go(onboardingDone ? '/home' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.memory, size: 72, color: AppColors.cyan),
            const SizedBox(height: 20),
            Text(
              'ASMForge',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.cyan),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comprendre la machine, instruction après instruction.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
