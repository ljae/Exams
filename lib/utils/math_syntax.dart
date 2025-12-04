import 'package:markdown/markdown.dart' as md;

class MathInlineSyntax extends md.InlineSyntax {
  MathInlineSyntax() : super(r'\$\$([\s\S]+?)\$\$|\$([^$]+?)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final isDisplay = match.group(1) != null;
    final content = match.group(1) ?? match.group(2) ?? '';
    
    if (content.isEmpty) return true; // Skip empty matches
    
    final element = md.Element('math', [md.Text(content)]);
    element.attributes['type'] = isDisplay ? 'display' : 'inline';
    element.attributes['raw'] = content;
    parser.addNode(element);
    return true;
  }
}

class MathBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^ *(\$\$|\\\[)'); // Matches $$ or \[ at start of line

  const MathBlockSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    final line = parser.current.content;
    
    // Check for single-line block: $$ math $$
    final match = RegExp(r'^ *(\$\$|\\\[)(.+)(\$\$|\\\]) *$').firstMatch(line);
    if (match != null) {
      parser.advance();
      final content = match.group(2) ?? '';
      final element = md.Element('math', [md.Text(content)]);
      element.attributes['type'] = 'display';
      element.attributes['raw'] = content;
      return element;
    }

    // Multi-line block
    final lines = <String>[];
    parser.advance(); // Skip opening delimiter line
    
    while (!parser.isDone) {
      final currentLine = parser.current.content;
      if (currentLine.trim() == r'$$' || currentLine.trim() == r'\]') {
        parser.advance();
        break;
      }
      lines.add(currentLine);
      parser.advance();
    }
    
    final content = lines.join('\n');
    final element = md.Element('math', [md.Text(content)]);
    element.attributes['type'] = 'display';
    element.attributes['raw'] = content;
    return element;
  }
}
