import 'package:flutter/material.dart';

import 'font_selector.dart';

/// Minimal settings dialog. For now it only exposes font selection.
class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('字体', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            FontSelector(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('完成'),
        ),
      ],
    );
  }
}
