import 'package:path/path.dart' as path;
import 'package:ssi/markdown_filenames.dart';
import 'package:ssi/src/directive.dart';
import 'package:ssi/ssi.dart';

class Include extends Directive {
  Include(Map<String, String> parameters) : super('include', parameters);

  @override
  Iterable<String> eval(
    ServerSideIncludeProcessor ssi,
    int recursionLevel,
    String directoryPath,
  ) {
    if (ssi.verbose) {
      print('[VERBOSE] Evaluating $this');
    }

    final filename = parameters['file'];

    if (filename == null) {
      throw ArgumentError(
        "#include directive's file parameter is missing: $parameters",
      );
    }

    final filePath = path.join(directoryPath, filename);

    final forceMarkdown = parameters['markdown'] == 'true';

    final shouldConvertMarkdown =
        forceMarkdown || (ssi.autoMarkdown && isMarkdownPath(filePath));

    var outputLines = ssi.recursiveExpand(
      filePath,
      recursionLevel,
      convertMarkdown: shouldConvertMarkdown,
    );

    return outputLines;
  }
}
