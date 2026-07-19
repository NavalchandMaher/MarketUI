import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market_app/utils/responsive.dart';

import '../models/strategy_models.dart';
import '../state/strategy_builder_provider.dart';

class Step3Risk extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool readOnly;

  const Step3Risk({
    super.key,
    this.onNext,
    this.onBack,
    this.readOnly = false,
  });

  @override
  State<Step3Risk> createState() => _Step3RiskState();
}

class _Step3RiskState extends State<Step3Risk> {
  late TextEditingController riskController;
  late TextEditingController rrController;
  late TextEditingController dailyTradeController;
  late TextEditingController openTradeController;

  bool equityProtection = true;
  bool newsFilter = false;
  bool sessionFilter = true;
  bool drawdownLock = true;
  bool dynamicPosition = false;

  String marginMode = "Cross";
  String positionSizing = "Risk %";

  @override
  void initState() {
    super.initState();

    riskController = TextEditingController();
    rrController = TextEditingController();
    dailyTradeController = TextEditingController();
    openTradeController = TextEditingController();
  }

  @override
  void dispose() {
    riskController.dispose();
    rrController.dispose();
    dailyTradeController.dispose();
    openTradeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StrategyBuilderProvider>();
    final RiskSettings risk = provider.model.riskSettings;

    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final outerPadding = EdgeInsets.all(isMobile ? 14 : 20);
    final cardPadding = EdgeInsets.all(isMobile ? 14 : 20);
    final fieldSpacing = isMobile ? 12.0 : 16.0;
    final inputPadding = isMobile
        ? const EdgeInsets.symmetric(vertical: 12, horizontal: 12)
        : const EdgeInsets.symmetric(vertical: 16, horizontal: 14);

    riskController.text = risk.riskPerTrade.toString();
    rrController.text = risk.rr.toString();
    dailyTradeController.text = risk.maxDailyTrades.toString();
    openTradeController.text = risk.maxOpenTrades.toString();

    return SingleChildScrollView(
      padding: outerPadding,
      child: Column(
        children: [
          Card(
            color: const Color(0xFF111827),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Risk Management",
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: isMobile ? 6 : 6),

                  Text(
                    "Configure money management and protection rules.",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isMobile ? 13 : 14,
                    ),
                  ),

                  SizedBox(height: isMobile ? 18 : 24),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: riskController,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Risk %",
                            prefixIcon: const Icon(Icons.percent),
                            contentPadding: inputPadding,
                            isDense: true,
                          ),
                        ),
                      ),

                      SizedBox(width: isMobile ? 12 : 16),

                      Expanded(
                        child: TextFormField(
                          controller: rrController,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Risk Reward",
                            prefixIcon: const Icon(Icons.balance),
                            contentPadding: inputPadding,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: fieldSpacing),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: dailyTradeController,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Max Daily Trades",
                            prefixIcon: const Icon(Icons.today),
                            contentPadding: inputPadding,
                            isDense: true,
                          ),
                        ),
                      ),

                      SizedBox(width: isMobile ? 12 : 16),

                      Expanded(
                        child: TextFormField(
                          controller: openTradeController,
                          readOnly: widget.readOnly,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Max Open Trades",
                            prefixIcon: const Icon(Icons.bar_chart),
                            contentPadding: inputPadding,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: fieldSpacing),

                  DropdownButtonFormField<String>(
                    value: positionSizing,
                    decoration: const InputDecoration(
                      labelText: "Position Sizing",
                    ),
                    items: const [
                      DropdownMenuItem(value: "Risk %", child: Text("Risk %")),

                      DropdownMenuItem(value: "Fixed", child: Text("Fixed")),

                      DropdownMenuItem(
                        value: "Balance %",
                        child: Text("Balance %"),
                      ),

                      DropdownMenuItem(value: "Kelly", child: Text("Kelly")),
                    ],
                    onChanged: widget.readOnly ? null : (v) {
                      setState(() {
                        positionSizing = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: marginMode,
                    decoration: const InputDecoration(labelText: "Margin Mode"),
                    items: const [
                      DropdownMenuItem(value: "Cross", child: Text("Cross")),

                      DropdownMenuItem(
                        value: "Isolated",
                        child: Text("Isolated"),
                      ),
                    ],
                    onChanged: widget.readOnly ? null : (v) {
                      setState(() {
                        marginMode = v!;
                      });
                    },
                  ),
                  SizedBox(height: isMobile ? 20 : 28),

                  const Divider(),

                  SizedBox(height: isMobile ? 12 : 16),

                  Text(
                    "Advanced Protection",
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  SwitchListTile(
                    value: equityProtection,
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("Equity Protection"),
                    subtitle: const Text(
                      "Stop trading after account reaches daily loss.",
                    ),
                    onChanged: widget.readOnly ? null : (value) {
                      setState(() {
                        equityProtection = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    value: drawdownLock,
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("Daily Drawdown Lock"),
                    subtitle: const Text(
                      "Disable strategy after max drawdown.",
                    ),
                    onChanged: widget.readOnly ? null : (value) {
                      setState(() {
                        drawdownLock = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    value: dynamicPosition,
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("Dynamic Position Sizing"),
                    subtitle: const Text(
                      "Adjust position size according to account balance.",
                    ),
                    onChanged: widget.readOnly ? null : (value) {
                      setState(() {
                        dynamicPosition = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    value: newsFilter,
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("News Filter"),
                    subtitle: const Text(
                      "Avoid opening trades during high impact news.",
                    ),
                    onChanged: widget.readOnly ? null : (value) {
                      setState(() {
                        newsFilter = value;
                      });
                    },
                  ),

                  SwitchListTile(
                    value: sessionFilter,
                    activeColor: const Color(0xFF3B82F6),
                    title: const Text("Session Filter"),
                    subtitle: const Text(
                      "Trade only during selected market sessions.",
                    ),
                    onChanged: widget.readOnly ? null : (value) {
                      setState(() {
                        sessionFilter = value;
                      });
                    },
                  ),

                  SizedBox(height: isMobile ? 20 : 30),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1220),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Risk Summary",
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: isMobile ? 12 : 16),

                        _summaryTile(
                          "Risk Per Trade",
                          "${riskController.text} %",
                        ),

                        _summaryTile("Risk Reward", rrController.text),

                        _summaryTile("Daily Trades", dailyTradeController.text),

                        _summaryTile("Open Trades", openTradeController.text),

                        _summaryTile("Margin", marginMode),

                        _summaryTile("Position Sizing", positionSizing),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: OutlinedButton.icon(
                  //         onPressed: widget.onBack,
                  //         icon: const Icon(Icons.arrow_back),
                  //         label: const Text("Back"),
                  //         style: OutlinedButton.styleFrom(
                  //           foregroundColor: Colors.white,
                  //           minimumSize: const Size.fromHeight(54),
                  //           side: const BorderSide(color: Color(0xFF3B82F6)),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(14),
                  //           ),
                  //         ),
                  //       ),
                  //     ),

                  //     const SizedBox(width: 16),

                  //     Expanded(
                  //       child: ElevatedButton.icon(
                  //         onPressed: () {
                  //           provider.updateRisk(
                  //             RiskSettings(
                  //               riskPerTrade:
                  //                   double.tryParse(riskController.text) ?? 1,
                  //               rr: double.tryParse(rrController.text) ?? 2,
                  //               maxDailyTrades:
                  //                   int.tryParse(dailyTradeController.text) ??
                  //                   10,
                  //               maxOpenTrades:
                  //                   int.tryParse(openTradeController.text) ?? 3,
                  //             ),
                  //           );

                  //           widget.onNext?.call();
                  //         },
                  //         icon: const Icon(Icons.arrow_forward),
                  //         label: const Text("Next"),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: const Color(0xFF3B82F6),
                  //           foregroundColor: Colors.white,
                  //           minimumSize: const Size.fromHeight(54),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(14),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
