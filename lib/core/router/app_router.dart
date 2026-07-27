import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../features/login/driver_login_screen.dart';
import '../../features/login/driver_home_screen.dart';
import '../../features/login/driver_trip_history_screen.dart';
import '../../features/earnings/driver_earnings_credits_screen.dart';
import '../session/driver_registration_resume_gate.dart';
import '../../features/profile/driver_profile_screen.dart';
import '../../features/profile/driver_registered_images_screen.dart';
import '../../features/registration/driver_my_vehicles_screen.dart';
import '../../features/registration/driver_registration_flow_screen.dart';
import '../../features/settings/driver_app_settings_screen.dart';
import '../session/driver_internal_tools_gate.dart';

/// Clave de almacenamiento del token de conductor (misma que login).
const String _kDriverTokenKey = 'driver_token';

/// Rutas principales de la app de conductor.
/// Si existe [driver_token] en almacenamiento seguro, la app abre en /home;
/// si no, en /login. Así se evita desloguear al bloquear o minimizar el dispositivo.
class AppRouter {
  AppRouter._();

  static const String login = 'driver_login';
  static const String home = 'driver_home';
  static const String register = 'driver_register';
  static const String profile = 'driver_profile';
  static const String registeredImages = 'driver_registered_images';
  static const String tripHistory = 'driver_trip_history';
  static const String earningsCredits = 'driver_earnings_credits';
  static const String myVehicles = 'driver_my_vehicles';
  static const String settings = 'driver_settings';

  static const _storage = FlutterSecureStorage();

  static Future<bool> _hasStoredToken() async {
    try {
      // Evita que Flutter quede "colgado" en el redirect inicial si en
      // algunos dispositivos FlutterSecureStorage tarda demasiado (o bloquea)
      // leyendo desde KeyStore.
      final token = await _storage
          .read(key: _kDriverTokenKey)
          .timeout(const Duration(seconds: 3));
      return token != null && token.isNotEmpty;
    } catch (e) {
      // Si hay cualquier problema con el almacenamiento seguro (casos raros
      // de KeyStore en algunos dispositivos), tratamos como "sin sesión"
      // para evitar que la app se quede en negro al arrancar.
      debugPrint('[AppRouter] Error leyendo token seguro: $e');
      return false;
    }
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) async {
      final hasToken = await _hasStoredToken();
      final location = state.matchedLocation;
      if (location == '/login' && hasToken) {
        if (await DriverRegistrationResumeGate.needsResume()) {
          return '/register?resumeAfterLogin=1';
        }
        return '/home';
      }
      // Con token se permite /register para reanudar (p. ej. solo vehículo) sin cerrar sesión.
      if (location == '/home' && hasToken) {
        if (await DriverRegistrationResumeGate.needsResume()) {
          return '/register?resumeAfterLogin=1';
        }
      }
      if (location == '/home' && !hasToken) return '/login';
      if (location == '/profile' && !hasToken) return '/login';
      if (location == '/my-vehicles' && !hasToken) return '/login';
      if (location == '/settings' && !hasToken) return '/login';
      if (location == '/earnings-credits' && !hasToken) return '/login';
      if (location == '/trip-history' && !hasToken) return '/login';
      if (location == '/registered-images') {
        if (!hasToken) return '/login';
        try {
          final allowed =
              await DriverInternalToolsGate.asyncAllowsInternalToolsRoute()
                  .timeout(const Duration(seconds: 3));
          if (!allowed) return '/home';
        } catch (e) {
          debugPrint('[AppRouter] gate imágenes internas: $e');
          return '/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: login,
        builder: (context, state) => const DriverLoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: register,
        builder: (context, state) {
          final extra = state.extra;
          final qpResume = state.uri.queryParameters['resumeAfterLogin'] == '1';
          var resumeAfterLogin = qpResume;
          var addVehicleOnly = false;
          String? completeVehicleGalleryForAssetId;
          int? openFromProfileStep;
          int? profilePreselectedCountryId;
          String? profileSectionUiStatus;
          if (extra is bool && extra) {
            resumeAfterLogin = true;
          } else if (extra is Map) {
            final m = Map<String, dynamic>.from(extra);
            if (m['resumeAfterLogin'] == true) resumeAfterLogin = true;
            if (m['addVehicleOnly'] == true) addVehicleOnly = true;
            final gid = m['completeVehicleGalleryForAssetId'];
            if (gid is String && gid.trim().isNotEmpty) {
              completeVehicleGalleryForAssetId = gid.trim();
            }
            final s = m['openFromProfileStep'] ?? m['profileOpenStep'];
            if (s is int) {
              openFromProfileStep = s;
            } else if (s is num) {
              openFromProfileStep = s.toInt();
            }
            final cid = m['profilePreselectedCountryId'] ?? m['profileCountryId'];
            if (cid is int) {
              profilePreselectedCountryId = cid;
            } else if (cid is num) {
              profilePreselectedCountryId = cid.toInt();
            }
            final ui = m['profileSectionUiStatus'] ?? m['profile_section_ui_status'];
            if (ui is String && ui.trim().isNotEmpty) {
              profileSectionUiStatus = ui.trim();
            }
          }
          return DriverRegistrationFlowScreen(
            resumeAfterLogin: resumeAfterLogin,
            addVehicleOnly: addVehicleOnly,
            completeVehicleGalleryForAssetId: completeVehicleGalleryForAssetId,
            openFromProfileStep: openFromProfileStep,
            profilePreselectedCountryId: profilePreselectedCountryId,
            profileSectionUiStatus: profileSectionUiStatus,
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: home,
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/my-vehicles',
        name: myVehicles,
        builder: (context, state) => const DriverMyVehiclesScreen(),
      ),
      GoRoute(
        path: '/trip-history',
        name: tripHistory,
        builder: (context, state) => const DriverTripHistoryScreen(),
      ),
      GoRoute(
        path: '/earnings-credits',
        name: earningsCredits,
        builder: (context, state) => const DriverEarningsCreditsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: profile,
        builder: (context, state) => const DriverProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: settings,
        builder: (context, state) => const DriverAppSettingsScreen(),
      ),
      GoRoute(
        path: '/registered-images',
        name: registeredImages,
        builder: (context, state) => const DriverRegisteredImagesScreen(),
      ),
    ],
  );
}
