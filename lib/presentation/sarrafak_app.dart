import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sarrafak/app_constants.dart';
import 'package:sarrafak/presentation/ui/screens/home.dart';

import '../services/here_map_service.dart';
import 'bloc/theme_bloc.dart';

class SarrafakApp extends StatelessWidget {
  const SarrafakApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeBloc(),
      child: const SarrafakAppView(),
    );
  }
}

class SarrafakAppView extends StatefulWidget {
  const SarrafakAppView({
    Key? key,
  }) : super(key: key);

  @override
  State<SarrafakAppView> createState() => _SarrafakAppViewState();
}

class _SarrafakAppViewState extends State<SarrafakAppView> {
  @override
  void initState() {
    HereMapService.initializeHERESDK();
    super.initState();
  }

  @override
  void dispose() {
    HereMapService.disposeHERESDK();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorSchemeSeed: AppConstants.kMainColor,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorSchemeSeed: const Color(0xffecb46b),
          ),
          themeMode: state.mode == ThemingMode.light
              ? ThemeMode.light
              : ThemeMode.dark,
          home: const Home(),
        );
      },
    );
  }
}
