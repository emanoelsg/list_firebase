// app/features/auth/presentation/pages/login/login_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/login_form.dart';

/// Página de login usando BaseState para gerenciar estados de loading, sucesso e erro.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Instância do AuthController injetada pelo GetX
  final authController = Get.find<AuthController>();

  // Controladores de formulário
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Títulos
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 50),
                            Text(
                              'Login',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .apply(color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Welcome Back',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .apply(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      // Formulário reativo via BaseState
                      authController.buildWhen(
                        onSuccess: () => LoginFormContainer(
                          authController: authController,
                          formKey: _formKey,
                          emailController: _emailCtrl,
                          passwordController: _passCtrl,
                        ),
                        onLoading: () => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        onError: (message) => LoginFormContainer(
                          authController: authController,
                          formKey: _formKey,
                          emailController: _emailCtrl,
                          passwordController: _passCtrl,
                        ),
                      ),

                      const SizedBox(height: 50),
                    ],
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
