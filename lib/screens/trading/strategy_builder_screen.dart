import 'package:flutter/material.dart';
import 'package:market_app/strategy_builder/models/strategy_models.dart';
import 'package:market_app/strategy_builder/state/strategy_builder_provider.dart';
import 'package:market_app/strategy_builder/widgets/wizard_scaffold.dart';
import 'package:provider/provider.dart';

import '../../models/strategy_model.dart' as legacy;

class StrategyBuilderScreen extends StatelessWidget {
  final legacy.StrategyModel? strategy;

  const StrategyBuilderScreen({super.key, this.strategy});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = StrategyBuilderProvider();

        // CREATE MODE
        if (strategy == null) {
          return provider;
        }

        // EDIT MODE
        provider.loadForEdit(
          strategyId: strategy!.id,
          strategy: StrategyModel.fromLegacy(strategy!),
        );

        return provider;
      },
      child: WizardScaffold(strategyId: strategy?.id, isEdit: strategy != null),
    );
  }
}
