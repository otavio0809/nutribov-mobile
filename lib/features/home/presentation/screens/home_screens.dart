import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriBov - Bovinocultura de Corte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho de boas-vindas
            const Text(
              'Gerenciamento Nutricional',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecione um módulo para começar:',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Grade de Módulos (Cards de Navegação)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMenuCard(
                    context,
                    title: 'Central de Alimentos',
                    subtitle: 'Forragens e Insumos',
                    icon: Icons.grass,
                    color: AppColors.primary,
                    onTap: () {
                      // TODO: Navegar para FoodListScreen
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Dados do Animal',
                    subtitle: 'Exigências (BR-Corte)',
                    icon: Icons.pets,
                    color: AppColors.secondary,
                    onTap: () {
                      // TODO: Navegar para AnimalFormScreen
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Formular Ração',
                    subtitle: 'Dietas e Custos',
                    icon: Icons.calculate,
                    color: Colors.teal.shade700,
                    onTap: () {
                      // TODO: Navegar para RationCalculatorScreen
                    },
                  ),
                  _buildMenuCard(
                    context,
                    title: 'Histórico',
                    subtitle: 'Dietas Salvas',
                    icon: Icons.history,
                    color: Colors.blueGrey.shade700,
                    onTap: () {
                      // TODO: Navegar para Historico
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
  , {
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
  }) {
  return Card(
  elevation: 3,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  child: InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(16),
  child: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  CircleAvatar(
  backgroundColor: color.withOpacity(0.15),
  radius: 24,
  child: Icon(icon, color: color, size: 28),
  ),
  const Spacer(),
  Text(
  title,
  style: const TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  color: AppColors.textPrimary,
  ),
  ),
  const SizedBox(height: 2),
  Text(
  subtitle,
  style: const TextStyle(
  fontSize: 12,
  color: AppColors.textSecondary,
  ),
  ),
  ],
  ),
  ),
  ),
  );
  }
}