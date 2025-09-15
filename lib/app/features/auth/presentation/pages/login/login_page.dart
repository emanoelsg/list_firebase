// app/features/auth/presentation/pages/login/login_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:list_firebase/app/features/auth/presentation/controller/auth_controller.dart';
import 'package:list_firebase/app/features/auth/presentation/widgets/login_form.dart';

/// A página de login, responsável por renderizar a UI para autenticação do usuário.
/// Ela acessa o [AuthController] para gerenciar o estado da aplicação.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Acessa a instância do AuthController injetada pelo GetX.
  late final authController = Get.find<AuthController>();

  // Controladores de formulário e de texto.
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    // Descarta os controladores de texto para evitar vazamentos de memória.
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // O `Scaffold` garante que a tela ocupe toda a área disponível.
      body: Container(
        // O `BoxDecoration` define o gradiente de fundo para toda a tela.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // O `SafeArea` impede que a UI seja obscurecida pelas barras de status e navegação.
        child: SafeArea(
          // O `LayoutBuilder` permite obter as restrições de tamanho do pai (toda a tela).
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // O `ConstrainedBox` força o conteúdo a ter uma altura mínima igual à da tela,
                // garantindo que o gradiente preencha toda a área.
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Conteúdo da parte superior (títulos)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(height: 50), // Espaçamento fixo para o topo
                            Text(
                              'Login',
                              style: Theme.of(context).textTheme.headlineLarge!.apply(color: Colors.white),
                            ),
                            const SizedBox(height: 5), // Espaçamento pequeno entre os textos
                            Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.headlineSmall!.apply(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      
                      // Widget reativo para exibir o formulário, o spinner ou a mensagem de erro.
                      Obx(() {
                        if (authController.isLoading.value) {
                          return const CircularProgressIndicator(color: Colors.white);
                        } else if (authController.hasError.value) {
                           // Exibe o formulário novamente após um erro e mostra o snackbar
                           WidgetsBinding.instance.addPostFrameCallback((_) {
          
                              // Limpa o erro para não exibir o snackbar novamente em rebuilds
                              authController.hasError.value = false;
                            });
                          return LoginFormContainer(
                            authController: authController,
                            formKey: _formKey,
                            emailController: _emailCtrl,
                            passwordController: _passCtrl,
                          );
                        } else {
                          return LoginFormContainer(
                            authController: authController,
                            formKey: _formKey,
                            emailController: _emailCtrl,
                            passwordController: _passCtrl,
                          );
                        }
                      }),
                      
                      // Espaçamento na parte inferior, se necessário
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