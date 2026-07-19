import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market_app/utils/responsive.dart';

import '../models/strategy_models.dart';
import '../state/strategy_builder_provider.dart';
import 'indicator_library_sheet.dart';

class Step2Conditions extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final bool readOnly;

  const Step2Conditions({
    super.key,
    this.onNext,
    this.onBack,
    this.readOnly = false,
  });

  @override
  State<Step2Conditions> createState() => _Step2ConditionsState();
}

class _Step2ConditionsState extends State<Step2Conditions>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openIndicatorLibrary(bool buySide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return IndicatorLibrarySheet(
          onSelect: (indicator) {
            context.read<StrategyBuilderProvider>().addCondition(
              buySide: buySide,
              indicator: indicator,
            );

            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final provider = context.watch<StrategyBuilderProvider>();

    return Padding(
      padding: EdgeInsets.all(isMobile ? 14 : 20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(14),
              ),
              labelStyle: TextStyle(
                fontSize: isMobile ? 11 : 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(fontSize: isMobile ? 10 : 12),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.trending_up), text: "BUY CONDITIONS"),

                Tab(icon: Icon(Icons.trending_down), text: "SELL CONDITIONS"),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 16 : 20),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildConditionList(
                  buySide: true,
                  items: provider.model.buyConditions,
                ),

                _buildConditionList(
                  buySide: false,
                  items: provider.model.sellConditions,
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),

          if (!widget.readOnly)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _openIndicatorLibrary(_tabController.index == 0),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Condition"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF3B82F6)),
                      minimumSize: Size.fromHeight(isMobile ? 48 : 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildConditionList({
    required bool buySide,
    required List<Condition> items,
  }) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: isMobile ? 60 : 70,
              color: Colors.grey.shade700,
            ),
            SizedBox(height: isMobile ? 14 : 20),
            Text(
              "No Conditions Added",
              style: TextStyle(
                fontSize: isMobile ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 36),
              child: Text(
                "Tap 'Add Condition' to create your first trading rule.",
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: isMobile ? 18 : 30),
            if (!widget.readOnly)
              ElevatedButton.icon(
                onPressed: () => _openIndicatorLibrary(buySide),
                icon: const Icon(Icons.add),
                label: const Text("Add First Condition"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  minimumSize: Size(isMobile ? 180 : 220, 50),
                ),
              ),
          ],
        ),
      );
    }

    if (widget.readOnly) {
      return ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => _conditionCard(
          buySide: buySide,
          condition: items[index],
          index: index,
        ),
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        context.read<StrategyBuilderProvider>().reorderConditions(
          buySide: buySide,
          oldIndex: oldIndex,
          newIndex: newIndex,
        );
      },
      itemBuilder: (context, index) {
        final condition = items[index];

        return _conditionCard(
          buySide: buySide,
          condition: condition,
          index: index,
          key: ValueKey(condition.id),
        );
      },
    );
  }

  Widget _conditionCard({
    required bool buySide,
    required Condition condition,
    required int index,
    Key? key,
  }) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    return Card(
          key: key,
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 14),
          color: const Color(0xFF111827),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF3B82F6),
                      child: Text(
                        condition.indicator.name.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),

                    SizedBox(width: isMobile ? 10 : 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isMobile ? 0 : 0),
                          Text(
                            condition.indicator.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 15 : 17,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            condition.indicator.category,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: buySide
                            ? Colors.green.withOpacity(0.15)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        buySide ? "BUY" : "SELL",
                        style: TextStyle(
                          color: buySide ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isMobile ? 12 : 16),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 12 : 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1220),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: condition.indicator.parameter.params.entries
                        .map(
                          (entry) => Chip(
                            backgroundColor: const Color(0xFF1F2937),
                            label: Text(
                              "${entry.key} : ${entry.value}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                SizedBox(height: isMobile ? 12 : 16),

                Row(
                  children: [
                    if (!widget.readOnly) ...[
                      IconButton(
                        tooltip: "Edit",
                        onPressed: () {
                          // TODO: Open indicator configuration dialog
                        },
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      ),
                      IconButton(
                        tooltip: "Delete",
                        onPressed: () {
                          context.read<StrategyBuilderProvider>().removeCondition(
                            buySide: buySide,
                            conditionId: condition.id,
                          );
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                      const Spacer(),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_indicator,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
  }
}
