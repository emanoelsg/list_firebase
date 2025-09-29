// test/lib/app/core/base/base_state_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';


// A mock controller to test the BaseState mixin.
class TestController extends GetxController with BaseState {}

void main() {
  // Ensure GetX is in test mode to avoid real-world side effects.
  Get.testMode = true;

  late TestController controller;

  setUp(() {
    // Initialize a new controller before each test.
    controller = TestController();
    Get.put<TestController>(controller);
  });

  tearDown(() {
    // Clean up GetX state after each test.
    Get.reset();
  });

  // A testable widget wrapper to pump the test subject.
  Widget makeTestableWidget(Widget child) {
    return GetMaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('BaseState Mixin', () {
    testWidgets('should render success widget when state is success', (tester) async {
      // Set the state to success.
      controller.state.value = ControllerState.success;
      
      // Pump the widget with the onSuccess callback.
      await tester.pumpWidget(makeTestableWidget(
        controller.buildWhen(
          onSuccess: () => const Text('Success!'),
        ),
      ));

      // Expect to find the success text.
      expect(find.text('Success!'), findsOneWidget);
    });

    testWidgets('should render default loading widget when state is loading', (tester) async {
      // Set the state to loading.
      controller.state.value = ControllerState.loading;

      // Pump the widget.
      await tester.pumpWidget(makeTestableWidget(
        controller.buildWhen(
          onSuccess: () => const Text('Success!'),
        ),
      ));

      // Expect to find the default CircularProgressIndicator.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should render custom loading widget when provided', (tester) async {
      // Set the state to loading.
      controller.state.value = ControllerState.loading;

      // Pump the widget with a custom onLoading callback.
      await tester.pumpWidget(makeTestableWidget(
        controller.buildWhen(
          onSuccess: () => const Text('Success!'),
          onLoading: () => const Text('Custom Loading...'),
        ),
      ));

      // Expect to find the custom loading text.
      expect(find.text('Custom Loading...'), findsOneWidget);
    });

    testWidgets('should render default error widget when state is error', (tester) async {
      // Set the state to error and provide a message.
      controller.state.value = ControllerState.error;
      controller.errorMessage.value = 'Failed to load data.';

      // Pump the widget.
      await tester.pumpWidget(makeTestableWidget(
        controller.buildWhen(
          onSuccess: () => const Text('Success!'),
        ),
      ));

      // Expect to find the default error message and a "Try Again" button.
      expect(find.text('Failed to load data.'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should render custom error widget when provided', (tester) async {
      // Set the state to error.
      controller.state.value = ControllerState.error;
      controller.errorMessage.value = 'Failed to load data.';

      // Pump the widget with a custom onError callback.
      await tester.pumpWidget(makeTestableWidget(
        controller.buildWhen(
          onSuccess: () => const Text('Success!'),
          onError: (message) => Text('Custom Error: $message'),
        ),
      ));

      // Expect to find the custom error message.
      expect(find.text('Custom Error: Failed to load data.'), findsOneWidget);
    });

    testWidgets('should not render anything when initial state', (tester) async {
      // The initial state should not render any of the other widgets.
      await tester.pumpWidget(makeTestableWidget(
        controller.buildWhen(
          onSuccess: () => const Text('Success!'),
          onLoading: () => const Text('Loading...'),
          onError: (message) => const Text('Error!'),
        ),
      ));

      // Expect no text or indicator from the other states.
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Success!'), findsNothing);
      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Error!'), findsNothing);
    });
  });
}