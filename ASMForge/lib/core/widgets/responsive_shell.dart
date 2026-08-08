import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class ShellDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// Coquille de navigation responsive (section 6) :
/// - < 600 logique : NavigationBar en bas (mobile) ;
/// - >= 600 logique : NavigationRail sur le côté (tablette / desktop / web
///   large).
class ResponsiveShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<ShellDestination> destinations;

  const ResponsiveShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        // La navigation reste stable même si l'utilisateur a poussé la
        // taille de texte d'accessibilité au maximum (section 33/42) :
        // seuls le contenu et les libellés visibles s'agrandissent, pas
        // la structure de la barre/du rail, pour éviter tout débordement.
        if (isWide) {
          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sur un écran large mais bas (ex : téléphone en paysage,
                // qui franchit le seuil de 600 de largeur logique), un
                // NavigationRail avec des libellés complets sur 5
                // destinations peut dépasser la hauteur disponible : il
                // n'a pas de défilement intégré. On force donc un
                // libellé compact (seule la destination sélectionnée
                // affiche son texte) et on l'enveloppe dans un
                // défilement vertical qui prend le relais si, malgré
                // tout, l'espace venait à manquer (grand texte
                // d'accessibilité, très petit écran…).
                LayoutBuilder(
                  builder: (context, railConstraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: railConstraints.maxHeight),
                        child: IntrinsicHeight(
                          child: MediaQuery.withClampedTextScaling(
                            maxScaleFactor: 1.15,
                            child: NavigationRail(
                              backgroundColor: AppColors.surface,
                              selectedIndex: currentIndex,
                              onDestinationSelected: onDestinationSelected,
                              labelType: NavigationRailLabelType.selected,
                              leading: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Icon(Icons.memory, color: AppColors.cyan, size: 32),
                              ),
                              destinations: [
                                for (final d in destinations)
                                  NavigationRailDestination(
                                    icon: Icon(d.icon),
                                    selectedIcon: Icon(d.selectedIcon),
                                    label: Text(d.label, overflow: TextOverflow.ellipsis),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
          );
        }
        return Scaffold(
          body: child,
          bottomNavigationBar: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.1,
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                    tooltip: d.label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
