import 'package:flutter/material.dart';

import '../../core/design_system/widgets.dart';
import '../../domain/food.dart';
import 'catalog_view_model.dart';

class FoodEditor extends StatefulWidget {
  const FoodEditor({super.key, required this.model, this.existing});
  final CatalogViewModel model;
  final Food? existing;

  @override
  State<FoodEditor> createState() => _FoodEditorState();
}

class _FoodEditorState extends State<FoodEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _manufacturer, _notes, _dose;
  late final Map<String, TextEditingController> _composition;
  late FoodGroup _group;
  late String _type, _source, _doseUnit;
  bool _saving = false;
  String? _error;

  static const _labels = {
    'MS': 'Matéria seca (MS)',
    'NDT': 'Nutrientes digestíveis totais (NDT)',
    'PB': 'Proteína bruta (PB)',
    'Ca': 'Cálcio (Ca)',
    'P': 'Fósforo (P)',
    'EE': 'Extrato etéreo (EE)',
    'FDN': 'Fibra em detergente neutro (FDN)',
    'FDA': 'Fibra em detergente ácido (FDA)',
    'N': 'Nitrogênio (N)',
  };

  @override
  void initState() {
    super.initState();
    final food = widget.existing;
    _name = TextEditingController(text: food?.name);
    _manufacturer = TextEditingController(text: food?.manufacturer);
    _notes = TextEditingController(text: food?.notes);
    _dose = TextEditingController(text: food?.dose?.toString());
    _group = food?.group ?? FoodGroup.input;
    _type = food?.type ?? _group.types.first;
    _source = food?.source ?? foodSources.first;
    _doseUnit = food?.doseUnit ?? doseUnits.first;
    _composition = {
      for (final key in _labels.keys)
        key: TextEditingController(text: food?.composition[key]?.toString()),
    };
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _manufacturer,
      _notes,
      _dose,
      ..._composition.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    final dose = _group == FoodGroup.additive ? parseNumber(_dose.text) : null;
    final food = Food(
      id:
          widget.existing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      group: _group,
      type: _type,
      source: _source,
      manufacturer: _group == FoodGroup.feed || _group == FoodGroup.additive
          ? _manufacturer.text.trim()
          : '',
      notes: _notes.text.trim(),
      dose: dose,
      doseUnit: dose == null ? null : _doseUnit,
      composition: {
        for (final entry in _composition.entries)
          if (entry.key != 'N' || _type == 'Fonte de NNP')
            if (parseNumber(entry.value.text) case final amount?)
              entry.key: amount,
      },
    );
    final saved = await widget.model.upsert(food);
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _saving = false;
      _error =
          widget.model.error ?? 'Aguarde a operação atual e tente novamente.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final nitrogen = parseNumber(_composition['N']!.text);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'Novo alimento' : 'Editar alimento',
        ),
      ),
      body: Form(
        key: _form,
        child: FarmPage(
          children: [
            FarmPanel(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Nome do alimento',
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Informe o nome' : null,
                ),
                FarmDropdown(
                  label: 'Grupo',
                  values: FoodGroup.values,
                  selected: _group,
                  display: (group) => group.label,
                  onChanged: (group) => setState(() {
                    _group = group;
                    _type = group.types.first;
                  }),
                ),
                FarmDropdown(
                  label: 'Tipo',
                  values: _group.types,
                  selected: _type,
                  display: (value) => value,
                  onChanged: (value) => setState(() => _type = value),
                ),
                FarmDropdown(
                  label: 'Origem dos dados',
                  values: foodSources,
                  selected: _source,
                  display: (value) => value,
                  onChanged: (value) => setState(() => _source = value),
                ),
                if (_group == FoodGroup.feed || _group == FoodGroup.additive)
                  TextFormField(
                    controller: _manufacturer,
                    decoration: const InputDecoration(labelText: 'Fabricante'),
                  ),
                TextFormField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observação ou fonte',
                  ),
                ),
              ],
            ),
            FarmPanel(
              children: [
                Text(
                  'Composição nutricional',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Informe MS na matéria natural e os demais teores na matéria seca. Preencha NDT, PB, Ca e P antes de formular.',
                ),
                for (final entry in _labels.entries)
                  if (entry.key != 'N' || _type == 'Fonte de NNP')
                    FarmNumberField(
                      controller: _composition[entry.key]!,
                      label: entry.value,
                      unit: '%',
                      max: 100,
                      optional: entry.key != 'MS',
                      positive: entry.key == 'MS',
                      onChanged: entry.key == 'N'
                          ? (_) => setState(() {})
                          : null,
                    ),
                if (_type == 'Fonte de NNP' && nitrogen != null)
                  Text(
                    'Proteína bruta equivalente  ${decimal(nitrogen * 6.25)}%',
                  ),
                if (_group == FoodGroup.additive) ...[
                  FarmNumberField(
                    controller: _dose,
                    label: 'Dose ou inclusão recomendada',
                    optional: true,
                  ),
                  FarmDropdown(
                    label: 'Unidade da dose',
                    values: doseUnits,
                    selected: _doseUnit,
                    display: (value) => value,
                    onChanged: (value) => setState(() => _doseUnit = value),
                  ),
                ],
              ],
            ),
            if (_error case final error?) FarmNotice(error, error: true),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: Text(_saving ? 'Salvando…' : 'Salvar alimento'),
            ),
          ],
        ),
      ),
    );
  }
}
