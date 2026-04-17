# ux_state_manager

A lightweight Flutter package that simplifies handling async UI states — **loading**, **error**, **empty**, and **success** — with minimal boilerplate and clean architecture.

---

## Features

- **Zero dependencies** — built on Flutter's native `ChangeNotifier`
- **Automatic state management** — fires the request in `initState`, no manual wiring
- **Smooth transitions** — `AnimatedSwitcher` crossfades between states
- **Built-in retry** — manual retry button + configurable auto-retry strategy
- **Smart empty detection** — auto-detects empty `List`, `Map`, or `String` results
- **Fully customisable** — override any default UI widget

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  ux_state_manager: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:ux_state_manager/ux_state_manager.dart';

UxStateBuilder<List<String>>(
  request: () async => ['Apple', 'Banana', 'Cherry'],
  builder: (context, items) => ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) => ListTile(title: Text(items[i])),
  ),
)
```

That's it. Loading, error, and empty states are handled automatically.

---

## API Reference

### `UxStateBuilder<T>`

The primary widget. Executes a `Future` and renders the correct UI for each state.

| Parameter       | Type                                                       | Required | Description                              |
|-----------------|------------------------------------------------------------|----------|------------------------------------------|
| `request`       | `Future<T> Function()`                                     | ✅        | The async function to execute            |
| `builder`       | `Widget Function(BuildContext, T data)`                    | ✅        | Renders the success state                |
| `loadingWidget` | `Widget?`                                                  | —        | Overrides the default spinner            |
| `errorBuilder`  | `Widget Function(BuildContext, Object error, VoidCallback)`| —        | Overrides the default error view         |
| `emptyWidget`   | `Widget?`                                                  | —        | Overrides the default empty view         |
| `retryStrategy` | `RetryStrategy`                                            | —        | Configures auto-retry behaviour          |

---

### `UxController<T>`

Use directly when you need controller-level access (e.g. in a ViewModel).

```dart
final controller = UxController<List<String>>();

// Execute a request
await controller.execute(() async => fetchItems());

// Retry the last request
await controller.retry();

// Reset to idle
controller.reset();

// Read current state
print(controller.state.status); // UxStatus.success
print(controller.state.data);   // ['Apple', ...]
```

Extend it in your own ViewModel:

```dart
class ItemsViewModel extends UxController<List<Item>> {
  Future<void> load() => execute(() => itemsRepository.getAll());
}
```

---

### `UxState<T>`

Immutable state object. Created via factory constructors:

```dart
UxState.idle()
UxState.loading()
UxState.success(data)
UxState.empty()
UxState.error(exception)
```

Convenience getters: `isIdle`, `isLoading`, `isSuccess`, `isEmpty`, `isError`.

---

### `RetryStrategy`

Configures automatic retry on failure:

```dart
RetryStrategy(
  maxRetries: 3,           // Retry up to 3 times before showing error
  delay: Duration(seconds: 2), // Wait 2s between retries
)
```

Pass it to `UxStateBuilder` or `UxController`:

```dart
UxStateBuilder<List<String>>(
  request: fetchItems,
  retryStrategy: const RetryStrategy(maxRetries: 2),
  builder: (context, items) => ...,
)
```

---

## Custom UI Overrides

### Custom loading widget

```dart
UxStateBuilder<List<String>>(
  request: fetchItems,
  loadingWidget: const MySkeletonLoader(),
  builder: (context, items) => ...,
)
```

### Custom error widget

```dart
UxStateBuilder<List<String>>(
  request: fetchItems,
  errorBuilder: (context, error, retry) => Column(
    children: [
      Text('Oops: $error'),
      ElevatedButton(onPressed: retry, child: const Text('Try again')),
    ],
  ),
  builder: (context, items) => ...,
)
```

### Custom empty widget

```dart
UxStateBuilder<List<String>>(
  request: fetchItems,
  emptyWidget: const Center(child: Text('Your list is empty')),
  builder: (context, items) => ...,
)
```

---

## File Structure

```
lib/
├── ux_state_manager.dart       # Barrel export
└── src/
    ├── core/
    │   ├── ux_state.dart       # UxStatus enum + UxState<T>
    │   └── ux_controller.dart  # ChangeNotifier with execute/retry
    ├── ui/
    │   ├── ux_state_builder.dart
    │   └── states/
    │       ├── loading_view.dart
    │       ├── error_view.dart
    │       └── empty_view.dart
    └── utils/
        └── retry_strategy.dart
```

---

## License

MIT © [Seqato](https://github.com/seqato)
