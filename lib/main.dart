import 'package:bank123/core/bindings/initial_binding.dart';
import 'package:bank123/features/auth/login_binding.dart';
import 'package:bank123/features/home/home_binding.dart';

import 'package:bank123/features/auth/telas/cadastro_page.dart';
import 'package:bank123/features/configuracao/configuracao_page.dart';
import 'package:bank123/features/perfil/perfil_page.dart';
import 'package:bank123/features/auth/telas/login.dart';
import 'package:bank123/core/telas/pagina_nao_encontrada.dart';
import 'package:bank123/core/telas/tela_de_erro.dart';
import 'package:bank123/features/transferencia/transferencia_page.dart';
import 'package:bank123/features/extrato/extrato_page.dart';
import 'package:bank123/features/home/telas/home_page.dart';
import 'package:bank123/core/telas/jailbreak_page.dart';
import 'package:bank123/core/widgets/mock_banner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bank123/core/firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:safe_device/safe_device.dart'; // Importação do pacote safe_device
import 'dart:ui';
import 'dart:io'; // Necessário para verificação de arquivos e sockets
import 'dart:async'; // Para o Timer de proteção ativa

// Verifica traços do Frida na memória do processo
Future<bool> checkFridaMemoryTrace() async {
  try {
    final file = File('/proc/self/maps');
    if (!file.existsSync()) return false;

    final content = await file.readAsString();
    final lowerContent = content.toLowerCase();

    // Assinaturas comuns do Frida e injetores
    if (lowerContent.contains('frida') ||
        lowerContent.contains('gum-js-loop') ||
        lowerContent.contains('gdbus') ||
        lowerContent.contains('linjector')) {
      debugPrint("Assinatura do Frida detectada na memória!");
      return true;
    }
  } catch (_) {}
  return false;
}

Future<bool> isFridaDetected() async {
  // 1. Verificar caminhos conhecidos do binário
  List<String> paths = [
    '/data/local/tmp/frida-server',
    '/data/local/bin/frida-server',
    '/data/local/frida-server',
    '/system/bin/frida-server',
    '/usr/bin/frida-server',
    '/data/local/tmp/re.frida.server',
  ];

  for (String path in paths) {
    try {
      if (File(path).existsSync()) {
        debugPrint("Frida detectado pelo caminho: $path");
        return true;
      }
    } catch (_) {}
  }

  // 2. Verificar porta padrão do Frida (27042)
  try {
    final socket = await Socket.connect(
      '127.0.0.1',
      27042,
      timeout: const Duration(milliseconds: 500),
    );
    socket.destroy();
    debugPrint("Frida detectado pela porta 27042");
    return true;
  } catch (_) {
    // Porta fechada
  }

  // 3. Verificar injeção na memória
  if (await checkFridaMemoryTrace()) {
    return true;
  }

  return false;
}

void startActiveProtection() {
  // Roda a cada 5 segundos
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    bool detected = await isFridaDetected();
    if (detected) {
      debugPrint("AMEAÇA DETECTADA DURANTE O USO! Encerrando aplicação.");
      exit(0); // Encerra o app abruptamente
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  bool isSecurityViolation = false;
  try {
    bool isJailBroken = await SafeDevice.isJailBroken;
    bool isFridaFound = await isFridaDetected();

    isSecurityViolation = isJailBroken || isFridaFound;
  } catch (e) {
    debugPrint("Erro ao verificar segurança: $e");
  }

  // Inicia a verificação contínua se o app passou na primeira verificação
  if (!isSecurityViolation) {
    startActiveProtection();
  }

  runApp(MainApp(isSecurityViolation: isSecurityViolation));
}

class MainApp extends StatelessWidget {
  final bool isSecurityViolation;
  const MainApp({super.key, this.isSecurityViolation = false});

  @override
  Widget build(BuildContext context) {
    const isMock = String.fromEnvironment('USE_MOCK') == 'true';

    return GetMaterialApp(
      debugShowCheckedModeBanner: true,
      initialBinding: InitialBinding(),
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => PaginaNaoEncontrada(),
      ),

      initialRoute: isSecurityViolation ? '/jailbreak' : '/',
      getPages: [
        GetPage(name: '/jailbreak', page: () => const JailbreakPage()),
        GetPage(name: '/', page: () => LoginScreen(), binding: LoginBinding()),
        GetPage(name: '/home-page', page: () => const HomePage(), binding: HomeBinding()),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
          binding: LoginBinding(),
        ),
        GetPage(name: '/cadastro', page: () => CadastroPage()),
        GetPage(name: '/perfil', page: () => const PerfilPage()),
        GetPage(name: '/configuracoes', page: () => const ConfiguracaoPage()),
        GetPage(name: '/error-page', page: () => TelaDeErro()),
        GetPage(name: '/transferencia', page: () => const TransferenciaPage()),
        GetPage(name: '/extrato', page: () => const ExtratoPage()),
      ],
      title: 'Bank 123',
      theme: ThemeData(
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      builder: (context, child) {
        if (!isMock || child == null) return child ?? const SizedBox.shrink();
        return Stack(
          children: [
            child,
            const MockBanner(),
          ],
        );
      },
    );
  }
}
