import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/application/settings_controller.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class AsmForgeApp extends ConsumerWidget {
  const AsmForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp.router(
      title: 'ASMForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(
        contrast: settings.highContrast ? AppContrast.high : AppContrast.normal,
        textScale: settings.textScale,
      ),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
