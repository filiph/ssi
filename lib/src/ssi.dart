import 'dart:io';

import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;
import 'package:ssi/src/directive.dart';
import 'package:ssi/src/variables.dart';

/// A processor that expands server-side includes.
class ServerSideIncludeProcessor {
  /// The maximum number of recursions.
  static const _maxRecursionLevel = 10000;

  /// Sets whether or not the output should include verbose logging.
  /// Useful for debugging.
  final bool verbose;

  /// Sets whether or not to automatically convert markdown files to HTML.
  final bool autoMarkdown;

  /// The variables to use when processing the file.
  late final Variables variables = Variables(this);

  /// Creates a new instance of [ServerSideIncludeProcessor].
  ServerSideIncludeProcessor({
    required this.verbose,
    required this.autoMarkdown,
  });

  /// Expands the given file path. Returns the expanded content as lines.
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
      final outputString = line.replaceAllMapped(Directive.regExp, (match) {
        final directive = Directive.fromMatch(match);
        final outputLines = directive.eval(this, recursionLevel, directoryPath);
        if (outputLines.isEmpty) {
          return Directive.magicNoOutputSequence;
        }
        return outputLines.join('\n');
      });

      if (convertMarkdown) {
        markdownBuf!.writeln(outputString);
      } else {
        yield* outputString.split('\n');
      }
    }

    if (convertMarkdown) {
      var contents = markdownBuf!.toString();
      contents = md.markdownToHtml(contents);
      yield* contents.split('\n');
    }
  }
}
