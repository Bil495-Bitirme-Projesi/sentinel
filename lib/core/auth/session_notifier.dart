import 'package:flutter/foundation.dart';

/// Oturum durumu değiştiğinde GoRouter'ın redirect guard'ını yeniden
/// tetiklemek için kullanılan [ChangeNotifier].
///
/// GoRouter'a `refreshListenable: SessionNotifier.instance` olarak verilir.
/// [AuthInterceptor] 401 aldığında [onSessionChanged()] çağırır →
/// router redirect guard'ı otomatik yeniden çalışır → login ekranına yönlenir.
class SessionNotifier extends ChangeNotifier {
  SessionNotifier._();

  static final SessionNotifier instance = SessionNotifier._();

  /// Oturum durumu değiştiğinde (login / logout / 401) çağrılır.
  void onSessionChanged() {
    notifyListeners();
  }
}

