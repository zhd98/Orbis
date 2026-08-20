import 'package:win32_registry/win32_registry.dart' as wreg;

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

    wreg.RegistryKey? key;
    try {
      key = wreg.Registry.openPath(
        wreg.RegistryHive.localMachine,
        wreg.Path(_fontsKeyPath),
      );
      for (final value in key.values) {
        // Font entries are REG_SZ; skip anything else defensively.
        if (value.type != wreg.RegistryValueType.string &&
            value.type != wreg.RegistryValueType.expandString) {
          continue;
        }
        _addFont(value.name, value.asString);
      }
    } catch (_) {
      // Key missing or access denied — treat as "no enumerable fonts".
    } finally {
      key?.close();
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
