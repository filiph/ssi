import 'package:ssi/src/ssi.dart';

class Variables {
  // ignore: unused_field
  final ServerSideIncludeProcessor _ssi;

  final Map<String, String> _variables = {};

  Variables(this._ssi);

  void set(String name, String value) => _variables[name] = value;

  String get(String name) {
    if (!_variables.containsKey(name)) {
      throw ArgumentError(
        'Trying to access variable "$name" which has not been set.',
      );
    }
    return _variables[name]!;
  }
}
