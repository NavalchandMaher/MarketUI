import 'package:flutter/material.dart';
import 'package:market_app/state/strategies_provider.dart';
import 'package:market_app/utils/responsive.dart';

import 'step1_basic.dart';
import 'step2_conditions.dart';
import 'step3_risk.dart';
import 'step4_review.dart';
import 'stepper_header.dart';

import 'package:provider/provider.dart';
import '../state/strategy_builder_provider.dart';

class WizardScaffold extends StatefulWidget {
  final String? strategyId;
  final bool isEdit;

  const WizardScaffold({super.key, this.strategyId, this.isEdit = false});

  @override
  State<WizardScaffold> createState() => _WizardScaffoldState();
}

class _WizardScaffoldState extends State<WizardScaffold>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep >= 3) return;

    setState(() {
      _currentStep++;
    });

    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    if (_currentStep <= 0) return;

    setState(() {
      _currentStep--;
    });

    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final builder = context.read<StrategyBuilderProvider>();
    final strategies = context.read<StrategiesProvider>();

    bool success;

    if (widget.isEdit) {
      success = await strategies.updateStrategyFromPayload(
        widget.strategyId!,
        builder.toPayload(),
      );
    } else {
      success = await strategies.createStrategyFromPayload(builder.toPayload());
    }

    if (!mounted) return;

    if (success) {
      if (widget.isEdit) {
        await strategies.loadStrategies(forceRefresh: true);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEdit
                ? "Strategy updated successfully"
                : "Strategy created successfully",
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strategies.errorMessage ?? "Failed to save strategy"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF0B1220),
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,

      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),

      titleSpacing: 0,

      title: Row(
        children: [
          Expanded(
            child: Text(
              widget.isEdit ? "Edit Strategy" : "New Strategy Builder",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  size: 16,
                  color: Color(0xFF3B82F6),
                ),
                SizedBox(width: 4),
                Text(
                  "Scalping",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          tooltip: "Save Draft",
          onPressed: () {},
          icon: const Icon(Icons.save_outlined, color: Colors.white),
        ),

        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final horizontalMargin = isMobile ? 12.0 : 20.0;
    final bottomSpacing = isMobile ? 16.0 : 20.0;
    final buttonGap = isMobile ? 10.0 : 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: _buildAppBar(),

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: isMobile ? 12 : 8),

            StepperHeader(step: _currentStep),

            SizedBox(height: isMobile ? 16 : 20),

            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                clipBehavior: Clip.antiAlias,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),

                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },

                  children: const [
                    Step1Basic(),
                    Step2Conditions(),
                    Step3Risk(),
                    Step4Review(),
                  ],
                ),
              ),
            ),

            SizedBox(height: bottomSpacing),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF111827),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentStep == 0 ? null : _previousStep,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text("Back"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF3B82F6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: buttonGap),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_currentStep == 3) {
                          await _finish();
                        } else {
                          _nextStep();
                        }
                      },
                      icon: Icon(
                        _currentStep == 3
                            ? Icons.save
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _currentStep == 3
                            ? (widget.isEdit
                                  ? "Update Strategy"
                                  : "Save Strategy")
                            : "Next",
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
