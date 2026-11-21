import 'nutrition.dart';

enum FoodGroup {
  forage('Forragem', ['Forragens secas', 'Forragens verdes', 'Silagens']),
  input('Insumo', [
    'Concentrado energético',
    'Concentrado proteico',
    'Subproduto',
    'Fonte de minerais',
    'Aditivos e outros',
  ]),
  feed('Ração', ['Ração comercial', 'Ração formulada']),
  additive('Núcleo / aditivo', [
    'Núcleo',
    'Fonte de NNP',
    'Fonte mineral',
    'Aditivo',
    'Outro',
  ]);

  const FoodGroup(this.label, this.types);
  final String label;
  final List<String> types;
}

const foodSources = [
  'CQBAL 4.0',
  'Análise bromatológica',
  'Rótulo do fabricante',
  'Formulação própria',
  'Outra fonte',
];
const doseUnits = [
  'g/animal/dia',
  'kg/animal/dia',
  'mg/animal/dia',
  'g/kg de MS',
  '% da dieta',
  '% da ração',
];

class Food {
  Food({
    required this.id,
    required this.name,
    required this.group,
    required this.type,
    required this.source,
    required Map<String, double> composition,
    this.manufacturer = '',
    this.notes = '',
    this.dose,
    this.doseUnit,
  }) : composition = Map.unmodifiable(composition);

  final String id, name, type, source, manufacturer, notes;
  final FoodGroup group;
  final Map<String, double> composition;
  final double? dose;
  final String? doseUnit;

  double? get equivalentProtein =>
      type == 'Fonte de NNP' && composition['N'] != null
      ? composition['N']! * 6.25
      : null;

  double percent(Nutrient nutrient) =>
      composition[nutrient.label] ??
      (nutrient == Nutrient.protein ? equivalentProtein : null) ??
      0;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'group': group.name,
    'type': type,
    'source': source,
    'manufacturer': manufacturer,
    'notes': notes,
    'composition': composition,
    'dose': dose,
    'doseUnit': doseUnit,
  };

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json['id'] as String,
    name: json['name'] as String,
    group: FoodGroup.values.byName(json['group'] as String),
    type: json['type'] as String,
    source: json['source'] as String,
    manufacturer: json['manufacturer'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    composition: (json['composition'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    ),
    dose: (json['dose'] as num?)?.toDouble(),
    doseUnit: json['doseUnit'] as String?,
  );
}
