import 'dart:async';

import '../connectivity/connectivity_service.dart';
import '../network/dio_client.dart';
import '../storage/hive_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/state/auth_bloc.dart';
import '../../features/auth/state/auth_event.dart';
import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/state/cart_bloc.dart';
import '../../features/cart/state/cart_event.dart';
import '../../features/orders/state/orders_bloc.dart';
import '../../features/orders/state/orders_event.dart';
import '../../features/recipes/data/datasources/recipe_local_data_source.dart';
import '../../features/recipes/data/datasources/recipe_remote_data_source.dart';
import '../../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../../features/recipes/domain/repositories/recipe_repository.dart';
import '../../features/recipes/state/recipe_bloc.dart';
import '../../features/recipes/state/recipe_event.dart';
import '../../features/search/state/search_bloc.dart';

class ServiceLocator {
  ServiceLocator._();

  static late final SecureStorageService secureStorage;
  static late final HiveStorageService hiveStorage;
  static late final ConnectivityService connectivity;
  static late final DioClient dioClient;

  static late final AuthRepository authRepository;
  static late final RecipeRepository recipeRepository;
  static late final CartRepository cartRepository;

  static late final AuthBloc authBloc;
  static late final RecipeBloc recipeBloc;
  static late final SearchBloc searchBloc;
  static late final CartBloc cartBloc;
  static late final OrdersBloc ordersBloc;

  static Future<void> init() async {
    // 1. Storage Services
    secureStorage = SecureStorageService();
    hiveStorage = HiveStorageService();
    await hiveStorage.init();

    // 2. Connectivity
    connectivity = ConnectivityServiceImpl();

    // 3. Network & Auth Callback
    dioClient = DioClient(
      secureStorage: secureStorage,
      onUnauthorized: () {
        authBloc.add(const SessionExpiredReq());
      },
    );

    // 4. Data Sources & Repositories
    final authRemote = AuthRemoteDataSourceImpl(dio: dioClient.dio);
    final authLocal = AuthLocalDataSourceImpl(secureStorage: secureStorage);
    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemote,
      localDataSource: authLocal,
    );

    final recipeRemote = RecipeRemoteDataSourceImpl(dio: dioClient.dio);
    final recipeLocal = RecipeLocalDataSourceImpl(hiveStorage: hiveStorage);
    recipeRepository = RecipeRepositoryImpl(
      remoteDataSource: recipeRemote,
      localDataSource: recipeLocal,
    );

    final cartLocal = CartLocalDataSourceImpl(hiveStorage: hiveStorage);
    cartRepository = CartRepositoryImpl(localDataSource: cartLocal);

    // 5. BLoCs
    authBloc = AuthBloc(authRepository: authRepository);
    recipeBloc = RecipeBloc(recipeRepository: recipeRepository);
    searchBloc = SearchBloc(recipeRepository: recipeRepository);
    cartBloc = CartBloc(cartRepository: cartRepository);
    ordersBloc = OrdersBloc();

    // 6. Initial events
    authBloc.add(const CheckAuthSessionReq());
    recipeBloc.add(const FetchRecipesReq());
    cartBloc.add(const LoadCartReq());
    ordersBloc.add(const LoadOrdersReq());
  }
}
