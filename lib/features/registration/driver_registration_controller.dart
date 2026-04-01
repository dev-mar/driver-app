import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../login/driver_login_controller.dart';
import '../session/driver_operational_profile.dart';
import 'driver_registration_models.dart';
import 'driver_registration_repository.dart';

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
    this.selectedCountryId,
    this.licenseCategories = const [],
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

  /// `public.countries.id` del país seleccionado (geo).
  final int? selectedCountryId;

  /// Categorías de licencia desde `GET .../license-categories` (vacío si aún no aplica).
  final List<DriverLicenseCategory> licenseCategories;

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
    int? selectedCountryId,
    List<DriverLicenseCategory>? licenseCategories,
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
    bool clearCatalogModelPicks = false,
    bool clearCatalogVehicleModelId = false,
    bool clearGlobalError = false,
    bool clearVehicleCatalogError = false,
    bool clearBoliviaMessage = false,
    bool clearDepartments = false,
    bool clearLocality = false,
    bool clearDepartmentName = false,
    bool clearPhoneCode = false,
    bool clearCountryName = false,
    bool clearLicenseCategories = false,
  }) {
    return DriverRegistrationFlowState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      globalError: clearGlobalError ? null : (globalError ?? this.globalError),
      countries: countries ?? this.countries,
      departments: clearDepartments ? const [] : (departments ?? this.departments),
      selectedCountryName:
          clearCountryName ? null : (selectedCountryName ?? this.selectedCountryName),
      selectedCountryPhoneCode: clearPhoneCode
          ? null
          : (selectedCountryPhoneCode ?? this.selectedCountryPhoneCode),
      selectedDepartmentName: clearDepartmentName
          ? null
          : (selectedDepartmentName ?? this.selectedDepartmentName),
      selectedLocalityId: clearLocality ? null : (selectedLocalityId ?? this.selectedLocalityId),
      selectedLocalityLabel:
          clearLocality ? null : (selectedLocalityLabel ?? this.selectedLocalityLabel),
      userUuid: userUuid ?? this.userUuid,
      carUuid: carUuid ?? this.carUuid,
      identityFaceImageB64: identityFaceImageB64 ?? this.identityFaceImageB64,
      boliviaOnlyMessage:
          clearBoliviaMessage ? null : (boliviaOnlyMessage ?? this.boliviaOnlyMessage),
      registrationTokenSaved: registrationTokenSaved ?? this.registrationTokenSaved,
      selectedCountryId: clearCountryName ? null : (selectedCountryId ?? this.selectedCountryId),
      licenseCategories: clearCountryName || clearLicenseCategories
          ? const []
          : (licenseCategories ?? this.licenseCategories),
      vehicleCatalog: vehicleCatalog ?? this.vehicleCatalog,
      vehicleCatalogLoading: vehicleCatalogLoading ?? this.vehicleCatalogLoading,
      vehicleCatalogError:
          clearVehicleCatalogError ? null : (vehicleCatalogError ?? this.vehicleCatalogError),
      selectedVehicleTypeId: selectedVehicleTypeId ?? this.selectedVehicleTypeId,
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
      catalogVehicleModelId: clearCatalogModelPicks || clearCatalogVehicleModelId
          ? null
          : (catalogVehicleModelId ?? this.catalogVehicleModelId),
    );
  }

  bool get isBoliviaSelected {
    final n = selectedCountryName?.toLowerCase().trim() ?? '';
    return n == 'bolivia';
  }
}

class DriverRegistrationFlowController
    extends StateNotifier<DriverRegistrationFlowState> {
  DriverRegistrationFlowController(this._ref, this._repo)
      : super(const DriverRegistrationFlowState());

  final Ref _ref;
  final DriverRegistrationRepository _repo;

  bool _isDocumentAlreadyRegisteredError(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('ya existe un documento') ||
        raw.contains('documento registrado para este tipo') ||
        (raw.contains('document') && raw.contains('already') && raw.contains('type'));
  }

  void clearError() {
    state = state.copyWith(clearGlobalError: true);
  }

  /// Reinicia el flujo (p. ej. antes de reanudar con datos del servidor).
  void resetFlow() {
    state = const DriverRegistrationFlowState();
  }

  /// Flujo solo vehículo (sesión ya activa, ej. conductor con vehículos que agrega otro).
  Future<void> applyAddVehicleOnlyFromSession() async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final has = await _repo.hasDriverToken();
      if (!has) {
        state = state.copyWith(
          loading: false,
          globalError:
              'Iniciá sesión para registrar un vehículo.',
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        step: 4,
        registrationTokenSaved: true,
        carUuid: null,
        clearGlobalError: true,
      );
      await loadCountries();
      await _ensureCountryIdForVehicleOnly();
      await loadVehicleCatalog();
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
    }
  }

  /// `true` = registro ya completo según servidor (ir al home).
  Future<bool> applyResumeFromApi() async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final st = await _repo.fetchRegistrationStatus();
      if (st.phase == 'complete') {
        state = state.copyWith(loading: false);
        return true;
      }
      final step = st.suggestedClientStep;
      state = state.copyWith(
        loading: false,
        userUuid: st.uuid.isNotEmpty ? st.uuid : state.userUuid,
        step: step,
        registrationTokenSaved: true,
      );
      if (step >= 4) {
        await loadCountries();
        await _ensureCountryIdForVehicleOnly();
        await loadVehicleCatalog();
      } else {
        unawaited(loadCountries());
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
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
        final sid = cat.serviceTypes.isNotEmpty ? cat.serviceTypes.first.id : 1;
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
            selectedEnabledServiceTypeIds: List<int>.from(c0.serviceTypeIds),
            compatSelectedServiceTypeId: null,
          );
        }
      }
      if (cat.catalogExtensionsAvailable) {
        setCatalogTransportMode('road_vehicle');
      }
    } catch (e) {
      state = state.copyWith(
        vehicleCatalogLoading: false,
        vehicleCatalogError:
            e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
    }
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
        stIds = pick != null ? List<int>.from(pick.serviceTypeIds) : const [];
      }
    }
    state = state.copyWith(
      catalogTransportMode: mode,
      clearCatalogModelPicks: true,
      selectedVehicleTypeId: vtId,
      selectedVehicleCategoryId: catId,
      selectedEnabledServiceTypeIds: stIds,
    );
  }

  void setCatalogManufacturerId(int? id) {
    state = state.copyWith(
      catalogManufacturerId: id,
      clearCatalogVehicleModelId: true,
    );
  }

  void setCatalogVehicleModelId(int? id) {
    state = state.copyWith(catalogVehicleModelId: id);
  }

  void selectVehicleCatalogType(int typeId) {
    final cat = state.vehicleCatalog;
    if (cat == null || cat.compatibilityMode) return;
    final cats = cat.categoriesForType(typeId);
    final c0 = cats.isNotEmpty ? cats.first : null;
    state = state.copyWith(
      clearCatalogModelPicks: true,
      selectedVehicleTypeId: typeId,
      selectedVehicleCategoryId: c0?.id,
      selectedEnabledServiceTypeIds:
          c0 != null ? List<int>.from(c0.serviceTypeIds) : const [],
    );
  }

  void selectVehicleCatalogCategory(int categoryId) {
    final cat = state.vehicleCatalog;
    if (cat == null || cat.compatibilityMode) return;
    final c = cat.categoryById(categoryId);
    if (c == null) return;
    state = state.copyWith(
      selectedVehicleCategoryId: categoryId,
      selectedEnabledServiceTypeIds: List<int>.from(c.serviceTypeIds),
    );
  }

  void toggleVehicleCatalogServiceType(int serviceTypeId) {
    final cat = state.vehicleCatalog;
    if (cat == null || cat.compatibilityMode) return;
    final allowed = cat.categoryById(state.selectedVehicleCategoryId)?.serviceTypeIds ?? const [];
    if (!allowed.contains(serviceTypeId)) return;
    final cur = List<int>.from(state.selectedEnabledServiceTypeIds);
    final had = cur.contains(serviceTypeId);
    if (had) {
      cur.remove(serviceTypeId);
    } else {
      cur.add(serviceTypeId);
    }
    state = state.copyWith(selectedEnabledServiceTypeIds: cur);
  }

  void selectCompatVehicleServiceType(int serviceTypeId) {
    state = state.copyWith(compatSelectedServiceTypeId: serviceTypeId);
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
          selectedCountryPhoneCode: (match != null && match.phoneCode.isNotEmpty)
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
    final pick = bolivia ?? (state.countries.isNotEmpty ? state.countries.first : null);
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
      state = state.copyWith(loading: false, countries: list);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
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
            'Este país aún no cuenta con cobertura del servicio Texi.',
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
          licenseCats = await _repo.fetchLicenseCategories(countryId: countryId);
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
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
    }
  }

  void selectDepartment(String? deptName) {
    if (deptName == null || deptName.isEmpty) {
      state = state.copyWith(
        selectedDepartmentName: null,
        clearLocality: true,
      );
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
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final res = await _repo.submitPersonalInfo({
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'birth_date': birthDateIso,
        'phone_number': phoneNumber,
        'locality_id': localityId,
        'profession': 'driver',
        'address': address,
        'gender': genderApiValue,
        'password': password,
      });
      state = state.copyWith(
        loading: false,
        userUuid: res.uuid,
        registrationTokenSaved: res.tokenSaved || state.registrationTokenSaved,
        step: 1,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
    }
  }

  Future<void> submitIdentityDocuments({
    required String uuid,
    required String documentNumber,
    required String frontB64,
    required String backB64,
    required String faceB64,
    required String expireDateIso,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final payload = <String, dynamic>{
        'uuid': uuid,
        'document_type': 1,
        'document_number': documentNumber,
        'front_document': frontB64,
        'back_document': backB64,
        'face_image': faceB64,
        'expire_date': expireDateIso,
      };
      final cid = state.selectedCountryId;
      if (cid != null) {
        payload['country_id'] = cid;
      }
      final tok = await _repo.submitDocumentInfo(payload);
      state = state.copyWith(
        loading: false,
        step: 2,
        identityFaceImageB64: faceB64,
        registrationTokenSaved: tok || state.registrationTokenSaved,
      );
    } catch (e) {
      if (_isDocumentAlreadyRegisteredError(e)) {
        state = state.copyWith(
          loading: false,
          step: 2,
          identityFaceImageB64: faceB64,
          clearGlobalError: true,
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
    }
  }

  Future<void> submitLicenseDocuments({
    required String uuid,
    required String documentNumber,
    required int licenseCategoryTypeId,
    required String frontB64,
    required String backB64,
    required String expireDateIso,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final payload = <String, dynamic>{
        'uuid': uuid,
        'document_type': licenseCategoryTypeId,
        'document_number': documentNumber,
        'front_document': frontB64,
        'back_document': backB64,
        'expire_date': expireDateIso,
      };
      final cid = state.selectedCountryId;
      if (cid != null) {
        payload['country_id'] = cid;
      }
      final tok = await _repo.submitDocumentInfo(payload);
      state = state.copyWith(
        loading: false,
        step: 3,
        registrationTokenSaved: tok || state.registrationTokenSaved,
      );
    } catch (e) {
      if (_isDocumentAlreadyRegisteredError(e)) {
        state = state.copyWith(
          loading: false,
          step: 3,
          clearGlobalError: true,
        );
        return;
      }
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
    }
  }

  /// Tras licencia: `PUT update-user` (activa usuario) → login → token para vehículo.
  Future<void> completeLoginAndContinue({
    required String fullPhone,
    required String password,
  }) async {
    state = state.copyWith(loading: true, clearGlobalError: true);

    final uuid = state.userUuid;
    if (uuid == null || uuid.isEmpty) {
      state = state.copyWith(
        loading: false,
        globalError: 'No se encontró el identificador de usuario. Volvé al inicio del registro.',
      );
      return;
    }

    try {
      await _repo.driverUpdateUserStatus(uuid: uuid);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
      return;
    }

    var ok = await _ref.read(driverLoginControllerProvider.notifier).login(
          fullPhone: fullPhone,
          password: password,
          driverRegistrationInProgress: true,
        );

    if (!ok) {
      final err =
          _ref.read(driverLoginControllerProvider).errorMessage ?? 'No se pudo validar el acceso';
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

    state = state.copyWith(loading: false, step: 4);
    await loadVehicleCatalog();
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
    required String insurancePolicy,
    required String licensePlate,
    required String titleDeed,
    required String vin,
  }) async {
      state = state.copyWith(loading: true, clearGlobalError: true);
    try {
      final vcat = state.vehicleCatalog;
      if (vcat == null || state.vehicleCatalogLoading) {
        state = state.copyWith(
          loading: false,
          globalError: 'Esperá a que cargue el catálogo del vehículo o reintentá.',
        );
        return;
      }
      if (vcat.compatibilityMode) {
        state = state.copyWith(
          loading: false,
          globalError: 'El catálogo del servidor no incluye tipo/categoría de vehículo. '
              'Verificá migraciones fleet en backend o contactá soporte.',
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
              'No se pudo obtener el país para la placa del vehículo. Completá país y localidad en tu perfil o contactá soporte.',
        );
        return;
      }
      final tid = state.selectedVehicleTypeId;
      final cid = state.selectedVehicleCategoryId;
      final enabled = state.selectedEnabledServiceTypeIds;
      if (tid == null || cid == null || enabled.isEmpty) {
        state = state.copyWith(
          loading: false,
          globalError: 'Completá tipo de vehículo, categoría y al menos un servicio.',
        );
        return;
      }
      final category = vcat.categoryById(cid);
      if (category == null || category.serviceTypeIds.isEmpty) {
        state = state.copyWith(
          loading: false,
          globalError: 'La categoría elegida no tiene servicios habilitados. Elegí otra.',
        );
        return;
      }
      for (final e in enabled) {
        if (!category.serviceTypeIds.contains(e)) {
          state = state.copyWith(
            loading: false,
            globalError: 'Hay un servicio seleccionado que no aplica a la categoría.',
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
            globalError: 'El catálogo no trae código de servicio para el ID $e. Reintentá o actualizá la app.',
          );
          return;
        }
        if (!codes.contains(c)) codes.add(c);
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
        'model_year': year,
        'brand': brand,
        'model': model,
        'metadata': <String, dynamic>{
          'color': color,
          'insurance_policy': insurancePolicy,
          'tittle_deed': titleDeed,
        },
      };
      if (vin.trim().isNotEmpty) {
        body['vin'] = vin.trim();
      }
      final mfr = state.catalogManufacturerId;
      final mdl = state.catalogVehicleModelId;
      if (mfr != null) body['manufacturer_id'] = mfr;
      if (mdl != null) body['model_id'] = mdl;
      final carUuid = await _repo.submitVehicle(body);
      state = state.copyWith(loading: false, carUuid: carUuid, step: 5);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
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
      await _repo.submitVehicleImages({
        'vehicle_asset_id': carId,
        'cars': [
          {
            'image': frontB64,
            'image_name': 'front_view.jpg',
            'purpose': 'vehicle_front',
          },
          {
            'image': backB64,
            'image_name': 'back_view.jpg',
            'purpose': 'vehicle_back',
          },
          {
            'image': leftB64,
            'image_name': 'left_side_view.jpg',
            'purpose': 'vehicle_left',
          },
          {
            'image': rightB64,
            'image_name': 'rigth_side_view.jpg',
            'purpose': 'vehicle_right',
          },
        ],
      });
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        globalError: e.toString().replaceFirst('DriverRegistrationException: ', ''),
      );
    }
  }

  void goToStep(int s) {
    state = state.copyWith(step: s, clearGlobalError: true);
  }
}

final driverRegistrationFlowControllerProvider = StateNotifierProvider<
    DriverRegistrationFlowController, DriverRegistrationFlowState>((ref) {
  return DriverRegistrationFlowController(
    ref,
    ref.watch(driverRegistrationRepositoryProvider),
  );
});
