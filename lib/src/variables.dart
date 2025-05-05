import 'package:ssi/ssi.dart';

/// A simple class that holds variables.
class Variables {
  // ignore: unused_field
  final ServerSideIncludeProcessor _ssi;

  final Map<String, String> _variables = {};

  Variables(this._ssi);

  /// Sets variable [name] to [value].
  void set(String name, String value) => _variables[name] = value;

  /// Gets the current value of variable [name].
  ///
  /// Throws [ArgumentError] if the variable hasn't been set
  /// (fail-fast principle).
  String get(String name) {
    if (!_variables.containsKey(name)) {
      throw ArgumentError(
        'Trying to access variable "$name" which has not been set.',
      );
    }
    return _variables[name]!;
  }
}
