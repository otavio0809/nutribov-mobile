import 'package:flutter/foundation.dart';

import '../../data/food_repository.dart';
import '../../domain/food.dart';

class CatalogViewModel extends ChangeNotifier {
  CatalogViewModel(this.repository);

  final FoodRepository repository;
  List<Food> _foods = [];
  List<Food> get foods => List.unmodifiable(_foods);
  bool _busy = false;
  bool get busy => _busy;
  String? _error;
  String? get error => _error;
  bool _disposed = false;

  Future<void> load() async {
    if (_busy) return;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      _foods = await repository.load();
    } catch (_) {
      _error = 'Não foi possível abrir os alimentos cadastrados.';
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> upsert(Food food) {
    if (_foods.any(
      (existing) =>
          existing.id != food.id &&
          existing.name.toLowerCase() == food.name.toLowerCase(),
    )) {
      _error = 'Já existe um alimento com esse nome.';
      notifyListeners();
      return Future.value(false);
    }
    final exists = _foods.any((existing) => existing.id == food.id);
    return _persist([
      for (final existing in _foods) existing.id == food.id ? food : existing,
      if (!exists) food,
    ]);
  }

  Future<bool> remove(String id) =>
      _persist(_foods.where((food) => food.id != id).toList());

  Future<bool> _persist(List<Food> updated) async {
    if (_busy) return false;
    _busy = true;
    _error = null;
    notifyListeners();
    try {
      await repository.save(updated);
      _foods = updated;
      return true;
    } catch (_) {
      _error = 'Não foi possível salvar a alteração. Tente novamente.';
      return false;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
