import 'package:flutter/material.dart';
import 'package:sentinel/core/navigation/app_router.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/core/network/minio_client.dart';
import 'package:sentinel/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CmsClient.init();    // REST API: sertifika + auth interceptor
  await MinioClient.init();  // MinIO: sertifika, uzun timeout, auth yok

  // Uygulama açılışında kalıcı depodan token geri yükle.
  // SessionStorage doluysa router redirect guard, kullanıcıyı rol ana sayfasına yönlendirir.
  // Dolu değilse /login'e yönlenir.
  await AuthService.tryRestoreSession();

  runApp(const SentinelApp());
}

class SentinelApp extends StatelessWidget {
  const SentinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sentinel',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}


