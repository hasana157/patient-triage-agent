import 'package:flutter/material.dart';

/// Multi-select FilterChip grid for symptom selection.
///
/// Includes 13 predefined symptoms. Additional symptoms can be typed.
class SymptomChipSelector extends StatelessWidget {
  const SymptomChipSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// Currently selected symptom strings.
  final List<String> selected;

  /// Called when the selection changes.
  final void Function(List<String> symptoms) onChanged;

  static const List<String> defaultSymptoms = [
    'chest_pain',
    'shortness_of_breath',
    'sweating',
    'fever',
    'nausea',
    'vomiting',
    'headache',
    'dizziness',
    'weakness',
    'trauma',
    'bleeding',
    'seizure',
    'altered_consciousness',
  ];

  /// Converts a snake_case symptom name to a display label.
  static String _displayLabel(String symptom) {
    return symptom.replaceAll('_', ' ').replaceFirst(
          symptom[0],
          symptom[0].toUpperCase(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: defaultSymptoms.map((symptom) {
        final isSelected = selected.contains(symptom);
        return FilterChip(
          label: Text(_displayLabel(symptom)),
          selected: isSelected,
          onSelected: (sel) {
            final updated = List<String>.from(selected);
            if (sel) {
              updated.add(symptom);
            } else {
              updated.remove(symptom);
            }
            onChanged(updated);
          },
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
