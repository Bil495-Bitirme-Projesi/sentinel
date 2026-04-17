import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sentinel/core/network/cms_client.dart';

/// Yüksek öncelikli bildirim kanalı sabitleri.
const String _kChannelId = 'sentinel_high';
const String _kChannelName = 'Sentinel Bildirimleri';
const String _kChannelDesc = 'Anomali ve güvenlik uyarıları';

/// Background handler'dan da erişilebilmesi için top-level instance.
final FlutterLocalNotificationsPlugin flutterLocalNotifications =
    FlutterLocalNotificationsPlugin();

/// Data-only mesajları bildirim olarak gösterir
Future<void> showLocalNotification(RemoteMessage message) async {
  final title = message.data['title'] as String? ??
      message.notification?.title ??
      'Sentinel';
  final body = message.data['body'] as String? ??
      message.notification?.body ??
      '';

  const androidDetails = AndroidNotificationDetails(
    _kChannelId,
    _kChannelName,
    channelDescription: _kChannelDesc,
    importance: Importance.high,
    priority: Priority.high,
    // Heads-up (floating banner) için showWhen ve ticker gerekli değil,
    // yüksek importance yeterli.
  );

  await flutterLocalNotifications.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(android: androidDetails),
  );
}

/// Firebase Cloud Messaging entegrasyonu.
///
/// Sorumluluklar:
///   1. IMPORTANCE_HIGH bildirim kanalı oluşturur (heads-up için zorunlu).
///   2. FCM token'ını alır ve backend'e kaydeder: POST /api/device-tokens
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
  // init — kanal kur + izin iste + token al + backend'e kaydet
  // ---------------------------------------------------------------------------

  Future<void> init() async {
    // 1. flutter_local_notifications'ı başlat ve IMPORTANCE_HIGH kanalı oluştur.
    await _initLocalNotifications();

    // 2. İzin iste (iOS zorunlu, Android 13+ gerekli)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }

    // 3. FCM token'ını al
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // Token yenilendiğinde otomatik güncelle
    _messaging.onTokenRefresh.listen(_registerToken);

    // 4. Uygulama açıkken gelen mesajları dinle
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
  }

  // ---------------------------------------------------------------------------
  // unregister — logout öncesi token'ı hem FCM'den hem backend'den sil
  // ---------------------------------------------------------------------------

  Future<void> unregister() async {
    // 1. Backend'deki token kaydını sil: DELETE /device-tokens
    //    Non-2xx veya ağ hatası → sessizce geç; FCM tarafı token'ı
    //    geçersiz kılacağından dangling kayıt bir süre sonra kendiliğinden ölür.
    try {
      await CmsClient.instance.delete('/device-tokens');
    } catch (_) {
      // ignore: avoid_print
      print('[FCM] unregister: backend token silme başarısız (sessizce geçildi)');
    }

    // 2. FCM tarafında token'ı geçersiz kıl.
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // ignore: avoid_print
      print('[FCM] unregister: FCM token silme başarısız (sessizce geçildi)');
    }
  }

  // ---------------------------------------------------------------------------
  // private
  // ---------------------------------------------------------------------------

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotifications.initialize(initSettings);

    // Android 8.0+ için kanal oluştur — IMPORTANCE_HIGH = heads-up (floating banner).
    const channel = AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.high,
    );

    await flutterLocalNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

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
  /// FCM foreground'da bildirim göstermez — flutter_local_notifications ile gösteriyoruz.
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    // ignore: avoid_print
    print('[FCM] Foreground mesaj: ${message.notification?.title}');
    await showLocalNotification(message);
  }
}

