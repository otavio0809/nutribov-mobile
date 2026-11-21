import 'package:flutter/material.dart';

import '../../core/design_system/theme.dart';
import '../../core/design_system/widgets.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    return FarmPage(
      children: [
        Container(
          padding: const EdgeInsets.all(FarmSpace.large),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [FarmColors.forest, FarmColors.leaf],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: FarmSpace.medium,
            children: [
              const Icon(
                Icons.agriculture_outlined,
                color: FarmColors.straw,
                size: 42,
              ),
              Text(
                'Nutrição de\nbovinos de corte',
                style: typography.headlineMedium?.copyWith(color: Colors.white),
              ),
              Text(
                'Calcule as exigências do animal e formule rações com os ingredientes da sua propriedade.',
                style: typography.bodyLarge?.copyWith(
                  color: const Color(0xFFEEF4E9),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: FarmColors.straw,
                  foregroundColor: FarmColors.forest,
                ),
                onPressed: () => onNavigate(1),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Calcular exigências'),
              ),
            ],
          ),
        ),
        _HomeCard(
          icon: Icons.grass_outlined,
          title: 'Central de alimentos',
          description:
              'Cadastre e consulte forragens, insumos, rações e aditivos.',
          onTap: () => onNavigate(2),
        ),
        _HomeCard(
          icon: Icons.restaurant_outlined,
          title: 'Formular ração',
          description:
              'Calcule a composição por lote, o custo e o fornecimento diário.',
          onTap: () => onNavigate(3),
        ),
      ],
    );
  }
}

class _HomeCard extends StatelessWidget {
  const _HomeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });
  final IconData icon;
  final String title, description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: ListTile(
      contentPadding: const EdgeInsets.all(FarmSpace.medium),
      leading: CircleAvatar(
        backgroundColor: FarmColors.mist,
        foregroundColor: FarmColors.forest,
        child: Icon(icon),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(description),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
  );
}
