// app/core/mixins/base_state.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Enum to represent the possible states of a controller's view.
/// This is a more robust approach than using separate booleans for loading and errors.
enum ControllerState {
  initial,
  loading,
  success,
  error,
}

/// A mixin for GetX controllers to handle UI states (loading, success, error)
/// and provide a convenient way to build widgets based on these states.
mixin BaseState<T extends GetxController> {
  // A single observable to manage the controller's state.
  final Rx<ControllerState> state = ControllerState.initial.obs;
  // An observable to store an optional error message when the state is 'error'.
  final Rxn<String> errorMessage = Rxn<String>();

  /// A utility method to build widgets conditionally based on the current state.
  /// It listens to the [state] and rebuilds the UI accordingly.
  Widget buildWhen({
    required Widget Function() onSuccess,
    Widget Function()? onLoading,
    Widget Function(String)? onError,
  }) {
    return Obx(() {
      switch (state.value) {
        case ControllerState.loading:
          // If a custom loading widget is provided, use it.
          // Otherwise, show a default CircularProgressIndicator.
          return onLoading?.call() ??
              const Center(child: CircularProgressIndicator());
        
        case ControllerState.error:
          // If a custom error widget is provided, use it with the error message.
          // Otherwise, show a default error message and a "Try Again" button.
          return onError?.call(errorMessage.value ?? 'An unknown error occurred.') ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(errorMessage.value ?? 'An unknown error occurred.'),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );

        case ControllerState.success:
          // In the success state, render the main content.
          return onSuccess();

        default:
          // Default case, usually for the initial state.
          return const SizedBox.shrink();
      }
    });
  }
}