import 'package:path/path.dart' as path;
import 'package:ssi/src/directive.dart';
import 'package:ssi/src/ssi.dart';

class Include extends Directive {
  Include(Map<String, String> parameters) : super('include', parameters);

  bool get shouldConvertMarkdown => parameters['markdown'] == 'true';

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

    var outputLines = ssi.recursiveExpand(
      filePath,
      recursionLevel,
      convertMarkdown: shouldConvertMarkdown,
    );

    return outputLines;
  }
}
