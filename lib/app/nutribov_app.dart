import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/design_system/theme.dart';
import '../data/food_repository.dart';
import '../domain/nutrition.dart';
import '../domain/recipe.dart';
import '../features/alimentos/catalog_view.dart';
import '../features/alimentos/catalog_view_model.dart';
import '../features/balanceamento/balance_view.dart';
import '../features/balanceamento/balance_view_model.dart';
import '../features/formulacao/recipe_view.dart';
import '../features/formulacao/recipe_view_model.dart';
import '../features/inicio/home_view.dart';

class NutriBovApp extends StatelessWidget {
  const NutriBovApp({super.key, required this.repository});
  final FoodRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NutriBov',
    debugShowCheckedModeBanner: false,
    theme: farmTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: _AppShell(repository: repository),
  );
}

class _AppShell extends StatefulWidget {
  const _AppShell({required this.repository});
  final FoodRepository repository;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  late final CatalogViewModel _catalog;
  late final BalanceViewModel _balance;
  late final RecipeViewModel _recipe;
  var _index = 0;

  @override
  void initState() {
    super.initState();
    _catalog = CatalogViewModel(widget.repository)..load();
    _balance = BalanceViewModel(const NutritionCalculator());
    _recipe = RecipeViewModel(const RecipeCalculator());
  }

  @override
  void dispose() {
    _catalog.dispose();
    _balance.dispose();
    _recipe.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        spacing: 8,
        children: [
          const Icon(Icons.eco_outlined),
          Text('NutriBov', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    ),
    body: IndexedStack(
      index: _index,
      sizing: StackFit.expand,
      children: [
        for (final (index, page) in <Widget>[
          HomeView(onNavigate: _goTo),
          BalanceView(model: _balance, onRecipe: () => _goTo(3)),
          CatalogView(model: _catalog),
          RecipeView(
            model: _recipe,
            catalog: _catalog,
            balance: _balance,
            onBalance: () => _goTo(1),
            onCatalog: () => _goTo(2),
          ),
        ].indexed)
          ExcludeFocus(excluding: _index != index, child: page),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _goTo,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_weight_outlined),
          label: 'Animal',
        ),
        NavigationDestination(
          icon: Icon(Icons.grass_outlined),
          label: 'Alimentos',
        ),
        NavigationDestination(
          icon: Icon(Icons.restaurant_outlined),
          label: 'Ração',
        ),
      ],
    ),
  );
}
