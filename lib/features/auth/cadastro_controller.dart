import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CadastroController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var isLoading = false.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> cadastrar() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        "Erro",
        "Por favor, preencha todos os campos.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Erro",
        "As senhas não conferem.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        "Erro",
        "A senha deve ter pelo menos 6 caracteres.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Desloga imediatamente para que ele tenha que passar pela análise e logar depois
      await _auth.signOut();

      Get.defaultDialog(
        title: "Sucesso",
        middleText:
            "Cadastro realizado com sucesso! Aguarde até 5 minutos para o cadastro ser analisado e tente logar novamente.",
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(color: Colors.black),
        middleTextStyle: const TextStyle(color: Colors.black),
        textConfirm: "OK",
        confirmTextColor: Colors.white,
        buttonColor: Colors.green,
        onConfirm: () {
          Get.offAllNamed('/login');
        },
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Erro ao criar conta.";

      if (e.code == 'email-already-in-use') {
        errorMessage = 'Este e-mail já está sendo usado.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'E-mail inválido.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'A senha é muito fraca.';
      }

      Get.snackbar(
        "Erro no Cadastro",
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Ocorreu um erro inesperado: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
