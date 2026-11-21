import 'package:flutter/material.dart';

import '../../core/design_system/widgets.dart';
import '../../domain/food.dart';
import 'catalog_view_model.dart';
import 'food_editor.dart';

class CatalogView extends StatefulWidget {
  const CatalogView({super.key, required this.model});
  final CatalogViewModel model;

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  var _search = '';
  FoodGroup? _group;

  Future<void> _edit([Food? food]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => FoodEditor(model: widget.model, existing: food),
      ),
    );
  }

  Future<void> _remove(Food food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir alimento?'),
        content: Text(
          '${food.name} será removido do catálogo e da formulação em edição.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await widget.model.remove(food.id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.model,
    builder: (context, _) {
      final model = widget.model;
      final foods = model.foods.where(
        (food) =>
            (_group == null || food.group == _group) &&
            food.name.toLowerCase().contains(_search.trim().toLowerCase()),
      );
      return FarmPage(
        children: [
          const PageHeading(
            'Central de alimentos',
            'Cadastre ingredientes e consulte sua composição.',
          ),
          FilledButton.icon(
            onPressed:
                model.busy || (model.error != null && model.foods.isEmpty)
                ? null
                : _edit,
            icon: const Icon(Icons.add),
            label: const Text('Novo alimento'),
          ),
          TextField(
            onChanged: (value) => setState(() => _search = value),
            decoration: const InputDecoration(
              labelText: 'Buscar por nome',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: _group == null,
                onSelected: (_) => setState(() => _group = null),
              ),
              for (final group in FoodGroup.values)
                ChoiceChip(
                  label: Text(group.label),
                  selected: _group == group,
                  onSelected: (selected) =>
                      setState(() => _group = selected ? group : null),
                ),
            ],
          ),
          if (model.busy) const LinearProgressIndicator(),
          if (model.error case final error?) ...[
            FarmNotice(error, error: true),
            if (model.foods.isEmpty)
              OutlinedButton(
                onPressed: model.load,
                child: const Text('Recarregar catálogo'),
              ),
          ],
          if (!model.busy && model.error == null && foods.isEmpty)
            FarmNotice(
              model.foods.isEmpty
                  ? 'Cadastre seu primeiro alimento.'
                  : 'Nenhum alimento encontrado.',
            ),
          for (final food in foods)
            FarmPanel(
              children: [
                Row(
                  children: [
                    const Icon(Icons.grass_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        food.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Editar ${food.name}',
                      onPressed: model.busy ? null : () => _edit(food),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Excluir ${food.name}',
                      onPressed: model.busy ? null : () => _remove(food),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
                Text('${food.group.label} · ${food.type}\n${food.source}'),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final key in ['MS', 'NDT', 'PB'])
                      if (food.composition[key] case final amount?)
                        Chip(label: Text('$key ${decimal(amount)}%')),
                  ],
                ),
              ],
            ),
        ],
      );
    },
  );
}
