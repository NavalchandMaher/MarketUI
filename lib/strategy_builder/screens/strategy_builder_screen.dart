import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/strategy_model.dart' as legacy;
import '../../state/strategies_provider.dart';
import '../../theme/app_theme.dart';
import '../state/strategy_builder_provider.dart';
import '../widgets/wizard_scaffold.dart';
import '../models/strategy_models.dart' as builder;

class StrategyBuilderScreen extends StatefulWidget {
  final legacy.StrategyModel? strategy;

  const StrategyBuilderScreen({super.key, this.strategy});

  @override
  State<StrategyBuilderScreen> createState() => _StrategyBuilderScreenState();
}

class _StrategyBuilderScreenState extends State<StrategyBuilderScreen> {
  late final StrategyBuilderProvider _provider;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();

    final builderModel = widget.strategy != null
        ? builder.StrategyModel.fromLegacy(widget.strategy!)
        : null;

    _provider = StrategyBuilderProvider(initialStrategy: builderModel);

    if (widget.strategy != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadStrategyDetails();
      });
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _loadStrategyDetails() async {
    setState(() => _isLoadingDetails = true);
    try {
      final payload = await context
          .read<StrategiesProvider>()
          .getStrategyPayload(widget.strategy!.id);
      final strategyModel = builder.StrategyModel.fromApiPayload(payload);
      _provider.loadForEdit(
        strategyId: widget.strategy!.id,
        strategy: strategyModel,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load strategy details: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingDetails = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StrategyBuilderProvider>.value(
      value: _provider,
      child: Theme(
        data: AppTheme.darkTheme.copyWith(useMaterial3: true),
        child: Stack(
          children: [
            WizardScaffold(
              strategyId: widget.strategy?.id,
              isEdit: widget.strategy != null,
            ),
            if (_isLoadingDetails)
              Container(
                color: Colors.black.withOpacity(0.35),
                alignment: Alignment.center,
                child: const CircularProgressIndicator.adaptive(),
              ),
          ],
        ),
      ),
    );
  }
}
