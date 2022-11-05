import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sarrafak/presentation/ui/screens/here_home.dart';

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

class SarrafakAppView extends StatelessWidget {
  const SarrafakAppView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          /*themeMode: state.mode == ThemingMode.light
              ? ThemeMode.light
              : ThemeMode.dark,*/
          home: const HereHome(),
        );
      },
    );
  }
}
