// filepath: c:\Users\Win 10\Downloads\apps\list_firebase\lib\app\core\base\base_state.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

mixin BaseState<T extends GetxController> {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  Widget buildWhen({
    required Widget Function() onSuccess,
    Widget Function()? onLoading,
    Widget Function(String)? onError,
  }) {
    return Obx(() {
      if (isLoading.value) {
        return onLoading?.call() ?? 
          const Center(child: CircularProgressIndicator());
      }

      if (error.value.isNotEmpty) {
        return onError?.call(error.value) ?? 
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(error.value),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
      }

      return onSuccess();
    });
  }
}