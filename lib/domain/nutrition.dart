import 'dart:math';

enum AnimalSystem {
  pasture('Pasto'),
  feedlot('Confinamento');

  const AnimalSystem(this.label);
  final String label;
}

enum Breed {
  zebu('Zebuíno'),
  beef('Cruzado de corte'),
  dairy('Cruzado de leite');

  const Breed(this.label);
  final String label;
}

enum AnimalSex {
  bull('Macho não castrado'),
  steer('Macho castrado'),
  female('Fêmea');

  const AnimalSex(this.label);
  final String label;
}

class Animal {
  const Animal({
    required this.system,
    required this.breed,
    required this.sex,
    required this.weight,
    required this.gain,
    required this.supplement,
  });

  final AnimalSystem system;
  final Breed breed;
  final AnimalSex sex;
  final double weight;
  final double gain;
  final double supplement;

  bool get supported =>
      system == AnimalSystem.feedlot ||
      (breed == Breed.zebu && sex == AnimalSex.bull);
}

enum Nutrient {
  dryMatter('MS', 'Matéria seca'),
  digestible('NDT', 'Nutrientes digestíveis totais'),
  protein('PB', 'Proteína bruta'),
  calcium('Ca', 'Cálcio'),
  phosphorus('P', 'Fósforo');

  const Nutrient(this.label, this.description);
  final String label;
  final String description;
}

typedef Nutrients = Map<Nutrient, double>;

class NutritionCalculator {
  const NutritionCalculator();

  Nutrients calculate(Animal animal) {
    if (!animal.supported) {
      throw const FormatException(
        'No pasto, a planilha calcula somente para macho zebuíno não castrado.',
      );
    }
    final weight = animal.weight;
    final gain = animal.gain;
    final supplement = animal.supplement;
    if (![weight, gain, supplement].every((v) => v.isFinite) ||
        weight <= 0 ||
        gain <= 0 ||
        supplement < 0) {
      throw const FormatException(
        'Informe peso e ganho positivos e suplemento a partir de zero.',
      );
    }

    // BR-CORTE, linhas 4–21. Ordem por sexo: inteiro, castrado, fêmea.
    final pasture = animal.system == AnimalSystem.pasture;
    final coefficients = switch (animal.breed) {
      Breed.zebu => [
        (0.8126, 1.0134, 517),
        (0.6241, 1.0608, 433),
        (0.611, 1.0667, 402),
      ],
      Breed.beef => [
        (0.7248, 1.0314, 560),
        (0.6586, 1.0499, 482),
        (0.6314, 1.0602, 417),
      ],
      Breed.dairy => [
        (0.7248, 1.0314, 616),
        (0.6586, 1.0499, 532),
        (0.6314, 1.0602, 493),
      ],
    };
    final (emptyFactor, emptyExponent, matureWeight) = pasture
        ? (0.8507, 1.0002, 517)
        : coefficients[animal.sex.index];
    final dairy = animal.breed == Breed.dairy;
    final zebu = animal.breed == Breed.zebu;
    final fasted =
        (dairy ? 0.9247 : 0.8915) * pow(weight, dairy ? 1.0085 : 1.0151);
    final empty = emptyFactor * pow(fasted, emptyExponent);
    final equivalent = empty / matureWeight * 517;
    final emptyGain = 0.963 * pow(gain, 1.0151);
    final metabolic = pow(weight, 0.75);
    final dryMatter = pasture
        ? -0.4684 +
              0.7732 * supplement +
              0.0742 * metabolic +
              0.7953 * gain -
              0.9047 * gain * gain
        : switch (animal.breed) {
            Breed.zebu =>
              -2.1948 +
                  0.08338 * metabolic +
                  3.9328 * gain -
                  0.903 * gain * gain,
            Breed.beef =>
              -0.6273 +
                  0.06453 * metabolic +
                  3.871 * gain -
                  0.614 * gain * gain,
            Breed.dairy =>
              -2.8836 +
                  0.08435 * metabolic +
                  4.5145 * gain -
                  0.9631 * gain * gain,
          };
    if (!dryMatter.isFinite || dryMatter <= 0 || supplement > dryMatter) {
      throw const FormatException(
        'Revise os dados. O consumo estimado deve ser positivo e cobrir o suplemento informado.',
      );
    }

    // BR-CORTE, linhas 36–45. Energia e proteína.
    final maintenanceEnergy = 0.075 * pow(empty, 0.75);
    final gainEnergy =
        (pasture ? 0.052 : 0.061) *
        pow(equivalent, 0.75) *
        pow(emptyGain, pasture ? 1.062 : 1.035);
    final retainedProtein = 1.14 * pow(gainEnergy / emptyGain, -1.137);
    final gainEfficiency = 0.327 / (0.539 + retainedProtein);
    final maintenanceFactor = switch (animal.breed) {
      Breed.zebu => 0.1,
      Breed.beef => 0.073,
      Breed.dairy => 0.01,
    };
    final maintenanceEfficiency =
        (0.513 + 0.173 * gainEfficiency + maintenanceFactor * emptyGain) *
        (pasture ? 0.92 : 1.0);
    final totalEnergy =
        maintenanceEnergy / maintenanceEfficiency + gainEnergy / gainEfficiency;
    final digestible =
        ((totalEnergy / dryMatter + 0.3032) / 0.9455) * dryMatter / 4.4;
    final maintenanceProtein = (pasture ? 3.9 : 3.6) * pow(fasted, 0.75);
    final gainProtein =
        176.01 * emptyGain -
        0.381 * pow(equivalent, 0.75) * pow(emptyGain, 1.035);
    final proteinEfficiency = fasted < 340
        ? 84.665 - 0.1179 * equivalent
        : 47.4;
    final totalProtein =
        maintenanceProtein + gainProtein / (proteinEfficiency / 100);
    final protein =
        (0.2 * (-53.07 + 90.8 * digestible - 3.13 * digestible * digestible) +
            1.25 * totalProtein) /
        0.93902 /
        1000;

    // BR-CORTE, linhas 67–73. Conversão de g/dia para kg/dia.
    final calciumGain = empty < (zebu ? 462 : 453)
        ? emptyGain * (zebu ? 147 : 66) * pow(empty, zebu ? -0.5 : -0.32)
        : 0.0;
    final phosphorusGain = empty < (zebu ? 445 : 479)
        ? emptyGain * (zebu ? 38.6 : 25.4) * pow(empty, zebu ? -0.36 : -0.25)
        : 0.0;
    final results = <Nutrient, double>{
      Nutrient.dryMatter: dryMatter,
      Nutrient.digestible: digestible,
      Nutrient.protein: protein,
      Nutrient.calcium: (11.7 * weight / 1000 + calciumGain) / 0.568 / 1000,
      Nutrient.phosphorus:
          (13.5 * weight / 1000 + phosphorusGain) / 0.678 / 1000,
    };
    if (results.values.any((v) => !v.isFinite || v < 0)) {
      throw const FormatException(
        'Os dados informados geraram resultados fora do intervalo de cálculo.',
      );
    }
    return Map.unmodifiable(results);
  }
}
