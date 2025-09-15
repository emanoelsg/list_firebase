// app/features/auth/presentation/pages/register/register_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/register_form.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';

/// The register page, responsible for rendering the UI for new user registration.
/// It retrieves the [AuthController] and uses it to manage state.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Retrieve the AuthController instance from the dependency injection.
  final authController = Get.find<AuthController>();

  // Form and text field controllers.
  final formKey = GlobalKey<FormState>();
  final signUpNameController = TextEditingController();
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  // It's good practice to manage the confirm password controller here as well.
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // Dispose of the text controllers to prevent memory leaks.
    signUpNameController.dispose();
    signUpEmailController.dispose();
    signUpPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.07),
                Text(
                  'Register',
                  style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Create your account',
                  style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                SizedBox(height: screenHeight * 0.07),

                // Use the BaseState mixin's buildWhen method to manage UI state
                authController.buildWhen(
                  onSuccess: () => RegisterFormContainer(
                    authController: authController,
                    formKey: formKey,
                    nameController: signUpNameController,
                    emailController: signUpEmailController,
                    passwordController: signUpPasswordController,
                    // Note: The register_form.dart needs a confirmPasswordController field
                    // to validate if passwords match. I've left it commented as a reminder.
                    // confirmPasswordController: confirmPasswordController,
                  ),
                  onLoading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  onError: (message) => RegisterFormContainer(
                    authController: authController,
                    formKey: formKey,
                    nameController: signUpNameController,
                    emailController: signUpEmailController,
                    passwordController: signUpPasswordController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}