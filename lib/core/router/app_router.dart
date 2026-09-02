import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/login/driver_login_screen.dart';
import '../../features/login/driver_password_reset_screen.dart';
import '../../features/login/driver_change_password_screen.dart';
import '../../features/login/driver_home_screen.dart';
import '../../features/login/driver_trip_history_screen.dart';
import '../../features/earnings/driver_earnings_credits_screen.dart';
import '../../features/earnings/driver_credits_topup_screen.dart';
import '../../features/club/driver_club_screen.dart';
import '../session/driver_must_change_password_gate.dart';
import '../session/driver_registration_resume_gate.dart';
import '../../features/profile/driver_profile_screen.dart';
import '../../features/profile/driver_registered_images_screen.dart';
import '../../features/registration/driver_my_vehicles_screen.dart';
import '../../features/registration/driver_registration_flow_screen.dart';
import '../../features/settings/driver_app_settings_screen.dart';
import '../session/driver_internal_tools_gate.dart';
import '../storage/driver_secure_storage.dart';

/// Clave de almacenamiento del token de conductor (misma que login).
const String _kDriverTokenKey = 'driver_token';

/// Rutas principales de la app de conductor.
/// Si existe [driver_token] en almacenamiento seguro, la app abre en /home;
/// si no, en /login. Así se evita desloguear al bloquear o minimizar el dispositivo.
class AppRouter {
  AppRouter._();

  static const String login = 'driver_login';
  static const String forgotPassword = 'driver_forgot_password';
  static const String changePassword = 'driver_change_password';
  static const String home = 'driver_home';
  static const String register = 'driver_register';
  static const String profile = 'driver_profile';
  static const String registeredImages = 'driver_registered_images';
  static const String tripHistory = 'driver_trip_history';
  static const String earningsCredits = 'driver_earnings_credits';
  static const String creditsTopup = 'driver_credits_topup';
  static const String club = 'driver_club';
  static const String myVehicles = 'driver_my_vehicles';
  static const String settings = 'driver_settings';

  static Future<bool> _hasStoredToken() async {
    try {
      final token = await DriverSecureStorage.read(
        _kDriverTokenKey,
        timeout: const Duration(seconds: 3),
      );
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('[AppRouter] Error leyendo token seguro: $e');
      return false;
    }
  }

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) async {
      final hasToken = await _hasStoredToken();
      final location = state.matchedLocation;
      if (hasToken && await DriverMustChangePasswordGate.needsChange()) {
        if (location != '/change-password') return '/change-password';
        return null;
      }
      if (location == '/change-password') {
        if (!hasToken) return '/login';
        return DriverRegistrationResumeGate.nextPostAuthLocation();
      }
      if (location == '/login' && hasToken) {
        return DriverRegistrationResumeGate.nextPostAuthLocation();
      }
      // Con token se permite /register para reanudar (p. ej. solo vehículo) sin cerrar sesión.
      if (location == '/home' && hasToken) {
        final pending = await DriverRegistrationResumeGate.registerRedirectFrom(
          location,
        );
        if (pending != null) return pending;
      }
      if (location == '/home' && !hasToken) return '/login';
      if (location == '/profile' && !hasToken) return '/login';
      if (location == '/my-vehicles' && !hasToken) return '/login';
      if (location == '/settings' && !hasToken) return '/login';
      if (location == '/earnings-credits' && !hasToken) return '/login';
      if (location == '/credits-topup' && !hasToken) return '/login';
      if (location == '/club' && !hasToken) return '/login';
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
        path: '/change-password',
        name: changePassword,
        builder: (context, state) => const DriverChangePasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: forgotPassword,
        builder: (context, state) {
          final extra = state.extra;
          var countryCode = '+591';
          var phoneLocal = '';
          if (extra is Map) {
            final m = Map<String, dynamic>.from(extra);
            final cc = m['countryCode']?.toString().trim();
            final ph = m['phoneLocal']?.toString().trim();
            if (cc != null && cc.isNotEmpty) countryCode = cc;
            if (ph != null) phoneLocal = ph;
          }
          return DriverPasswordResetScreen(
            initialCountryCode: countryCode,
            initialPhoneLocal: phoneLocal,
          );
        },
      ),
      GoRoute(
        path: '/register',
        name: register,
        builder: (context, state) {
          final extra = state.extra;
          final qpResume = state.uri.queryParameters['resumeAfterLogin'] == '1';
          final qpAddVehicle =
              state.uri.queryParameters['addVehicleOnly'] == '1';
          var resumeAfterLogin = qpResume;
          var addVehicleOnly = qpAddVehicle;
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
            key: ValueKey(
              'drv-reg|'
              '${addVehicleOnly ? 'v' : 'f'}|'
              '${resumeAfterLogin ? 'r' : 'n'}|'
              '${completeVehicleGalleryForAssetId ?? ''}|'
              '${openFromProfileStep ?? ''}',
            ),
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
        path: '/credits-topup',
        name: creditsTopup,
        builder: (context, state) => const DriverCreditsTopupScreen(),
      ),
      GoRoute(
        path: '/club',
        name: club,
        builder: (context, state) => const DriverClubScreen(),
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
