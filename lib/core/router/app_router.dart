import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../features/login/driver_login_screen.dart';
import '../../features/login/driver_home_screen.dart';
import '../../features/profile/driver_profile_screen.dart';
import '../../features/registration/driver_registration_flow_screen.dart';

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
      if (location == '/login' && hasToken) return '/home';
      // Con token se permite /register para reanudar (p. ej. solo vehículo) sin cerrar sesión.
      if (location == '/home' && !hasToken) return '/login';
      if (location == '/profile' && !hasToken) return '/login';
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
          var resumeAfterLogin = false;
          var addVehicleOnly = false;
          if (extra is bool && extra) {
            resumeAfterLogin = true;
          } else if (extra is Map) {
            final m = Map<String, dynamic>.from(extra);
            if (m['resumeAfterLogin'] == true) resumeAfterLogin = true;
            if (m['addVehicleOnly'] == true) addVehicleOnly = true;
          }
          return DriverRegistrationFlowScreen(
            resumeAfterLogin: resumeAfterLogin,
            addVehicleOnly: addVehicleOnly,
          );
        },
      ),
      GoRoute(
        path: '/home',
        name: home,
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: profile,
        builder: (context, state) => const DriverProfileScreen(),
      ),
    ],
  );
}

