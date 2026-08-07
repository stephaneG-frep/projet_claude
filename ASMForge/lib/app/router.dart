import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/responsive_shell.dart';
import '../features/glossary/presentation/glossary_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/lessons/presentation/learn_screen.dart';
import '../features/lessons/presentation/lesson_screen.dart';
import '../features/missions/presentation/mission_detail_screen.dart';
import '../features/missions/presentation/missions_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/projects/presentation/project_detail_screen.dart';
import '../features/reference/presentation/reference_detail_screen.dart';
import '../features/simulator/presentation/lab_screen.dart';
import '../features/settings/presentation/about_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/progress/presentation/profile_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

const _shellDestinations = [
  ShellDestination(label: 'Accueil', icon: Icons.home_outlined, selectedIcon: Icons.home),
  ShellDestination(label: 'Apprendre', icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book),
  ShellDestination(label: 'Laboratoire', icon: Icons.science_outlined, selectedIcon: Icons.science),
  ShellDestination(label: 'Missions', icon: Icons.flag_outlined, selectedIcon: Icons.flag),
  ShellDestination(label: 'Profil', icon: Icons.person_outline, selectedIcon: Icons.person),
];

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ResponsiveShell(
          currentIndex: navigationShell.currentIndex,
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          destinations: _shellDestinations,
          child: navigationShell,
        );
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/learn',
            builder: (context, state) => const LearnScreen(),
            routes: [
              GoRoute(
                path: 'lesson/:moduleId/:lessonId',
                builder: (context, state) => LessonScreen(
                  moduleId: state.pathParameters['moduleId']!,
                  lessonId: state.pathParameters['lessonId']!,
                ),
              ),
              GoRoute(
                path: 'reference/:name',
                builder: (context, state) => ReferenceDetailScreen(
                  name: state.pathParameters['name']!,
                ),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/lab', builder: (context, state) => const LabScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/missions',
            builder: (context, state) => const MissionsScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) => MissionDetailScreen(id: state.pathParameters['id']!),
              ),
              GoRoute(
                path: 'project/:id',
                builder: (context, state) => ProjectDetailScreen(id: state.pathParameters['id']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(path: 'settings', builder: (context, state) => const SettingsScreen()),
              GoRoute(path: 'about', builder: (context, state) => const AboutScreen()),
              GoRoute(path: 'glossary', builder: (context, state) => const GlossaryScreen()),
            ],
          ),
        ]),
      ],
    ),
  ],
);
