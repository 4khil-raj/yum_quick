import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/app/app.dart';
import 'src/core/network/dio_client.dart';
import 'src/core/storage/hive_storage_service.dart';
import 'src/core/storage/secure_storage_service.dart';
import 'src/features/auth/data/datasources/auth_local_data_source.dart';
import 'src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'src/features/auth/data/repositories/auth_repository_impl.dart';
import 'src/features/auth/presentation/bloc/auth_bloc.dart';
import 'src/features/auth/presentation/bloc/auth_event.dart';
import 'src/features/cart/data/datasources/cart_local_data_source.dart';
import 'src/features/cart/data/repositories/cart_repository_impl.dart';
import 'src/features/cart/presentation/bloc/cart_bloc.dart';
import 'src/features/cart/presentation/bloc/cart_event.dart';
import 'src/features/orders/data/datasources/orders_local_data_source.dart';
import 'src/features/orders/data/repositories/orders_repository_impl.dart';
import 'src/features/orders/presentation/bloc/orders_bloc.dart';
import 'src/features/orders/presentation/bloc/orders_event.dart';
import 'src/features/recipes/data/datasources/recipe_local_data_source.dart';
import 'src/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'src/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'src/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'src/features/recipes/presentation/bloc/recipe_event.dart';
import 'src/features/search/presentation/bloc/search_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive Storage Initialization & Box Registration
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

  // 2. Network Client with Token Injection & 401 Session Interceptor
  late final AuthBloc authBloc;
  final dioClient = DioClient(
    secureStorage: secureStorage,
    onUnauthorized: () {
      authBloc.add(const SessionExpiredReq());
    },
  );

  // 3. Repositories
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

  // 4. BLoCs Injection
  authBloc = AuthBloc(authRepository: authRepository);
  final recipeBloc = RecipeBloc(recipeRepository: recipeRepository);
  final searchBloc = SearchBloc(recipeRepository: recipeRepository);
  final cartBloc = CartBloc(cartRepository: cartRepository);
  final ordersBloc = OrdersBloc(ordersRepository: ordersRepository);

  // 5. Initial Lifecycle Events
  authBloc.add(const CheckAuthSessionReq());
  recipeBloc.add(const FetchRecipesReq());
  cartBloc.add(const LoadCartReq());
  ordersBloc.add(const LoadOrdersReq());

  // 6. Root App Registration via MultiBlocProvider
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<RecipeBloc>.value(value: recipeBloc),
        BlocProvider<SearchBloc>.value(value: searchBloc),
        BlocProvider<CartBloc>.value(value: cartBloc),
        BlocProvider<OrdersBloc>.value(value: ordersBloc),
      ],
      child: const YumQuickApp(),
    ),
  );
}
