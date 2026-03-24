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
  String get driverAppTitle => 'Texi Conductor';

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
  String get loginErrorInvalidCredentials =>
      'No se pudo iniciar sesión. Revisa tu número.';

  @override
  String get loginPhoneRequired => 'Ingresa tu número de teléfono';

  @override
  String get homeRequestRide => 'Solicitar viaje';

  @override
  String homeNearbyDrivers(int count) {
    return '$count conductor cercano';
  }

  @override
  String get homeNearbyDriversNone =>
      'No hay conductores cercanos en este momento';

  @override
  String homeUpdatesEvery(int seconds) {
    return 'Se actualiza cada $seconds segundos';
  }

  @override
  String get homeLocationError =>
      'Activa la ubicación para ver el mapa y conductores cercanos.';

  @override
  String get homeLocationErrorGps =>
      'No se pudo obtener tu ubicación. Revisa el GPS.';

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
  String get tripMoveMapSetPickup =>
      'Mueve el mapa y toca el botón para fijar dónde te recogerán.';

  @override
  String get tripMoveMapSetDestination =>
      'Mueve el mapa y toca el botón para fijar el destino.';

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
  String get tripNoCoverageInZone =>
      'No tenemos cobertura del servicio en esta zona por el momento. Prueba en otra ubicación o acércate a una zona de servicio.';

  @override
  String get tripNoDriversAvailable =>
      'No hay conductores disponibles en este momento. Intenta de nuevo en unos instantes.';

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
  String get driverLoginSubtitle =>
      'Ingresa con tu número y contraseña para comenzar a recibir viajes.';

  @override
  String get driverLoginPassword => 'Contraseña';

  @override
  String get driverLoginButton => 'Ingresar';

  @override
  String get driverLoginPhoneAndPasswordRequired =>
      'Ingresa tu número y contraseña';

  @override
  String get driverLoginErrorGeneric => 'No se pudo iniciar sesión';

  @override
  String get driverLoginRegisterHint =>
      '¿No tienes credenciales? Puedes registrarte como conductor.';

  @override
  String get driverLoginRegisterCta => 'Registrarme';

  @override
  String get driverHomeTitle => 'Conductor';

  @override
  String get driverHomeOnlineTitle => 'Estás en línea';

  @override
  String get driverHomeOfflineTitle => 'Estás desconectado';

  @override
  String get driverHomeOnlineSubtitle =>
      'Los pasajeros cercanos verán tu vehículo y podrás recibir solicitudes.';

  @override
  String get driverHomeOfflineSubtitle =>
      'Activa el interruptor para comenzar a recibir viajes.';

  @override
  String get driverHomeRequestsTitle => 'Solicitudes de viaje';

  @override
  String get driverHomeRequestsEmpty =>
      'Aquí verás las solicitudes de los pasajeros\ncuando estés en línea.';

  @override
  String get driverHomeMiniStatusOnline => 'En línea';

  @override
  String get driverHomeMiniStatusOffline => 'Desconectado';

  @override
  String get driverHomeMiniConnecting => 'Conectando…';

  @override
  String get driverHomeMiniVehicleEmpty => 'Sin vehículo registrado';

  @override
  String driverHomeMiniRating(String rating) {
    return '$rating ★';
  }

  @override
  String get driverLogout => 'Cerrar sesión';

  @override
  String get driverOnlineAuthTitle => 'Confirma tu identidad';

  @override
  String get driverOnlineAuthSubtitle =>
      'Después te pediremos huella, rostro o PIN del dispositivo. Así protegemos tu cuenta al activar el servicio.';

  @override
  String get driverOnlineAuthContinue => 'Continuar';

  @override
  String get driverOnlineAuthCancel => 'Cancelar';

  @override
  String get driverOnlineAuthReasonBiometric =>
      'Confirma tu identidad para conectarte como conductor';

  @override
  String get driverOnlineAuthReasonDeviceCredential =>
      'Confirma con tu PIN o patrón para conectarte';

  @override
  String get driverOnlineAuthVerifyFailed =>
      'No se pudo verificar la identidad del dispositivo';

  @override
  String get driverProfileMenu => 'Mi perfil';

  @override
  String get driverProfileTitle => 'Mi perfil';

  @override
  String get driverProfileBack => 'Volver al inicio';

  @override
  String get driverProfileRefreshTooltip => 'Actualizar';

  @override
  String get driverProfileRetry => 'Reintentar';

  @override
  String get driverProfileErrorNoSession =>
      'Sesión no disponible. Vuelve a iniciar sesión.';

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
  String get driverProfileVerificationTitle =>
      'Estado de la cuenta: En revisión';

  @override
  String get driverProfileVerificationBody =>
      'Tu documentación fue recibida correctamente. Nuestro equipo la está validando para habilitar tu servicio lo antes posible.';

  @override
  String get driverProfileSectionPersonal => 'Información personal';

  @override
  String get driverProfileSectionContact => 'Contacto';

  @override
  String get driverProfileSectionLocation => 'Ubicación';

  @override
  String get driverProfileReadOnlyFooter =>
      'Por ahora estos datos son de solo lectura. Muy pronto habilitaremos la edición desde la app.';

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
  String get driverProfileDefaultName => 'Conductor TEXI';

  @override
  String get driverOnlineErrorNoInternet =>
      'Sin conexión a internet. Conéctate para ponerte en línea.';

  @override
  String get driverOnlineErrorNoGps =>
      'Activa los permisos de ubicación para poder compartir tu posición.';

  @override
  String get driverOnlineErrorNoToken =>
      'Sesión inválida. Vuelve a iniciar sesión.';

  @override
  String get driverOnlineErrorSocket =>
      'No se pudo conectar al servidor. Intenta de nuevo.';

  @override
  String get driverOnlineErrorUnknown =>
      'No se pudo poner en línea. Intenta de nuevo.';

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
  String get driverTripOfferPriceTbd => 'A acordar';

  @override
  String get driverTripOfferBadgeNew => 'Nueva';

  @override
  String driverTripOfferPickupEta(String minutes) {
    return '~$minutes min a la recogida';
  }

  @override
  String driverTripOfferRouteEta(String minutes) {
    return '~$minutes min al destino';
  }

  @override
  String driverTripOfferRouteKm(String distance) {
    return '$distance de ruta';
  }

  @override
  String get driverOfferErrorNoConnection => 'Sin conexión con el servidor.';

  @override
  String get driverOfferErrorExpired => 'Esta oferta ya no está disponible.';

  @override
  String get driverOfferErrorTaken =>
      'El viaje ya fue asignado o no está disponible.';

  @override
  String get driverOfferErrorGeneric => 'No se pudo actualizar la solicitud.';

  @override
  String get driverTripNavigatePickup => 'Navegar al origen';

  @override
  String get driverTripNavigateDestination => 'Navegar al destino';

  @override
  String get driverTripReactivate => 'Volver a recibir viajes';

  @override
  String driverTripSnackbarNavigationFailed(String label) {
    return 'No se pudo abrir la navegación ($label)';
  }

  @override
  String get driverTripBackgroundPromptTitle => '¿Mantener servicio activo?';

  @override
  String get driverTripBackgroundPromptDisconnect => 'Desconectar';

  @override
  String get driverTripBackgroundPromptKeep => 'Mantener activo';

  @override
  String driverTripBackgroundPromptBody(String seconds) {
    return 'Estuviste fuera de la app por más de 15 minutos.\nSi deseas seguir recibiendo solicitudes, confirma ahora.\n\nDesconexión automática en ${seconds}s';
  }

  @override
  String get driverHomeBackgroundLocationTitle => 'Ubicación en segundo plano';

  @override
  String get driverHomeBackgroundLocationBody =>
      'Para que los pasajeros puedan encontrarte cuando la app no está a la vista, concede ubicación «Todo el tiempo» en el siguiente paso. Solo se usa mientras estás conectado como conductor. Puedes cambiarlo en los ajustes del sistema cuando quieras.';

  @override
  String get driverHomeBackgroundLocationLater => 'Ahora no';

  @override
  String get driverHomeBackgroundLocationContinue => 'Continuar';

  @override
  String get driverMapDriverPosition => 'Tu posición';

  @override
  String get driverMapPickupPoint => 'Punto de recogida';

  @override
  String get driverMapDestinationPoint => 'Destino';

  @override
  String get driverMapCalculatingRoute => 'Calculando ruta...';

  @override
  String get driverTripRatingHeaderTitle => 'Viaje completado';

  @override
  String get driverTripRatingTitle => 'Califica al pasajero';

  @override
  String get driverTripRatingSubtitle =>
      'Tu opinión nos ayuda a mantener un buen servicio para todos.';

  @override
  String get driverTripRatingSubmit => 'Enviar calificación';

  @override
  String get driverTripRatingSkip => 'Omitir por ahora';

  @override
  String get driverTripRatingSummaryLabel => 'Resumen del viaje';

  @override
  String get driverTripRatingPassengerDefault => 'Pasajero';

  @override
  String get driverTripRatingOriginDefault => 'Recogida';

  @override
  String get driverTripRatingDestinationDefault => 'Destino';

  @override
  String driverTripRatingDistanceKm(String distance) {
    return '$distance km';
  }

  @override
  String driverTripRatingEtaMinutes(String minutes) {
    return '~$minutes min';
  }

  @override
  String get driverTripRatingPriceLabel => 'Tarifa';

  @override
  String get driverTripRatingYourRating => 'Tu valoración';

  @override
  String driverTripRatingRouteHint(String origin, String destination) {
    return '$origin → $destination';
  }

  @override
  String get driverRegImageTakePhoto => 'Tomar foto';

  @override
  String get driverRegImageChooseGallery => 'Elegir de galería';

  @override
  String driverRegImageTooLarge(int maxKb) {
    return 'La imagen es muy pesada (máx. $maxKb KB). Elige otra o reduce la resolución.';
  }

  @override
  String get driverRegImageReadError => 'No se pudo obtener la imagen.';

  @override
  String get driverRegStepData => 'Datos';

  @override
  String get driverRegStepIdentity => 'Identidad';

  @override
  String get driverRegStepLicense => 'Licencia';

  @override
  String get driverRegStepAccess => 'Acceso';

  @override
  String get driverRegStepVehicle => 'Vehículo';

  @override
  String get driverRegStepPhotos => 'Fotos';

  @override
  String get driverRegGenderOther => 'Otro / prefiero no indicar';

  @override
  String get driverRegTitle => 'Registro de conductor';

  @override
  String driverRegStepCounter(String current, String total) {
    return 'Paso $current de $total';
  }

  @override
  String get driverRegSnackSelectCountryCoverage =>
      'Selecciona un país con cobertura del servicio.';

  @override
  String get driverRegSnackSelectDepartmentLocality =>
      'Elige departamento y localidad (provincia).';

  @override
  String get driverRegSnackPasswordsMismatch => 'Las contraseñas no coinciden.';

  @override
  String get driverRegSnackIdentityIncomplete =>
      'Completa número, vencimiento y las tres imágenes.';

  @override
  String get driverRegSnackLicenseIncomplete =>
      'Necesitamos la categoría, la fecha de vencimiento y una foto de cada lado de la licencia.';

  @override
  String get driverRegSnackVehicleYearInvalid => 'Año del vehículo no válido.';

  @override
  String get driverRegSnackVehiclePhotosIncomplete =>
      'Necesitamos las cuatro vistas: frente, parte trasera y ambos laterales del vehículo.';

  @override
  String get driverRegDoneTitle => '¡Listo!';

  @override
  String get driverRegDoneBody =>
      'Gracias por unirte a Texi. Tus datos y documentos ya fueron registrados y entrarán a revisión para validación. En la brevedad activaremos tu servicio para que puedas atender viajes. Ahora inicia sesión con tus credenciales.';

  @override
  String get driverRegDoneGoLogin => 'Ir a iniciar sesión';
}
