import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/food.dart';

abstract interface class FoodRepository {
  Future<List<Food>> load();
  Future<void> save(List<Food> foods);
}

class LocalFoodRepository implements FoodRepository {
  LocalFoodRepository(this.preferences);
  final SharedPreferencesAsync preferences;
  static const _key = 'nutribov.foods.v1';

  @override
  Future<List<Food>> load() async {
    final raw = await preferences.getString(_key);
    if (raw == null) {
      return [
        Food(
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
            'EE': 4,
            'FDN': 13.42,
            'FDA': 3.69,
          },
        ),
      ];
    }
    return (jsonDecode(raw) as List<dynamic>)
        .map((entry) => Food.fromJson(entry as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(List<Food> foods) => preferences.setString(
    _key,
    jsonEncode(foods.map((food) => food.toJson()).toList()),
  );
}
