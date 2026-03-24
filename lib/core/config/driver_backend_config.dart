/// URLs del backend de **usuarios / auth** (REST) — no confundir con Socket.IO ni con geo.
class DriverUsersBackendConfig {
  DriverUsersBackendConfig._();

  static const String baseUrl =
      'http://ec2-3-150-198-57.us-east-2.compute.amazonaws.com:8001';
}

/// Servicio de **geo** (árbol país → departamento → localidad). Host distinto al de usuarios.
class DriverGeoBackendConfig {
  DriverGeoBackendConfig._();

  static const String baseUrl =
      'http://ec2-3-18-6-233.us-east-2.compute.amazonaws.com:8003';
}
