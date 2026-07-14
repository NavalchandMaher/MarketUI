import 'package:flutter/material.dart';

enum IndicatorFieldType { number, decimal, dropdown, toggle }

class IndicatorField {
  final String key;
  final String label;
  final IndicatorFieldType type;
  final dynamic defaultValue;
  final List<String>? options;

  const IndicatorField({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.options,
  });
}

class IndicatorDefinition {
  final String id;
  final String name;
  final String category;

  /// NEW
  final IconData icon;

  final List<IndicatorField> fields;

  const IndicatorDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.fields,
  });
}
