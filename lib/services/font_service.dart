import 'package:win32_registry/win32_registry.dart';

/// Enumerates installed Windows fonts via the registry.
///
/// On Windows desktop, Flutter resolves installed system fonts natively
/// (DirectWrite), so [loadFont] only verifies that the family exists; no
/// manual byte loading into the engine is required.
class FontService {
  static final Map<String, String> _fontFiles = {};
  static bool _enumerated = false;

  static const String _fontsKeyPath =
      r'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts';

  /// Installed font family names (e.g. "Arial", "Microsoft YaHei"), sorted.
  static List<String> listFontFamilies() {
    _enumerate();
    return _fontFiles.keys.where((k) => k.isNotEmpty).toList()..sort();
  }

  static void _enumerate() {
    if (_enumerated) return;
    _enumerated = true;

    try {
      final key = LOCAL_MACHINE.open(_fontsKeyPath);
      try {
        // `values` yields records of (name, RegistryValue); font entries are
        // all REG_SZ, so we only care about StringValue.
        for (final entry in key.values) {
          final value = entry.value;
          if (value is StringValue) {
            _addFont(entry.name, value.value);
          }
        }
      } finally {
        key.close();
      }
    } catch (_) {
      // Key missing or access denied — treat as "no enumerable fonts".
    }
  }

  static void _addFont(String valueName, String fileName) {
    final family = valueName
        .replaceAll(RegExp(r'\s*\((TrueType|OpenType)\)\s*$'), '')
        .trim();
    if (family.isEmpty || fileName.isEmpty) return;
    _fontFiles.putIfAbsent(family, () => fileName);
  }

  /// Verifies that [familyName] is installed. The engine picks up system
  /// fonts automatically, so nothing needs to be loaded into memory.
  static Future<bool> loadFont(String familyName) async {
    _enumerate();
    return _fontFiles.containsKey(familyName);
  }
}
