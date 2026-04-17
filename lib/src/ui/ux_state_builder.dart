import 'package:flutter/material.dart';
import '../core/ux_controller.dart';
import '../core/ux_state.dart';
import '../utils/retry_strategy.dart';
import 'states/loading_view.dart';
import 'states/error_view.dart';
import 'states/empty_view.dart';

/// A widget that executes a [Future] and renders the appropriate UI for each
/// async state: loading, success, empty, and error.
///
/// Automatically fires [request] in `initState` and transitions between states
/// with a smooth [AnimatedSwitcher] crossfade.
///
/// ```dart
/// UxStateBuilder<List<String>>(
///   request: () async => ['A', 'B', 'C'],
///   builder: (context, items) => ListView.builder(
///     itemCount: items.length,
///     itemBuilder: (_, i) => ListTile(title: Text(items[i])),
///   ),
/// )
/// ```
class UxStateBuilder<T> extends StatefulWidget {
  /// The async function that fetches data.
  final Future<T> Function() request;

  /// Called when [request] completes with non-empty data.
  final Widget Function(BuildContext context, T data) builder;

  /// Overrides the default [LoadingView] spinner.
  final Widget? loadingWidget;

  /// Overrides the default [ErrorView]. Receives the error and a retry callback.
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
      errorBuilder;

  /// Overrides the default [EmptyView].
  final Widget? emptyWidget;

  /// Controls automatic retry behaviour on failure. Defaults to no retries.
  final RetryStrategy retryStrategy;

  /// Creates a [UxStateBuilder].
  const UxStateBuilder({
    super.key,
    required this.request,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyWidget,
    this.retryStrategy = const RetryStrategy(),
  });

  @override
  State<UxStateBuilder<T>> createState() => _UxStateBuilderState<T>();
}

class _UxStateBuilderState<T> extends State<UxStateBuilder<T>> {
  late final UxController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = UxController<T>(retryStrategy: widget.retryStrategy);
    _controller.execute(widget.request);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildForState(_controller.state),
        );
      },
    );
  }

  Widget _buildForState(UxState<T> state) {
    switch (state.status) {
      case UxStatus.idle:
      case UxStatus.loading:
        return KeyedSubtree(
          key: const ValueKey('loading'),
          child: widget.loadingWidget ?? const LoadingView(),
        );
      case UxStatus.success:
        return KeyedSubtree(
          key: const ValueKey('success'),
          child: widget.builder(context, state.data as T),
        );
      case UxStatus.empty:
        return KeyedSubtree(
          key: const ValueKey('empty'),
          child: widget.emptyWidget ?? const EmptyView(),
        );
      case UxStatus.error:
        return KeyedSubtree(
          key: const ValueKey('error'),
          child: widget.errorBuilder != null
              ? widget.errorBuilder!(
                  context, state.error!, _controller.retry)
              : ErrorView(
                  error: state.error!,
                  onRetry: _controller.retry,
                ),
        );
    }
  }
}
