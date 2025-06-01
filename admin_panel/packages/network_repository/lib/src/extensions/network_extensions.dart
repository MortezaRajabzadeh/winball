extension NetworkExtensions<T> on Future Function() {
  Future<T> withRetries({int count = 3, int secondsToWait = 5}) async {
    int initialCount = count;
    while (true) {
      try {
        if (initialCount != count) {
          await Future.delayed(Duration(seconds: secondsToWait));
        }
        return await this();
      } catch (e) {
        if (initialCount > 0) {
          initialCount--;
        } else {
          rethrow;
        }
      }
    }
  }
}
