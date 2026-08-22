// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get driverAppTitle => 'Texi Conductor';

  @override
  String get loginCode => 'Código';

  @override
  String get loginPhone => 'Teléfono';

  @override
  String get tripOrigin => 'Origen';

  @override
  String get tripDestination => 'Destino';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

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
      'O ingresa tu número y contraseña si ya eres un conductor Texi.';

  @override
  String get driverLoginPassword => 'Contraseña';

  @override
  String get driverLoginButton => 'Ingresar';

  @override
  String get driverLoginPhoneAndPasswordRequired =>
      'Ingresa tu número y contraseña';

  @override
  String get driverLoginCountryCodeHint => '+591';

  @override
  String get driverLoginPhoneHint => '7 123 4567';

  @override
  String get driverLoginErrorGeneric => 'No se pudo iniciar sesión';

  @override
  String get driverLoginErrorAccountBlocked =>
      'Tu cuenta fue bloqueada. Contacta a soporte para revisar el caso.';

  @override
  String get driverLoginErrorNetwork =>
      'No se pudo conectar. Revisa tu internet e intenta de nuevo.';

  @override
  String get driverLoginErrorConnection =>
      'Sin conexión con el servidor. Verifica tu red.';

  @override
  String get driverLoginErrorInvalidResponse =>
      'Respuesta inválida del servidor. Intenta nuevamente.';

  @override
  String get driverLoginErrorTokenMissing =>
      'No se recibió token de sesión. Intenta nuevamente.';

  @override
  String get driverLoginErrorUnexpected =>
      'Error inesperado al iniciar sesión. Intenta nuevamente.';

  @override
  String get driverLoginErrorSessionSuperseded =>
      'Tu sesión se abrió en otro dispositivo.';

  @override
  String get driverLoginErrorTripOperationalLock =>
      'Termina o cancela tu viaje actual antes de iniciar sesión en otro dispositivo.';

  @override
  String get driverLoginErrorDeviceBound =>
      'Esta cuenta está vinculada a otro dispositivo. Contacta a soporte para cambiar de teléfono.';

  @override
  String get driverLoginRegisterCta => 'Registrarme';

  @override
  String get driverLoginRegisterBannerTitle => '¿Nuevo conductor?';

  @override
  String get driverLoginRegisterBannerSubtitle =>
      'Crear cuenta solo toma unos minutos. Empieza a recibir viajes con TEXIAPP.';

  @override
  String get driverHomeTitle => 'Conductor';

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
  String get driverHomeMiniStatusRestoringConnection => 'Restaurando conexión…';

  @override
  String get driverHomeVehicleRegistrationBanner =>
      'Falta registrar tu vehículo. Sin vehículo no puedes recibir viajes.';

  @override
  String get driverHomeVehicleRegistrationCta => 'Completar datos del vehículo';

  @override
  String get driverHomeCannotGoOnlineWithoutVehicle =>
      'Registra tu vehículo para poder conectarte y recibir viajes.';

  @override
  String get driverHomeVehicleRequiredDialogTitle => 'Vehículo requerido';

  @override
  String driverHomeCreditsLowWarning(String balance, String min) {
    return 'Tu saldo ($balance) está cerca del mínimo ($min) para permanecer en línea. Recargá créditos pronto para evitar que te desconectemos automáticamente.';
  }

  @override
  String get driverFcmOpenedTripOfferHint =>
      'Si acabamos de cargar la solicitud desde la alerta, revisa la lista abajo. Si no aparece, puede haber expirado o falló la conexión: vuelve a ponerte en línea.';

  @override
  String get driverFcmOpenedTripOfferOfflineHint =>
      'Estás fuera de línea. Activa disponibilidad para poder atender solicitudes desde las alertas.';

  @override
  String get driverHomeMiniVehicleEmpty => 'Vehículo';

  @override
  String driverHomeMiniRating(String rating) {
    return '$rating ★';
  }

  @override
  String get driverLogout => 'Cerrar sesión';

  @override
  String get driverHomeMenuSectionAccount => 'Cuenta';

  @override
  String get driverHomeMenuSectionActivity => 'Actividad';

  @override
  String get driverHomeMenuSectionSession => 'Sesión';

  @override
  String get driverHomeMenuTitle => 'Menú';

  @override
  String get driverEarningsCreditsMenu => 'Ingresos y créditos';

  @override
  String get driverClubMenu => 'Club del Conductor';

  @override
  String get driverClubTitle => 'Club del Conductor';

  @override
  String get driverClubHeroBadge => 'EXCLUSIVO';

  @override
  String get driverClubHeroHello => 'Hola';

  @override
  String driverClubHeroHelloName(String name) {
    return 'Hola, $name';
  }

  @override
  String get driverClubHeroTagline => 'Beneficios para quien ya opera.';

  @override
  String get driverClubHowItWorks => 'Qué es el Club Texi Conductor';

  @override
  String get driverClubLearnOnWeb => 'Conoce más sobre este beneficio';

  @override
  String get driverClubWalletTitle => 'Crédito Club';

  @override
  String driverClubExpiresOn(String date) {
    return 'Vigente hasta $date';
  }

  @override
  String get driverClubWalletEmptyHint => 'Aún no hay crédito Club.';

  @override
  String get driverClubWalletLiveHint => 'Se usa al completar viajes.';

  @override
  String get driverClubInviteTitle => 'Invita y gana';

  @override
  String get driverClubInviteSubtitle =>
      'Comparte tu código. Así crece tu red.';

  @override
  String get driverClubYourCode => 'Tu código';

  @override
  String get driverClubCopyCode => 'Copiar';

  @override
  String get driverClubCodeCopied => 'Código copiado';

  @override
  String get driverClubShareWhatsapp => 'WhatsApp';

  @override
  String driverClubWhatsappShare(String code) {
    return 'Únete como conductor TEXIAPP con mi código $code';
  }

  @override
  String get driverClubEnterCodeHint => '¿Te invitaron? Ingresa su código';

  @override
  String get driverClubClaimCta => 'Registrar código';

  @override
  String get driverClubClaimOk => 'Código registrado';

  @override
  String get driverClubInviteesTitle => 'Mis invitados';

  @override
  String get driverClubInviteesEmpty => 'Todavía no hay invitados.';

  @override
  String get driverClubStatusPending => 'Pendiente';

  @override
  String get driverClubStatusProgress => 'En proceso';

  @override
  String get driverClubStatusDone => 'Listo';

  @override
  String get driverClubBenefitsTitle => 'Más beneficios';

  @override
  String get driverClubLevelsTitle => 'Niveles';

  @override
  String get driverClubLevelsHint =>
      'Tu categoría la confirma el equipo. Estos números son la referencia del mes.';

  @override
  String driverClubMonthTripsValue(int count) {
    return '$count viajes este mes';
  }

  @override
  String driverClubMonthRatingValue(String rating) {
    return '$rating estrellas este mes';
  }

  @override
  String get driverClubMonthRatingEmpty => 'Aún no hay calificaciones este mes';

  @override
  String driverClubTripsRange(int min, int max) {
    return '$min–$max viajes';
  }

  @override
  String driverClubTripsFrom(int min) {
    return 'Desde $min viajes';
  }

  @override
  String driverClubRatingFrom(String rating) {
    return 'Desde $rating estrellas';
  }

  @override
  String get driverClubRatingNone => 'Sin mínimo de estrellas';

  @override
  String get driverClubChallengesTitle => 'Desafíos';

  @override
  String get driverClubChallengesBlurb => 'Retos cortos, cuando estén activos.';

  @override
  String get driverClubAdsTitle => 'Publicidad en tu vehículo';

  @override
  String get driverClubAdsBlurb => 'Postula cuando abra la convocatoria.';

  @override
  String get driverRegFieldReferralCode => 'Código de referido (opcional)';

  @override
  String get driverRegFieldReferralCodeHint => 'Ej. CARLOS-782';

  @override
  String get driverEarningsCreditsTitle => 'Ingresos y créditos';

  @override
  String get driverEarningsCreditsFilterHint =>
      'Filtrá por período. Los totales y listas se actualizan según el rango.';

  @override
  String get driverEarningsCreditsLoadError =>
      'No se pudo cargar la información. Deslizá para reintentar.';

  @override
  String get driverEarningsCreditsStatTrips => 'Viajes completados';

  @override
  String get driverEarningsCreditsStatTripsHint => 'En el período seleccionado';

  @override
  String get driverEarningsCreditsStatGross => 'Total viajes';

  @override
  String get driverEarningsCreditsStatGrossHint =>
      'Suma de montos de viajes completados';

  @override
  String get driverEarningsCreditsStatBalance => 'Saldo créditos';

  @override
  String get driverEarningsCreditsStatCommission => 'Comisión créditos';

  @override
  String get driverEarningsCreditsStatCommissionHint =>
      'Descontado del saldo en el período';

  @override
  String get driverEarningsCreditsLedgerSection => 'Movimientos de crédito';

  @override
  String get driverEarningsCreditsLedgerEmpty =>
      'No hay movimientos en este período.';

  @override
  String get driverEarningsCreditsLedgerGrant => 'Abono';

  @override
  String get driverEarningsCreditsLedgerCommission => 'Comisión por viaje';

  @override
  String get driverEarningsCreditsTripsSection => 'Viajes en el período';

  @override
  String get driverEarningsCreditsTripsEmpty =>
      'No hay viajes completados en este período.';

  @override
  String get driverEarningsCreditsTripIdShort => 'Viaje';

  @override
  String get driverTripHistoryMenu => 'Historial de viajes';

  @override
  String get driverTripHistoryTitle => 'Historial de viajes';

  @override
  String get driverTripHistoryFilterAll => 'Todos';

  @override
  String get driverTripHistoryFilterCompleted => 'Completados';

  @override
  String get driverTripHistoryFilterCancelled => 'Cancelados';

  @override
  String get driverTripHistoryFilterInProgress => 'En curso';

  @override
  String get driverTripHistoryDateAll => 'Todo el tiempo';

  @override
  String get driverTripHistoryDateToday => 'Hoy';

  @override
  String get driverTripHistoryDate7d => 'Últimos 7 días';

  @override
  String get driverTripHistoryDate30d => 'Últimos 30 días';

  @override
  String get driverTripHistoryStatusLabel => 'Estado';

  @override
  String get driverTripHistoryStatusCompleted => 'Completado';

  @override
  String get driverTripHistoryStatusCancelled => 'Cancelado';

  @override
  String get driverTripHistoryStatusInProgress => 'En curso';

  @override
  String get driverTripHistoryDateCustom => 'Personalizado';

  @override
  String get driverTripHistoryActiveFilters => 'Filtros activos';

  @override
  String get driverTripHistoryCustomRangeLabel => 'Rango elegido';

  @override
  String get driverTripHistorySectionToday => 'Hoy';

  @override
  String get driverTripHistorySectionYesterday => 'Ayer';

  @override
  String get driverTripHistorySectionOlder => 'Anteriores';

  @override
  String get driverTripHistoryEmpty => 'Aún no tienes viajes en este filtro.';

  @override
  String get driverTripHistoryLoadError =>
      'No se pudo cargar el historial. Intenta nuevamente.';

  @override
  String get driverTripHistoryNoSession =>
      'Tu sesión expiró. Vuelve a iniciar sesión.';

  @override
  String get driverTripHistoryPrevPage => 'Anterior';

  @override
  String get driverTripHistoryNextPage => 'Siguiente';

  @override
  String get driverTripHistoryPricePending => 'Sin monto';

  @override
  String get driverHomeMenuAddVehicle => 'Mis vehículos';

  @override
  String get driverMyVehiclesTitle => 'Mis vehículos';

  @override
  String get driverMyVehiclesRefreshTooltip => 'Actualizar lista';

  @override
  String get driverMyVehiclesAddFab => 'Agregar vehículo';

  @override
  String get driverMyVehiclesAddLockedTitle => 'Aún no disponible';

  @override
  String get driverMyVehiclesAddLockedBody =>
      'Por ahora solo puedes tener un vehículo registrado. Agregar otro es un beneficio que se habilita según tu antigüedad y evaluación como conductor. Si crees que ya corresponde, contacta a soporte.';

  @override
  String get driverMyVehiclesAddLockedCta => 'Entendido';

  @override
  String get driverMyVehiclesEmpty =>
      'Aún no tienes vehículos registrados. Puedes agregar uno para ofrecer servicio.';

  @override
  String get driverMyVehiclesRetry => 'Reintentar';

  @override
  String driverMyVehiclesPhotosPendingBadge(int uploaded, int required) {
    return 'Galería incompleta: $uploaded de $required fotos obligatorias';
  }

  @override
  String get driverMyVehiclesCompletePhotosCta => 'Completar fotos';

  @override
  String get driverMyVehiclesCompletePhotosTitle => 'Fotos del vehículo';

  @override
  String get driverMyVehiclesPhotosSavedSnackbar =>
      'Fotos guardadas correctamente';

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
  String get driverProfileOnboardingTitle => 'Carga y verificaciones';

  @override
  String get driverProfileOnboardingBody =>
      'Revisa el estado de cada bloque. Las fotos de CI, licencia y vehículo se pueden cambiar hasta que el bloque figure como Verificado. Un bloque verificado ya no se puede abrir; el resumen está más abajo.';

  @override
  String get driverProfileSectionOnboardingPersonal => 'Información personal';

  @override
  String get driverProfileSectionOnboardingIdentity => 'Documento de identidad';

  @override
  String get driverProfileSectionOnboardingLicense => 'Licencia de conducir';

  @override
  String get driverProfileSectionOnboardingVehicle => 'Vehículo y fotos';

  @override
  String get driverProfileOnboardingStatusIncomplete => 'Pendiente';

  @override
  String get driverProfileOnboardingStatusPending => 'En revisión';

  @override
  String get driverProfileOnboardingStatusVerified => 'Verificado';

  @override
  String get driverProfileOnboardingStatusAction => 'Ajuste solicitado';

  @override
  String get driverProfileOnboardingTapToContinue =>
      'Toca para abrir o actualizar';

  @override
  String get driverProfileOnboardingTapEditable =>
      'Toca para completar o corregir';

  @override
  String get driverProfileOnboardingTapEditPhotos =>
      'Toca para cambiar las fotos (hasta que se apruebe)';

  @override
  String get driverProfileOnboardingTapViewOnly =>
      'Toca para ver (en revisión)';

  @override
  String get driverProfileOnboardingTapLocked =>
      'Verificado. El resumen está más abajo.';

  @override
  String get driverRegProfileSectionReadOnlyBanner =>
      'Este bloque está en revisión. Puedes consultar la información, pero no guardar cambios hasta que el equipo la procese.';

  @override
  String get driverRegProfileSectionPhotosEditableBanner =>
      'Puedes cambiar las fotos hasta que este bloque se apruebe. El resto de datos queda bloqueado.';

  @override
  String get driverRegActionSavePhotos => 'Guardar fotos';

  @override
  String get driverRegSnackChangeAtLeastOnePhoto =>
      'Cambia al menos una foto para guardar.';

  @override
  String get driverRegProfileSectionLockedBanner =>
      'Este bloque ya fue verificado y no puede modificarse desde la app.';

  @override
  String get driverRegErrorSectionNotEditable =>
      'Esta sección no admite cambios en su estado actual.';

  @override
  String get driverRegErrorRateLimited =>
      'Hay demasiadas solicitudes en poco tiempo. Espera un momento e intenta de nuevo.';

  @override
  String get driverRegErrorNoConnection =>
      'Sin conexión a internet. Revisa tu señal e intenta de nuevo.';

  @override
  String get driverRegPassengerUpgradeTitle => 'Ya tienes cuenta de pasajero';

  @override
  String get driverRegPassengerUpgradeBody =>
      'Este número ya está registrado como pasajero. Abre WhatsApp y envía el mensaje para confirmar que es tuyo.';

  @override
  String get driverRegPassengerUpgradeBodyCode =>
      'Este número ya está registrado como pasajero. Ingresa el código de verificación para confirmar que es tuyo.';

  @override
  String get driverRegPassengerUpgradeOpenWhatsApp => 'Abrir WhatsApp';

  @override
  String get driverRegPassengerUpgradeWaiting =>
      'Esperando tu mensaje en WhatsApp…';

  @override
  String get driverRegPassengerUpgradeExpired =>
      'El mensaje expiró. Intenta de nuevo.';

  @override
  String get driverRegPassengerUpgradeCodeHint => 'Código de verificación';

  @override
  String get driverRegPassengerUpgradeConfirm => 'Continuar';

  @override
  String get driverRegErrorPassengerUpgradeRequired =>
      'Este número ya es de un pasajero. Confirma el número por WhatsApp para registrarte como conductor.';

  @override
  String get driverRegErrorDuplicatePhoneDriver =>
      'Este número ya está registrado como conductor. Inicia sesión o recupera tu acceso.';

  @override
  String get driverRegErrorUpgradeOtpInvalid =>
      'El código no es válido o expiró. Pide uno nuevo e intenta de nuevo.';

  @override
  String get driverRegErrorUpgradeOtpNotFound =>
      'No hay una cuenta de pasajero con este número. Completa el registro como conductor nuevo.';

  @override
  String get driverRegErrorAccountDeletionPending =>
      'Esta cuenta está en proceso de eliminación. Cancela esa solicitud desde la app de pasajero antes de registrarte como conductor.';

  @override
  String get driverRegErrorUpgradeWhatsAppSend =>
      'No se pudo enviar el código por WhatsApp. Intenta de nuevo en unos minutos.';

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
  String get driverAppCreditsTitle => 'Créditos de uso';

  @override
  String get driverAppCreditsUnavailable =>
      'No se pudo cargar el saldo. Desliza para actualizar.';

  @override
  String driverAppCreditsBalance(String balance) {
    return 'Saldo: $balance';
  }

  @override
  String get driverAppCreditsProgramOn => 'Comisión por viaje activa';

  @override
  String get driverAppCreditsProgramOff => 'Sin comisión automática por viaje';

  @override
  String driverAppCreditsDetailPercent(String percent) {
    return '$percent% sobre el monto del viaje';
  }

  @override
  String driverAppCreditsDetailFixed(String amount) {
    return '$amount por viaje completado';
  }

  @override
  String get driverProfileFieldName => 'Nombre';

  @override
  String get driverProfileFieldReferralCode => 'Código de referido';

  @override
  String get driverProfileCopyReferralCode => 'Copiar código de referido';

  @override
  String get driverProfileReferralCopied => 'Código copiado';

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
  String get driverOnlineErrorGpsServiceOff =>
      'Activa el GPS del dispositivo (ubicación) para poder ponerte en línea y recibir viajes.';

  @override
  String get driverOnlineErrorNoNotifications =>
      'Activa las notificaciones para la app. Sin ellas no podrás recibir ofertas de viaje con la app en segundo plano.';

  @override
  String get driverOnlineErrorNoToken =>
      'Sesión inválida. Vuelve a iniciar sesión.';

  @override
  String get driverOnlineErrorSessionExpiredReLogin =>
      'Tu sesión expiró o ya no es válida. Vuelve a iniciar sesión.';

  @override
  String get driverOnlineErrorSocket =>
      'No se pudo conectar al servidor. Intenta de nuevo.';

  @override
  String get driverOnlineErrorVehicleRequired =>
      'Necesitas un vehículo registrado para conectarte. Completa el registro del vehículo o usa “Agregar otro vehículo” en el menú.';

  @override
  String get driverOnlineErrorGoOnlineBlocked =>
      'Tu cuenta no puede mostrarse disponible para viajes desde la app. Contacta a soporte si crees que es un error.';

  @override
  String driverOnlineErrorCreditsBelowMin(Object minCredits, Object balance) {
    return 'Créditos insuficientes para habilitar online. Mínimo requerido: $minCredits; saldo actual: $balance.';
  }

  @override
  String get driverOnlineErrorAccountBlocked =>
      'Tu cuenta de conductor está bloqueada. Se cerró tu sesión por seguridad.';

  @override
  String get driverOnlineErrorUnknown =>
      'No se pudo poner en línea. Intenta de nuevo.';

  @override
  String get driverOnlineErrorActiveTripCantGoOffline =>
      'No puedes desconectarte con un viaje activo o pendiente de calificación. Termina o cancela el viaje primero.';

  @override
  String get driverOnlineErrorReconnecting =>
      'Se perdió la conexión. Reconectando…';

  @override
  String get driverOnlineErrorRbacForbidden =>
      'Tu cuenta no tiene permiso para esta acción. Si sigue igual, cierra sesión y vuelve a entrar o contacta soporte.';

  @override
  String get driverOnlineErrorRbacSession =>
      'No pudimos validar tu sesión. Cierra sesión y vuelve a iniciar sesión.';

  @override
  String get driverOnlineErrorRbacTechnical =>
      'Hubo un problema al verificar permisos. Intenta de nuevo en unos segundos.';

  @override
  String get driverHomeOnlineRequirementsHint =>
      'Solo aplica para recibir viajes: el servidor debe verte en línea, con ubicación y poder enviarte avisos. Otras pantallas (como tu perfil) no lo requieren.';

  @override
  String get driverHomeOpenSystemLocationSettings =>
      'Abrir ajustes de ubicación (GPS)';

  @override
  String get driverHomeOpenAppPermissionSettings => 'Abrir permisos de la app';

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
  String driverTripOfferPrice(String amount) {
    return 'Precio estimado: $amount';
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
  String get driverTripPaymentCash => 'Efectivo';

  @override
  String get driverTripPaymentQr => 'QR';

  @override
  String get driverTripExtrasTitle => 'El pasajero indicó';

  @override
  String get driverTripExtrasHint =>
      'Informativo. Cierra para volver a la lista de solicitudes.';

  @override
  String get driverTripAddonsHint =>
      'Revisá preferencias y requerimientos. Cierra para volver a la lista.';

  @override
  String get driverTripExtrasClose => 'Cerrar';

  @override
  String get driverTripExtraPet => 'Mascota';

  @override
  String get driverTripExtraPetAlert => 'Mascota a bordo.';

  @override
  String get driverTripExtraPetDetail => 'El pasajero viaja con una mascota.';

  @override
  String get driverTripExtraChildSeat => 'Silla para niño';

  @override
  String get driverTripExtraWheelchair => 'Silla de ruedas';

  @override
  String get driverTripExtraWheelchairAlert => 'Pasajero con silla de ruedas.';

  @override
  String get driverTripExtraWheelchairDetail =>
      'Requiere espacio en el maletero para silla plegable. Por favor, brinda asistencia si es necesario.';

  @override
  String get driverTripExtraOver4 => 'Más de 4 personas';

  @override
  String get driverTripExtraLuggageAlert => 'Con maletas.';

  @override
  String get driverTripExtraLuggageDetail =>
      'El pasajero lleva maletas. Asegúrate de tener el maletero vacío para el equipaje.';

  @override
  String get driverTripExtraAcAlert => 'Aire acondicionado.';

  @override
  String get driverTripExtraAcDetail =>
      'El pasajero pidió viajar con aire acondicionado.';

  @override
  String get driverTripSpecialSeats6Alert => 'Grupo grande (hasta 6 pasajeros)';

  @override
  String get driverTripSpecialSeats6Detail =>
      'Requiere un vehículo amplio con capacidad confirmada para 6 pasajeros.';

  @override
  String get driverTripSpecialRoofRackAlert => 'Requiere parrilla en el techo';

  @override
  String get driverTripSpecialRoofRackDetail =>
      'El pasajero llevará carga en el techo. Asegúrate de tener amarres/ligas disponibles.';

  @override
  String get driverTripSpecialCargoAlert => 'Viaje con carga / mercadería';

  @override
  String get driverTripSpecialCargoDetail =>
      'Espacio total de carga ocupado. Incluye tiempo adicional para carga y descarga.';

  @override
  String get driverRegFieldSixSeats => 'Vehículo con 6 asientos';

  @override
  String get driverRegHintSixSeats =>
      'Marcá si tu auto puede llevar hasta 6 pasajeros. Se usará para viajes de grupo grande.';

  @override
  String get driverTripOfferBadgeOperations => 'Operaciones';

  @override
  String get driverTripOfferOperationsSubtitle =>
      'Asignación desde el portal de operaciones';

  @override
  String get driverFcmOpenedTripOfferOperationsHint =>
      'Solicitud de operaciones cargada. Revisa la lista de viajes abajo.';

  @override
  String get driverOfferErrorNoConnection => 'Sin conexión con el servidor.';

  @override
  String get driverOfferErrorExpired => 'Esta oferta ya no está disponible.';

  @override
  String get driverOfferErrorTaken =>
      'El viaje ya fue asignado o no está disponible.';

  @override
  String get driverTripErrorGeneric =>
      'No se pudo actualizar el estado del viaje.';

  @override
  String get driverTripNavigatePickup => 'Navegar al origen';

  @override
  String get driverTripNavigateDestination => 'Navegar al destino';

  @override
  String get driverRegisteredImagesMenu => 'Imágenes registradas';

  @override
  String get driverTripChatOpenCta => 'Chat seguro';

  @override
  String get driverTripChatTitle => 'Chat del viaje';

  @override
  String get driverTripChatSubtitle =>
      'Conversación activa con el pasajero en tiempo real.';

  @override
  String get driverTripChatOnline => 'En línea';

  @override
  String get driverTripChatOffline => 'Sin conexión';

  @override
  String get driverTripChatTemplateArrived => 'Ya llegué al punto';

  @override
  String get driverTripChatTemplateCannotFind => 'No logro ubicarte';

  @override
  String get driverTripChatTemplateConfirmLocation => 'Confirma tu ubicación';

  @override
  String get driverTripChatNow => 'Ahora';

  @override
  String get driverTripChatErrorStorage =>
      'Chat no disponible: falta configuración en el servidor. Contacta a soporte.';

  @override
  String get driverTripChatErrorPhase =>
      'El chat solo está disponible antes de iniciar el viaje.';

  @override
  String driverTripChatErrorSendReceive(String code) {
    return 'No se pudo enviar/recibir chat ($code). Revisa la conexión.';
  }

  @override
  String get driverTripChatEmptyState =>
      'Aún no hay mensajes.\nEnvía uno para iniciar la conversación.';

  @override
  String get driverTripChatMessageHint => 'Escribe un mensaje';

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
  String get driverForegroundNotifyTitle => 'Texi · Modo conductor';

  @override
  String get driverForegroundNotifyBodySearching =>
      'Buscando viajes. El GPS sigue activo para ubicarte.';

  @override
  String get driverForegroundNotifyBodyTrip =>
      'Viaje activo · compartiendo ubicación.';

  @override
  String driverForegroundNotifyBodyOffers(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count solicitudes pendientes — abre Texi',
      one: '1 solicitud pendiente — abre Texi para responder',
    );
    return '$_temp0';
  }

  @override
  String get driverNotifyChatTitle => 'Nuevo mensaje de chat';

  @override
  String driverNotifyChatBody(String sender, String message) {
    return '$sender: $message';
  }

  @override
  String get driverNotifyChatSenderPassenger => 'Pasajero';

  @override
  String get driverNotifyChatSenderDriver => 'Conductor';

  @override
  String get driverMapPickupPoint => 'Punto de recogida';

  @override
  String get driverMapDestinationPoint => 'Destino';

  @override
  String get driverDirectionsTollOnRoute => 'Peaje en ruta';

  @override
  String get driverDirectionsTollSnippet =>
      'Ajusta velocidad y carril con antelación.';

  @override
  String get driverDirectionsRelevantIntersection => 'Intersección relevante';

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
  String get driverTripRatingPassengerDefault => 'Pasajero';

  @override
  String get driverTripRatingYourRating => 'Tu valoración';

  @override
  String get driverTripRatingFeedbackPromptLow =>
      '¿Qué afectó el viaje? (múltiple)';

  @override
  String get driverTripRatingFeedbackPromptHigh =>
      '¿Qué destacó del pasajero? (múltiple)';

  @override
  String get driverRatingFallbackDelay => 'Demasiado tiempo de espera';

  @override
  String get driverRatingFallbackLocation => 'Dificultad para encontrarnos';

  @override
  String get driverRatingFallbackRespect => 'Falta de respeto';

  @override
  String get driverRatingFallbackPayment => 'Problema con el pago';

  @override
  String get driverRatingFallbackOther => 'Otro inconveniente';

  @override
  String get driverRatingFallbackPunctual => 'Puntual y listo para salir';

  @override
  String get driverRatingFallbackRespectful => 'Trato respetuoso';

  @override
  String get driverRatingFallbackClearPickup => 'Recogida clara y rápida';

  @override
  String get driverRatingFallbackRecommended => 'Pasajero recomendado';

  @override
  String get driverRatingFallbackExcellent => 'Excelente experiencia';

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
  String get driverRegImageCompatibleCaptureUsed =>
      'Se usó captura optimizada desde la cámara para reducir el peso.';

  @override
  String get driverRegImageLongPressLightHint =>
      'Mantén pulsado un recuadro para repetir la foto con captura optimizada (menos resolución inicial).';

  @override
  String get driverRegCropSelfieTitle => 'Ajustar selfie';

  @override
  String get driverRegCropDocumentTitle => 'Ajustar documento';

  @override
  String get driverRegCropVehicleTitle => 'Encuadrar el vehículo';

  @override
  String get driverRegPhotoReviewTitle => 'Revisa tu foto';

  @override
  String get driverRegPhotoReviewSubtitle =>
      'Puedes confirmarla, tomar otra o recortarla antes de continuar.';

  @override
  String get driverRegPhotoReviewUse => 'Usar esta foto';

  @override
  String get driverRegPhotoReviewChange => 'Cambiar foto';

  @override
  String get driverRegPhotoReviewEdit => 'Recortar o ajustar';

  @override
  String get driverRegPhotoReviewCancel => 'Cancelar';

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
  String get driverRegSnackVehicleYearInvalid => 'Ingresa un año de 4 dígitos.';

  @override
  String get driverRegSnackSelectCatalogBrandModel =>
      'Selecciona marca y modelo en los listados antes de continuar.';

  @override
  String get driverSettingsTitle => 'Configuración';

  @override
  String get driverRegSnackVehiclePhotosIncomplete =>
      'Necesitamos las cuatro vistas: frente, parte trasera y ambos laterales del vehículo.';

  @override
  String get driverRegDoneTitle => '¡Listo!';

  @override
  String get driverRegDoneBody =>
      'Gracias por unirte a TEXIAPP. Tus datos y documentos ya fueron registrados y están en revisión. Nos pondremos en contacto contigo a la brevedad para continuar con tu registro. Ahora inicia sesión con tus credenciales.';

  @override
  String get driverRegDoneGoLogin => 'Ir a iniciar sesión';

  @override
  String get driverRegAddVehicleTitle => 'Registrar vehículo de servicio';

  @override
  String get driverRegAddVehicleDoneTitle => 'Vehículo registrado';

  @override
  String get driverRegAddVehicleDoneBody =>
      'Los datos del vehículo quedaron guardados. Puedes seguir usando la app.';

  @override
  String get driverRegAddVehicleDoneCta => 'Volver al inicio';

  @override
  String get driverRegResumeDoneTitle => 'Registro completado';

  @override
  String get driverRegResumeDoneBody =>
      '¡Listo! Ya puedes usar el servicio como conductor.';

  @override
  String get driverRegResumeDoneCta => 'Ir al inicio';

  @override
  String get driverRegOnboardingDoneTitle => '¡Solicitud enviada con éxito!';

  @override
  String get driverRegOnboardingDoneBody =>
      'Ya estamos revisando tus datos y te contactaremos muy pronto. Haz clic en Entrar a la app para iniciar sesión, registrar tu vehículo o contactar a soporte si necesitas ayuda. ¡Ya falta poco!';

  @override
  String get driverRegOnboardingDoneCta => 'Entrar a la app';

  @override
  String get driverRegRetryLoadCountries => 'Reintentar cargar países';

  @override
  String get driverRegSectionOperationRegion => 'Región de operación';

  @override
  String get driverRegFieldCountry => 'País';

  @override
  String get driverRegValidationSelectCountry => 'Selecciona país';

  @override
  String get driverRegFieldDepartment => 'Departamento';

  @override
  String get driverRegNoCoverageInCountry => 'Sin cobertura en este país';

  @override
  String get driverRegValidationSelectDepartment => 'Selecciona departamento';

  @override
  String get driverRegFieldLocality => 'Localidad (provincia)';

  @override
  String get driverRegChooseDepartmentFirst => 'Elige un departamento';

  @override
  String get driverRegValidationSelectLocality => 'Selecciona localidad';

  @override
  String get driverRegSectionPersonalData => 'Datos personales';

  @override
  String get driverRegFieldFirstName => 'Nombres';

  @override
  String get driverRegFieldLastName => 'Apellidos';

  @override
  String get driverRegFieldEmail => 'Correo electrónico';

  @override
  String get driverRegHintOptional => 'Opcional';

  @override
  String get driverRegEmailHelper =>
      'Elige el correo de tu teléfono o escribe otro.';

  @override
  String get driverRegEmailPickFromDevice => 'Usar correo del teléfono';

  @override
  String get driverRegValidationEmailInvalid => 'Ingresa un correo válido.';

  @override
  String get driverRegValidationRequired => 'Requerido';

  @override
  String get driverRegValidationMinAge18 =>
      'Debes tener al menos 18 años para registrarte como conductor.';

  @override
  String get driverRegAgeRequirementHint =>
      'El registro y uso de la app de conductor están reservados a personas mayores de 18 años.';

  @override
  String get driverRegAgeRequirementFieldHelper =>
      'Mayores de 18 años. El calendario solo permite fechas válidas.';

  @override
  String get driverRegAgeRequirementDialogTitle => 'Mayoría de edad requerida';

  @override
  String get driverRegAgeRequirementDialogBody =>
      'Debes tener al menos 18 años para registrarte como conductor. Corrige la fecha de nacimiento para continuar.';

  @override
  String get driverRegValidationSelectOption => 'Selecciona una opción';

  @override
  String get driverRegSectionContact => 'Contacto';

  @override
  String get driverRegSectionContactAddress => 'Contacto y domicilio';

  @override
  String get driverRegFieldPhoneNumber => 'Número de teléfono';

  @override
  String get driverRegHintLocalDigitsOnly => 'Ej. 12345678';

  @override
  String get driverRegHintBoliviaLocalPhone => 'Ej. 70000000';

  @override
  String get driverRegChooseCountryFirst => 'Selecciona país primero';

  @override
  String get driverRegValidationIncompleteNumber => 'Número incompleto';

  @override
  String get driverRegValidationBoliviaPhoneInvalid => 'Número no válido';

  @override
  String get driverRegSectionAddress => 'Domicilio';

  @override
  String get driverRegFieldAddress => 'Dirección de domicilio';

  @override
  String get driverRegHintAddressReference => 'Calle, zona o referencia';

  @override
  String get driverRegSectionPassword => 'Contraseña de acceso';

  @override
  String get driverRegSectionPasswordHint =>
      'Crea una contraseña para acceder a la aplicación.';

  @override
  String get driverRegHintMin8Chars => 'Mínimo 8 caracteres';

  @override
  String get driverRegValidationMin8Chars => 'Mínimo 8 caracteres';

  @override
  String get driverRegFieldConfirmPassword => 'Confirmar contraseña';

  @override
  String get driverRegIntroPersonal =>
      'Datos verídicos y alineados con tu documentación.';

  @override
  String get driverRegIntroIdentity =>
      'Documento legible y foto de perfil donde se te identifique bien: rostro completo, sin gorra ni lentes oscuros, sin tapabocas ni sombra en la cara.';

  @override
  String get driverRegSectionIdentityDocument => 'Documento de identidad';

  @override
  String get driverRegSubtitleIdentityDocument =>
      'Número y vigencia según el documento.';

  @override
  String get driverRegFieldDocumentNumber => 'Número de documento';

  @override
  String get driverRegFieldDocumentExpiry => 'Vencimiento del documento';

  @override
  String get driverRegSectionFrontBack => 'Anverso y reverso';

  @override
  String get driverRegSubtitleOneImagePerSide => 'Una imagen por cada lado.';

  @override
  String get driverRegSectionProfilePhoto => 'Foto de perfil';

  @override
  String get driverRegSubtitleProfilePhoto =>
      'Para validar tu identidad: cara descubierta, sin gorra, sin lentes que tapen los ojos, buena luz.';

  @override
  String get driverRegIntroLicense =>
      'Categoría, vencimiento y fotos claras de ambos lados de la licencia.';

  @override
  String get driverRegSectionCategoryValidity => 'Categoría y vigencia';

  @override
  String get driverRegSubtitleCategoryValidity =>
      'Categoría de licencia y fecha de vencimiento (formato YYYY-MM-DD).';

  @override
  String get driverRegFieldCategory => 'Categoría';

  @override
  String get driverRegHintCategoryExample => 'Ej. B';

  @override
  String get driverRegValidationChooseCategory => 'Elige una categoría';

  @override
  String get driverRegFieldExpiry => 'Vencimiento';

  @override
  String get driverRegHintLicenseExpiryDate =>
      'Fecha en la que vence tu licencia';

  @override
  String get driverRegValidationIndicateExpiryDate =>
      'Indica la fecha de vencimiento';

  @override
  String get driverRegSectionLicenseFrontBack => 'Licencia — anverso y reverso';

  @override
  String get driverRegSectionActivateAccount => 'Enviar tu registro';

  @override
  String get driverRegSubtitleReviewBeforeContinue =>
      'Revisa tus datos y envíalos a revisión.';

  @override
  String get driverRegSectionYourSummary => 'Tu resumen';

  @override
  String get driverRegSubtitleProfileWorkZone => 'Perfil y zona de trabajo.';

  @override
  String get driverRegFieldFullName => 'Nombre completo';

  @override
  String get driverRegFieldServiceArea => 'Zona de servicio';

  @override
  String get driverRegIdentityLicenseRegistered =>
      'Documentación de identidad y licencia registrada.';

  @override
  String get driverRegIntroVehicle =>
      'Datos como en la placa. Después subirás cuatro fotos del vehículo.';

  @override
  String get driverRegSectionVehicleData => 'Datos del vehículo';

  @override
  String get driverRegSectionVehicleClassification =>
      'Clasificación del vehículo';

  @override
  String get driverRegFieldVehicleType => 'Tipo de vehículo';

  @override
  String get driverRegFieldVehicleCategory => 'Categoría';

  @override
  String get driverRegFieldServiceTypes => 'Servicios habilitados';

  @override
  String get driverRegFieldServiceType => 'Tipo de servicio';

  @override
  String get driverRegCatalogRetry => 'Reintentar catálogo';

  @override
  String get driverRegCatalogBrandModelTitle => 'Marca y modelo';

  @override
  String get driverRegCatalogTransportStepTitle => '1. ¿Qué vas a conducir?';

  @override
  String get serviceTypeNameStandard => 'Estándar';

  @override
  String get driverRegCatalogTransportCar => 'Automóvil';

  @override
  String get driverRegCatalogTransportMoto => 'Motocicleta';

  @override
  String get driverRegCatalogPickBrand => 'Marca';

  @override
  String get driverRegCatalogPickModel => 'Modelo';

  @override
  String get driverRegCatalogPickBrandFirst => 'Elige la marca primero';

  @override
  String get driverRegCatalogCustomTitle => 'Datos de tu vehículo';

  @override
  String get driverRegCatalogCustomHint => 'Se enviará a revisión.';

  @override
  String get driverRegCatalogCustomManufacturer => 'Marca';

  @override
  String get driverRegCatalogCustomModel => 'Modelo';

  @override
  String get driverRegCatalogCustomYear => 'Año';

  @override
  String get driverRegCatalogCustomSave => 'Guardar';

  @override
  String driverRegCatalogCustomSummary(
    String brand,
    String model,
    String year,
  ) {
    return 'A revisión: $brand · $model ($year)';
  }

  @override
  String get driverRegSnackCatalogCustomRequired =>
      'Completa marca, modelo y año para la opción Otros.';

  @override
  String get driverRegCatalogTechnicalTitle =>
      'Catálogos técnicos (referencia)';

  @override
  String get driverRegCatalogEmissionNorms => 'Normas de emisiones';

  @override
  String get driverRegCatalogAxles => 'Configuración de ejes';

  @override
  String get driverRegCatalogBodyTypes => 'Tipos de carrocería';

  @override
  String get driverRegCatalogUnits => 'Unidades de medida';

  @override
  String get driverRegCatalogLoad => 'Cargar catálogo';

  @override
  String get driverRegVehicleTypeNoCategories =>
      'Este tipo no tiene categorías en el catálogo. Prueba otro tipo o contacta soporte.';

  @override
  String get driverRegCategoryNoServices =>
      'Esta categoría no tiene servicios en el catálogo.';

  @override
  String get driverRegServiceTypeFallbackPrefix => 'Servicio ';

  @override
  String get driverRegSnackVehicleCatalogNotReady =>
      'Espera a que cargue el catálogo o pulsa reintentar.';

  @override
  String get driverRegCatalogNoServiceTypes =>
      'No hay tipos de servicio disponibles. Reintenta más tarde o contacta soporte.';

  @override
  String get driverRegErrorVehicleServiceBridgeMissing =>
      'No se pudieron sincronizar los servicios del conductor en este entorno. Intenta nuevamente en unos segundos.';

  @override
  String get driverRegErrorMissingUserId =>
      'No se encontró el identificador del conductor. Vuelve al inicio del registro.';

  @override
  String get driverRegErrorVehicleCatalogLoading =>
      'Espera a que cargue el catálogo del vehículo o reintenta.';

  @override
  String get driverRegErrorVehicleCatalogIncomplete =>
      'El catálogo del servidor no incluye tipo o categoría de vehículo. Contacta soporte.';

  @override
  String get driverRegErrorVehicleTypeCategoryRequired =>
      'Completa tipo de vehículo y categoría.';

  @override
  String get driverRegErrorVehicleCategoryInvalid =>
      'La categoría seleccionada no es válida. Elige otra.';

  @override
  String get driverRegErrorVehicleNoServicesConfigured =>
      'No hay servicios configurados para esta categoría. Elige otra o contacta soporte.';

  @override
  String get driverRegErrorVehicleServiceNotAllowedForCategory =>
      'Hay un servicio seleccionado que no aplica a la categoría.';

  @override
  String get driverRegErrorVehicleServiceCodeMissing =>
      'El catálogo no trae código de servicio para la selección actual. Reintenta o actualiza la app.';

  @override
  String get driverRegErrorSessionUnavailable =>
      'Sesión no disponible. Inicia sesión nuevamente.';

  @override
  String get driverRegErrorSecureStorage =>
      'No se pudieron leer datos locales de este dispositivo. Cierra la app y vuelve a intentar. Si persiste, borra los datos de la app en Ajustes.';

  @override
  String get driverRegCatalogCompatEmptyUsesDefault =>
      'El catálogo llegó vacío. Puedes continuar: se usará el servicio predeterminado. Para ver la lista, revisa la base o toca reintentar.';

  @override
  String get driverRegCatalogFallbackBanner =>
      'Catálogo de respaldo: las listas técnicas pueden no coincidir con producción. Cuando la base esté completa, desaparecerá este aviso.';

  @override
  String get driverRegFieldBrand => 'Marca';

  @override
  String get driverRegHintBrandExample => 'Ej. Toyota';

  @override
  String get driverRegFieldModel => 'Modelo';

  @override
  String get driverRegHintModelExample => 'Ej. Corolla';

  @override
  String get driverRegFieldYear => 'Año';

  @override
  String get driverRegFieldColor => 'Color';

  @override
  String get driverRegHintTypeOrPickColor => 'Escribe o elige abajo';

  @override
  String get driverRegSectionPlateVin => 'Placa y número de chasis (VIN)';

  @override
  String get driverRegSubtitlePlateUppercase =>
      'La placa se guarda en mayúsculas.';

  @override
  String get driverRegFieldPlate => 'Placa';

  @override
  String get driverRegHintPlateExample => 'Ej. ABC1231';

  @override
  String get driverRegHelperUppercaseSaved => 'Se registra en MAYÚSCULAS';

  @override
  String get driverRegFieldVinChassis => 'VIN / chasis';

  @override
  String get driverRegHintVin17Chars => '17 caracteres alfanuméricos';

  @override
  String get driverRegHelperVehicleDocumentReference =>
      'Como en la tarjeta o documento del vehículo';

  @override
  String get driverRegSectionInsuranceOwnership => 'Seguro y propiedad';

  @override
  String get driverRegSubtitleInsuranceOwnership =>
      'Número de póliza y datos del título de propiedad o documento equivalente.';

  @override
  String get driverRegFieldInsurancePolicyNumber =>
      'Número de póliza de seguro';

  @override
  String get driverRegHintAsPolicy => 'Como en la póliza vigente';

  @override
  String get driverRegFieldTitleDocData =>
      'Título de propiedad / datos del documento';

  @override
  String get driverRegHintReferenceFromDocument =>
      'Referencia según tu documento';

  @override
  String get driverRegIntroVehiclePhotos =>
      'Una foto por cada lado del auto: frente, atrás, lateral izquierdo y lateral derecho. Buena luz y el vehículo completo en el encuadre.';

  @override
  String get driverRegSectionVehicleViews => 'Vistas del vehículo';

  @override
  String get driverRegSubtitleVehicleViews =>
      'Toca cada recuadro para tomar o cambiar la foto; verás una miniatura al cargarla.';

  @override
  String get driverRegPhotoFrontTitle => 'Frente';

  @override
  String get driverRegPhotoFrontHint =>
      'Encuadre el frente; que se vea la placa si corresponde.';

  @override
  String get driverRegPhotoRearTitle => 'Parte trasera';

  @override
  String get driverRegPhotoRearHint => 'Toda la parte posterior del vehículo.';

  @override
  String get driverRegPhotoLeftTitle => 'Lado izquierdo';

  @override
  String get driverRegPhotoLeftHint =>
      'De costado, costado izquierdo completo.';

  @override
  String get driverRegPhotoRightTitle => 'Lado derecho';

  @override
  String get driverRegPhotoRightHint => 'De costado, costado derecho completo.';

  @override
  String get driverRegActionActivate => 'Enviar';

  @override
  String get driverRegActionFinish => 'Finalizar';

  @override
  String get driverRegActionContinue => 'Continuar';

  @override
  String get driverRegActionBack => 'Anterior';

  @override
  String get driverRegActionSave => 'Guardar';

  @override
  String get driverRegCancelTitle => 'Cancelar registro';

  @override
  String get driverRegCancelBodyUser =>
      'Por seguridad, los datos registrados hasta ahora no se guardarán y se eliminará el avance de este registro. Podrás empezar de nuevo cuando quieras.';

  @override
  String get driverRegCancelBodyVehicle =>
      'Por seguridad, el vehículo que estás registrando no se guardará. Tu cuenta y el resto de vehículos no se modifican.';

  @override
  String get driverRegCancelConfirm => 'Sí, cancelar';

  @override
  String get driverRegCancelKeepGoing => 'Seguir';

  @override
  String get driverRegTitleProfileCompletion => 'Completar registro';

  @override
  String get driverRegProfileStepSaved => 'Cambios guardados.';

  @override
  String driverRegProfileRedirectSnackbar(String stepFrom, String stepTo) {
    return 'Según tu registro, abrimos «$stepTo» en lugar de «$stepFrom».';
  }

  @override
  String get driverRegImageReady => 'Imagen lista';

  @override
  String get driverRegTapToUpload => 'Toca para subir';

  @override
  String get driverRegDocFrontTitle => 'Anverso';

  @override
  String get driverRegDocFrontHint => 'Foto y datos principales.';

  @override
  String get driverRegDocBackTitle => 'Reverso';

  @override
  String get driverRegDocBackHint => 'Código, firma o datos adicionales.';

  @override
  String get driverRegLicenseFrontTitle => 'Frontal';

  @override
  String get driverRegLicenseFrontHint => 'Foto y categorías.';

  @override
  String get driverRegLicenseBackTitle => 'Reverso';

  @override
  String get driverRegLicenseBackHint => 'Restricciones u observaciones.';

  @override
  String get driverRegProfilePhotoReadyHint =>
      'Foto lista. Toca el círculo para cambiarla.';

  @override
  String get driverRegProfilePhotoGuideHint =>
      'Asegúrate de que tu rostro esté centrado y con buena iluminación.';

  @override
  String get driverRegTapCardToReplacePhoto =>
      'Toca la tarjeta para reemplazar esta foto.';

  @override
  String get driverRegChangePhoto => 'Cambiar foto';

  @override
  String get driverRegTakeOrChoosePhoto => 'Tomar o elegir foto';

  @override
  String get driverRegColorBlack => 'Negro';

  @override
  String get driverRegColorWhite => 'Blanco';

  @override
  String get driverRegColorGray => 'Gris';

  @override
  String get driverRegColorSilver => 'Plata';

  @override
  String get driverRegColorRed => 'Rojo';

  @override
  String get driverRegColorBlue => 'Azul';

  @override
  String get driverRegColorGreen => 'Verde';

  @override
  String get driverRegColorYellow => 'Amarillo';

  @override
  String get driverRegColorOrange => 'Naranja';

  @override
  String get driverRegColorViolet => 'Violeta';

  @override
  String get driverRegColorBrown => 'Marrón';

  @override
  String get driverRegColorBeige => 'Beige';

  @override
  String get driverRegColorGold => 'Dorado';

  @override
  String get driverLegalSectionTitle => 'Legal y privacidad';

  @override
  String get driverLegalSectionSubtitle =>
      'Consulta los documentos aplicables a tu cuenta y gestiona tus datos.';

  @override
  String get driverLegalPrivacyPolicy => 'Política de privacidad';

  @override
  String get driverLegalTermsOfService => 'Términos de servicio';

  @override
  String get driverLegalDeleteAccountTitle => 'Eliminar cuenta';

  @override
  String driverLegalDeleteAccountBody(int graceDays) {
    return 'Tu cuenta entrará en eliminación programada durante $graceDays días. Al confirmar se cerrará tu sesión y no podrás usar la app. Para recuperarla, inicia sesión con tus credenciales y cancela la solicitud antes de la fecha límite.';
  }

  @override
  String get driverLegalDeleteAccountAction => 'Ver cómo solicitar';

  @override
  String get driverLegalDeleteAccountConfirmSchedule => 'Programar eliminación';

  @override
  String get driverLegalDeleteAccountScheduling => 'Programando eliminación…';

  @override
  String get driverLegalDeleteAccountScheduledSuccess =>
      'Eliminación programada. Tu sesión se cerró; inicia sesión para recuperar tu cuenta antes de la fecha límite.';

  @override
  String get driverLoginAccountDeletionPendingTitle => 'Eliminación programada';

  @override
  String driverLoginAccountDeletionPendingBody(String effectiveDate) {
    return 'Esta cuenta tiene una eliminación programada para el $effectiveDate. No puedes usar la app hasta recuperarla.';
  }

  @override
  String get driverLoginAccountDeletionPendingDateFallback =>
      'la fecha indicada';

  @override
  String get driverLoginAccountDeletionRecover => 'Recuperar cuenta';

  @override
  String get driverLoginAccountDeletionDismiss => 'Entendido';

  @override
  String get driverLoginAccountDeletionRecovering => 'Recuperando cuenta…';

  @override
  String get driverLoginAccountDeletionRecoverSuccess =>
      'Cuenta recuperada. Bienvenido de nuevo.';

  @override
  String get driverLegalDeleteAccountPendingTitle => 'Eliminación programada';

  @override
  String driverLegalDeleteAccountPendingBody(
    String effectiveDate,
    int daysRemaining,
  ) {
    return 'Tu cuenta se eliminará el $effectiveDate. Quedan $daysRemaining días para cancelar y reactivar tu acceso.';
  }

  @override
  String get driverLegalDeleteAccountPendingDateFallback => 'la fecha indicada';

  @override
  String get driverLegalDeleteAccountCancelAction => 'Cancelar eliminación';

  @override
  String get driverLegalDeleteAccountCancelling => 'Cancelando eliminación…';

  @override
  String get driverLegalDeleteAccountCancelSuccess =>
      'Eliminación cancelada. Tu cuenta sigue activa.';

  @override
  String get driverPlayNotificationDisclosureTitle =>
      'Notificaciones de viajes';

  @override
  String get driverPlayNotificationDisclosureBody =>
      'TEXIAPP necesita enviarte notificaciones cuando haya solicitudes de viaje, cambios de estado o mensajes del pasajero mientras trabajas como conductor.';

  @override
  String get driverPlayLocationDisclosureTitle =>
      'Ubicación para recibir viajes';

  @override
  String get driverPlayLocationDisclosureBody =>
      'TEXIAPP usa tu ubicación para mostrarte en el mapa, asignarte viajes cercanos y compartir tu posición con el pasajero durante un viaje activo.';

  @override
  String get driverPlayDisclosureContinue => 'Continuar';

  @override
  String get driverLegalLoginHint =>
      'Al continuar, aceptas nuestras políticas de uso y términos de servicio.';

  @override
  String get driverLegalLoginPrefix => 'Al continuar, aceptas nuestras ';

  @override
  String get driverLegalLoginConjunction => ' y ';

  @override
  String get driverLegalActivatePrefix => 'Al enviar aceptas nuestras ';

  @override
  String get driverLegalUsagePolicies => 'políticas de uso';

  @override
  String get driverLegalRegistrationHint =>
      'Al activar aceptas nuestras políticas de uso.';

  @override
  String get driverPlayCameraDisclosureTitle => 'Acceso a la cámara';

  @override
  String get driverPlayCameraDisclosureBody =>
      'TEXIAPP usa la cámara para capturar documentos de identidad, licencia y fotos de tu vehículo durante el registro. Las imágenes se envían de forma segura para verificación.';

  @override
  String get driverPlayGalleryDisclosureTitle => 'Acceso a fotos';

  @override
  String get driverPlayGalleryDisclosureBody =>
      'TEXIAPP accede a fotos que elijas de tu galería para el registro de conductor. Solo se sube la imagen que selecciones.';

  @override
  String get driverAppUpdateRequiredTitle => 'Actualización requerida';

  @override
  String get driverAppUpdateRequiredMessage =>
      'Hay una nueva versión de Texi Conductor disponible. Actualiza la app para continuar.';

  @override
  String get driverAppUpdateOptionalTitle => 'Nueva versión disponible';

  @override
  String get driverAppUpdateOptionalMessage =>
      'Hay una actualización en Play Store. Te recomendamos instalarla para la mejor experiencia.';

  @override
  String get driverAppUpdateOpenStore => 'Ir a Play Store';

  @override
  String get driverAppUpdateLater => 'Más tarde';

  @override
  String get driverPasswordResetForgotLink => '¿Olvidaste tu contraseña?';

  @override
  String get driverPasswordResetTitle => 'Restablecer contraseña';

  @override
  String get driverPasswordResetLead =>
      'Confirma tu número. Lo más rápido es enviar el mensaje de WhatsApp (el mismo de verificación TEXIAPP). Si prefieres, te enviamos un código al correo.';

  @override
  String get driverPasswordResetWhatsAppCta => 'Verificar con WhatsApp';

  @override
  String get driverPasswordResetEmailCta => 'Enviar código al correo';

  @override
  String get driverPasswordResetWaTitle => 'Verificación por WhatsApp';

  @override
  String get driverPasswordResetWaBody =>
      'Abre WhatsApp y envía el mensaje prescrito. Cuando lo recibamos, vuelve a TEXIAPP para crear tu nueva contraseña.';

  @override
  String get driverPasswordResetWaWaiting =>
      'Esperando el mensaje de WhatsApp…';

  @override
  String get driverPasswordResetEmailMissingBody =>
      'No encontramos un correo en tu cuenta. Ingresa uno para enviarte el código. Lo guardaremos al restablecer la contraseña.';

  @override
  String get driverPasswordResetEmailLabel => 'Correo';

  @override
  String get driverPasswordResetSendCode => 'Enviar código';

  @override
  String driverPasswordResetEmailCodeBody(String email) {
    return 'Ingresa el código que enviamos a $email y crea tu nueva contraseña.';
  }

  @override
  String get driverPasswordResetEmailFallback => 'tu correo';

  @override
  String get driverPasswordResetCodeLabel => 'Código';

  @override
  String get driverPasswordResetNewPasswordBody =>
      'Número confirmado. Crea una contraseña nueva (mínimo 8 caracteres).';

  @override
  String get driverPasswordResetNewPassword => 'Nueva contraseña';

  @override
  String get driverPasswordResetConfirmPassword => 'Repetir contraseña';

  @override
  String get driverPasswordResetSave => 'Guardar contraseña';

  @override
  String get driverPasswordResetSuccess =>
      'Contraseña actualizada. Iniciá sesión con la nueva clave.';

  @override
  String get driverPasswordResetErrorNotFound =>
      'No hay una cuenta de conductor con ese número.';

  @override
  String get driverPasswordResetErrorEmailRequired =>
      'Ingresa un correo para enviarte el código.';

  @override
  String get driverPasswordResetErrorOtpInvalid =>
      'Código incorrecto o expirado.';

  @override
  String get driverPasswordResetErrorNotVerified =>
      'Todavía no confirmamos el mensaje de WhatsApp. Envíalo y vuelve a intentar.';

  @override
  String get driverPasswordResetErrorRateLimit =>
      'Demasiados intentos. Espera unos minutos.';

  @override
  String get driverPasswordResetErrorWaUnavailable =>
      'WhatsApp no está disponible ahora. Probá con el correo.';

  @override
  String get driverPasswordResetErrorEmailConflict =>
      'Ese correo ya está en uso por otra cuenta.';

  @override
  String get driverPasswordResetErrorMismatch =>
      'Las contraseñas no coinciden.';

  @override
  String get driverPasswordResetErrorExpired =>
      'El mensaje de WhatsApp expiró. Volvé a intentarlo.';

  @override
  String get driverChangePasswordTitle => 'Crea tu contraseña';

  @override
  String get driverChangePasswordLead =>
      'Soporte te dio una clave temporal para entrar. Por seguridad, crea ahora una contraseña propia. Esta pantalla solo aparece cuando el reset lo hizo soporte, no cuando recuperas la clave desde la app.';

  @override
  String get driverChangePasswordCurrent => 'Contraseña temporal';

  @override
  String get driverChangePasswordNew => 'Nueva contraseña';

  @override
  String get driverChangePasswordConfirm => 'Repetir nueva contraseña';

  @override
  String get driverChangePasswordSave => 'Guardar y continuar';

  @override
  String get driverChangePasswordSuccess => 'Contraseña actualizada.';

  @override
  String get driverChangePasswordLogout => 'Cerrar sesión';

  @override
  String get driverChangePasswordErrorCurrent =>
      'La contraseña temporal no es correcta.';

  @override
  String get driverChangePasswordErrorSame =>
      'La nueva contraseña debe ser distinta a la temporal.';

  @override
  String get driverChangePasswordErrorGeneric =>
      'No se pudo actualizar la contraseña.';
}
