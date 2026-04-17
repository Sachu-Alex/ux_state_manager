/// A lightweight Flutter package for handling async UI states.
///
/// Usage:
/// ```dart
/// UxStateBuilder<List<String>>(
///   request: () async => ['A', 'B', 'C'],
///   builder: (context, data) => ListView.builder(
///     itemCount: data.length,
///     itemBuilder: (_, i) => ListTile(title: Text(data[i])),
///   ),
/// )
/// ```
library ux_state_manager;

export 'src/core/ux_state.dart';
export 'src/core/ux_controller.dart';
export 'src/ui/ux_state_builder.dart';
export 'src/utils/retry_strategy.dart';
