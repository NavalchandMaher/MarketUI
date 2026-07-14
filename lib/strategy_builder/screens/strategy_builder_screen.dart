import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/strategy_model.dart' as legacy;
import '../../theme/app_theme.dart';
import '../state/strategy_builder_provider.dart';
import '../widgets/wizard_scaffold.dart';
import '../models/strategy_models.dart' as builder;

class StrategyBuilderScreen extends StatelessWidget {
  final legacy.StrategyModel? strategy;

  const StrategyBuilderScreen({super.key, this.strategy});

  @override
  Widget build(BuildContext context) {
    final builderModel = strategy != null
        ? builder.StrategyModel.fromLegacy(strategy!)
        : null;

    return ChangeNotifierProvider(
      create: (_) => StrategyBuilderProvider(initialStrategy: builderModel),
      child: Theme(
        data: AppTheme.darkTheme.copyWith(useMaterial3: true),
        child: const WizardScaffold(),
      ),
    );
  }
}
