// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Texi';

  @override
  String get splashGettingLocation => 'Obteniendo tu ubicación...';

  @override
  String get loginWelcome => 'Bienvenido';

  @override
  String get loginSubtitle => 'Ingresa tu número para continuar';

  @override
  String get loginCode => 'Código';

  @override
  String get loginPhone => 'Teléfono';

  @override
  String get loginContinue => 'Continuar';

  @override
  String get loginErrorInvalidCredentials => 'No se pudo iniciar sesión. Revisa tu número.';

  @override
  String get loginPhoneRequired => 'Ingresa tu número de teléfono';

  @override
  String get homeRequestRide => 'Solicitar viaje';

  @override
  String homeNearbyDrivers(int count) {
    return '$count conductor cercano';
  }

  @override
  String get homeNearbyDriversNone => 'No hay conductores cercanos en este momento';

  @override
  String homeUpdatesEvery(int seconds) {
    return 'Se actualiza cada $seconds segundos';
  }

  @override
  String get homeLocationError => 'Activa la ubicación para ver el mapa y conductores cercanos.';

  @override
  String get homeLocationErrorGps => 'No se pudo obtener tu ubicación. Revisa el GPS.';

  @override
  String get homeRetry => 'Reintentar';

  @override
  String get tripOrigin => 'Origen';

  @override
  String get tripDestination => 'Destino';

  @override
  String get tripYourLocation => 'Tu ubicación actual';

  @override
  String get tripWherePickup => '¿Dónde te recogemos?';

  @override
  String get tripUseMyLocation => 'Usar mi ubicación actual';

  @override
  String get tripSearchAddress => 'Buscar dirección';

  @override
  String get tripChooseOnMap => 'Elegir en el mapa';

  @override
  String get tripUseAsPickup => 'Usar como punto de recogida';

  @override
  String get tripUseAsDestination => 'Usar como destino';

  @override
  String get tripMoveMapSetPickup => 'Mueve el mapa y toca el botón para fijar dónde te recogerán.';

  @override
  String get tripMoveMapSetDestination => 'Mueve el mapa y toca el botón para fijar el destino.';

  @override
  String get tripTapMapDestination => 'Toca el mapa o elige una opción abajo';

  @override
  String get tripSeePrices => 'Ver precios';

  @override
  String get tripSearchPlaceholder => 'Buscar dirección...';

  @override
  String get tripUseMapCenter => 'Usar esta ubicación';

  @override
  String get tripWhereTo => '¿A dónde vas?';

  @override
  String get tripSearchError => 'No se encontró la dirección';

  @override
  String get tripSearchingAddress => 'Buscando...';

  @override
  String get tripNoCoverageInZone => 'No tenemos cobertura del servicio en esta zona por el momento. Prueba en otra ubicación o acércate a una zona de servicio.';

  @override
  String get tripNoDriversAvailable => 'No hay conductores disponibles en este momento. Intenta de nuevo en unos instantes.';

  @override
  String get tripNext => 'Siguiente';

  @override
  String get quoteTitle => 'Elige tu viaje';

  @override
  String get quoteSubtitle => 'Selecciona un tipo de servicio';

  @override
  String get quotePerTrip => 'por viaje';

  @override
  String get quoteConfirm => 'Confirmar';

  @override
  String get confirmTitle => 'Confirma tu viaje';

  @override
  String get confirmFrom => 'Desde';

  @override
  String get confirmTo => 'Hasta';

  @override
  String get confirmRequestRide => 'Solicitar viaje';

  @override
  String get searchingTitle => 'Buscando conductor';

  @override
  String get searchingSubtitle => 'Estamos encontrando la mejor opción para ti';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonError => 'Algo salió mal';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get driverLoginWelcome => 'Bienvenido, conductor';

  @override
  String get driverLoginSubtitle => 'Ingresa con tu número y contraseña para comenzar a recibir viajes.';

  @override
  String get driverLoginPassword => 'Contraseña';

  @override
  String get driverLoginButton => 'Ingresar';

  @override
  String get driverLoginPhoneAndPasswordRequired => 'Ingresa tu número y contraseña';

  @override
  String get driverHomeTitle => 'Conductor';

  @override
  String get driverHomeOnlineTitle => 'Estás en línea';

  @override
  String get driverHomeOfflineTitle => 'Estás desconectado';

  @override
  String get driverHomeOnlineSubtitle => 'Los pasajeros cercanos verán tu vehículo y podrás recibir solicitudes.';

  @override
  String get driverHomeOfflineSubtitle => 'Activa el interruptor para comenzar a recibir viajes.';

  @override
  String get driverHomeRequestsTitle => 'Solicitudes de viaje';

  @override
  String get driverHomeRequestsEmpty => 'Aquí verás las solicitudes de los pasajeros\ncuando estés en línea.';

  @override
  String get driverLogout => 'Cerrar sesión';

  @override
  String get driverProfileMenu => 'Mi perfil';

  @override
  String get driverProfileTitle => 'Mi perfil';

  @override
  String get driverProfileRefreshTooltip => 'Actualizar';

  @override
  String get driverProfileRetry => 'Reintentar';

  @override
  String get driverProfileErrorNoSession => 'Sesión no disponible. Vuelve a iniciar sesión.';

  @override
  String get driverProfileErrorEmpty => 'Respuesta vacía del servidor.';

  @override
  String get driverProfileErrorBadFormat => 'No se pudo leer el perfil.';

  @override
  String get driverProfileRoleSubtitle => 'Conductor TEXI';

  @override
  String get driverProfileBadgeActive => 'Perfil activo';

  @override
  String get driverProfileBadgeSecure => 'Cuenta segura';

  @override
  String get driverProfileVerificationTitle => 'Estado de la cuenta: En revisión';

  @override
  String get driverProfileVerificationBody => 'Tu documentación fue recibida correctamente. Nuestro equipo la está validando para habilitar tu servicio lo antes posible.';

  @override
  String get driverProfileSectionPersonal => 'Información personal';

  @override
  String get driverProfileSectionContact => 'Contacto';

  @override
  String get driverProfileSectionLocation => 'Ubicación';

  @override
  String get driverProfileReadOnlyFooter => 'Por ahora estos datos son de solo lectura. Muy pronto habilitaremos la edición desde la app.';

  @override
  String get driverProfileFieldName => 'Nombre';

  @override
  String get driverProfileFieldBirthDate => 'Fecha de nacimiento';

  @override
  String get driverProfileFieldGender => 'Género';

  @override
  String get driverProfileFieldPhone => 'Teléfono';

  @override
  String get driverProfileFieldEmail => 'Correo';

  @override
  String get driverProfileFieldAddress => 'Dirección';

  @override
  String get driverProfileFieldLocality => 'Localidad';

  @override
  String get driverProfileGenderMale => 'Masculino';

  @override
  String get driverProfileGenderFemale => 'Femenino';

  @override
  String get driverProfileGenderOther => 'Otro';

  @override
  String get driverProfileValueEmpty => '—';

  @override
  String get driverOnlineErrorNoInternet => 'Sin conexión a internet. Conéctate para ponerte en línea.';

  @override
  String get driverOnlineErrorNoGps => 'Activa los permisos de ubicación para poder compartir tu posición.';

  @override
  String get driverOnlineErrorNoToken => 'Sesión inválida. Vuelve a iniciar sesión.';

  @override
  String get driverOnlineErrorSocket => 'No se pudo conectar al servidor. Intenta de nuevo.';

  @override
  String get driverOnlineErrorUnknown => 'No se pudo poner en línea. Intenta de nuevo.';

  @override
  String get driverTripInProgressTitle => 'Viaje en curso';

  @override
  String get driverTripStatusAccepted => 'Ir a recoger';

  @override
  String get driverTripStatusArrived => 'En punto de recogida';

  @override
  String get driverTripStatusStarted => 'En trayecto';

  @override
  String get driverTripStatusCompleted => 'Viaje completado';

  @override
  String get driverTripStatusCancelled => 'Viaje cancelado';

  @override
  String get driverTripStatusInProgress => 'Viaje en curso';

  @override
  String driverTripEstimatedPrice(String amount) {
    return 'Precio estimado: $amount';
  }

  @override
  String get driverTripArrivedButton => 'Llegué al punto de recogida';

  @override
  String get driverTripStartButton => 'Iniciar viaje';

  @override
  String get driverTripCompleteButton => 'Finalizar viaje';

  @override
  String get driverTripOfferTitle => 'Nueva solicitud de viaje';

  @override
  String driverTripOfferPrice(String amount) {
    return 'Precio estimado: $amount';
  }

  @override
  String driverTripOfferEta(int minutes) {
    return 'Tiempo estimado de llegada: $minutes min';
  }

  @override
  String get driverTripReject => 'Rechazar';

  @override
  String get driverTripAccept => 'Aceptar';

  @override
  String get driverMapDriverPosition => 'Tu posición';

  @override
  String get driverMapPickupPoint => 'Punto de recogida';

  @override
  String get driverMapDestinationPoint => 'Destino';

  @override
  String get driverMapCalculatingRoute => 'Calculando ruta...';
}
