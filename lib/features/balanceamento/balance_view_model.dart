import 'package:flutter/foundation.dart';

import '../../domain/nutrition.dart';

class BalanceViewModel extends ChangeNotifier {
  BalanceViewModel(this.calculator);
  final NutritionCalculator calculator;

  Animal? _animal;
  Animal? get animal => _animal;
  Nutrients? _result;
  Nutrients? get result => _result;
  String? _error;
  String? get error => _error;

  void invalidate() {
    if (_result == null && _error == null) return;
    _animal = null;
    _result = null;
    _error = null;
    notifyListeners();
  }

  void calculate(Animal animal) {
    try {
      _result = calculator.calculate(animal);
      _animal = animal;
      _error = null;
    } on FormatException catch (error) {
      _result = null;
      _animal = null;
      _error = error.message;
    }
    notifyListeners();
  }
}
