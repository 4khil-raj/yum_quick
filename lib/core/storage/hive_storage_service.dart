import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class HiveStorageService {
  static const String boxRecipesCache = 'recipes_cache_box';
  static const String boxCart = 'cart_box';
  static const String boxFavorites = 'favorites_box';
  static const String boxRecentSearches = 'recent_searches_box';
  static const String boxOrders = 'orders_box';
  static const String boxPreferences = 'preferences_box';

  static const String keyFirstPageRecipes = 'first_page_recipes';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(boxRecipesCache)) {
      await Hive.openBox<String>(boxRecipesCache);
    }
    if (!Hive.isBoxOpen(boxCart)) {
      await Hive.openBox<String>(boxCart);
    }
    if (!Hive.isBoxOpen(boxFavorites)) {
      await Hive.openBox<bool>(boxFavorites);
    }
    if (!Hive.isBoxOpen(boxRecentSearches)) {
      await Hive.openBox<String>(boxRecentSearches);
    }
    if (!Hive.isBoxOpen(boxOrders)) {
      await Hive.openBox<String>(boxOrders);
    }
    if (!Hive.isBoxOpen(boxPreferences)) {
      await Hive.openBox<String>(boxPreferences);
    }
  }

  Future<void> cacheFirstPageRecipes(Map<String, dynamic> recipesJson) async {
    final box = Hive.box<String>(boxRecipesCache);
    await box.put(keyFirstPageRecipes, jsonEncode(recipesJson));
  }

  Map<String, dynamic>? getCachedFirstPageRecipes() {
    final box = Hive.box<String>(boxRecipesCache);
    final raw = box.get(keyFirstPageRecipes);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearRecipeCache() async {
    final box = Hive.box<String>(boxRecipesCache);
    await box.clear();
  }

  Future<void> saveCartItems(List<Map<String, dynamic>> items) async {
    final box = Hive.box<String>(boxCart);
    await box.put('cart_items', jsonEncode(items));
  }

  List<Map<String, dynamic>> getCartItems() {
    final box = Hive.box<String>(boxCart);
    final raw = box.get('cart_items');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearCart() async {
    final box = Hive.box<String>(boxCart);
    await box.clear();
  }

  Set<int> getFavoriteIds() {
    final box = Hive.box<bool>(boxFavorites);
    final ids = <int>{};
    for (final key in box.keys) {
      if (key is int && box.get(key) == true) {
        ids.add(key);
      } else if (key is String && box.get(key) == true) {
        final parsed = int.tryParse(key);
        if (parsed != null) ids.add(parsed);
      }
    }
    return ids;
  }

  Future<void> toggleFavorite(int recipeId) async {
    final box = Hive.box<bool>(boxFavorites);
    final isFav = box.get(recipeId.toString()) ?? false;
    await box.put(recipeId.toString(), !isFav);
  }

  bool isFavorite(int recipeId) {
    final box = Hive.box<bool>(boxFavorites);
    return box.get(recipeId.toString()) ?? false;
  }

  List<String> getRecentSearches() {
    final box = Hive.box<String>(boxRecentSearches);
    final raw = box.get('searches');
    if (raw == null) return [];
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  Future<void> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;
    final searches = getRecentSearches();
    searches.remove(clean);
    searches.insert(0, clean);
    if (searches.length > 10) searches.removeLast();
    final box = Hive.box<String>(boxRecentSearches);
    await box.put('searches', jsonEncode(searches));
  }

  Future<void> clearRecentSearches() async {
    final box = Hive.box<String>(boxRecentSearches);
    await box.clear();
  }

  Future<void> saveOrders(List<Map<String, dynamic>> orders) async {
    final box = Hive.box<String>(boxOrders);
    await box.put('orders_list', jsonEncode(orders));
  }

  List<Map<String, dynamic>> getOrders() {
    final box = Hive.box<String>(boxOrders);
    final raw = box.get('orders_list');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearOrders() async {
    final box = Hive.box<String>(boxOrders);
    await box.clear();
  }

  Future<void> savePreference(String key, String value) async {
    final box = Hive.box<String>(boxPreferences);
    await box.put(key, value);
  }

  String? getPreference(String key) {
    final box = Hive.box<String>(boxPreferences);
    return box.get(key);
  }

  Future<void> removePreference(String key) async {
    final box = Hive.box<String>(boxPreferences);
    await box.delete(key);
  }

  Future<void> clearPreferences() async {
    final box = Hive.box<String>(boxPreferences);
    await box.clear();
  }
}
