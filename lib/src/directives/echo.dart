import 'package:ssi/src/directive.dart';
import 'package:ssi/src/ssi.dart';

class Echo extends Directive {
  Echo(Map<String, String> parameters) : super('echo', parameters);

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
        "#echo directive's var parameter is missing: $parameters",
      );
    }

    final value = ssi.variables.get(varParam);
    yield value;
  }
}
