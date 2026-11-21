import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/nutribov_app.dart';
import 'data/food_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    NutriBovApp(repository: LocalFoodRepository(SharedPreferencesAsync())),
  );
}
