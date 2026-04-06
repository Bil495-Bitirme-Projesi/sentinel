import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sentinel/core/network/cms_client.dart';

/// Firebase Cloud Messaging entegrasyonu.
///
/// Sorumluluklar:
///   1. FCM token'ını alır.
///   2. Token'ı backend'e kaydeder: POST /api/device-tokens { fcmToken }
///   3. Foreground mesaj dinleyicisini kurar.
///
/// Kullanım:
///   await NotificationService.instance.init();   // login sonrası çağrılır
///   await NotificationService.instance.unregister(); // logout öncesi
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------
  // init — izin iste + token al + backend'e kaydet
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    // İzin iste (iOS zorunlu, Android 13+ gerekli)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // Kullanıcı izin vermedi — bildirimler çalışmaz, hata fırlatma
      return;
    }

    // FCM token'ını al
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // Token yenilendiğinde otomatik güncelle
    _messaging.onTokenRefresh.listen(_registerToken);

    // Uygulama açıkken gelen mesajları dinle
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  // ---------------------------------------------------------------------------
  // unregister — logout öncesi token'ı backend'den sil (opsiyonel)
  // ---------------------------------------------------------------------------

  /// Backend'de token kaydı tutulmak istenmiyorsa logout sırasında çağrılabilir.
  /// Şimdilik sadece FCM token'ını FCM sunucusundan siler.
  Future<void> unregister() async {
    await _messaging.deleteToken();
  }

  // ---------------------------------------------------------------------------
  // private
  // ---------------------------------------------------------------------------

  /// Token'ı backend'e gönderir: POST /api/device-tokens
  Future<void> _registerToken(String token) async {
    try {
      await CmsClient.instance.post(
        '/device-tokens',
        data: {'fcmToken': token},
      );
    } catch (_) {
      // Token kaydı kritik değil — sessizce geç
    }
  }

  /// Uygulama ön plandayken gelen mesaj işleyicisi.
  /// İleride buraya in-app bildirim gösterme (banner/snackbar) eklenebilir.
  void _onForegroundMessage(RemoteMessage message) {
    // TODO: in-app bildirim göster (ör. SnackBar veya overlay banner)
    // ignore: avoid_print
    print('[FCM] Foreground mesaj: ${message.notification?.title}');
  }
}

