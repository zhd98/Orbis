/// App-wide settings.
///
/// [fontFamily] being `null` means "use the system default font".
class AppSettings {
  final String? fontFamily;
  final double fontSize;

  const AppSettings({this.fontFamily, this.fontSize = 16});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          other.fontFamily == fontFamily &&
          other.fontSize == fontSize;

  @override
  int get hashCode => Object.hash(fontFamily, fontSize);
}
