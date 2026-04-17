import 'package:flutter/foundation.dart';
import 'ux_state.dart';
import '../utils/retry_strategy.dart';

/// Manages the lifecycle of an async operation and exposes its [UxState].
///
/// Extend this class in your own ViewModel or use it directly via
/// [UxStateBuilder]. Notifies listeners whenever the state changes.
///
/// ```dart
/// final controller = UxController<List<String>>();
/// await controller.execute(() => api.fetchItems());
/// print(controller.state.data);
/// ```
class UxController<T> extends ChangeNotifier {
  UxState<T> _state = UxState.idle();

  /// The current [UxState] of the managed operation.
  UxState<T> get state => _state;

  Future<T> Function()? _lastRequest;

  /// Strategy applied when a request fails. Defaults to no retries.
  final RetryStrategy retryStrategy;

  /// Creates a [UxController] with an optional [retryStrategy].
  UxController({this.retryStrategy = const RetryStrategy()});

  /// Executes [request], updating [state] through loading → success/empty/error.
  ///
  /// Automatically retries up to [RetryStrategy.maxRetries] times on failure
  /// before transitioning to [UxState.error].
  Future<void> execute(Future<T> Function() request) async {
    _lastRequest = request;
    _setState(UxState.loading());

    int attempts = 0;
    while (true) {
      try {
        final result = await request();
        if (_isEmpty(result)) {
          _setState(UxState.empty());
        } else {
          _setState(UxState.success(result));
        }
        return;
      } catch (e) {
        attempts++;
        if (attempts <= retryStrategy.maxRetries) {
          if (retryStrategy.delay != null) {
            await Future.delayed(retryStrategy.delay!);
          }
          continue;
        }
        _setState(UxState.error(e));
        return;
      }
    }
  }

  /// Re-runs the last request passed to [execute].
  ///
  /// Does nothing if [execute] has never been called.
  Future<void> retry() async {
    if (_lastRequest != null) {
      await execute(_lastRequest!);
    }
  }

  /// Resets [state] back to [UxState.idle] and clears the last request.
  void reset() {
    _lastRequest = null;
    _setState(UxState.idle());
  }

  void _setState(UxState<T> newState) {
    _state = newState;
    notifyListeners();
  }

  bool _isEmpty(T value) {
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    if (value is String) return value.isEmpty;
    return false;
  }
}
