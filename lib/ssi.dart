import 'dart:io';

import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;
import 'package:ssi/src/directive.dart';
import 'package:ssi/src/variables.dart';

/// Exception thrown when the recursive expansion reaches its maximum
/// level (which means there's a dependency loop).
class RecursionLimitExceededException implements Exception {
  /// The maximum number of recursions.
  static int maxRecursionLevel = 10000;

  final String filePath;

  final int recursionLevel;

  /// Creates a new instance of [RecursionLimitExceededException].
  RecursionLimitExceededException(this.filePath, this.recursionLevel);

  @override
  String toString() {
    return 'Recursion limit exceeded in $filePath. '
        'A possible reason might be that you have a cycle in your '
        'includes (for example, a file is including another file, '
        'which in turn is including the first one).';
  }
}

/// A processor that expands server-side includes.
class ServerSideIncludeProcessor {
  /// A sequence of characters that signifies an empty line that should
  /// not be in the output.
  ///
  /// This is for directives such as `<!--set ... -->`, which often
  /// stand on an otherwise empty line which we don't want to have
  /// in the output.
  ///
  /// This stands in contrast to an empty line that _should_ be in the output
  /// (because it was in the input, without a directive).
  ///
  /// This is using a unicode character (`0x2602` umbrella) so that it's
  /// almost impossible to have in the input by chance.
  static String magicNoOutputSequence =
      "\u2602SSI NO OUTPUT (IF YOU SEE THIS, THE ssi TOOL HAS A BUG)\u2602";

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
  ///
  /// This includes lines that contain [magicNoOutputSequence] and which
  /// should be stripped from the final output.
  ///
  /// Throws a [RecursionLimitExceededException] if the maximum recursion
  /// level is exceeded (i.e. there's a dependency cycle).
  Iterable<String> recursiveExpand(
    String filePath,
    int recursionLevel, {
    bool convertMarkdown = false,
  }) sync* {
    if (recursionLevel > RecursionLimitExceededException.maxRecursionLevel) {
      throw RecursionLimitExceededException(filePath, recursionLevel);
    }

    final directoryPath = path.dirname(filePath);
    final file = File(filePath);

    final lines = file.readAsLinesSync();

    final markdownBuf = convertMarkdown ? StringBuffer() : null;

    for (final line in lines) {
      // Each line can have multiple directives. Here, we process all.
      final outputString = line.replaceAllMapped(Directive.regExp, (match) {
        final directive = Directive.fromMatch(match);
        final outputLines = directive.eval(this, recursionLevel, directoryPath);
        if (outputLines.isEmpty) {
          return magicNoOutputSequence;
        }
        // Since we're using the simple approach of `replaceAllMapped` here,
        // we can't return a list of lines. So we join them together.
        return outputLines.join('\n');
      });

      if (convertMarkdown) {
        markdownBuf!.writeln(outputString);
      } else {
        // Some directives will return a String that contains multiple
        // lines. We need to split them here.
        yield* outputString.split('\n');
      }
    }

    if (convertMarkdown) {
      // When converting Markdown, we need the whole contents as String.
      var contents = markdownBuf!.toString();
      contents = md.markdownToHtml(contents);
      yield* contents.split('\n');
    }
  }
}
