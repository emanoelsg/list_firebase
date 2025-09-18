// app/features/auth/presentation/pages/register/register_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/core/mixins/base_state.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/register_form.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authController = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Títulos
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: screenHeight * 0.07),
                                Text(
                                  'Register',
                                  style: TextStyle( fontSize: 42, fontWeight: FontWeight.bold,)
                                  
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  'Create your account',
                                  style: TextStyle( fontSize: 28,)
                                ),
                                SizedBox(height: screenHeight * 0.07),
                              ],
                            ),
                          ),
                        ),

                        // Formulário
                        Expanded(
                          flex: 3,
                          child: Obx(() {
                            final state = authController.state.value;

                            if (state == ControllerState.loading) {
                              return const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              );
                            } else {
                              return RegisterFormContainer(
                                authController: authController,
                                formKey: formKey,
                                nameController: nameController,
                                emailController: emailController,
                                passwordController: passwordController,

                              );
                            }
                          }),
                        ),

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
