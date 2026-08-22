import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../login/driver_login_controller.dart';
import '../session/driver_operational_profile.dart';
import 'driver_registration_models.dart';
import 'driver_registration_repository.dart';
import 'registration_flow_bindings.dart';
import 'registration_flow_server_rehydration.dart';

/// Placeholder de póliza y título cuando la app no los pide (web/portal sí).
/// Alineado al default del backend para `tittle_deed`.
const String kDriverVehicleInsuranceOwnershipPlaceholder = '—';

final driverRegistrationRepositoryProvider =
    Provider<DriverRegistrationRepository>((ref) {
      return DriverRegistrationRepository();
    });

class DriverRegistrationFlowState {
  const DriverRegistrationFlowState({
    this.step = 0,
    this.loading = false,
    this.globalError,
    this.countries = const [],
    this.departments = const [],
    this.selectedCountryName,
    this.selectedCountryPhoneCode,
    this.selectedDepartmentName,
    this.selectedLocalityId,
    this.selectedLocalityLabel,
    this.userUuid,
    this.carUuid,
    this.identityFaceImageB64,
    this.boliviaOnlyMessage,
    this.registrationTokenSaved = false,
    this.presignUploadAvailable = false,
    this.selectedCountryId,
    this.licenseCategories = const [],
    this.registeredLicenseDocumentTypeId,
    this.vehicleCatalog,
    this.vehicleCatalogLoading = false,
    this.vehicleCatalogError,
    this.selectedVehicleTypeId,
    this.selectedVehicleCategoryId,
    this.selectedEnabledServiceTypeIds = const [],
    this.compatSelectedServiceTypeId,
    this.catalogTransportMode,
    this.catalogManufacturerId,
    this.catalogVehicleModelId,
    this.catalogCustomProposal,
    this.supportsSixPassengers = false,
    this.singleStepFromProfile = false,
    this.profileRedirectFromStep,
    this.profileRedirectToStep,
    this.passengerUpgradeOtpRequired = false,
  });

  /// 0 personal+geo, 1 documento identidad, 2 licencia, 3 login bridge, 4 vehículo, 5 fotos
  final int step;
  final bool loading;
  final String? globalError;
  final List<GeoCountry> countries;
  final List<GeoDepartment> departments;

  final String? selectedCountryName;

  /// Código telefónico del país seleccionado (sin +), desde API geo.
  final String? selectedCountryPhoneCode;
  final String? selectedDepartmentName;
  final int? selectedLocalityId;
  final String? selectedLocalityLabel;

  final String? userUuid;
  final String? carUuid;

  /// Foto de perfil / `face_image` solo para documento de identidad (`document_type` 1). No se envía en licencia.
  final String? identityFaceImageB64;

  /// Si el país no es Bolivia, mensaje informativo (cobertura geo).
  final String? boliviaOnlyMessage;

  /// True si algún `POST` de registro guardó `driver_token` (sesión antes del vehículo).
  final bool registrationTokenSaved;

  /// `personal-info` puede devolver `presign_upload_available`; si es true, subimos fotos a S3 y mandamos `*_storage_key`.
  final bool presignUploadAvailable;

  /// `public.countries.id` del país seleccionado (geo).
  final int? selectedCountryId;

  /// Categorías de licencia desde `GET .../license-categories` (vacío si aún no aplica).
  final List<DriverLicenseCategory> licenseCategories;

  /// `document_type` de la licencia ya registrada (`me-profile.license_document_type_id`).
  final int? registeredLicenseDocumentTypeId;

  /// Tras login; guía tipo/categoría/servicios (`GET /api/v2/vehicles/catalog`).
  final VehicleCatalog? vehicleCatalog;
  final bool vehicleCatalogLoading;
  final String? vehicleCatalogError;
  final int? selectedVehicleTypeId;
  final int? selectedVehicleCategoryId;
  final List<int> selectedEnabledServiceTypeIds;

  /// En `compatibility_mode`: un solo `service_type_id` del listado `service_types`.
  final int? compatSelectedServiceTypeId;

  /// `road_vehicle` | `motorcycle` — filtra marca/modelo del catálogo extendido.
  final String? catalogTransportMode;
  final int? catalogManufacturerId;
  final int? catalogVehicleModelId;
  final VehicleCatalogCustomProposal? catalogCustomProposal;
  final bool supportsSixPassengers;

  /// Desde perfil: un solo bloque (sin asistente lineal); no avanzar de paso al guardar.
  final bool singleStepFromProfile;

  /// Snack de UX: perfil pidió paso [profileRedirectFromStep] y el servidor derivó [profileRedirectToStep].
  final int? profileRedirectFromStep;
  final int? profileRedirectToStep;

  /// Tras 409 `REG_PASSENGER_EXISTS_UPGRADE_REQUIRED`: pedir desafío (WA inbound o código) y reenviar personal-info.
  final bool passengerUpgradeOtpRequired;

  DriverRegistrationFlowState copyWith({
    int? step,
    bool? loading,
    String? globalError,
    List<GeoCountry>? countries,
    List<GeoDepartment>? departments,
    String? selectedCountryName,
    String? selectedCountryPhoneCode,
    String? selectedDepartmentName,
    int? selectedLocalityId,
    String? selectedLocalityLabel,
    String? userUuid,
    String? carUuid,
    String? identityFaceImageB64,
    String? boliviaOnlyMessage,
    bool? registrationTokenSaved,
    bool? presignUploadAvailable,
    int? selectedCountryId,
    List<DriverLicenseCategory>? licenseCategories,
    int? registeredLicenseDocumentTypeId,
    VehicleCatalog? vehicleCatalog,
    bool? vehicleCatalogLoading,
    String? vehicleCatalogError,
    int? selectedVehicleTypeId,
    int? selectedVehicleCategoryId,
    List<int>? selectedEnabledServiceTypeIds,
    int? compatSelectedServiceTypeId,
    String? catalogTransportMode,
    int? catalogManufacturerId,
    int? catalogVehicleModelId,
    VehicleCatalogCustomProposal? catalogCustomProposal,
    bool? supportsSixPassengers,
    bool? singleStepFromProfile,
    int? profileRedirectFromStep,
    int? profileRedirectToStep,
    bool? passengerUpgradeOtpRequired,
    bool clearProfileRedirect = false,
    bool clearCatalogModelPicks = false,
    bool clearCatalogVehicleModelId = false,
    bool clearCatalogCustomProposal = false,
    bool clearGlobalError = false,
    bool clearVehicleCatalogError = false,
    bool clearBoliviaMessage = false,
    bool clearDepartments = false,
    bool clearLocality = false,
    bool clearDepartmentName = false,
    bool clearPhoneCode = false,
    bool clearCountryName = false,
    bool clearLicenseCategories = false,
    bool clearRegisteredLicenseDocumentTypeId = false,
  }) {
    return DriverRegistrationFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      globalError: clearGlobalError ? null : (globalError ?? this.globalError),
      countries: countries ?? this.countries,
      departments: clearDepartments
          ? const []
          : (departments ?? this.departments),
      selectedCountryName: clearCountryName
          ? null
          : (selectedCountryName ?? this.selectedCountryName),
      selectedCountryPhoneCode: clearPhoneCode
          ? null
          : (selectedCountryPhoneCode ?? this.selectedCountryPhoneCode),
      selectedDepartmentName: clearDepartmentName
          ? null
          : (selectedDepartmentName ?? this.selectedDepartmentName),
      selectedLocalityId: clearLocality
          ? null
          : (selectedLocalityId ?? this.selectedLocalityId),
      selectedLocalityLabel: clearLocality
          ? null
          : (selectedLocalityLabel ?? this.selectedLocalityLabel),
      userUuid: userUuid ?? this.userUuid,
      carUuid: carUuid ?? this.carUuid,
      identityFaceImageB64: identityFaceImageB64 ?? this.identityFaceImageB64,
      boliviaOnlyMessage: clearBoliviaMessage
          ? null
          : (boliviaOnlyMessage ?? this.boliviaOnlyMessage),
      registrationTokenSaved:
          registrationTokenSaved ?? this.registrationTokenSaved,
      presignUploadAvailable:
          presignUploadAvailable ?? this.presignUploadAvailable,
      selectedCountryId: clearCountryName
          ? null
          : (selectedCountryId ?? this.selectedCountryId),
      licenseCategories: clearCountryName || clearLicenseCategories
          ? const []
          : (licenseCategories ?? this.licenseCategories),
      registeredLicenseDocumentTypeId: clearRegisteredLicenseDocumentTypeId
          ? null
          : (registeredLicenseDocumentTypeId ??
              this.registeredLicenseDocumentTypeId),
      vehicleCatalog: vehicleCatalog ?? this.vehicleCatalog,
      vehicleCatalogLoading:
          vehicleCatalogLoading ?? this.vehicleCatalogLoading,
      vehicleCatalogError: clearVehicleCatalogError
          ? null
          : (vehicleCatalogError ?? this.vehicleCatalogError),
      selectedVehicleTypeId:
          selectedVehicleTypeId ?? this.selectedVehicleTypeId,
      selectedVehicleCategoryId:
          selectedVehicleCategoryId ?? this.selectedVehicleCategoryId,
      selectedEnabledServiceTypeIds:
          selectedEnabledServiceTypeIds ?? this.selectedEnabledServiceTypeIds,
      compatSelectedServiceTypeId:
          compatSelectedServiceTypeId ?? this.compatSelectedServiceTypeId,
      catalogTransportMode: catalogTransportMode ?? this.catalogTransportMode,
      catalogManufacturerId: clearCatalogModelPicks
          ? null
          : (catalogManufacturerId ?? this.catalogManufacturerId),
      catalogVehicleModelId:
          clearCatalogModelPicks || clearCatalogVehicleModelId
          ? null
          : (catalogVehicleModelId ?? this.catalogVehicleModelId),
      catalogCustomProposal: clearCatalogModelPicks || clearCatalogCustomProposal
          ? null
          : (catalogCustomProposal ?? this.catalogCustomProposal),
      supportsSixPassengers: supportsSixPassengers ?? this.supportsSixPassengers,
      singleStepFromProfile:
          singleStepFromProfile ?? this.singleStepFromProfile,
      profileRedirectFromStep: clearProfileRedirect
          ? null
          : (profileRedirectFromStep ?? this.profileRedirectFromStep),
      profileRedirectToStep: clearProfileRedirect
          ? null
          : (profileRedirectToStep ?? this.profileRedirectToStep),
      passengerUpgradeOtpRequired:
          passengerUpgradeOtpRequired ?? this.passengerUpgradeOtpRequired,
    );
  }

  bool get isBoliviaSelected {
    final n = selectedCountryName?.toLowerCase().trim() ?? '';
    return n == 'bolivia';
  }

  bool get canDeclareSixPassengerSeats {
    if (catalogTransportMode == 'motorcycle') return false;
    final cat = vehicleCatalog;
    if (cat == null) return catalogTransportMode != 'motorcycle';
    for (final id in selectedEnabledServiceTypeIds) {
      final code = (cat.serviceTypeCodeFor(id) ?? '').toLowerCase();
      if (code.contains('moto') || code.contains('two_wheel')) continue;
      if (code.contains('econom') ||
          code.contains('comfort') ||
          code.contains('confort') ||
          code.contains('exclus') ||
          code.contains('premium') ||
          code.contains('standard') ||
          code.contains('estandar')) {
        return true;
      }
    }
    return selectedEnabledServiceTypeIds.isEmpty &&
        catalogTransportMode != 'motorcycle';
  }
}

class DriverRegistrationFlowController
    extends StateNotifier<DriverRegistrationFlowState> {
  DriverRegistrationFlowController(this._ref, this._repo)
    : super(const DriverRegistrationFlowState());

  final Ref _ref;
  final DriverRegistrationRepository _repo;

  Future<void>? _rehydrateInFlight;
  int? _lastRehydratedStep;

  /// Reintentos breves antes de caer a Base64 en JSON (reduce evidencias inline gigantes en DB).
  static const List<Duration> _presignRetryDelays = [
    Duration.zero,
    Duration(milliseconds: 450),
    Duration(milliseconds: 1100),
  ];

  /// Vehículo: un intento extra (S3 / red inestable en 4 PUT seguidos).
  static const List<Duration> _vehiclePresignRetryDelays = [
    Duration.zero,
    Duration(milliseconds: 450),
    Duration(milliseconds: 1100),
    Duration(milliseconds: 2000),
  ];

  Future<String?> _registrationPresignWithRetries({
    required String uuid,
    required String purpose,
    required String base64Raw,
  }) async {
    for (var i = 0; i < _presignRetryDelays.length; i++) {
      final d = _presignRetryDelays[i];
      if (d > Duration.zero) await Future<void>.delayed(d);
      final sk = await _repo.uploadRegistrationImageViaPresign(
        uuid: uuid,
        purpose: purpose,
        base64Raw: base64Raw,
      );
      if (sk != null) return sk;
    }
    return null;
  }

  Future<String?> _vehiclePresignWithRetries({
    required String vehicleAssetId,
    required String purpose,
    required String base64Raw,
  }) async {
    for (var i = 0; i < _vehiclePresignRetryDelays.length; i++) {
      final d = _vehiclePresignRetryDelays[i];
      if (d > Duration.zero) await Future<void>.delayed(d);
      final sk = await _repo.uploadVehicleImageViaPresign(
        vehicleAssetId: vehicleAssetId,
        purpose: purpose,
        base64Raw: base64Raw,
      );
      if (sk != null) return sk;
    }
    return null;
  }

  bool _isDocumentAlreadyRegisteredError(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('ya existe un documento') ||
        raw.contains('documento registrado para este tipo') ||
        (raw.contains('document') &&
            raw.contains('already') &&
            raw.contains('type'));
  }

  Future<void> _assignDocImagePart({
    required Map<String, dynamic> base,
    required String uuid,
    required String purpose,
    required String inlineField,
    required String keyField,
    String? b64,
    String? existingKey,
  }) async {
    if (b64 != null && b64.trim().isNotEmpty) {
      final sk = await _registrationPresignWithRetries(
        uuid: uuid,
        purpose: purpose,
        base64Raw: b64,
      );
      if (sk != null) {
        base[keyField] = sk;
      } else {
        base[inlineField] = b64;
      }
      return;
    }
    if (existingKey != null && existingKey.trim().isNotEmpty) {
      base[keyField] = existingKey.trim();
    }
  }

  Future<Map<String, dynamic>> _identityDocumentPayload({
    required String uuid,
    required String documentNumber,
    required String expireDateIso,
    String? frontB64,
    String? backB64,
    String? faceB64,
    String? frontStorageKey,
    String? backStorageKey,
    String? faceStorageKey,
    int? countryId,
  }) async {
    final base = <String, dynamic>{
      'uuid': uuid,
      'document_type': 1,
      'document_number': documentNumber,
      'expire_date': expireDateIso,
    };
    if (countryId != null) {
      base['country_id'] = countryId;
    }
    await _assignDocImagePart(
      base: base,
      uuid: uuid,
      purpose: 'identity_front',
      inlineField: 'front_document',
      keyField: 'front_document_storage_key',
      b64: frontB64,
      existingKey: frontStorageKey,
    );
    await _assignDocImagePart(
      base: base,
      uuid: uuid,
      purpose: 'identity_back',
      inlineField: 'back_document',
      keyField: 'back_document_storage_key',
      b64: backB64,
      existingKey: backStorageKey,
    );
    await _assignDocImagePart(
      base: base,
      uuid: uuid,
      purpose: 'identity_face',
      inlineField: 'face_image',
      keyField: 'face_image_storage_key',
      b64: faceB64,
      existingKey: faceStorageKey,
    );
    return base;
  }

  Future<Map<String, dynamic>> _licenseDocumentPayload({
    required String uuid,
    required int licenseCategoryTypeId,
    required String documentNumber,
    required String expireDateIso,
    String? frontB64,
    String? backB64,
    String? frontStorageKey,
    String? backStorageKey,
    int? countryId,
  }) async {
    final base = <String, dynamic>{
      'uuid': uuid,
      'document_type': licenseCategoryTypeId,
      'document_number': documentNumber,
      'expire_date': expireDateIso,
    };
    if (countryId != null) {
      base['country_id'] = countryId;
    }
    await _assignDocImagePart(
      base: base,
      uuid: uuid,
      purpose: 'license_front',
      inlineField: 'front_document',
      keyField: 'front_document_storage_key',
      b64: frontB64,
      existingKey: frontStorageKey,
    );
    await _assignDocImagePart(
      base: base,
      uuid: uuid,
      purpose: 'license_back',
      inlineField: 'back_document',
      keyField: 'back_document_storage_key',
      b64: backB64,
      existingKey: backStorageKey,
    );
    return base;
  }

  void clearError() {
    state = state.copyWith(clearGlobalError: true);
  }

  void clearPassengerUpgradePrompt() {
    state = state.copyWith(passengerUpgradeOtpRequired: false);
  }

  void restoreDraftState({
    required int step,
    String? userUuid,
    String? carUuid,
    String? selectedCountryName,
    String? selectedCountryPhoneCode,
    String? selectedDepartmentName,
    int? selectedLocalityId,
    String? selectedLocalityLabel,
    int? selectedCountryId,
    String? identityFaceImageB64,
  }) {
    state = state.copyWith(
      step: step.clamp(0, 5),
      userUuid: userUuid ?? state.userUuid,
      carUuid: carUuid ?? state.carUuid,
      selectedCountryName: selectedCountryName ?? state.selectedCountryName,
      selectedCountryPhoneCode:
          selectedCountryPhoneCode ?? state.selectedCountryPhoneCode,
      selectedDepartmentName:
          selectedDepartmentName ?? state.selectedDepartmentName,
      selectedLocalityId: selectedLocalityId ?? state.selectedLocalityId,
      selectedLocalityLabel:
          selectedLocalityLabel ?? state.selectedLocalityLabel,
      selectedCountryId: selectedCountryId ?? state.selectedCountryId,
      identityFaceImageB64: identityFaceImageB64 ?? state.identityFaceImageB64,
    );
  }

  /// Reinicia el flujo (modos aislados: galería / agregar vehículo).
  void resetFlow() {
    _lastRehydratedStep = null;
    state = const DriverRegistrationFlowState();
  }

  int? _parseProfileInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw == null) return null;
    return int.tryParse(raw.toString().trim());
  }

  Future<void> _applyGeoFromMeProfile(Map<String, dynamic> profile) async {
    final localityId = _parseProfileInt(profile['locality_id']);
    final countryId = _parseProfileInt(profile['registration_country_id']);
    final localityLabel = profile['locality']?.toString().trim();

    if (state.countries.isEmpty) {
      await loadCountries();
    }

    if (countryId != null && countryId > 0) {
      await _selectCountryByIdIfPossible(countryId);
    } else if (registrationFieldIsBlank(state.selectedCountryName) &&
        state.countries.isNotEmpty) {
      GeoCountry? bolivia;
      for (final c in state.countries) {
        if (c.name.toLowerCase().trim() == 'bolivia') {
          bolivia = c;
          break;
        }
      }
      final pick = bolivia ?? state.countries.first;
      await selectCountry(pick.name);
    } else if (!registrationFieldIsBlank(state.selectedCountryName) &&
        state.departments.isEmpty) {
      await selectCountry(state.selectedCountryName);
    }

    if (localityId == null) return;

    if (state.departments.isEmpty &&
        !registrationFieldIsBlank(state.selectedCountryName)) {
      await selectCountry(state.selectedCountryName);
    }

    for (final dept in state.departments) {
      for (final loc in dept.localities) {
        if (loc.id == localityId) {
          state = state.copyWith(
            selectedDepartmentName: dept.name,
            selectedLocalityId: localityId,
            selectedLocalityLabel: loc.name,
          );
          return;
        }
      }
    }

    if (!registrationFieldIsBlank(localityLabel)) {
      state = state.copyWith(
        selectedLocalityId: localityId,
        selectedLocalityLabel: localityLabel,
      );
    } else {
      state = state.copyWith(selectedLocalityId: localityId);
    }
  }

  Future<void> _mergeVehicleFromServer(RegistrationFlowBindings form) async {
    try {
      final vehicles = await _repo.fetchMyVehicleSummaries();
      if (vehicles.isEmpty) return;

      DriverVehicleSummary? pick;
      for (final v in vehicles) {
        if (v.needsGalleryCompletion) {
          pick = v;
          break;
        }
      }
      pick ??= vehicles.first;

      mergeVehicleSummaryIntoRegistrationForm(
        form: form,
        brand: pick.brand,
        model: pick.model,
        year: pick.year,
        color: pick.color,
        vin: pick.vin,
        licensePlate: pick.licensePlate,
      );

      if (registrationFieldIsBlank(state.carUuid)) {
        state = state.copyWith(carUuid: pick.vehicleAssetId);
      }
    } catch (_) {}
  }

  Future<bool> rehydrateFromServerIfNeeded(
    RegistrationFlowBindings form, {
    int? step,
    bool force = false,
  }) async {
    final targetStep = (step ?? state.step).clamp(0, 5);
    final geoMissing = state.selectedLocalityId == null &&
        registrationFieldIsBlank(state.selectedCountryName);
    if (!force &&
        _lastRehydratedStep == targetStep &&
        !registrationFormStepNeedsServerRehydrate(
          form: form,
          step: targetStep,
          geoMissing: geoMissing,
        )) {
      return false;
    }

    if (_rehydrateInFlight != null) {
      await _rehydrateInFlight;
      final geoAfterWait = state.selectedLocalityId == null &&
          registrationFieldIsBlank(state.selectedCountryName);
      if (_lastRehydratedStep == targetStep) {
        return !registrationFormStepNeedsServerRehydrate(
          form: form,
          step: targetStep,
          geoMissing: geoAfterWait,
        );
      }
    }

    final future = _rehydrateFromServerImpl(form, targetStep);
    _rehydrateInFlight = future;
    try {
      await future;
      _lastRehydratedStep = targetStep;
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DriverRegistration] rehydrateFromServerIfNeeded: $e');
      }
      return false;
    } finally {
      _rehydrateInFlight = null;
    }
  }

  Future<void> _rehydrateFromServerImpl(
    RegistrationFlowBindings form,
    int targetStep,
  ) async {
    final hasToken = state.registrationTokenSaved || await _repo.hasDriverToken();
    if (!hasToken) return;

    final profile = await fetchDriverMeProfileData();
    mergeMeProfileIntoRegistrationForm(
      profile: profile,
      form: form,
      countryPhoneCode: state.selectedCountryPhoneCode,
    );
    await _applyGeoFromMeProfile(profile);

    mergeMeProfileIntoRegistrationForm(
      profile: profile,
      form: form,
      countryPhoneCode: state.selectedCountryPhoneCode,
    );

    final profileUuid = profile['uuid']?.toString().trim();
    if (registrationFieldIsBlank(state.userUuid) &&
        profileUuid != null &&
        profileUuid.isNotEmpty) {
      state = state.copyWith(userUuid: profileUuid);
    }

    final licenseTypeId = registrationParseLicenseDocumentTypeId(profile);
    if (licenseTypeId != null) {
      state = state.copyWith(registeredLicenseDocumentTypeId: licenseTypeId);
    }
    applyLicenseCategoryFromProfile(
      form: form,
      categories: state.licenseCategories,
      documentTypeId: licenseTypeId ?? state.registeredLicenseDocumentTypeId,
    );

    if (targetStep >= 4) {
      if (state.countries.isEmpty || state.selectedCountryId == null) {
        await _ensureCountryIdForVehicleOnly();
      }
      if (state.vehicleCatalog == null && !state.vehicleCatalogLoading) {
        await loadVehicleCatalog();
      }
      await _mergeVehicleFromServer(form);
    }
    try {
      final images = await _repo.fetchRegisteredImages();
      applyRegisteredImagesToForm(form: form, data: images);
    } catch (_) {}
  }

  /// Flujo solo vehículo (sesión ya activa, ej. conductor con vehículos que agrega otro).
  Future<void> applyAddVehicleOnlyFromSession() async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final has = await _repo.hasDriverToken();
      if (!has) {
        state = state.copyWith(
          loading: false,
          globalError: 'Inicia sesión para registrar un vehículo.',
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        step: 4,
        registrationTokenSaved: true,
        carUuid: null,
        clearGlobalError: true,
        singleStepFromProfile: false,
        clearProfileRedirect: true,
      );
      await loadCountries();
      await _ensureCountryIdForVehicleOnly();
      await loadVehicleCatalog();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  /// Solo paso 5 (galería) para un `vehicle_asset_id` ya creado (p. ej. falló la subida antes).
  Future<void> applyCompleteVehicleGalleryFromSession(
    String vehicleAssetId,
  ) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final has = await _repo.hasDriverToken();
      if (!has) {
        state = state.copyWith(
          loading: false,
          globalError: 'Inicia sesión para completar las fotos del vehículo.',
        );
        return;
      }
      final id = vehicleAssetId.trim();
      if (id.isEmpty) {
        state = state.copyWith(
          loading: false,
          globalError: 'Identificador de vehículo inválido.',
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        step: 5,
        carUuid: id,
        registrationTokenSaved: true,
        clearGlobalError: true,
        singleStepFromProfile: false,
        clearProfileRedirect: true,
      );
      await loadCountries();
      await _ensureCountryIdForVehicleOnly();
      await loadVehicleCatalog();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  /// Desde [DriverProfile]: abre un paso concreto del flujo (0–5) con sesión existente.
  /// No cierra con “registro completo” — permite reenviar documentos aunque el fase global sea `complete`.
  Future<bool> openProfileRegistrationStep(
    int flowStep, {
    int? preselectedCountryId,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final has = await _repo.hasDriverToken();
      if (!has) {
        state = state.copyWith(
          loading: false,
          globalError: 'Inicia sesión para continuar el registro.',
          singleStepFromProfile: false,
        );
        return false;
      }
      final st = await _repo.fetchRegistrationStatus();
      final clamped = flowStep < 0 ? 0 : (flowStep > 5 ? 5 : flowStep);
      final resolved = st.resolveProfileFlowStep(clamped);
      if (kDebugMode && resolved != clamped) {
        debugPrint(
          '[DriverRegistration] openProfileRegistrationStep: '
          '$clamped → $resolved (checklist/gaps)',
        );
      }
      final step = resolved;
      state = state.copyWith(
        loading: false,
        userUuid: st.uuid.isNotEmpty ? st.uuid : state.userUuid,
        step: step,
        registrationTokenSaved: true,
        clearGlobalError: true,
        singleStepFromProfile: true,
        clearProfileRedirect: resolved == clamped,
        profileRedirectFromStep: resolved != clamped ? clamped : null,
        profileRedirectToStep: resolved != clamped ? resolved : null,
      );
      if (state.countries.isEmpty) {
        await loadCountries();
      }
      if (preselectedCountryId != null) {
        await _selectCountryByIdIfPossible(preselectedCountryId);
      }
      if (step >= 4) {
        await _ensureCountryIdForVehicleOnly();
        await loadVehicleCatalog();
      } else if (step >= 1) {
        final cname = state.selectedCountryName?.trim();
        if (cname != null && cname.isNotEmpty) {
          await selectCountry(cname);
        }
      }
      return true;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
        singleStepFromProfile: false,
      );
      return false;
    }
  }

  Future<void> _selectCountryByIdIfPossible(int countryId) async {
    final list = state.countries;
    if (list.isEmpty) return;
    for (final c in list) {
      if (c.id == countryId) {
        await selectCountry(c.name);
        return;
      }
    }
  }

  /// `true` = registro ya completo según servidor (ir al home).
  Future<bool> applyResumeFromApi() async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final st = await _repo.fetchRegistrationStatus();
      if (st.phase == 'complete') {
        state = state.copyWith(loading: false, clearProfileRedirect: true);
        return true;
      }
      final step = st.suggestedClientStep;
      // Solo falta vehículo/fotos: no reabrimos el asistente completo; el conductor usa menú → Registrar vehículo.
      if (step >= 4) {
        state = state.copyWith(loading: false, clearProfileRedirect: true);
        return true;
      }
      state = state.copyWith(
        loading: false,
        userUuid: st.uuid.isNotEmpty ? st.uuid : state.userUuid,
        step: step,
        registrationTokenSaved: true,
        singleStepFromProfile: false,
        clearProfileRedirect: true,
      );
      unawaited(loadCountries());
      return false;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
      return false;
    }
  }

  Future<void> loadVehicleCatalog() async {
    state = state.copyWith(
      vehicleCatalogLoading: true,
      clearVehicleCatalogError: true,
      clearGlobalError: true,
    );
    try {
      final cat = await _repo.fetchVehicleCatalog();
      if (cat.compatibilityMode) {
        final visible = filterServiceTypesForVehicleRegistrationCompat(
          cat.serviceTypes,
        );
        final sid =
            registrationDefaultCompatServiceTypeId(
              cat,
              visible,
              state.compatSelectedServiceTypeId,
            ) ??
            (visible.isNotEmpty
                ? visible.first.id
                : (cat.serviceTypes.isNotEmpty
                      ? cat.serviceTypes.first.id
                      : 1));
        state = state.copyWith(
          vehicleCatalogLoading: false,
          vehicleCatalog: cat,
          selectedVehicleTypeId: null,
          selectedVehicleCategoryId: null,
          selectedEnabledServiceTypeIds: const [],
          compatSelectedServiceTypeId: sid,
        );
      } else if (cat.vehicleTypes.isEmpty) {
        state = state.copyWith(
          vehicleCatalogLoading: false,
          vehicleCatalog: cat,
          selectedVehicleTypeId: null,
          selectedVehicleCategoryId: null,
          selectedEnabledServiceTypeIds: const [],
          compatSelectedServiceTypeId: null,
        );
      } else {
        final tid = cat.vehicleTypes.first.id;
        final cats = cat.categoriesForType(tid);
        if (cats.isEmpty) {
          state = state.copyWith(
            vehicleCatalogLoading: false,
            vehicleCatalog: cat,
            selectedVehicleTypeId: tid,
            selectedVehicleCategoryId: null,
            selectedEnabledServiceTypeIds: const [],
            compatSelectedServiceTypeId: null,
          );
        } else {
          final c0 = cats.first;
          state = state.copyWith(
            vehicleCatalogLoading: false,
            vehicleCatalog: cat,
            selectedVehicleTypeId: tid,
            selectedVehicleCategoryId: c0.id,
            selectedEnabledServiceTypeIds:
                _enabledServiceIdsDefaultStandardOnly(cat, c0),
            compatSelectedServiceTypeId: null,
          );
        }
      }
      if (cat.catalogExtensionsAvailable &&
          !cat.compatibilityMode &&
          state.selectedVehicleTypeId != null) {
        setCatalogTransportMode(
          _catalogTransportModeStringForVehicleType(
            cat,
            state.selectedVehicleTypeId!,
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(
        vehicleCatalogLoading: false,
        vehicleCatalogError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  /// `road_vehicle` | `motorcycle` según `fleet.vehicle_types` (livianos/carga vs dos ruedas).
  String _catalogTransportModeStringForVehicleType(
    VehicleCatalog cat,
    int typeId,
  ) {
    for (final t in cat.vehicleTypes) {
      if (t.id != typeId) continue;
      final code = t.code.toLowerCase();
      if (code == 'two_wheeler' || code == 'motorcycle') return 'motorcycle';
    }
    return 'road_vehicle';
  }

  VehicleCatalogVehicleType? _vehicleTypeForTransportMode(
    VehicleCatalog cat,
    String mode,
  ) {
    final m = mode.toLowerCase();
    if (m == 'motorcycle') {
      for (final t in cat.vehicleTypes) {
        final c = t.code.toLowerCase();
        if (c == 'two_wheeler' || c == 'motorcycle') return t;
      }
      for (final t in cat.vehicleTypes) {
        final l = t.label.toLowerCase();
        if (l.contains('dos ruedas') || l.contains('motocicleta')) return t;
      }
    } else {
      for (final t in cat.vehicleTypes) {
        final c = t.code.toLowerCase();
        if (c == 'light_motor_vehicle' || c == 'car' || c == 'passenger_car') {
          return t;
        }
      }
      for (final t in cat.vehicleTypes) {
        if (t.code.toLowerCase() != 'two_wheeler') return t;
      }
    }
    return cat.vehicleTypes.isNotEmpty ? cat.vehicleTypes.first : null;
  }

  VehicleCatalogCategory? _defaultCategoryForTypeAndMode(
    VehicleCatalog cat,
    int vehicleTypeId,
    String mode,
  ) {
    final cats = cat.categoriesForType(vehicleTypeId);
    if (cats.isEmpty) return null;
    final m = mode.toLowerCase();
    if (m == 'motorcycle') {
      for (final c in cats) {
        final code = c.code.toLowerCase();
        if (code == 'motorbike_taxi' ||
            code.contains('motorbike') ||
            code.contains('moto')) {
          return c;
        }
      }
      return cats.first;
    }
    for (final c in cats) {
      final code = c.code.toLowerCase();
      if (code == 'sedan_taxi' || code == 'economy_comfort') return c;
    }
    for (final c in cats) {
      if (!c.code.toLowerCase().contains('motorbike') &&
          !c.code.toLowerCase().contains('moto')) {
        return c;
      }
    }
    return cats.first;
  }

  /// Filtra marca/modelo (catálogo DB) y alinea tipo/categoría según `fleet.*` (p. ej. two_wheeler).
  void setCatalogTransportMode(String mode) {
    final cat = state.vehicleCatalog;
    if (cat == null || !cat.catalogExtensionsAvailable) return;
    var vtId = state.selectedVehicleTypeId;
    var catId = state.selectedVehicleCategoryId;
    var stIds = List<int>.from(state.selectedEnabledServiceTypeIds);
    if (!cat.compatibilityMode) {
      final vt = _vehicleTypeForTransportMode(cat, mode);
      if (vt != null) {
        vtId = vt.id;
        final pick = _defaultCategoryForTypeAndMode(cat, vt.id, mode);
        catId = pick?.id;
        stIds = pick != null
            ? _enabledServiceIdsDefaultStandardOnly(cat, pick)
            : const [];
      }
    }
    state = state.copyWith(
      catalogTransportMode: mode,
      clearCatalogModelPicks: true,
      selectedVehicleTypeId: vtId,
      selectedVehicleCategoryId: catId,
      selectedEnabledServiceTypeIds: stIds,
      supportsSixPassengers:
          mode == 'motorcycle' ? false : state.supportsSixPassengers,
    );
  }

  void setCatalogManufacturerId(int? id) {
    state = state.copyWith(
      catalogManufacturerId: id,
      clearCatalogVehicleModelId: true,
      clearCatalogCustomProposal: true,
    );
  }

  void setCatalogVehicleModelId(int? id) {
    state = state.copyWith(catalogVehicleModelId: id);
  }

  void setCatalogCustomProposal(VehicleCatalogCustomProposal? proposal) {
    state = state.copyWith(
      catalogCustomProposal: proposal,
      clearCatalogCustomProposal: proposal == null,
    );
  }

  /// Marca/modelo catch-all + propuesta en un solo `copyWith` (no borra la propuesta).
  void applyCatalogCustomSelection({
    int? manufacturerId,
    int? modelId,
    required VehicleCatalogCustomProposal proposal,
  }) {
    state = state.copyWith(
      catalogManufacturerId: manufacturerId ?? state.catalogManufacturerId,
      catalogVehicleModelId: modelId ?? state.catalogVehicleModelId,
      catalogCustomProposal: proposal,
    );
  }

  void selectVehicleCatalogType(int typeId) {
    final cat = state.vehicleCatalog;
    if (cat == null || cat.compatibilityMode) return;
    final cats = cat.categoriesForType(typeId);
    final c0 = cats.isNotEmpty ? cats.first : null;
    final mode = _catalogTransportModeStringForVehicleType(cat, typeId);
    state = state.copyWith(
      clearCatalogModelPicks: true,
      selectedVehicleTypeId: typeId,
      selectedVehicleCategoryId: c0?.id,
      selectedEnabledServiceTypeIds: c0 != null
          ? _enabledServiceIdsDefaultStandardOnly(cat, c0)
          : const [],
      catalogTransportMode: mode,
    );
  }

  void selectVehicleCatalogCategory(int categoryId) {
    final cat = state.vehicleCatalog;
    if (cat == null || cat.compatibilityMode) return;
    final c = cat.categoryById(categoryId);
    if (c == null) return;
    state = state.copyWith(
      selectedVehicleCategoryId: categoryId,
      selectedEnabledServiceTypeIds: _enabledServiceIdsDefaultStandardOnly(
        cat,
        c,
      ),
    );
  }

  void toggleVehicleCatalogServiceType(int serviceTypeId) {
    final cat = state.vehicleCatalog;
    if (cat == null || cat.compatibilityMode) return;
    final category = cat.categoryById(state.selectedVehicleCategoryId);
    if (category == null) return;
    final allowed = registrationServiceTypeIdsForCategory(cat, category);
    if (!allowed.contains(serviceTypeId)) return;
    final cur = List<int>.from(state.selectedEnabledServiceTypeIds);
    final had = cur.contains(serviceTypeId);
    if (had) {
      cur.remove(serviceTypeId);
    } else {
      cur.add(serviceTypeId);
    }
    if (cur.isEmpty) {
      final fb = _defaultServiceTypeIdPreferStandard(cat, allowed);
      if (fb != null) cur.add(fb);
    }
    state = state.copyWith(selectedEnabledServiceTypeIds: cur);
  }

  void selectCompatVehicleServiceType(int serviceTypeId) {
    state = state.copyWith(compatSelectedServiceTypeId: serviceTypeId);
  }

  void setSupportsSixPassengers(bool value) {
    state = state.copyWith(supportsSixPassengers: value);
  }

  /// Prioriza servicio tipo estándar/económico entre los permitidos; si no hay match, el primero.
  int? _defaultServiceTypeIdPreferStandard(
    VehicleCatalog vcat,
    List<int> allowedIds,
  ) {
    if (allowedIds.isEmpty) return null;
    const preferredCodes = <String>{
      'standard',
      'estandar',
      'economy',
      'economico',
      'basic',
      'regular',
    };
    for (final id in allowedIds) {
      final c = vcat.serviceTypeCodeFor(id)?.toLowerCase();
      if (c != null && preferredCodes.contains(c)) return id;
    }
    for (final id in allowedIds) {
      String name = '';
      for (final s in vcat.serviceTypes) {
        if (s.id == id) {
          name = s.name.toLowerCase();
          break;
        }
      }
      if (name.contains('estándar') ||
          name.contains('estandar') ||
          name.contains('standard') ||
          name.contains('económ') ||
          name.contains('economico')) {
        return id;
      }
    }
    return allowedIds.first;
  }

  /// Solo IDs registrables (sin exclusivo) y por defecto únicamente el estándar.
  List<int> _enabledServiceIdsDefaultStandardOnly(
    VehicleCatalog cat,
    VehicleCatalogCategory category,
  ) {
    final reg = registrationServiceTypeIdsForCategory(cat, category);
    if (reg.isEmpty) return [];
    final d = _defaultServiceTypeIdPreferStandard(cat, reg);
    if (d != null) return [d];
    return [reg.first];
  }

  String? _phoneCodeForCountryName(String countryName) {
    for (final c in state.countries) {
      if (c.name == countryName) return c.phoneCode;
    }
    return null;
  }

  int? _countryIdForName(String countryName) {
    for (final c in state.countries) {
      if (c.name == countryName) return c.id;
    }
    return null;
  }

  /// `registration.country_id` en alta v2 sin pasar por paso personal (login incompleto, agregar vehículo).
  Future<void> _ensureCountryIdForVehicleOnly() async {
    if (state.selectedCountryId != null) return;
    try {
      final p = await DriverOperationalProfile.fetch();
      final cid = p.registrationCountryId;
      if (cid != null && cid > 0) {
        if (state.countries.isEmpty) await loadCountries();
        GeoCountry? match;
        for (final c in state.countries) {
          if (c.id == cid) {
            match = c;
            break;
          }
        }
        state = state.copyWith(
          selectedCountryId: cid,
          selectedCountryName: match?.name ?? state.selectedCountryName,
          selectedCountryPhoneCode:
              (match != null && match.phoneCode.isNotEmpty)
              ? match.phoneCode
              : state.selectedCountryPhoneCode,
        );
        return;
      }
    } catch (_) {}
    if (state.countries.isEmpty) {
      await loadCountries();
    }
    GeoCountry? bolivia;
    for (final c in state.countries) {
      if (c.name.toLowerCase().trim() == 'bolivia') {
        bolivia = c;
        break;
      }
    }
    final pick =
        bolivia ?? (state.countries.isNotEmpty ? state.countries.first : null);
    if (pick != null) {
      state = state.copyWith(
        selectedCountryId: pick.id,
        selectedCountryName: pick.name,
        selectedCountryPhoneCode: pick.phoneCode.isNotEmpty
            ? pick.phoneCode
            : state.selectedCountryPhoneCode,
      );
    }
  }

  Future<void> loadCountries() async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final list = await _repo.fetchCountries();
      // UI v1: solo Bolivia visible en registro (catálogo completo sigue en backend).
      final visible = list
          .where((c) => c.name.toLowerCase().trim() == 'bolivia')
          .toList();
      state = state.copyWith(loading: false, countries: visible);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  Future<void> selectCountry(String? name) async {
    if (name == null || name.isEmpty) {
      state = state.copyWith(
        clearCountryName: true,
        clearPhoneCode: true,
        clearDepartments: true,
        clearLocality: true,
        clearDepartmentName: true,
        clearBoliviaMessage: true,
      );
      return;
    }

    final phoneCode = _phoneCodeForCountryName(name);
    final isBo = name.toLowerCase().trim() == 'bolivia';
    final countryId = _countryIdForName(name);

    if (!isBo) {
      state = state.copyWith(
        selectedCountryName: name,
        selectedCountryPhoneCode: phoneCode,
        selectedCountryId: countryId,
        licenseCategories: const [],
        clearDepartments: true,
        clearLocality: true,
        clearDepartmentName: true,
        boliviaOnlyMessage:
            'Este país aún no cuenta con cobertura del servicio TEXIAPP.',
      );
      return;
    }

    state = state.copyWith(
      selectedCountryName: name,
      selectedCountryPhoneCode: phoneCode,
      selectedCountryId: countryId,
      clearBoliviaMessage: true,
      clearLocality: true,
      clearDepartmentName: true,
      clearLicenseCategories: true,
      loading: true,
      clearGlobalError: true,
    );
    try {
      final depts = await _repo.fetchDepartmentsForCountry(name);
      var licenseCats = <DriverLicenseCategory>[];
      if (countryId != null) {
        try {
          licenseCats = await _repo.fetchLicenseCategories(
            countryId: countryId,
          );
        } catch (_) {
          licenseCats = List<DriverLicenseCategory>.from(
            DriverLicenseCategory.legacyBoliviaFallback,
          );
        }
      }
      if (licenseCats.isEmpty) {
        licenseCats = List<DriverLicenseCategory>.from(
          DriverLicenseCategory.legacyBoliviaFallback,
        );
      }
      state = state.copyWith(
        loading: false,
        departments: depts,
        licenseCategories: licenseCats,
        clearDepartments: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        clearDepartments: true,
        clearDepartmentName: true,
        licenseCategories: List<DriverLicenseCategory>.from(
          DriverLicenseCategory.legacyBoliviaFallback,
        ),
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  void selectDepartment(String? deptName) {
    if (deptName == null || deptName.isEmpty) {
      state = state.copyWith(selectedDepartmentName: null, clearLocality: true);
      return;
    }
    state = state.copyWith(
      selectedDepartmentName: deptName,
      clearLocality: true,
    );
  }

  void selectLocality(GeoLocality? loc) {
    if (loc == null) {
      state = state.copyWith(clearLocality: true);
      return;
    }
    state = state.copyWith(
      selectedLocalityId: loc.id,
      selectedLocalityLabel: loc.name,
    );
  }

  List<GeoLocality> localitiesForSelectedDepartment() {
    final dName = state.selectedDepartmentName;
    if (dName == null) return const [];
    for (final d in state.departments) {
      if (d.name == dName) return d.localities;
    }
    return const [];
  }

  Future<void> submitPersonalInfo({
    required String firstName,
    required String lastName,
    required String email,
    required String birthDateIso,
    required String phoneNumber,
    required int localityId,
    required String address,
    required String genderApiValue,
    required String password,
    String? upgradeVerificationCode,
    String? referralCode,
  }) async {
    state = state.copyWith(
      loading: true,
      clearGlobalError: true,
      passengerUpgradeOtpRequired: false,
    );
    try {
      final res = await _repo.submitPersonalInfo({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'birth_date': birthDateIso,
        'phone_number': phoneNumber,
        'locality_id': localityId,
        if (state.selectedCountryId != null)
          'country_id': state.selectedCountryId,
        'profession': 'driver',
        'address': address,
        'gender': genderApiValue,
        'password': password,
        if (upgradeVerificationCode != null &&
            upgradeVerificationCode.trim().isNotEmpty)
          'upgrade_verification_code': upgradeVerificationCode.trim(),
        if (referralCode != null && referralCode.trim().isNotEmpty)
          'referral_code': referralCode.trim().toUpperCase(),
      });
      state = state.copyWith(
        loading: false,
        userUuid: res.uuid,
        registrationTokenSaved: res.tokenSaved || state.registrationTokenSaved,
        presignUploadAvailable: res.presignUploadAvailable,
        step: state.singleStepFromProfile ? state.step : 1,
        passengerUpgradeOtpRequired: false,
      );
    } on DriverRegistrationException catch (e) {
      final code = (e.code ?? '').trim();
      if (code == 'REG_PASSENGER_EXISTS_UPGRADE_REQUIRED') {
        state = state.copyWith(
          loading: false,
          passengerUpgradeOtpRequired: true,
          clearGlobalError: true,
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        passengerUpgradeOtpRequired: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        passengerUpgradeOtpRequired: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  Future<PassengerUpgradeChallenge?> requestPassengerUpgradeOtp(
    String phoneNumber,
  ) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final challenge = await _repo.issuePassengerUpgradeOtp(phoneNumber);
      state = state.copyWith(loading: false);
      return challenge;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
      return null;
    }
  }

  Future<String?> pollPassengerUpgradeChallenge({
    required String phoneE164,
    required String challengeId,
  }) {
    return _repo.getPassengerUpgradeChallengeStatus(
      phoneE164: phoneE164,
      challengeId: challengeId,
    );
  }

  Future<void> submitIdentityDocuments({
    required String uuid,
    required String documentNumber,
    String? frontB64,
    String? backB64,
    String? faceB64,
    String? frontStorageKey,
    String? backStorageKey,
    String? faceStorageKey,
    required String expireDateIso,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final cid = state.selectedCountryId;
      final payload = await _identityDocumentPayload(
        uuid: uuid,
        documentNumber: documentNumber,
        expireDateIso: expireDateIso,
        frontB64: frontB64,
        backB64: backB64,
        faceB64: faceB64,
        frontStorageKey: frontStorageKey,
        backStorageKey: backStorageKey,
        faceStorageKey: faceStorageKey,
        countryId: cid,
      );
      final tok = await _repo.submitDocumentInfo(payload);
      state = state.copyWith(
        loading: false,
        step: state.singleStepFromProfile ? state.step : 2,
        identityFaceImageB64: faceB64,
        registrationTokenSaved: tok || state.registrationTokenSaved,
      );
    } catch (e) {
      if (_isDocumentAlreadyRegisteredError(e)) {
        state = state.copyWith(
          loading: false,
          step: state.singleStepFromProfile ? state.step : 2,
          identityFaceImageB64: faceB64,
          clearGlobalError: true,
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  Future<void> submitLicenseDocuments({
    required String uuid,
    required String documentNumber,
    required int licenseCategoryTypeId,
    String? frontB64,
    String? backB64,
    String? frontStorageKey,
    String? backStorageKey,
    required String expireDateIso,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final cid = state.selectedCountryId;
      final payload = await _licenseDocumentPayload(
        uuid: uuid,
        licenseCategoryTypeId: licenseCategoryTypeId,
        documentNumber: documentNumber,
        expireDateIso: expireDateIso,
        frontB64: frontB64,
        backB64: backB64,
        frontStorageKey: frontStorageKey,
        backStorageKey: backStorageKey,
        countryId: cid,
      );
      final tok = await _repo.submitDocumentInfo(payload);
      state = state.copyWith(
        loading: false,
        step: state.singleStepFromProfile ? state.step : 3,
        registrationTokenSaved: tok || state.registrationTokenSaved,
      );
    } catch (e) {
      if (_isDocumentAlreadyRegisteredError(e)) {
        state = state.copyWith(
          loading: false,
          step: state.singleStepFromProfile ? state.step : 3,
          clearGlobalError: true,
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  /// Tras licencia: `PUT /api/v2/driver/registration/activate` → login. El alta de vehículo sigue en menú → «Registrar vehículo de servicio».
  Future<void> completeLoginAndContinue({
    required String fullPhone,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);

    final uuid = state.userUuid;
    if (uuid == null || uuid.isEmpty) {
      state = state.copyWith(
        loading: false,
        globalError:
            'No se encontró el identificador de usuario. Vuelve al inicio del registro.',
      );
      return;
    }

    try {
      await _repo.driverUpdateUserStatus(uuid: uuid);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
      return;
    }

    var ok = await _ref
        .read(driverLoginControllerProvider.notifier)
        .login(
          fullPhone: fullPhone,
          password: password,
          driverRegistrationInProgress: true,
        );

    if (!ok) {
      final err =
          _ref.read(driverLoginControllerProvider).errorMessage ??
          'No se pudo validar el acceso';
      if (await _repo.hasDriverToken() &&
          _messageSuggestsIncompleteRegistrationOnly(err)) {
        ok = true;
      } else {
        state = state.copyWith(
          loading: false,
          globalError: _friendlyActivationError(err),
        );
        return;
      }
    }

    // Alta inicial: tras activar + login el vehículo se registra desde el menú de la app (no en este asistente).
    state = state.copyWith(loading: false, clearGlobalError: true);
  }

  /// El backend suele devolver este texto cuando bloquea login hasta terminar el alta.
  bool _messageSuggestsIncompleteRegistrationOnly(String message) {
    final m = message.toLowerCase();
    return m.contains('activo') ||
        m.contains('activa') ||
        m.contains('complet') ||
        m.contains('incomplet') ||
        m.contains('registro');
  }

  String _friendlyActivationError(String raw) {
    if (_messageSuggestsIncompleteRegistrationOnly(raw)) {
      return 'Tu cuenta aún no puede iniciar sesión con el flujo habitual porque el registro '
          'no está terminado. El equipo debe permitir sesión durante el alta del vehículo '
          '(o enviar token en las respuestas de registro). Detalle: $raw';
    }
    return raw;
  }

  Future<void> submitVehicle({
    required String brand,
    required String model,
    required int year,
    required String color,
    required String licensePlate,
    required String vin,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final vcat = state.vehicleCatalog;
      if (vcat == null || state.vehicleCatalogLoading) {
        state = state.copyWith(
          loading: false,
          globalError:
              'Espera a que cargue el catálogo del vehículo o reintenta.',
        );
        return;
      }
      if (vcat.compatibilityMode) {
        state = state.copyWith(
          loading: false,
          globalError:
              'El catálogo del servidor no incluye tipo/categoría de vehículo. '
              'Verifica las migraciones de fleet en el backend o contacta a soporte.',
        );
        return;
      }
      var countryId = state.selectedCountryId;
      if (countryId == null) {
        await _ensureCountryIdForVehicleOnly();
        countryId = state.selectedCountryId;
      }
      if (countryId == null) {
        state = state.copyWith(
          loading: false,
          globalError:
              'No se pudo obtener el país para la placa del vehículo. Completa país y localidad en tu perfil o contacta a soporte.',
        );
        return;
      }
      final tid = state.selectedVehicleTypeId;
      final cid = state.selectedVehicleCategoryId;
      if (tid == null || cid == null) {
        state = state.copyWith(
          loading: false,
          globalError: 'Completa tipo de vehículo y categoría.',
        );
        return;
      }
      final category = vcat.categoryById(cid);
      if (category == null) {
        state = state.copyWith(
          loading: false,
          globalError: 'The selected category is invalid. Choose another one.',
        );
        return;
      }
      final regIds = registrationServiceTypeIdsForCategory(vcat, category);
      var effectiveRegIds = List<int>.from(regIds);
      if (effectiveRegIds.isEmpty) {
        // Fallback controlado: algunos entornos preprod aún no cargan vínculos
        // category->service. Permitimos continuar con "standard/economy" si existe.
        final all = vcat.serviceTypes.map((s) => s.id).toList(growable: false);
        final fb = _defaultServiceTypeIdPreferStandard(vcat, all);
        if (fb != null) {
          effectiveRegIds = [fb];
        } else {
          state = state.copyWith(
            loading: false,
            globalError:
                'No services are available for registration in this category. Choose another one or contact support.',
          );
          return;
        }
      }
      var enabled = List<int>.from(state.selectedEnabledServiceTypeIds);
      final hadNoneSelected = enabled.isEmpty;
      if (hadNoneSelected) {
        final fb = _defaultServiceTypeIdPreferStandard(vcat, effectiveRegIds);
        if (fb != null) enabled = [fb];
      }
      if (hadNoneSelected && enabled.isNotEmpty) {
        state = state.copyWith(selectedEnabledServiceTypeIds: enabled);
      }
      if (enabled.isEmpty) {
        state = state.copyWith(
          loading: false,
          globalError:
              'No services are configured for this category. Choose another one or contact support.',
        );
        return;
      }
      for (final e in enabled) {
        if (!effectiveRegIds.contains(e)) {
          state = state.copyWith(
            loading: false,
            globalError:
                'Hay un servicio seleccionado que no aplica a la categoría.',
          );
          return;
        }
      }
      final codes = <String>[];
      for (final e in enabled) {
        final c = vcat.serviceTypeCodeFor(e);
        if (c == null) {
          state = state.copyWith(
            loading: false,
            globalError:
                'El catálogo no trae código de servicio para el ID $e. Reintenta o actualiza la app.',
          );
          return;
        }
        if (!codes.contains(c)) codes.add(c);
      }
      final proposal = state.catalogCustomProposal;
      var effectiveBrand = brand;
      var effectiveModel = model;
      var effectiveYear = year;
      VehicleCatalogCustomProposal? proposalForApi = proposal;
      if (proposal != null) {
        effectiveBrand = proposal.proposedManufacturerName;
        effectiveModel = proposal.proposedModelName;
        effectiveYear = year;
        proposalForApi = VehicleCatalogCustomProposal(
          kind: proposal.kind,
          proposedManufacturerName: proposal.proposedManufacturerName,
          proposedModelName: proposal.proposedModelName,
          proposedModelYear: year,
          selectedManufacturerId: proposal.selectedManufacturerId,
          selectedManufacturerName: proposal.selectedManufacturerName,
        );
      }
      final vcatMfrs = vcat.manufacturers;
      CatalogManufacturer? pickedMfr;
      for (final m in vcatMfrs) {
        if (m.id == state.catalogManufacturerId) {
          pickedMfr = m;
          break;
        }
      }
      CatalogVehicleModelEntry? pickedModel;
      for (final e in vcat.vehicleModels) {
        if (e.id == state.catalogVehicleModelId) {
          pickedModel = e;
          break;
        }
      }
      if ((pickedMfr?.isCatchAll == true || pickedModel?.isCatchAll == true) &&
          proposal == null) {
        state = state.copyWith(
          loading: false,
          globalError: 'catalog_custom_required',
        );
        return;
      }
      final validFrom = DateTime.now().toIso8601String().split('T').first;
      final body = <String, dynamic>{
        'vehicle_type_id': tid,
        'vehicle_category_id': cid,
        'enabled_service_codes': codes,
        'registration': <String, dynamic>{
          'country_id': countryId,
          'plate_number': licensePlate,
          'valid_from': validFrom,
        },
        'model_year': effectiveYear,
        'brand': effectiveBrand,
        'model': effectiveModel,
        'metadata': <String, dynamic>{
          'color': color,
          'insurance_policy': kDriverVehicleInsuranceOwnershipPlaceholder,
          'tittle_deed': kDriverVehicleInsuranceOwnershipPlaceholder,
        },
      };
      if (vin.trim().isNotEmpty) {
        body['vin'] = vin.trim();
      }
      final mfr = state.catalogManufacturerId;
      final mdl = state.catalogVehicleModelId;
      if (mfr != null) body['manufacturer_id'] = mfr;
      if (mdl != null) body['model_id'] = mdl;
      if (proposalForApi != null) {
        body['catalog_proposal'] = proposalForApi.toApiJson();
      }
      final isMoto = state.catalogTransportMode == 'motorcycle' ||
          codes.every((c) => c.toLowerCase().contains('moto'));
      if (isMoto) {
        body['passenger_specs'] = <String, dynamic>{'seat_count_total': 1};
      } else {
        body['passenger_specs'] = <String, dynamic>{
          'seat_count_total': state.supportsSixPassengers ? 6 : 4,
        };
        if (state.supportsSixPassengers) {
          final meta = Map<String, dynamic>.from(
            body['metadata'] as Map<String, dynamic>? ?? const {},
          );
          meta['supports_six_passengers'] = true;
          body['metadata'] = meta;
        }
      }
      final carUuid = await _repo.submitVehicle(body);
      state = state.copyWith(loading: false, carUuid: carUuid, step: 5);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  Future<void> submitVehicleImages({
    required String carId,
    required String frontB64,
    required String backB64,
    required String leftB64,
    required String rightB64,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      // Mismo criterio que documentos con presign: **siempre** intentar PUT por URL firmada
      // (`/api/v2/vehicles/media/presign`). El flag `presign_upload_available` del personal-info
      // solo refiere al relay de **registro conductor**; el vehículo puede tener presign activo
      // aunque el flag sea false — antes omitíamos presign y mandábamos 4× Base64 (JSON enorme
      // → 500 HTML en nginx).
      Future<Map<String, dynamic>> slot({
        required String purpose,
        required String imageName,
        required String b64,
      }) async {
        final sk = await _vehiclePresignWithRetries(
          vehicleAssetId: carId,
          purpose: purpose,
          base64Raw: b64,
        );
        if (sk != null) {
          if (kDebugMode && !state.presignUploadAvailable) {
            debugPrint(
              '[DriverRegistration] vehículo: presign OK ($purpose) '
              '(presign_upload_available=false en personal-info; se usó presign de flota)',
            );
          }
          return <String, dynamic>{
            'image_storage_key': sk,
            'image_name': imageName,
            'purpose': purpose,
          };
        }
        if (state.presignUploadAvailable) {
          throw DriverRegistrationException(
            'No se pudieron subir las fotos del vehículo al almacenamiento seguro. '
            'Reintenta en unos minutos o con otra red. Si sigue igual, escríbenos a soporte.',
          );
        }
        if (kDebugMode) {
          debugPrint(
            '[DriverRegistration] vehículo: presign $purpose falló; '
            'inline Base64 (entorno sin presign en registro — cuerpo puede ser grande)',
          );
        }
        return <String, dynamic>{
          'image': b64,
          'image_name': imageName,
          'purpose': purpose,
        };
      }

      // Secuencial: menos presión concurrente en presign/S3 que cuatro en paralelo.
      final cars = <Map<String, dynamic>>[
        await slot(
          purpose: 'vehicle_front',
          imageName: 'front_view.jpg',
          b64: frontB64,
        ),
        await slot(
          purpose: 'vehicle_back',
          imageName: 'back_view.jpg',
          b64: backB64,
        ),
        await slot(
          purpose: 'vehicle_left',
          imageName: 'left_side_view.jpg',
          b64: leftB64,
        ),
        await slot(
          purpose: 'vehicle_right',
          imageName: 'rigth_side_view.jpg',
          b64: rightB64,
        ),
      ];

      await _repo.submitVehicleImages(<String, dynamic>{
        'vehicle_asset_id': carId,
        'cars': cars,
      });
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }

  /// Reemplazo parcial de ángulos (perfil, bloque aún no verificado).
  Future<void> submitVehicleImagesChanged({
    required String carId,
    String? frontB64,
    String? backB64,
    String? leftB64,
    String? rightB64,
  }) async {
    final parts = <({String purpose, String imageName, String b64})>[];
    if (frontB64 != null && frontB64.isNotEmpty) {
      parts.add((purpose: 'vehicle_front', imageName: 'front_view.jpg', b64: frontB64));
    }
    if (backB64 != null && backB64.isNotEmpty) {
      parts.add((purpose: 'vehicle_back', imageName: 'back_view.jpg', b64: backB64));
    }
    if (leftB64 != null && leftB64.isNotEmpty) {
      parts.add((purpose: 'vehicle_left', imageName: 'left_side_view.jpg', b64: leftB64));
    }
    if (rightB64 != null && rightB64.isNotEmpty) {
      parts.add((purpose: 'vehicle_right', imageName: 'rigth_side_view.jpg', b64: rightB64));
    }
    if (parts.isEmpty) return;
    if (parts.length == 4) {
      await submitVehicleImages(
        carId: carId,
        frontB64: frontB64!,
        backB64: backB64!,
        leftB64: leftB64!,
        rightB64: rightB64!,
      );
      return;
    }
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      Future<Map<String, dynamic>> slot({
        required String purpose,
        required String imageName,
        required String b64,
      }) async {
        final sk = await _vehiclePresignWithRetries(
          vehicleAssetId: carId,
          purpose: purpose,
          base64Raw: b64,
        );
        if (sk != null) {
          return <String, dynamic>{
            'image_storage_key': sk,
            'image_name': imageName,
            'purpose': purpose,
          };
        }
        return <String, dynamic>{
          'image': b64,
          'image_name': imageName,
          'purpose': purpose,
        };
      }

      final cars = <Map<String, dynamic>>[];
      for (final p in parts) {
        cars.add(
          await slot(purpose: p.purpose, imageName: p.imageName, b64: p.b64),
        );
      }
      await _repo.submitVehicleImages(<String, dynamic>{
        'vehicle_asset_id': carId,
        'cars': cars,
      });
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst(
          'DriverRegistrationException: ',
          '',
        ),
      );
    }
  }
  void clearProfileRedirectNotice() {
    state = state.copyWith(clearProfileRedirect: true);
  }

  Future<void> goToStep(
    int s, {
    RegistrationFlowBindings? form,
    bool rehydrateIfEmpty = true,
  }) async {
    final next = s.clamp(0, 5);
    state = state.copyWith(step: next, clearGlobalError: true);
    if (form != null && rehydrateIfEmpty) {
      await rehydrateFromServerIfNeeded(form, step: next);
    }
  }
}

final driverRegistrationFlowControllerProvider =
    StateNotifierProvider<
      DriverRegistrationFlowController,
      DriverRegistrationFlowState
    >((ref) {
      return DriverRegistrationFlowController(
        ref,
        ref.watch(driverRegistrationRepositoryProvider),
      );
    });
