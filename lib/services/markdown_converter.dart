import 'package:flutter_quill/flutter_quill.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:quill_delta/quill_delta.dart';

/// Lightweight, dependency-free converters between flutter_quill [Document]
/// (Delta) and Markdown text, covering the subset used by the minimal editor:
/// headings, bold/italic, inline code, code blocks, block quotes, ordered and
/// unordered lists, links, and strikethrough.
///
/// Note: this is a first-pass implementation. Round-tripping of complex or
/// nested Markdown may not be perfect and should be refined after real-device
/// testing.

String deltaToMarkdown(Document document) {
  final ops = document.toDelta().operations;
  final sb = StringBuffer();
  String pendingPrefix = '';
  for (final op in ops) {
    if (op.data is! String) continue; // skip embeds (images, etc.)
    final text = op.data as String;
    final attrs = Map<String, dynamic>.from(op.attributes ?? const {});
    final prefix = _blockPrefix(attrs);
    final segments = text.split('\n');
    for (var i = 0; i < segments.length; i++) {
      if (i > 0) {
        sb.writeln();
        pendingPrefix = prefix;
      }
      final seg = segments[i];
      if (seg.isEmpty) continue;
      sb.write((i == 0 ? prefix : pendingPrefix) + _inline(seg, attrs));
    }
  }
  return sb.toString().trimRight() + '\n';
}

String _blockPrefix(Map<String, dynamic> attrs) {
  if (attrs['code-block'] == true) return '    ';
  final header = attrs['header'];
  if (header is int && header >= 1 && header <= 6) {
    return '#' * header + ' ';
  }
  if (attrs['blockquote'] == true) return '> ';
  if (attrs['list'] == 'ordered') return '1. ';
  if (attrs['list'] == 'bullet') return '- ';
  return '';
}

String _inline(String text, Map<String, dynamic> attrs) {
  var s = text;
  if (attrs['code'] == true) return '`$s`';
  if (attrs['link'] != null) return '[$s](${attrs['link']})';
  if (attrs['bold'] == true && attrs['italic'] == true) {
    s = '***$s***';
  } else if (attrs['bold'] == true) {
    s = '**$s**';
  } else if (attrs['italic'] == true) {
    s = '*$s*';
  }
  if (attrs['strike'] == true) s = '~~$s~~';
  return s;
}

Delta markdownToDelta(String text) {
  final doc = md.Document(extensionSet: md.ExtensionSet.gitHubFlavored);
  final nodes = doc.parseLines(text.split('\n'));
  final delta = Delta();
  for (final node in nodes) {
    _nodeToDelta(node, delta, {});
  }
  if (delta.operations.isEmpty) delta.insert('\n');
  return delta;
}

void _nodeToDelta(
  md.Node node,
  Delta delta,
  Map<String, dynamic> parentAttrs,
) {
  if (node is md.Text) {
    delta.insert(node.text, parentAttrs.isEmpty ? null : parentAttrs);
    return;
  }
  if (node is! md.Element) return;

  switch (node.tag) {
    case 'h1':
    case 'h2':
    case 'h3':
    case 'h4':
    case 'h5':
    case 'h6':
      final level = int.parse(node.tag[1]);
      _inlineChildren(node, delta, {...parentAttrs, 'header': level});
      delta.insert('\n', {'header': level});
      break;
    case 'p':
      _inlineChildren(node, delta, parentAttrs);
      delta.insert('\n');
      break;
    case 'blockquote':
      for (final child in node.children ?? const <md.Node>[]) {
        _nodeToDelta(child, delta, {...parentAttrs, 'blockquote': true});
      }
      break;
    case 'ul':
    case 'ol':
      final ordered = node.tag == 'ol';
      for (final child in node.children ?? const <md.Node>[]) {
        if (child is md.Element && child.tag == 'li') {
          final listAttr = ordered ? 'ordered' : 'bullet';
          _inlineChildren(child, delta, {...parentAttrs, 'list': listAttr});
          delta.insert('\n', {'list': listAttr});
        }
      }
      break;
    case 'pre':
      final code = _collectText(node).trimRight();
      for (final line in code.split('\n')) {
        delta.insert(line, {'code-block': true});
        delta.insert('\n', {'code-block': true});
      }
      break;
    case 'hr':
      delta.insert('\n');
      break;
    default:
      _inlineChildren(node, delta, parentAttrs);
  }
}

void _inlineChildren(
  md.Element element,
  Delta delta,
  Map<String, dynamic> attrs,
) {
  for (final child in element.children ?? const <md.Node>[]) {
    if (child is md.Text) {
      delta.insert(child.text, attrs.isEmpty ? null : attrs);
    } else if (child is md.Element) {
      final childAttrs = Map<String, dynamic>.from(attrs);
      switch (child.tag) {
        case 'strong':
          childAttrs['bold'] = true;
          break;
        case 'em':
          childAttrs['italic'] = true;
          break;
        case 'code':
          childAttrs['code'] = true;
          break;
        case 'a':
          childAttrs['link'] = child.attributes['href'];
          break;
        case 'strike':
        case 'del':
          childAttrs['strike'] = true;
          break;
      }
      _inlineChildren(child, delta, childAttrs);
    }
  }
}

String _collectText(md.Node node) {
  if (node is md.Text) return node.text;
  if (node is md.Element) {
    return (node.children ?? const <md.Node>[]).map(_collectText).join();
  }
  return '';
}
