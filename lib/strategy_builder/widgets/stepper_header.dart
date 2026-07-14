import 'package:flutter/material.dart';

class StepperHeader extends StatelessWidget {
  final int step;

  const StepperHeader({super.key, required this.step});

  static const List<String> _titles = ["Basic", "Conditions", "Risk", "Review"];

  static const List<IconData> _icons = [
    Icons.description_outlined,
    Icons.analytics_outlined,
    Icons.shield_outlined,
    Icons.check_circle_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: List.generate(_titles.length, (index) {
          final bool active = index == step;
          final bool completed = index < step;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completed
                              ? const Color(0xFF22C55E)
                              : active
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF1F2937),
                          border: Border.all(
                            color: active
                                ? const Color(0xFF60A5FA)
                                : Colors.white12,
                          ),
                        ),
                        child: Icon(
                          completed ? Icons.check : _icons[index],
                          color: Colors.white,
                          size: 22,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Step ${index + 1}",
                        style: TextStyle(
                          color: active ? Colors.white : Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _titles[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active ? Colors.white : Colors.grey.shade400,
                          fontWeight: active
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                if (index != _titles.length - 1)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 28),
                      height: 4,
                      decoration: BoxDecoration(
                        color: completed
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF1F2937),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
