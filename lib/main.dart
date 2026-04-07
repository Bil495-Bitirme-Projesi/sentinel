import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:sentinel/config/app_theme.dart'; // Eski temayı kullanmadığımız için yoruma aldım
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
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,

      // İŞTE YENİ, ŞIK VE PROFESYONEL TEMAMIZ (CardThemeData olarak güncellendi)
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto', // Veya projenizde kullandığınız bir font
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
          secondary: Colors.blueAccent,
          surface: Colors.grey.shade50,
        ),

        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.deepPurple.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIconColor: Colors.deepPurple,
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}