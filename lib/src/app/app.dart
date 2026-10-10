import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yum_quick/src/core/di/injection.dart';
import 'package:yum_quick/src/core/theme/app_theme.dart';

import 'router.dart';

class YumQuickApp extends StatelessWidget {
  const YumQuickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: ServiceLocator.authBloc),
        BlocProvider.value(value: ServiceLocator.recipeBloc),
        BlocProvider.value(value: ServiceLocator.searchBloc),
        BlocProvider.value(value: ServiceLocator.cartBloc),
        BlocProvider.value(value: ServiceLocator.ordersBloc),
      ],
      child: MaterialApp.router(
        title: 'YumQuick Food Delivery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
