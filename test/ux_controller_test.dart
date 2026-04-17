import 'package:flutter_test/flutter_test.dart';
import 'package:ux_state_manager/ux_state_manager.dart';

void main() {
  group('UxState', () {
    test('idle factory', () {
      final state = UxState<String>.idle();
      expect(state.isIdle, true);
      expect(state.data, null);
      expect(state.error, null);
    });

    test('loading factory', () {
      final state = UxState<String>.loading();
      expect(state.isLoading, true);
    });

    test('success factory', () {
      final state = UxState<String>.success('hello');
      expect(state.isSuccess, true);
      expect(state.data, 'hello');
    });

    test('empty factory', () {
      final state = UxState<List>.empty();
      expect(state.isEmpty, true);
    });

    test('error factory', () {
      final err = Exception('oops');
      final state = UxState<String>.error(err);
      expect(state.isError, true);
      expect(state.error, err);
    });
  });

  group('UxController', () {
    test('starts as idle', () {
      final controller = UxController<String>();
      expect(controller.state.isIdle, true);
    });

    test('execute → success', () async {
      final controller = UxController<String>();
      await controller.execute(() async => 'result');
      expect(controller.state.isSuccess, true);
      expect(controller.state.data, 'result');
    });

    test('execute → empty for empty list', () async {
      final controller = UxController<List<String>>();
      await controller.execute(() async => <String>[]);
      expect(controller.state.isEmpty, true);
    });

    test('execute → empty for empty map', () async {
      final controller = UxController<Map>();
      await controller.execute(() async => {});
      expect(controller.state.isEmpty, true);
    });

    test('execute → error on exception', () async {
      final controller = UxController<String>();
      await controller.execute(() async => throw Exception('fail'));
      expect(controller.state.isError, true);
    });

    test('retry re-runs last request', () async {
      int calls = 0;
      final controller = UxController<String>();
      await controller.execute(() async {
        calls++;
        return 'ok';
      });
      await controller.retry();
      expect(calls, 2);
      expect(controller.state.isSuccess, true);
    });

    test('reset returns to idle', () async {
      final controller = UxController<String>();
      await controller.execute(() async => 'data');
      controller.reset();
      expect(controller.state.isIdle, true);
    });

    test('RetryStrategy retries on failure', () async {
      int attempts = 0;
      final controller = UxController<String>(
        retryStrategy: const RetryStrategy(maxRetries: 2),
      );
      await controller.execute(() async {
        attempts++;
        throw Exception('fail');
      });
      expect(attempts, 3); // 1 initial + 2 retries
      expect(controller.state.isError, true);
    });

    test('notifies listeners on state change', () async {
      final controller = UxController<String>();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);
      await controller.execute(() async => 'data');
      expect(notifyCount, 2); // loading + success
    });
  });
}
