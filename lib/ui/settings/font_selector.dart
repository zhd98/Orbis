import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../../services/font_service.dart';

/// Font picker: "System default" plus every installed Windows font.
class FontSelector extends ConsumerStatefulWidget {
  const FontSelector({super.key});

  @override
  ConsumerState<FontSelector> createState() => _FontSelectorState();
}

class _FontSelectorState extends ConsumerState<FontSelector> {
  List<String> _fonts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFonts();
  }

  void _loadFonts() {
    final fonts = FontService.listFontFamilies();
    if (mounted) {
      setState(() {
        _fonts = fonts;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    if (_loading) {
      return const SizedBox(
        height: 24,
        child: LinearProgressIndicator(),
      );
    }
    return DropdownButton<String>(
      isExpanded: true,
      value: settings.fontFamily ?? '',
      hint: const Text('系统默认'),
      items: [
        const DropdownMenuItem(value: '', child: Text('系统默认')),
        ..._fonts.map(
          (f) => DropdownMenuItem(value: f, child: Text(f)),
        ),
      ],
      onChanged: (value) async {
        final family = value == '' ? null : value;
        if (family != null) {
          await FontService.loadFont(family);
        }
        ref.read(settingsProvider.notifier).setFont(family);
      },
    );
  }
}
