import 'package:flutter/foundation.dart';

import '../../domain/recipe.dart';

class RecipeViewModel extends ChangeNotifier {
  RecipeViewModel(this.calculator);
  final RecipeCalculator calculator;

  RecipeResult? _result;
  RecipeResult? get result => _result;
  String? _error;
  String? get error => _error;

  void invalidate() {
    if (_result == null && _error == null) return;
    _result = null;
    _error = null;
    notifyListeners();
  }

  void calculate(List<Ingredient> ingredients, {double? supplement}) {
    try {
      _result = calculator.calculate(ingredients, supplement: supplement);
      _error = null;
    } on FormatException catch (error) {
      _result = null;
      _error = error.message;
    }
    notifyListeners();
  }
}
