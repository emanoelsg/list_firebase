// app/features/auth/presentation/widgets/register_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/utils/constants/sizes.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';

class RegisterFormContainer extends StatelessWidget {
  final AuthController authController;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const RegisterFormContainer({
    super.key,
    required this.authController,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: screenHeight),
      child: Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: screenHeight * 0.06),

            /// Register Form
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter your email' : null,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) =>
                        value == null || value.isEmpty || value.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            /// Register Button
            Obx(() => _buildRegisterButton()),

            SizedBox(height: screenHeight * 0.075),

            /// Link to Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () {
                    Get.back(); // Navigate back to the login page
                  },
                  child: const Text('Sign In'),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.06),
          ],
        ),
      ),
    );
  }

  /// Builds the register button, which changes to a loading indicator
  /// based on the controller's state.
  Widget _buildRegisterButton() {
    final isLoading = authController.state.value == ControllerState.loading;

    return isLoading
        ? const CircularProgressIndicator(color: Colors.deepPurple)
        : ElevatedButton(
            key: const Key('register_button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                authController.signUp(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              }
            },
            child: const Text('Register'),
          );
  }
}