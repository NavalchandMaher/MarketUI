import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market_app/utils/responsive.dart';
import '../state/strategy_builder_provider.dart';
import '../models/strategy_models.dart';

class Step1Basic extends StatefulWidget {
  final VoidCallback? onNext;
  const Step1Basic({super.key, this.onNext});

  @override
  State<Step1Basic> createState() => _Step1BasicState();
}

class _Step1BasicState extends State<Step1Basic> {
  final _nameCtl = TextEditingController();
  final _descCtl = TextEditingController();

  @override
  void dispose() {
    _nameCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StrategyBuilderProvider>(context);
    final model = provider.model;
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final sectionSpacing = isMobile ? 12.0 : 16.0;
    final fieldPadding = isMobile
        ? const EdgeInsets.symmetric(vertical: 12, horizontal: 14)
        : const EdgeInsets.symmetric(vertical: 16, horizontal: 18);
    final labelStyle = TextStyle(fontSize: isMobile ? 14 : 16);

    if (_nameCtl.text != model.name) {
      _nameCtl.text = model.name;
      _nameCtl.selection = TextSelection.collapsed(
        offset: _nameCtl.text.length,
      );
    }
    if (_descCtl.text != model.description) {
      _descCtl.text = model.description;
      _descCtl.selection = TextSelection.collapsed(
        offset: _descCtl.text.length,
      );
    }

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            SizedBox(height: isMobile ? 6 : 8),
            const Text(
              'Define the core settings of your strategy.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: sectionSpacing),
            TextField(
              controller: _nameCtl,
              decoration: InputDecoration(
                labelText: 'Strategy Name',
                filled: true,
                fillColor: const Color(0xFF0B1220),
                contentPadding: fieldPadding,
                labelStyle: labelStyle,
              ),
              onChanged: (v) => provider.updateBasic(name: v),
            ),
            SizedBox(height: sectionSpacing),
            TextField(
              controller: _descCtl,
              decoration: InputDecoration(
                labelText: 'Description',
                filled: true,
                fillColor: const Color(0xFF0B1220),
                contentPadding: fieldPadding,
                labelStyle: labelStyle,
              ),
              onChanged: (v) => provider.updateBasic(description: v),
              maxLines: 3,
            ),
            SizedBox(height: sectionSpacing),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(model.exchange),
                    initialValue: model.exchange,
                    items: ['BINANCE', 'COINBASE', 'KRAKEN']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => provider.updateBasic(exchange: v),
                    decoration: InputDecoration(
                      labelText: 'Exchange',
                      isDense: true,
                      contentPadding: fieldPadding,
                      labelStyle: labelStyle,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(model.timeframe),
                    initialValue: model.timeframe,
                    items: ['1m', '5m', '15m', '1h', '4h']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => provider.updateBasic(timeframe: v),
                    decoration: InputDecoration(
                      labelText: 'Timeframe',
                      isDense: true,
                      contentPadding: fieldPadding,
                      labelStyle: labelStyle,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sectionSpacing),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(model.strategyType),
                    initialValue: model.strategyType,
                    items: ['Scalping', 'Swing', 'Trend']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => provider.updateBasic(strategyType: v),
                    decoration: InputDecoration(
                      labelText: 'Strategy Type',
                      isDense: true,
                      contentPadding: fieldPadding,
                      labelStyle: labelStyle,
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 10 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Trading Mode'),
                      const SizedBox(height: 6),
                      ToggleButtons(
                        isSelected: [model.paperMode, model.liveMode],
                        onPressed: (i) => provider.updateBasic(
                          paperMode: i == 0,
                          liveMode: i == 1,
                        ),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Paper'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('Live'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: sectionSpacing),
            CheckboxListTile(
              title: const Text('Set as default strategy'),
              value: model.isDefault,
              onChanged: (value) =>
                  provider.updateBasic(isDefault: value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: const Color(0xFF3B82F6),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: sectionSpacing),
            const Text(
              'Templates',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _templateChip(provider, 'EMA Scalping'),
                _templateChip(provider, 'EMA Swing'),
                _templateChip(provider, 'Supertrend'),
                _templateChip(provider, 'Breakout'),
                _templateChip(provider, 'VWAP'),
                _templateChip(provider, 'MACD'),
                _templateChip(provider, 'RSI'),
                _templateChip(provider, 'Custom'),
              ],
            ),
            SizedBox(height: sectionSpacing),
            // if (widget.onNext != null)
            //   Align(
            //     alignment: Alignment.centerRight,
            //     child: ElevatedButton(
            //       onPressed: widget.onNext,
            //       child: const Text('Next'),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _templateChip(StrategyBuilderProvider provider, String label) {
    StrategyModel tmpl;
    switch (label) {
      case 'EMA Scalping':
        tmpl = StrategyModel(
          name: 'EMA Scalping',
          strategyType: 'Scalping',
          buyConditions: [],
          sellConditions: [],
        );
        break;
      case 'EMA Swing':
        tmpl = StrategyModel(name: 'EMA Swing', strategyType: 'Swing');
        break;
      case 'Supertrend':
        tmpl = StrategyModel(name: 'Supertrend', strategyType: 'Trend');
        break;
      default:
        tmpl = StrategyModel(name: label);
    }
    return ActionChip(
      backgroundColor: const Color(0xFF111827),
      label: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveBreakpoints.isMobile(context) ? 12 : 14,
        ),
      ),
      onPressed: () => provider.loadTemplate(tmpl),
    );
  }
}
