import 'package:flutter/material.dart';

import '../models/indicator_definition.dart';
import '../models/strategy_models.dart';

class IndicatorConfigDialog extends StatefulWidget {
  final IndicatorDefinition definition;

  const IndicatorConfigDialog({super.key, required this.definition});

  @override
  State<IndicatorConfigDialog> createState() => _IndicatorConfigDialogState();
}

class _IndicatorConfigDialogState extends State<IndicatorConfigDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> _values = {};

  final Map<String, TextEditingController> _controllers = {};

  IndicatorApply _applyTo = IndicatorApply.buy;

  @override
  void initState() {
    super.initState();

    for (final field in widget.definition.fields) {
      _values[field.key] = field.defaultValue;

      switch (field.type) {
        case IndicatorFieldType.number:
        case IndicatorFieldType.decimal:
          _controllers[field.key] = TextEditingController(
            text: field.defaultValue.toString(),
          );

          break;

        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,

      initialChildSize: .90,

      maxChildSize: .95,

      minChildSize: .65,

      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0B1220),

            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),

          child: SafeArea(
            top: false,

            child: Form(
              key: _formKey,

              child: ListView(
                controller: scrollController,

                padding: const EdgeInsets.all(20),

                children: [
                  Center(
                    child: Container(
                      width: 60,

                      height: 5,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,

                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    widget.definition.name,

                    style: const TextStyle(
                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.definition.category,

                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 30),

                  ...widget.definition.fields
                      .map((field) => _buildField(field))
                      .toList(),

                  const SizedBox(height: 24),

                  _buildApplyToSection(),

                  const SizedBox(height: 24),

                  _buildPreviewCard(),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text("Cancel"),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: Text("Add ${widget.definition.name}"),
                          onPressed: _saveIndicator,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(IndicatorField field) {
    switch (field.type) {
      case IndicatorFieldType.number:
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: TextFormField(
            controller: _controllers[field.key],
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Required";
              }
              return null;
            },
            onChanged: (value) {
              _values[field.key] = int.tryParse(value) ?? 0;
            },
          ),
        );

      case IndicatorFieldType.decimal:
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: TextFormField(
            controller: _controllers[field.key],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Required";
              }
              return null;
            },
            onChanged: (value) {
              _values[field.key] = double.tryParse(value) ?? 0;
            },
          ),
        );

      case IndicatorFieldType.dropdown:
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: DropdownButtonFormField<String>(
            value: _values[field.key]?.toString(),
            decoration: InputDecoration(
              labelText: field.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: field.options!
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _values[field.key] = value;
              });
            },
          ),
        );

      case IndicatorFieldType.toggle:
        return SwitchListTile(
          value: (_values[field.key] as bool?) ?? false,
          title: Text(field.label),
          onChanged: (value) {
            setState(() {
              _values[field.key] = value;
            });
          },
        );
    }
  }

  Widget _buildApplyToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Apply To",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        SegmentedButton<IndicatorApply>(
          segments: const [
            ButtonSegment(
              value: IndicatorApply.buy,
              icon: Icon(Icons.trending_up),
              label: Text("BUY"),
            ),

            ButtonSegment(
              value: IndicatorApply.sell,
              icon: Icon(Icons.trending_down),
              label: Text("SELL"),
            ),

            ButtonSegment(
              value: IndicatorApply.both,
              icon: Icon(Icons.swap_horiz),
              label: Text("BOTH"),
            ),
          ],

          selected: {_applyTo},

          onSelectionChanged: (selection) {
            setState(() {
              _applyTo = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      color: const Color(0xFF111827),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Live Preview",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Text(
              widget.definition.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),

            const SizedBox(height: 14),

            ..._values.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),

                    Text(
                      entry.value.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 30),

            Row(
              children: [
                const Expanded(
                  child: Text("Apply To", style: TextStyle(color: Colors.grey)),
                ),

                Chip(
                  backgroundColor: const Color(0xFF1F2937),
                  label: Text(_applyTo.name.toUpperCase()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveIndicator() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final indicator = Indicator(
      id: widget.definition.id,
      name: widget.definition.name,
      category: widget.definition.category,
      applyTo: _applyTo,
      parameter: IndicatorParameter(Map<String, dynamic>.from(_values)),
    );

    Navigator.of(context).pop(indicator);
  }
}
