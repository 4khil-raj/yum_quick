import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yum_quick/app/router.dart';
import 'package:yum_quick/core/theme/app_theme.dart';
// import 'app/app.dart';
import 'core/network/dio_client.dart';
import 'core/storage/hive_storage_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/cart/data/datasources/cart_local_data_source.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/orders/data/datasources/orders_local_data_source.dart';
import 'features/orders/data/repositories/orders_repository_impl.dart';
import 'features/orders/presentation/bloc/orders_bloc.dart';
import 'features/orders/presentation/bloc/orders_event.dart';
import 'features/recipes/data/datasources/recipe_local_data_source.dart';
import 'features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'features/recipes/data/repositories/recipe_repository_impl.dart';
import 'features/recipes/presentation/bloc/recipe_bloc.dart';
import 'features/recipes/presentation/bloc/recipe_event.dart';
import 'features/search/presentation/bloc/search_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<String>(HiveStorageService.boxRecipesCache);
  await Hive.openBox<String>(HiveStorageService.boxCart);
  await Hive.openBox<bool>(HiveStorageService.boxFavorites);
  await Hive.openBox<String>(HiveStorageService.boxRecentSearches);
  await Hive.openBox<String>(HiveStorageService.boxOrders);
  await Hive.openBox<String>(HiveStorageService.boxPreferences);

  final hiveStorage = HiveStorageService();
  await hiveStorage.init();
  final secureStorage = SecureStorageService(hiveStorage: hiveStorage);

  late final AuthBloc authBloc;
  final dioClient = DioClient(
    secureStorage: secureStorage,
    onUnauthorized: () {
      authBloc.add(const SessionExpiredReq());
    },
  );

  final authRepository = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(dio: dioClient.dio),
    localDataSource: AuthLocalDataSourceImpl(secureStorage: secureStorage),
  );

  final recipeRepository = RecipeRepositoryImpl(
    remoteDataSource: RecipeRemoteDataSourceImpl(dio: dioClient.dio),
    localDataSource: RecipeLocalDataSourceImpl(hiveStorage: hiveStorage),
  );

  final cartRepository = CartRepositoryImpl(
    localDataSource: CartLocalDataSourceImpl(hiveStorage: hiveStorage),
  );

  final ordersRepository = OrdersRepositoryImpl(
    localDataSource: OrdersLocalDataSourceImpl(hiveStorage: hiveStorage),
  );

  authBloc = AuthBloc(authRepository: authRepository);
  final recipeBloc = RecipeBloc(recipeRepository: recipeRepository);
  final searchBloc = SearchBloc(recipeRepository: recipeRepository);
  final cartBloc = CartBloc(cartRepository: cartRepository);
  final ordersBloc = OrdersBloc(ordersRepository: ordersRepository);

  authBloc.add(const CheckAuthSessionReq());
  recipeBloc.add(const FetchRecipesReq());
  cartBloc.add(const LoadCartReq());
  ordersBloc.add(const LoadOrdersReq());

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<RecipeBloc>.value(value: recipeBloc),
        BlocProvider<SearchBloc>.value(value: searchBloc),
        BlocProvider<CartBloc>.value(value: cartBloc),
        BlocProvider<OrdersBloc>.value(value: ordersBloc),
      ],
      child:  MaterialApp.router(
      title: 'YumQuick Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    ),
  ),
);
}
