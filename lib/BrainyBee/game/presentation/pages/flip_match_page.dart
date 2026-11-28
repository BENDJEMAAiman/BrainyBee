
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app_project/BrainyBee/game/business_logic/flip_match_cubit.dart';
import 'package:mobile_app_project/BrainyBee/game/data/flip_match_repository.dart';
import 'package:mobile_app_project/BrainyBee/game/model/game_config.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/pages/game_screen.dart';
import 'package:mobile_app_project/BrainyBee/game/presentation/pages/menu_screen.dart';

class FlipMatchPage extends StatelessWidget {
  const FlipMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FlipMatchCubit(
        FlipMatchRepository(),
      ),
      child: const _FlipMatchView(),
    );
  }
}

class _FlipMatchView extends StatefulWidget {
  const _FlipMatchView();

  @override
  State<_FlipMatchView> createState() => _FlipMatchViewState();
}

class _FlipMatchViewState extends State<_FlipMatchView> {
  GameConfig? selectedConfig;

  void _startGame(GameConfig config) {
    context.read<FlipMatchCubit>().startGame(config);

    setState(() {
      selectedConfig = config;
    });
  }

  void _exitGame() {
    final cubit = context.read<FlipMatchCubit>();

    cubit.pauseGame();

    setState(() {
      selectedConfig = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedConfig == null) {
      return MenuScreen(
        onDifficultySelected: _startGame,
      );
    }

    return GameScreen(
      config: selectedConfig!,
      onExit: _exitGame,
    );
  }
}
