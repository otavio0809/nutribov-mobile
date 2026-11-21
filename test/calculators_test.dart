import 'package:flutter_test/flutter_test.dart';
import 'package:nutribov/domain/food.dart';
import 'package:nutribov/domain/nutrition.dart';
import 'package:nutribov/domain/recipe.dart';

void main() {
  const calculator = NutritionCalculator();
  const animal = Animal(
    system: AnimalSystem.pasture,
    breed: Breed.zebu,
    sex: AnimalSex.bull,
    weight: 400,
    gain: 1.25,
    supplement: 0.5,
  );

  test('matches the five cached outputs of the supplied workbook', () {
    final result = calculator.calculate(animal);
    const expected = {
      Nutrient.dryMatter: 6.135381007,
      Nutrient.digestible: 5.398704607,
      Nutrient.protein: 1.025344325,
      Nutrient.calcium: 0.02538236672,
      Nutrient.phosphorus: 0.01646660117,
    };
    for (final entry in expected.entries) {
      expect(result[entry.key], closeTo(entry.value, 1e-7));
    }
  });

  test('supports all nine feedlot profiles at the example weight and gain', () {
    for (final breed in Breed.values) {
      for (final sex in AnimalSex.values) {
        final result = calculator.calculate(
          Animal(
            system: AnimalSystem.feedlot,
            breed: breed,
            sex: sex,
            weight: 400,
            gain: 1.25,
            supplement: 0.5,
          ),
        );
        expect(result.length, Nutrient.values.length);
        expect(
          result.values.every((value) => value > 0 && value.isFinite),
          isTrue,
        );
      }
    }
  });

  test('rejects a pasture profile missing from the workbook', () {
    expect(
      () => calculator.calculate(
        const Animal(
          system: AnimalSystem.pasture,
          breed: Breed.zebu,
          sex: AnimalSex.female,
          weight: 400,
          gain: 1.25,
          supplement: 0.5,
        ),
      ),
      throwsFormatException,
    );
  });

  test(
    'reproduces the 100 kg corn example and converts it to a daily portion',
    () {
      final corn = Food(
        id: 'INS001',
        name: 'Milho Moído',
        group: FoodGroup.input,
        type: 'Concentrado energético',
        source: 'CQBAL 4.0',
        composition: {
          'MS': 87.88,
          'NDT': 86.11,
          'PB': 8.96,
          'Ca': 0.03,
          'P': 0.26,
        },
      );
      final result = const RecipeCalculator().calculate([
        Ingredient(corn, 100, 2),
      ], supplement: animal.supplement);
      expect(result.quantity, 100);
      expect(result.batch[Nutrient.dryMatter], closeTo(87.88, 1e-8));
      expect(result.batch[Nutrient.digestible], closeTo(75.673468, 1e-8));
      expect(result.batch[Nutrient.protein], closeTo(7.874048, 1e-8));
      expect(result.batch[Nutrient.calcium], closeTo(0.026364, 1e-8));
      expect(result.batch[Nutrient.phosphorus], closeTo(0.228488, 1e-8));
      expect(result.dailyAmount, closeTo(0.5689576695, 1e-8));
      expect(result.daily[Nutrient.dryMatter], closeTo(0.5, 1e-8));
      expect(result.daily[Nutrient.digestible], closeTo(0.43055, 1e-8));
      expect(result.cost, 200);
      expect(result.costPerKg, 2);
      expect(result.dailyCost, closeTo(1.137915339, 1e-8));
    },
  );
}
