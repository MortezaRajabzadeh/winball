class BaseExceptions implements Exception {
  final String error;
  final int? code;
  const BaseExceptions({
    required this.error,
    this.code,
  });
}
