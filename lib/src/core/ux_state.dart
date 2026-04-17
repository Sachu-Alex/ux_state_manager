/// Represents the current phase of an async UI operation.
enum UxStatus {
  /// No request has been started yet.
  idle,

  /// A request is in progress.
  loading,

  /// The request completed and returned non-empty data.
  success,

  /// The request completed but returned an empty result.
  empty,

  /// The request failed with an error.
  error,
}

/// Immutable snapshot of an async UI operation.
///
/// Use the factory constructors to create each state, and the boolean
/// convenience getters to branch on the current status.
///
/// ```dart
/// final state = UxState<List<String>>.success(['A', 'B']);
/// if (state.isSuccess) print(state.data); // ['A', 'B']
/// ```
class UxState<T> {
  /// The current phase of the operation.
  final UxStatus status;

  /// The result data, available when [isSuccess] is `true`.
  final T? data;

  /// The thrown error, available when [isError] is `true`.
  final Object? error;

  const UxState._({
    required this.status,
    this.data,
    this.error,
  });

  /// Creates an [idle] state — no request has started.
  factory UxState.idle() => const UxState._(status: UxStatus.idle);

  /// Creates a [loading] state — a request is in progress.
  factory UxState.loading() => const UxState._(status: UxStatus.loading);

  /// Creates a [success] state carrying [data].
  factory UxState.success(T data) =>
      UxState._(status: UxStatus.success, data: data);

  /// Creates an [empty] state — the request returned no data.
  factory UxState.empty() => const UxState._(status: UxStatus.empty);

  /// Creates an [error] state carrying the thrown [error].
  factory UxState.error(Object error) =>
      UxState._(status: UxStatus.error, error: error);

  /// `true` when [status] is [UxStatus.idle].
  bool get isIdle => status == UxStatus.idle;

  /// `true` when [status] is [UxStatus.loading].
  bool get isLoading => status == UxStatus.loading;

  /// `true` when [status] is [UxStatus.success].
  bool get isSuccess => status == UxStatus.success;

  /// `true` when [status] is [UxStatus.empty].
  bool get isEmpty => status == UxStatus.empty;

  /// `true` when [status] is [UxStatus.error].
  bool get isError => status == UxStatus.error;
}
