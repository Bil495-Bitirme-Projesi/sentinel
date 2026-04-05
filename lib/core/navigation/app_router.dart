import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinel/core/auth/session_storage.dart';
import 'package:sentinel/models/user_role.dart';
import 'package:sentinel/screens/admin/admin_shell.dart';
import 'package:sentinel/screens/admin/cameras/camera_form_screen.dart';
import 'package:sentinel/screens/admin/cameras/cameras_list_screen.dart';
import 'package:sentinel/screens/admin/stats/stats_screen.dart';
import 'package:sentinel/screens/admin/users/add_user_screen.dart';
import 'package:sentinel/screens/admin/users/user_detail_screen.dart';
import 'package:sentinel/screens/admin/users/users_list_screen.dart';
import 'package:sentinel/screens/login/login_screen.dart';
import 'package:sentinel/screens/operator/alerts/alert_detail_screen.dart';
import 'package:sentinel/screens/operator/alerts/alerts_list_screen.dart';
import 'package:sentinel/screens/operator/history/history_screen.dart';
import 'package:sentinel/screens/operator/operator_shell.dart';
import 'package:sentinel/screens/operator/profile/profile_screen.dart';
import 'package:sentinel/screens/splash_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route path sabitleri
// ─────────────────────────────────────────────────────────────────────────────

/// Uygulama genelinde kullanılan rota yolları.
///
/// Kullanım örnekleri:
///   context.go(AppRoutes.login)
///   context.go(AppRoutes.opAlertDetail('42'))
///   context.go(AppRoutes.adminCameraEdit('5'))
abstract class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login  = '/login';

  // ── Operator ──────────────────────────────────────────────────────────────
  static const opAlerts  = '/operator/alerts';
  static const opHistory = '/operator/history';
  static const opProfile = '/operator/profile';

  /// Alert detay: /operator/alerts/<id>
  static String opAlertDetail(String id) => '/operator/alerts/$id';

  // ── Admin ─────────────────────────────────────────────────────────────────
  static const adminCameras   = '/admin/cameras';
  static const adminCameraNew = '/admin/cameras/new';
  static const adminUsers     = '/admin/users';
  static const adminUserNew   = '/admin/users/new';
  static const adminStats     = '/admin/stats';

  /// Kamera düzenleme: /admin/cameras/<id>/edit
  static String adminCameraEdit(String id) => '/admin/cameras/$id/edit';

  /// Kullanıcı detay: /admin/users/<id>
  static String adminUserDetail(String id) => '/admin/users/$id';
}

// ─────────────────────────────────────────────────────────────────────────────
// GoRouter instance
// ─────────────────────────────────────────────────────────────────────────────

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: _redirect,
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (_, __) => const SplashScreen(),
    ),

    // ── Login ────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (_, __) => const LoginScreen(),
    ),

    // ── Operator shell (3 sekme) ─────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => OperatorShell(navigationShell: shell),
      branches: [
        // Sekme 0 — Alerts
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.opAlerts,
              builder: (_, __) => const AlertsListScreen(),
              routes: [
                GoRoute(
                  // Göreceli yol: /operator/alerts/:id
                  path: ':id',
                  builder: (_, state) => AlertDetailScreen(
                    alertId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Sekme 1 — Geçmiş
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.opHistory,
              builder: (_, __) => const HistoryScreen(),
            ),
          ],
        ),

        // Sekme 2 — Profil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.opProfile,
              builder: (_, __) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Admin shell (3 sekme) ────────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (_, __, shell) => AdminShell(navigationShell: shell),
      branches: [
        // Sekme 0 — Kameralar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminCameras,
              builder: (_, __) => const CamerasListScreen(),
              routes: [
                // Yeni kamera (literal 'new' → parametre ':id'den önce eşleşir)
                GoRoute(
                  path: 'new',
                  builder: (_, __) => const CameraFormScreen(),
                ),
                // Kamera düzenleme: /admin/cameras/:id/edit
                GoRoute(
                  path: ':id/edit',
                  builder: (_, state) => CameraFormScreen(
                    cameraId: state.pathParameters['id'],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Sekme 1 — Kullanıcılar
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminUsers,
              builder: (_, __) => const UsersListScreen(),
              routes: [
                // Yeni kullanıcı
                GoRoute(
                  path: 'new',
                  builder: (_, __) => const AddUserScreen(),
                ),
                // Kullanıcı detay: /admin/users/:id
                GoRoute(
                  path: ':id',
                  builder: (_, state) => UserDetailScreen(
                    userId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Sekme 2 — İstatistik
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.adminStats,
              builder: (_, __) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ─────────────────────────────────────────────────────────────────────────────
// Redirect guard
// ─────────────────────────────────────────────────────────────────────────────

/// Her navigasyonda çalışan yetkilendirme guard'ı.
///
/// Kurallar:
/// 1. Oturum yoksa → /login (splash ve login hariç)
/// 2. Oturum varsa splash veya login'deyse → rol ana sayfasına yönlendir
/// 3. Aksi halde yönlendirme yok (null döner)
String? _redirect(BuildContext context, GoRouterState state) {
  final loggedIn = SessionStorage.isLoggedIn;
  final location = state.uri.toString();

  // Oturum yoksa: sadece /login erişilebilir
  if (!loggedIn && location != AppRoutes.login) {
    return AppRoutes.login;
  }

  // Oturum varsa: splash / login'den role'e göre yönlendir
  if (loggedIn && (location == AppRoutes.splash || location == AppRoutes.login)) {
    final role = SessionStorage.currentUser?.role;
    return role == UserRole.admin ? AppRoutes.adminCameras : AppRoutes.opAlerts;
  }

  return null; // Yönlendirme yok
}

