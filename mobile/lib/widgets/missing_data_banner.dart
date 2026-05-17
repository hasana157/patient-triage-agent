import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Yellow dismissible banner listing missing field names.
/// Renders nothing if [fields] is empty.
class MissingDataBanner extends StatefulWidget {
  const MissingDataBanner({super.key, required this.fields});
  final List<String> fields;

  @override
  State<MissingDataBanner> createState() => _MissingDataBannerState();
}

class _MissingDataBannerState extends State<MissingDataBanner> {
  bool _dismissed = false;

  @override
  void didUpdateWidget(MissingDataBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.fields != oldWidget.fields) _dismissed = false;
  }

  String _displayName(String f) =>
      f.replaceAll('_', ' ').replaceFirst(f[0], f[0].toUpperCase());

  @override
  Widget build(BuildContext context) {
    if (widget.fields.isEmpty || _dismissed) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.yellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.yellow.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.yellow, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Missing data: ${widget.fields.map(_displayName).join(', ')}',
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),
          ),
          InkWell(
            onTap: () => setState(() => _dismissed = true),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
