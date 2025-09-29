// app/features/auth/presentation/widgets/login_form.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/common/helpers/helper_functions.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/core/utils/constants/sizes.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/pages/register/register_page.dart';

/// A widget that represents the login form container.
/// It includes the email and password fields, login button, and a link to the registration page.
class LoginFormContainer extends StatelessWidget {
  final AuthController authController;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFormContainer({
    super.key,
    required this.authController,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    // Get the screen height for responsive spacing
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

            /// Login Form
            Form(
              key: formKey,
              child: Column(
                children: [
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
                        value == null || value.isEmpty ? 'Please enter your password' : null,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.05),

            /// Login Button
            _buildLoginButton(),

            SizedBox(height: screenHeight * 0.075),

            /// Link to Registration
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    THelperFunctions.navigateToScreen(
                      context,
                      const RegisterPage(),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.06),
          ],
        ),
      ),
    );
  }

  /// Builds the login button, which changes to a loading indicator
  /// based on the controller's state.
  Widget _buildLoginButton() {
    return Obx(() {
      final isLoading = authController.state.value == ControllerState.loading;

      return isLoading
          ? const CircularProgressIndicator(color: Colors.deepPurple)
          : ElevatedButton(
              key: const Key('login_button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  authController.loginWithEmail(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                }
              },
              child: const Text('Login'),
            );
    });
  }
}