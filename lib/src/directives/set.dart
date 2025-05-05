import 'package:ssi/src/directive.dart';
import 'package:ssi/ssi.dart';

class Set extends Directive {
  Set(Map<String, String> parameters) : super('set', parameters);

  @override
  Iterable<String> eval(
    ServerSideIncludeProcessor ssi,
    int recursionLevel,
    String directoryPath,
  ) sync* {
    if (ssi.verbose) {
      print('[VERBOSE] Evaluating $this');
    }

    final varParam = parameters['var'];

    if (varParam == null) {
      throw ArgumentError(
        "#set directive's var parameter is missing: $parameters",
      );
    }

    final valueParam = parameters['value'];

    if (valueParam == null) {
      throw ArgumentError(
        "#set directive's value parameter is missing: $parameters",
      );
    }

    ssi.variables.set(varParam, valueParam);
  }
}
