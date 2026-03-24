import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../login/driver_login_controller.dart';
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
    this.boliviaOnlyMessage,
    this.registrationTokenSaved = false,
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

  /// Si el país no es Bolivia, mensaje informativo (cobertura geo).
  final String? boliviaOnlyMessage;

  /// True si algún `POST` de registro guardó `driver_token` (sesión antes del vehículo).
  final bool registrationTokenSaved;

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
    String? boliviaOnlyMessage,
    bool? registrationTokenSaved,
    bool clearGlobalError = false,
    bool clearBoliviaMessage = false,
    bool clearDepartments = false,
    bool clearLocality = false,
    bool clearDepartmentName = false,
    bool clearPhoneCode = false,
    bool clearCountryName = false,
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
      boliviaOnlyMessage:
          clearBoliviaMessage ? null : (boliviaOnlyMessage ?? this.boliviaOnlyMessage),
      registrationTokenSaved: registrationTokenSaved ?? this.registrationTokenSaved,
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

  void clearError() {
    state = state.copyWith(clearGlobalError: true);
  }

  String? _phoneCodeForCountryName(String countryName) {
    for (final c in state.countries) {
      if (c.name == countryName) return c.phoneCode;
    }
    return null;
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
    if (!isBo) {
      state = state.copyWith(
        selectedCountryName: name,
        selectedCountryPhoneCode: phoneCode,
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
      clearBoliviaMessage: true,
      clearLocality: true,
      clearDepartmentName: true,
      loading: true,
      clearGlobalError: true,
    );
    try {
      final depts = await _repo.fetchDepartmentsForCountry(name);
      state = state.copyWith(
        loading: false,
        departments: depts,
        clearDepartments: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        clearDepartments: true,
        clearDepartmentName: true,
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
      final tok = await _repo.submitDocumentInfo({
        'uuid': uuid,
        'document_type': 1,
        'document_number': documentNumber,
        'front_document': frontB64,
        'back_document': backB64,
        'face_image': faceB64,
        'expire_date': expireDateIso,
      });
      state = state.copyWith(
        loading: false,
        step: 2,
        registrationTokenSaved: tok || state.registrationTokenSaved,
      );
    } catch (e) {
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
      final tok = await _repo.submitDocumentInfo({
        'uuid': uuid,
        'document_type': licenseCategoryTypeId,
        'document_number': documentNumber,
        'front_document': frontB64,
        'back_document': backB64,
        'expire_date': expireDateIso,
      });
      state = state.copyWith(
        loading: false,
        step: 3,
        registrationTokenSaved: tok || state.registrationTokenSaved,
      );
    } catch (e) {
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
      final carUuid = await _repo.submitVehicle({
        'brand': brand,
        'color': color,
        'insurance_policy': insurancePolicy,
        'license_plate': licensePlate,
        'model': model,
        'tittle_deed': titleDeed,
        'vin': vin,
        'year': year,
      });
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
        'car_id': carId,
        'cars': [
          {'image': frontB64, 'image_name': 'front_view.jpg'},
          {'image': backB64, 'image_name': 'back_view.jpg'},
          {'image': leftB64, 'image_name': 'left_side_view.jpg'},
          {'image': rightB64, 'image_name': 'rigth_side_view.jpg'},
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
