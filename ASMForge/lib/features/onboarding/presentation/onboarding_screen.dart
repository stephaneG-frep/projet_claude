import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../progress/application/progress_controller.dart';

class _Slide {
  final IconData icon;
  final String title;
  final String description;
  const _Slide(this.icon, this.title, this.description);
}

const _slides = [
  _Slide(
    Icons.developer_board,
    'Comprendre le processeur',
    'Découvrez comment un CPU exécute réellement des instructions, '
        'étape par étape, sans jargon inutile.',
  ),
  _Slide(
    Icons.edit_note,
    'Écrire des instructions',
    'Apprenez à écrire vos propres lignes d\'assembleur dans un '
        'laboratoire pensé pour les débutants.',
  ),
  _Slide(
    Icons.dashboard_customize,
    'Voir les registres évoluer',
    'Observez en direct comment RAX, RBX et les autres registres '
        'changent à chaque instruction.',
  ),
  _Slide(
    Icons.grid_view,
    'Manipuler la mémoire',
    'Visualisez la mémoire et la pile comme de vrais emplacements de '
        'données, pas des abstractions.',
  ),
  _Slide(
    Icons.flag,
    'Résoudre des missions',
    'Restaurez CORE-01 à travers des missions concrètes qui mettent en '
        'pratique chaque notion apprise.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _choosingLevel = false;
  String _selectedLevel = 'beginner';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(progressControllerProvider.notifier).completeOnboarding(_selectedLevel);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _choosingLevel ? _buildLevelChoice(context) : _buildSlides(context),
      ),
    );
  }

  Widget _buildSlides(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final slide = _slides[i];
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(slide.icon, size: 96, color: AppColors.cyan),
                    const SizedBox(height: 32),
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      slide.description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _slides.length; i++)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == _page ? AppColors.cyan : Colors.white24,
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              TextButton(
                onPressed: () => setState(() => _choosingLevel = true),
                child: const Text('Passer'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  if (_page == _slides.length - 1) {
                    setState(() => _choosingLevel = true);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(_page == _slides.length - 1 ? 'Continuer' : 'Suivant'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelChoice(BuildContext context) {
    const options = [
      ('beginner', 'Je débute complètement', 'Aucune expérience en programmation ni en assembleur.'),
      ('programmer', 'Je connais la programmation', 'À l\'aise avec un langage, mais pas avec l\'assembleur.'),
      ('familiar', 'Je connais déjà un peu l\'assembleur', 'Notions déjà acquises, envie d\'aller plus loin.'),
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text('Quel est votre niveau ?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Cela n\'adapte que nos recommandations de départ : tous les '
            'cours restent accessibles.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LevelCard(
                selected: _selectedLevel == option.$1,
                title: option.$2,
                description: option.$3,
                onTap: () => setState(() => _selectedLevel = option.$1),
              ),
            ),
          const Spacer(),
          FilledButton(
            onPressed: _finish,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('ENTRER DANS LA FORGE'),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _LevelCard({
    required this.selected,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.cyan : Colors.white12, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.cyan : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(description, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
