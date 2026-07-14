import 'package:flutter/material.dart';

import '../factory/indicator_config_factory.dart';
import '../factory/indicator_factory.dart';
import '../models/indicator_definition.dart';
import '../models/strategy_models.dart';

typedef IndicatorSelect = void Function(Indicator indicator);

class IndicatorLibrarySheet extends StatefulWidget {
  final IndicatorSelect onSelect;

  const IndicatorLibrarySheet({super.key, required this.onSelect});

  @override
  State<IndicatorLibrarySheet> createState() => _IndicatorLibrarySheetState();
}

class _IndicatorLibrarySheetState extends State<IndicatorLibrarySheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  String _search = "";

  final List<String> _categories = const [
    "All",
    "Trend",
    "Momentum",
    "Volume",
    "Volatility",
    "Price Action",
    "AI",
  ];

  List<IndicatorDefinition> get _allIndicators => IndicatorFactory.indicators;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,

      initialChildSize: .90,

      minChildSize: .60,

      maxChildSize: .95,

      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1220),

            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),

          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Indicator Library",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _search = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search indicators...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFF111827),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: const Color(0xFF3B82F6),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                tabs: _categories.map((e) => Tab(text: e)).toList(),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _categories.map((category) {
                    final filtered = _allIndicators.where((indicator) {
                      final matchCategory =
                          category == "All" || indicator.category == category;

                      final matchSearch =
                          _search.isEmpty ||
                          indicator.name.toLowerCase().contains(_search);

                      return matchCategory && matchSearch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          "No indicators found",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    return GridView.builder(
                      controller: scrollController,

                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,

                            crossAxisSpacing: 14,

                            mainAxisSpacing: 14,

                            childAspectRatio: 1.35,
                          ),

                      itemCount: filtered.length,

                      itemBuilder: (context, index) {
                        final indicator = filtered[index];

                        return _buildIndicatorCard(indicator);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIndicatorCard(IndicatorDefinition indicator) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () => _openIndicatorConfig(indicator),

      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),

          borderRadius: BorderRadius.circular(18),

          border: Border.all(color: Colors.white10),
        ),

        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            CircleAvatar(
              radius: 22,

              backgroundColor: const Color(0xFF3B82F6),

              child: Icon(indicator.icon, color: Colors.white),
            ),

            const SizedBox(height: 16),

            Text(
              indicator.name,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              indicator.category,

              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openIndicatorConfig(IndicatorDefinition definition) async {
    final indicator = await IndicatorConfigFactory.open(context, definition);

    if (!mounted) return;

    if (indicator != null) {
      widget.onSelect(indicator);
    }
  }

  List<IndicatorDefinition> _filterIndicators(String category) {
    return _allIndicators.where((indicator) {
      final categoryMatch = category == "All" || indicator.category == category;

      final searchMatch =
          _search.isEmpty ||
          indicator.name.toLowerCase().contains(_search.toLowerCase());

      return categoryMatch && searchMatch;
    }).toList();
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey),

          SizedBox(height: 16),

          Text(
            "No indicators found",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6),

          Text(
            "Try another search keyword",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String text, bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF3B82F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
