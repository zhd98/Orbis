import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// A minimal WYSIWYG Markdown editor built on flutter_quill.
///
/// The chosen font family and size are applied through [DefaultStyles] so that
/// headings, paragraphs, quotes and code all honor the user's selection.
class WysiwygEditor extends StatelessWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final ScrollController scrollController;
  final String? fontFamily;
  final double fontSize;

  const WysiwygEditor({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.scrollController,
    this.fontFamily,
    required this.fontSize,
  });

  DefaultStyles _buildStyles(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;
    TextStyle s(double size, [FontWeight? w]) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: w,
          color: baseColor,
        );
    final vSpace = const VerticalSpacing(0, 6);
    final hSpace = const HorizontalSpacing(0, 0);
    DefaultTextBlockStyle block(TextStyle style) => DefaultTextBlockStyle(
          style,
          hSpace,
          vSpace,
          const VerticalSpacing(0, 0),
          null,
        );
    final mono = TextStyle(
      fontFamily: 'Consolas',
      fontSize: fontSize,
      backgroundColor: Colors.grey.withOpacity(0.12),
    );
    return DefaultStyles(
      base: block(s(fontSize)),
      paragraph: block(s(fontSize)),
      h1: block(s(fontSize * 1.8, FontWeight.bold)),
      h2: block(s(fontSize * 1.5, FontWeight.bold)),
      h3: block(s(fontSize * 1.25, FontWeight.bold)),
      h4: block(s(fontSize * 1.1, FontWeight.bold)),
      h5: block(s(fontSize, FontWeight.bold)),
      h6: block(s(fontSize * 0.9, FontWeight.bold)),
      quote: DefaultTextBlockStyle(
        s(fontSize).copyWith(
          color: baseColor.withOpacity(0.7),
          fontStyle: FontStyle.italic,
        ),
        hSpace,
        vSpace,
        const VerticalSpacing(0, 0),
        const BoxDecoration(
          border: Border(
            left: BorderSide(color: Colors.grey, width: 3),
          ),
        ),
      ),
      codeBlock: block(mono),
      code: mono,
    );
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      controller: controller,
      focusNode: focusNode,
      scrollController: scrollController,
      config: QuillEditorConfig(
        padding: const EdgeInsets.all(28),
        customStyles: _buildStyles(context),
        autoFocus: false,
        scrollable: true,
        expands: false,
      ),
    );
  }
}
