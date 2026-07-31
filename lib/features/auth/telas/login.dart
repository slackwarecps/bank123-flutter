import 'package:bank123/features/auth/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  // Find the injected controller
  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: colorScheme.primary,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon/bank_icon.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bank123',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Bem-vindo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/icon/bank_icon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Email Field
                    TextField(
                      controller: controller.emailController,
                      focusNode: controller.emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'E-mail',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Obx(
                        () => FilledButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () => controller.login(),
                          child:
                              controller.isLoading.value
                                  ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text(
                                    'Entrar',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),
                      ),
                    ),
                                        const SizedBox(height: 24),
                                        const Divider(),
                                        const SizedBox(height: 16),
                                        Obx(() {
                                          if (!controller.isBiometricAllowed.value) {
                                            return const SizedBox.shrink();
                                          }
                                          return InkWell(
                                            borderRadius: BorderRadius.circular(8),
                                            onTap: () => controller.loginWithBiometrics(),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.fingerprint, color: colorScheme.primary),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Login com biometria',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: colorScheme.primary,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                        const SizedBox(height: 16),
                    
                                              TextButton(
                                                onPressed: () => Get.toNamed('/cadastro'),
                                                child: const Text('Não tem conta? Cadastre-se'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                          