import 'package:flutter/material.dart';

import '../../core/design_system/widgets.dart';
import '../../domain/nutrition.dart';
import 'balance_view_model.dart';

class BalanceView extends StatefulWidget {
  const BalanceView({super.key, required this.model, required this.onRecipe});
  final BalanceViewModel model;
  final VoidCallback onRecipe;

  @override
  State<BalanceView> createState() => _BalanceViewState();
}

class _BalanceViewState extends State<BalanceView> {
  final _form = GlobalKey<FormState>();
  final _feedback = GlobalKey();
  final _weight = TextEditingController(text: '400');
  final _gain = TextEditingController(text: '1,25');
  final _supplement = TextEditingController(text: '0,50');
  var _system = AnimalSystem.pasture;
  var _breed = Breed.zebu;
  var _sex = AnimalSex.bull;

  @override
  void dispose() {
    _weight.dispose();
    _gain.dispose();
    _supplement.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.model.calculate(
      Animal(
        system: _system,
        breed: _breed,
        sex: _sex,
        weight: parseNumber(_weight.text)!,
        gain: parseNumber(_gain.text)!,
        supplement: parseNumber(_supplement.text)!,
      ),
    );
    revealAfterLayout(_feedback);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.model,
    builder: (context, _) {
      final result = widget.model.result;
      final unsupported =
          _system == AnimalSystem.pasture &&
          (_breed != Breed.zebu || _sex != AnimalSex.bull);
      return Form(
        key: _form,
        child: FarmPage(
          children: [
            const PageHeading(
              'Dados do animal',
              'Calcule as exigências nutricionais diárias com as equações da planilha.',
            ),
            FarmPanel(
              children: [
                FarmDropdown(
                  label: 'Sistema de produção',
                  values: AnimalSystem.values,
                  selected: _system,
                  display: (value) => value.label,
                  onChanged: (value) {
                    setState(() => _system = value);
                    widget.model.invalidate();
                  },
                ),
                FarmDropdown(
                  label: 'Grupo genético',
                  values: Breed.values,
                  selected: _breed,
                  display: (value) => value.label,
                  onChanged: (value) {
                    setState(() => _breed = value);
                    widget.model.invalidate();
                  },
                ),
                FarmDropdown(
                  label: 'Sexo',
                  values: AnimalSex.values,
                  selected: _sex,
                  display: (value) => value.label,
                  onChanged: (value) {
                    setState(() => _sex = value);
                    widget.model.invalidate();
                  },
                ),
                FarmNumberField(
                  controller: _weight,
                  label: 'Peso corporal',
                  unit: 'kg',
                  positive: true,
                  onChanged: (_) => widget.model.invalidate(),
                ),
                FarmNumberField(
                  controller: _gain,
                  label: 'Ganho médio diário desejado',
                  unit: 'kg/dia',
                  positive: true,
                  onChanged: (_) => widget.model.invalidate(),
                ),
                FarmNumberField(
                  controller: _supplement,
                  label: 'Consumo de suplemento',
                  unit: 'kg MS/dia',
                  onChanged: (_) => widget.model.invalidate(),
                ),
              ],
            ),
            if (unsupported)
              const FarmNotice(
                'Para pasto, nosso app disponibiliza o cálculo somente para macho zebuíno não castrado, por enquanto.',
              ),
            FilledButton.icon(
              onPressed: unsupported ? null : _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calcular exigências'),
            ),
            if (widget.model.error case final error?)
              FarmNotice(error, key: _feedback, error: true),
            if (result != null)
              FarmPanel(
                key: _feedback,
                children: [
                  Text(
                    'Exigências nutricionais',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Text('Por animal por dia · em kg'),
                  for (final nutrient in Nutrient.values)
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: Text(
                            '${nutrient.label} · ${nutrient.description}',
                          ),
                        ),
                        Text(decimal(result[nutrient]!, digits: 4)),
                      ],
                    ),
                  OutlinedButton.icon(
                    onPressed: widget.onRecipe,
                    icon: const Icon(Icons.restaurant_outlined),
                    label: const Text('Ir para formulação'),
                  ),
                ],
              ),
          ],
        ),
      );
    },
  );
}
