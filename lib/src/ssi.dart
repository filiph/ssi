import 'dart:io';

import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;
import 'package:ssi/src/directive.dart';
import 'package:ssi/src/variables.dart';

class ServerSideIncludeProcessor {
  /// The maximum number of recursions.
  static const _maxRecursionLevel = 10000;

  final bool verbose;

  final bool autoMarkdown;

  late final Variables variables = Variables(this);

  ServerSideIncludeProcessor({
    required this.verbose,
    required this.autoMarkdown,
  });

  Iterable<String> recursiveExpand(
    String filePath,
    int recursionLevel, {
    bool convertMarkdown = false,
  }) sync* {
    if (recursionLevel > _maxRecursionLevel) {
      throw StateError(
        'Maximum recursion level reached. '
        'A possible reason might be that you have a cycle in your '
        'includes (for example, a file is including another file, '
        'which in turn is including the first one).',
      );
    }

    final directoryPath = path.dirname(filePath);
    final file = File(filePath);

    final lines = file.readAsLinesSync();

    final markdownBuf = convertMarkdown ? StringBuffer() : null;

    for (final line in lines) {
      final outputLine = line.replaceAllMapped(Directive.regExp, (match) {
        final directive = Directive.fromMatch(match);
        final outputLines = directive.eval(this, recursionLevel, directoryPath);
        if (outputLines.isEmpty) {
          return Directive.magicNoOutputSequence;
        }
        return outputLines.join('\n');
      });

      if (convertMarkdown) {
        markdownBuf!.writeln(outputLine);
      } else {
        yield outputLine;
      }
    }

    if (convertMarkdown) {
      var contents = markdownBuf!.toString();
      contents = md.markdownToHtml(contents);
      yield* contents.split('\n');
    }
  }
}
