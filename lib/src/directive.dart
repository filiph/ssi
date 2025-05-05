import 'package:ssi/src/directives/echo.dart';
import 'package:ssi/src/directives/include.dart';
import 'package:ssi/src/directives/set.dart';
import 'package:ssi/ssi.dart';

abstract class Directive {
  /// The regular expression that matches any directive.
  ///
  /// The first group is the directive's [name]. The next groups are
  /// the directive's parameters.
  static final RegExp regExp = RegExp(
    r'<!--#([a-z]+)\s+((?:[a-z]+="[^"]*"\s*)*)-->',
  );

  /// The regular expression that matches a directive parameter (`key="value"`).
  static final RegExp _param = RegExp(r'([a-z]+)="([^"]*)"');

  /// The directive's name. For example, `include`.
  final String name;

  /// The directive's parameters. For example, `file="foo.txt"`.
  final Map<String, String> parameters;

  /// Creates a [Directive].
  const Directive(this.name, this.parameters);

  /// Creates a [Directive] from a [Match] from [regExp].
  factory Directive.fromMatch(Match match) {
    final name = match.group(1)!;
    final paramString = match.group(2)!;

    final parameters = <String, String>{};
    final paramMatches = _param.allMatches(paramString);

    for (final paramMatch in paramMatches) {
      final key = paramMatch.group(1)!;
      final value = paramMatch.group(2)!;
      parameters[key] = value;
    }

    switch (name) {
      case 'include':
        return Include(parameters);
      case 'set':
        return Set(parameters);
      case 'echo':
        return Echo(parameters);
      default:
        throw UnimplementedError(
          'No code for directive "$name" (parameters: $parameters)',
        );
    }
  }

  /// Evaluates the directive. Returns the output lines.
  Iterable<String> eval(
    ServerSideIncludeProcessor ssi,
    int recursionLevel,
    String directoryPath,
  );

  @override
  String toString() {
    return '$runtimeType($parameters)';
  }
}
