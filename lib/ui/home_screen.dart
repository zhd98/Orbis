import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../services/font_service.dart';
import '../services/markdown_converter.dart';
import 'settings/settings_panel.dart';
import 'widgets/wysiwyg_editor.dart';

/// Minimal editor surface: a WYSIWYG area plus Open / Save / Settings actions.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    const group = XTypeGroup(
      label: 'Markdown',
      extensions: ['md', 'markdown', 'txt'],
    );
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final text = await file.readAsString();
    final delta = markdownToDelta(text);
    setState(() {
      _controller = QuillController(
        document: Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    });
  }

  Future<void> _save() async {
    const group = XTypeGroup(label: 'Markdown', extensions: ['md']);
    final path = await saveFile(
      suggestedName: 'untitled.md',
      acceptedTypeGroups: [group],
    );
    if (path == null) return;
    final markdown = deltaToMarkdown(_controller.document);
    await File(path).writeAsString(markdown);
  }

  Future<void> _openSettings() async {
    await showDialog(
      context: context,
      builder: (_) => const SettingsPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Ignis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open_outlined),
            tooltip: '打开',
            onPressed: _open,
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: '保存',
            onPressed: _save,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: WysiwygEditor(
        key: ObjectKey(_controller),
        controller: _controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        fontFamily: settings.fontFamily,
        fontSize: settings.fontSize,
      ),
    );
  }
}
