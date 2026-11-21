import 'food.dart';
import 'nutrition.dart';

class Ingredient {
  const Ingredient(this.food, this.quantity, this.price);
  final Food food;
  final double quantity;
  final double price;
}

class RecipeResult {
  RecipeResult({
    required this.quantity,
    required this.cost,
    required this.dailyAmount,
    required Nutrients batch,
    required Nutrients daily,
  }) : batch = Map.unmodifiable(batch),
       daily = Map.unmodifiable(daily);

  final double quantity, cost;
  final double? dailyAmount;
  final Nutrients batch, daily;

  double get costPerKg => cost / quantity;
  double? get dailyCost =>
      dailyAmount == null ? null : dailyAmount! * costPerKg;
}

class RecipeCalculator {
  const RecipeCalculator();

  RecipeResult calculate(List<Ingredient> ingredients, {double? supplement}) {
    if (ingredients.isEmpty ||
        ingredients.any(
          (item) =>
              !item.quantity.isFinite ||
              item.quantity <= 0 ||
              !item.price.isFinite ||
              item.price < 0,
        )) {
      throw const FormatException(
        'Informe ao menos um ingrediente com quantidade positiva e preço válido.',
      );
    }

    var quantity = 0.0;
    var cost = 0.0;
    final batch = {for (final nutrient in Nutrient.values) nutrient: 0.0};
    for (final item in ingredients) {
      quantity += item.quantity;
      cost += item.quantity * item.price;
      final dryMatter =
          item.quantity * (item.food.percent(Nutrient.dryMatter) / 100);
      batch[Nutrient.dryMatter] = batch[Nutrient.dryMatter]! + dryMatter;
      for (final nutrient in Nutrient.values.skip(1)) {
        batch[nutrient] =
            batch[nutrient]! + dryMatter * (item.food.percent(nutrient) / 100);
      }
    }
    final dryMatter = batch[Nutrient.dryMatter]!;
    if (dryMatter <= 0 ||
        ![quantity, cost, ...batch.values].every((value) => value.isFinite)) {
      throw const FormatException(
        'Revise as quantidades, os preços e a matéria seca dos ingredientes.',
      );
    }

    // FORMULAR RAÇÃO, células D26 e D30:D34.
    final dailyFactor = supplement == null ? null : supplement / dryMatter;
    final dailyAmount = dailyFactor == null ? null : dailyFactor * quantity;
    final daily = dailyFactor == null
        ? <Nutrient, double>{}
        : batch.map((nutrient, mass) => MapEntry(nutrient, mass * dailyFactor));
    if (dailyAmount != null &&
        ![
          dailyAmount,
          dailyAmount * (cost / quantity),
          ...daily.values,
        ].every((v) => v.isFinite)) {
      throw const FormatException(
        'Revise a quantidade de suplemento e o tamanho do lote.',
      );
    }
    return RecipeResult(
      quantity: quantity,
      cost: cost,
      dailyAmount: dailyAmount,
      batch: batch,
      daily: daily,
    );
  }
}
