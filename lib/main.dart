import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sentinel/config/app_theme.dart';
import 'package:sentinel/core/navigation/app_router.dart';
import 'package:sentinel/core/network/cms_client.dart';
import 'package:sentinel/core/network/minio_client.dart';
import 'package:sentinel/firebase_options.dart';
import 'package:sentinel/services/auth_service.dart';
import 'package:sentinel/services/notification_service.dart';

/// Uygulama arka planda veya kapalıyken gelen FCM mesajlarını işler.
/// Top-level fonksiyon olmak ZORUNDA (sınıf içinde olamaz).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // notification payload'ı yoksa (data-only mesaj) yerel bildirim göster.
  if (message.notification == null) {
    await showLocalNotification(message);
  }
  // notification payload'ı varsa FCM zaten gösteriyor, ama kanalı bizimkiyle
  // eşleştirmek için karşılık gelen meta-data AndroidManifest'te tanımlı olmalı.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background mesaj handler'ını Firebase init'ten HEMEN SONRA kaydet.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
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
      theme: AppTheme.themeData,
      routerConfig: appRouter,
    );
  }
}
