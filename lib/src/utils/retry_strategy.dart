/// Configures automatic retry behaviour for [UxController.execute].
///
/// By default no retries are attempted. Set [maxRetries] to a positive value
/// to automatically re-run the request on failure before surfacing an error.
///
/// ```dart
/// RetryStrategy(maxRetries: 3, delay: Duration(seconds: 2))
/// ```
class RetryStrategy {
  /// Maximum number of retry attempts after the first failure.
  ///
  /// Defaults to `0` (no automatic retries).
  final int maxRetries;

  /// Optional pause between each retry attempt.
  ///
  /// When `null` the next attempt starts immediately.
  final Duration? delay;

  /// Creates a [RetryStrategy].
  ///
  /// [maxRetries] defaults to `0`. [delay] is optional.
  const RetryStrategy({
    this.maxRetries = 0,
    this.delay,
  });
}
