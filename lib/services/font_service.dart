import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:win32/win32.dart';

/// Enumerates installed Windows fonts (via the registry) and loads the
/// selected family into the Flutter engine so it can be used by [TextStyle].
class FontService {
  static final Map<String, String> _fontFiles = {};
  static final Set<String> _loaded = {};
  static bool _enumerated = false;

  static const String _fontsKeyPath =
      r'SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts';

  /// Installed font family names (e.g. "Arial", "Segoe UI"), sorted.
  static List<String> listFontFamilies() {
    _enumerate();
    final names = _fontFiles.keys.where((k) => k.isNotEmpty).toList()..sort();
    return names;
  }

  static void _enumerate() {
    if (_enumerated) return;
    _enumerated = true;

    final subKey = _fontsKeyPath.toNativeUtf16();
    final phk = calloc<IntPtr>();
    try {
      final rc = RegOpenKeyEx(
        HKEY_LOCAL_MACHINE,
        subKey,
        0,
        KEY_READ,
        phk,
      );
      if (rc != ERROR_SUCCESS) return;
      final hKey = phk.value;

      const int maxName = 512;
      const int maxData = 1024;
      final nameBuf = calloc<Utf16>(maxName);
      final dataBuf = calloc<Uint8>(maxData);
      final nameLen = calloc<Uint32>()..value = maxName;
      final dataLen = calloc<Uint32>()..value = maxData;
      final type = calloc<Uint32>();

      var index = 0;
      while (true) {
        nameLen.value = maxName;
        dataLen.value = maxData;
        final res = RegEnumValue(
          hKey,
          index,
          nameBuf,
          nameLen,
          nullptr,
          type,
          dataBuf,
          dataLen,
        );
        if (res != ERROR_SUCCESS) break;
        final name = nameBuf.toDartString();
        final data = dataBuf.cast<Utf16>().toDartString();
        _addFont(name, data);
        index++;
      }

      calloc.free(nameBuf);
      calloc.free(dataBuf);
      calloc.free(nameLen);
      calloc.free(dataLen);
      calloc.free(type);
      RegCloseKey(hKey);
    } finally {
      calloc.free(subKey);
      calloc.free(phk);
    }
  }

  static void _addFont(String valueName, String fileName) {
    final family = valueName
        .replaceAll(RegExp(r'\s*\((TrueType|OpenType)\)\s*$'), '')
        .trim();
    if (family.isEmpty || fileName.isEmpty) return;
    _fontFiles.putIfAbsent(family, () => fileName);
  }

  /// Loads a font family from the system Fonts folder into the Flutter engine.
  /// Returns true if the font is now available (or was already loaded).
  static Future<bool> loadFont(String familyName) async {
    if (_loaded.contains(familyName)) return true;
    _enumerate();
    final fileName = _fontFiles[familyName];
    if (fileName == null) return false;
    final file = File('C:\\Windows\\Fonts\\$fileName');
    if (!await file.exists()) return false;
    try {
      final bytes = await file.readAsBytes();
      final loader = ui.FontLoader(familyName);
      loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      await loader.load();
      _loaded.add(familyName);
      return true;
    } catch (_) {
      return false;
    }
  }
}
