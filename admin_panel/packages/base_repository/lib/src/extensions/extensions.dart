extension StringExtensions on String? {
  num get convertToNum {
    if (this == null) {
      return 0;
    } else {
      if (this?.isEmpty ?? true) {
        return 0;
      } else if (this!.contains('.')) {
        return double.parse(this ?? '0.0');
      } else {
        return int.parse(this ?? '0');
      }
    }
  }

  bool get isValidJson =>
      this != null &&
      this != 'Null' &&
      this != 'Null \n' &&
      this != 'Null\n' &&
      this != 'null' &&
      this != 'null\n' &&
      this != 'null \n' &&
      (this ?? '').isNotEmpty;
}

extension IntegerExtensions on num {
  bool get convertToBool => this == 0 ? false : true;
  bool get isRequestValid => toString().startsWith('2');
}

extension BooleanExtensions on bool {
  int get convertBooleanToInteger {
    return this ? 1 : 0;
  }
}
