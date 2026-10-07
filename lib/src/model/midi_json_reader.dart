// @license
// Copyright (c) Audanika
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

// #############################################################################
/// Reads the values of a JSON map strictly; the `fromJson` factories of the
/// models use it.
///
/// Every read throws a [FormatException] naming the model and the key when
/// a key is missing or a value has the wrong type. A nullable type accepts
/// a missing key or null. A type may be an extension type such as
/// `MidiPortId` or `MidiTime`; the check then uses its representation type.
///
/// The reader is deliberately not exported: it is a detail of the models.
final class MidiJsonReader {
  /// Creates a reader of [json].
  ///
  /// - [json] the map to read.
  /// - [type] the name of the model in error messages.
  const MidiJsonReader(this.json, {required this.type});

  // ...........................................................................
  /// Returns the value of [key] as a [T].
  T value<T>(String key) {
    if (null is! T && !json.containsKey(key)) {
      throw FormatException('$type: "$key" is missing', json);
    }
    return _checked<T>(json[key], key);
  }

  /// Returns [convert] applied to the value of [key], or null when the key
  /// is missing or null.
  R? optional<T extends Object, R>(String key, R Function(T value) convert) {
    final value = this.value<T?>(key);
    return value == null ? null : convert(value);
  }

  /// Returns the model that [fromJson] decodes from the map of [key].
  T object<T>(String key, T Function(Map<String, Object?> json) fromJson) =>
      fromJson(value<Map<String, Object?>>(key));

  // ...........................................................................
  /// Returns the list of [key] with every item checked to be a [T].
  List<T> list<T>(String key) {
    final items = value<List<Object?>>(key);
    return [
      for (var i = 0; i < items.length; i++) _checked<T>(items[i], '$key[$i]'),
    ];
  }

  /// Returns the models that [fromJson] decodes from the list of maps of
  /// [key].
  List<T> objects<T>(
    String key,
    T Function(Map<String, Object?> json) fromJson,
  ) => [for (final item in list<Map<String, Object?>>(key)) fromJson(item)];

  // ...........................................................................
  /// Returns the string of [key] when it is one of [names].
  String oneOf(String key, List<String> names) =>
      _oneOf(value<String>(key), key, names);

  /// Returns the enum value of [values] named by the string of [key].
  E enumValue<E extends Enum>(String key, List<E> values) =>
      values.byName(oneOf(key, _names(values)));

  /// Returns the enum values of [values] named by the list of strings of
  /// [key].
  Set<E> enumSet<E extends Enum>(String key, List<E> values) {
    final names = _names(values);
    return {
      for (final name in list<String>(key))
        values.byName(_oneOf(name, key, names)),
    };
  }

  // ...........................................................................
  /// The map to read.
  final Map<String, Object?> json;

  /// The name of the model in error messages.
  final String type;

  // ...........................................................................
  /// Returns [value] as a [T] or throws naming [key].
  T _checked<T>(Object? value, String key) {
    if (value is T) return value;
    throw _invalid(key, '$T', '${value.runtimeType}');
  }

  /// Returns [name] when it is one of [names] or throws naming [key].
  String _oneOf(String name, String key, List<String> names) {
    if (names.contains(name)) return name;
    throw _invalid(key, 'one of ${names.join(', ')}', "'$name'");
  }

  /// Returns the error for a value of [key] that is [actual] instead of
  /// [expected].
  FormatException _invalid(String key, String expected, String actual) =>
      FormatException('$type: "$key" must be $expected, but is $actual', json);

  /// Returns the names of [values].
  static List<String> _names(List<Enum> values) => [
    for (final value in values) value.name,
  ];
}
