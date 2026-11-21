import 'package:flutter/material.dart';

import '../../core/design_system/widgets.dart';
import '../../domain/food.dart';
import '../../domain/nutrition.dart';
import '../../domain/recipe.dart';
import '../alimentos/catalog_view_model.dart';
import '../balanceamento/balance_view_model.dart';
import 'recipe_view_model.dart';

class _IngredientInput {
  _IngredientInput(this.foodId, String amount)
    : quantity = TextEditingController(text: amount);

  String foodId;
  final TextEditingController quantity;
  final price = TextEditingController();

  void dispose() {
    quantity.dispose();
    price.dispose();
  }
}

class RecipeView extends StatefulWidget {
  const RecipeView({
    super.key,
    required this.model,
    required this.catalog,
    required this.balance,
    required this.onBalance,
    required this.onCatalog,
  });
  final RecipeViewModel model;
  final CatalogViewModel catalog;
  final BalanceViewModel balance;
  final VoidCallback onBalance, onCatalog;

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  final _form = GlobalKey<FormState>();
  final _feedback = GlobalKey();
  final _name = TextEditingController();
  final _notes = TextEditingController();
  DateTime? _date;
  final _inputs = <_IngredientInput>[];
  String? _inputError;

  @override
  void initState() {
    super.initState();
    widget.catalog.addListener(_onCatalogChanged);
    widget.balance.addListener(_invalidate);
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    widget.catalog.removeListener(_onCatalogChanged);
    widget.balance.removeListener(_invalidate);
    for (final input in _inputs) {
      input.dispose();
    }
    super.dispose();
  }

  void _onCatalogChanged() {
    final ids = widget.catalog.foods.map((food) => food.id).toSet();
    final removed = _inputs
        .where((input) => !ids.contains(input.foodId))
        .toList();
    setState(() => _inputs.removeWhere(removed.contains));
    for (final input in removed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => input.dispose());
    }
    _invalidate();
  }

  void _invalidate() {
    if (_inputError != null) setState(() => _inputError = null);
    widget.model.invalidate();
  }

  void _add(Food food) {
    setState(() => _inputs.add(_IngredientInput(food.id, '100')));
    _invalidate();
  }

  void _remove(_IngredientInput input) {
    setState(() => _inputs.remove(input));
    WidgetsBinding.instance.addPostFrameCallback((_) => input.dispose());
    _invalidate();
  }

  void _calculate() {
    if (!_form.currentState!.validate()) return;
    final foods = {for (final food in widget.catalog.foods) food.id: food};
    final ingredients = <Ingredient>[];
    for (final input in _inputs) {
      final food = foods[input.foodId]!;
      final missing = Nutrient.values.where(
        (nutrient) =>
            !food.composition.containsKey(nutrient.label) &&
            (nutrient != Nutrient.protein || food.equivalentProtein == null),
      );
      if (missing.isNotEmpty) {
        setState(
          () => _inputError =
              '${food.name} precisa dos teores de ${missing.map((n) => n.label).join(', ')}. Complete o cadastro.',
        );
        revealAfterLayout(_feedback);
        return;
      }
      ingredients.add(
        Ingredient(
          food,
          parseNumber(input.quantity.text)!,
          parseNumber(input.price.text) ?? 0,
        ),
      );
    }
    FocusScope.of(context).unfocus();
    widget.model.calculate(
      ingredients,
      supplement: widget.balance.animal?.supplement,
    );
    revealAfterLayout(_feedback);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      widget.model,
      widget.catalog,
      widget.balance,
    ]),
    builder: (context, _) {
      final foods = widget.catalog.foods;
      final result = widget.model.result;
      final requirements = widget.balance.result;
      return Form(
        key: _form,
        child: FarmPage(
          children: [
            const PageHeading(
              'Formular ração',
              'Monte um lote e calcule a composição, o rendimento diário e o custo.',
            ),
            FarmPanel(
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nome da formulação (opcional)',
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.event_outlined),
                  label: Text(
                    _date == null
                        ? 'Selecionar data (opcional)'
                        : MaterialLocalizations.of(
                            context,
                          ).formatCompactDate(_date!),
                  ),
                  onPressed: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _date ?? now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(now.year + 10, 12, 31),
                    );
                    if (!mounted || date == null) return;
                    setState(() => _date = date);
                  },
                ),
                TextField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observação (opcional)',
                  ),
                ),
              ],
            ),
            if (requirements == null)
              FarmPanel(
                children: [
                  const Text(
                    'Calcule os dados do animal para estimar a porção diária e comparar o suplemento às exigências.',
                  ),
                  OutlinedButton(
                    onPressed: widget.onBalance,
                    child: const Text('Abrir dados do animal'),
                  ),
                ],
              ),
            if (foods.isEmpty)
              FarmPanel(
                children: [
                  Text(
                    widget.catalog.busy
                        ? 'Carregando alimentos…'
                        : 'Cadastre um alimento para começar.',
                  ),
                  if (!widget.catalog.busy)
                    OutlinedButton(
                      onPressed: widget.onCatalog,
                      child: const Text('Abrir central de alimentos'),
                    ),
                ],
              ),
            if (foods.isNotEmpty && _inputs.isEmpty)
              const FarmNotice(
                'Adicione um ingrediente. Para reproduzir o Excel, use 100 kg de Milho Moído.',
              ),
            for (final input in _inputs)
              FarmPanel(
                key: ObjectKey(input),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ingrediente ${_inputs.indexOf(input) + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remover ingrediente',
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _remove(input),
                      ),
                    ],
                  ),
                  FarmDropdown(
                    label: 'Alimento',
                    values: foods.map((food) => food.id).toList(),
                    selected: input.foodId,
                    display: (id) =>
                        foods.firstWhere((food) => food.id == id).name,
                    onChanged: (id) {
                      setState(() => input.foodId = id);
                      _invalidate();
                    },
                  ),
                  FarmNumberField(
                    controller: input.quantity,
                    label: 'Quantidade no lote',
                    unit: 'kg',
                    positive: true,
                    onChanged: (_) => _invalidate(),
                  ),
                  FarmNumberField(
                    controller: input.price,
                    label: 'Preço por kg (opcional)',
                    unit: 'R\$/kg',
                    optional: true,
                    onChanged: (_) => _invalidate(),
                  ),
                  if (result != null)
                    Text(
                      'Participação no lote  ${decimal(parseNumber(input.quantity.text)! * 100 / result.quantity)}%',
                    ),
                ],
              ),
            if (foods.isNotEmpty)
              OutlinedButton.icon(
                onPressed: _inputs.length >= 15 || widget.catalog.busy
                    ? null
                    : () => _add(foods.first),
                icon: const Icon(Icons.add),
                label: const Text('Adicionar ingrediente'),
              ),
            if (_inputs.length >= 15)
              const FarmNotice(
                'A formulação comporta até 15 ingredientes, como na planilha.',
              ),
            if (_inputs.isNotEmpty)
              FilledButton.icon(
                onPressed: widget.catalog.busy ? null : _calculate,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calcular formulação'),
              ),
            if ((_inputError ?? widget.model.error) case final error?)
              FarmNotice(error, key: _feedback, error: true),
            if (result != null)
              _RecipeSummary(
                key: _feedback,
                result: result,
                requirements: requirements,
                completePricing: _inputs.every(
                  (input) => input.price.text.trim().isNotEmpty,
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _RecipeSummary extends StatelessWidget {
  const _RecipeSummary({
    super.key,
    required this.result,
    required this.requirements,
    required this.completePricing,
  });

  final RecipeResult result;
  final Nutrients? requirements;
  final bool completePricing;

  @override
  Widget build(BuildContext context) {
    final daily = result.dailyAmount;
    final target = requirements;
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FarmPanel(
          children: [
            Text(
              'Resumo do lote',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text('Quantidade total  ${decimal(result.quantity)} kg'),
            if (completePricing) ...[
              Text('Custo do lote  ${money(result.cost)}'),
              Text('Custo por kg  ${money(result.costPerKg)}'),
            ] else
              const Text(
                'Preencha o preço de todos os ingredientes para ver os custos.',
              ),
            if (daily != null)
              Text(
                'Porção na matéria natural  ${decimal(daily, digits: 3)} kg/animal/dia',
              ),
            if (completePricing && result.dailyCost != null)
              Text('Custo diário  ${money(result.dailyCost!)} por animal'),
          ],
        ),
        FarmPanel(
          children: [
            Text(
              'Composição do lote',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            for (final nutrient in Nutrient.values)
              Row(
                children: [
                  Expanded(
                    child: Text('${nutrient.label} · ${nutrient.description}'),
                  ),
                  Text('${decimal(result.batch[nutrient]!, digits: 4)} kg'),
                ],
              ),
          ],
        ),
        if (target != null && daily != null)
          FarmPanel(
            children: [
              Text(
                'Fornecimento diário',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                'A diferença é o fornecimento desta ração menos a exigência total do animal. Inclua os demais alimentos consumidos para avaliar a dieta completa.',
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 54,
                  columns: const [
                    DataColumn(label: Text('Nutriente')),
                    DataColumn(
                      label: Text('Exigência\n(kg/dia)'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Fornecido\n(kg/dia)'),
                      numeric: true,
                    ),
                    DataColumn(
                      label: Text('Diferença\n(kg/dia)'),
                      numeric: true,
                    ),
                  ],
                  rows: [
                    for (final nutrient in Nutrient.values)
                      DataRow(
                        cells: [
                          DataCell(Text(nutrient.label)),
                          DataCell(Text(decimal(target[nutrient]!, digits: 4))),
                          DataCell(
                            Text(decimal(result.daily[nutrient]!, digits: 4)),
                          ),
                          DataCell(
                            Text(
                              decimal(
                                result.daily[nutrient]! - target[nutrient]!,
                                digits: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
