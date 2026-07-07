import 'package:flutter/material.dart';

import '../utils/constants.dart';

class SymbolTimeframeSelector extends StatelessWidget {
  final String symbol;
  final String timeframe;
  final ValueChanged<String> onSymbolChanged;
  final ValueChanged<String> onTimeframeChanged;

  const SymbolTimeframeSelector({
    super.key,
    required this.symbol,
    required this.timeframe,
    required this.onSymbolChanged,
    required this.onTimeframeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Symbol',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: symbol,
                    isExpanded: true,
                    items: AppConstants.symbols
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onSymbolChanged(value);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Timeframe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radius),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: timeframe,
                    isExpanded: true,
                    items: ['1m', '5m', '15m', '30m', '1h', '4h', '1d']
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onTimeframeChanged(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
