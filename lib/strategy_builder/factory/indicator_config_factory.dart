import 'package:flutter/material.dart';

import '../models/indicator_definition.dart';
import '../models/strategy_models.dart';
import '../widgets/indicator_config_dialog.dart';

class IndicatorConfigFactory {
  const IndicatorConfigFactory._();

  static Future<Indicator?> open(
    BuildContext context,
    IndicatorDefinition definition,
  ) {
    return showModalBottomSheet<Indicator>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IndicatorConfigDialog(definition: definition),
    );
  }
}
