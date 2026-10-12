class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String loginEndpoint = '/auth/login';
  static const String meEndpoint = '/auth/me';
  static const String refreshEndpoint = '/auth/refresh';

  static const String recipesEndpoint = '/recipes';
  static const String searchRecipesEndpoint = '/recipes/search';
  static const String tagsEndpoint = '/recipes/tags';
  static const String tagRecipesEndpoint = '/recipes/tag';
  static const String mealTypeRecipesEndpoint = '/recipes/meal-type';
}
