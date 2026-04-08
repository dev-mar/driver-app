import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session/driver_registration_resume_gate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../gen_l10n/app_localizations.dart';
import '../login/driver_login_controller.dart';
import '../login/driver_realtime_controller.dart';
import '../session/driver_operational_profile.dart';
import 'driver_registration_controller.dart';
import 'driver_registration_draft_store.dart';
import 'driver_registration_draft_media_store.dart';
import 'driver_registration_models.dart';
import 'registration_image_helper.dart';
import 'widgets/driver_vehicle_catalog_section.dart';
import 'widgets/registration_section_card.dart';
import 'widgets/registration_soft_info_row.dart';

/// Fuerza MAYÚSCULAS en el campo de placa (convención y coincidencia con documentación).
class _UpperCasePlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Flujo completo de registro de conductor (geo + usuario + documentos + vehículo).
class DriverRegistrationFlowScreen extends ConsumerStatefulWidget {
  const DriverRegistrationFlowScreen({
    super.key,
    this.resumeAfterLogin = false,
    this.addVehicleOnly = false,
  });

  /// Si es true: sesión ya iniciada; se consulta `GET /api/v2/driver/registration` y se salta a la etapa faltante.
  final bool resumeAfterLogin;

  /// Desde home: alta de un vehículo adicional (pasos vehículo + fotos) con sesión activa.
  final bool addVehicleOnly;

  @override
  ConsumerState<DriverRegistrationFlowScreen> createState() =>
      _DriverRegistrationFlowScreenState();
}

class _DriverRegistrationFlowScreenState
    extends ConsumerState<DriverRegistrationFlowScreen> {
  final _formPersonal = GlobalKey<FormState>();
  final _formId = GlobalKey<FormState>();
  final _formLicense = GlobalKey<FormState>();
  final _formVehicle = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneLocalCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();

  final _docNumberCtrl = TextEditingController();
  final _docExpireCtrl = TextEditingController();

  final _licenseExpireCtrl = TextEditingController();

  final _vehicleBrandCtrl = TextEditingController();
  final _vehicleModelCtrl = TextEditingController();
  final _vehicleYearCtrl = TextEditingController(text: '2020');
  final _vehicleColorCtrl = TextEditingController();
  final _vehicleVinCtrl = TextEditingController();
  final _vehiclePlateCtrl = TextEditingController();
  final _vehicleInsuranceCtrl = TextEditingController();
  final _vehicleTitleCtrl = TextEditingController();

  String? _genderValue; // API: Male, Female, Other
  DriverLicenseCategory? _licenseCategory;

  String? _idFrontB64;
  String? _idBackB64;
  String? _faceB64;

  String? _licFrontB64;
  String? _licBackB64;

  String? _carFrontB64;
  String? _carBackB64;
  String? _carLeftB64;
  String? _carRightB64;
  bool _suppressDraftSave = false;
  final Map<String, String?> _draftImagePaths = <String, String?>{};

  Future<void> _persistDraft() async {
    if (_suppressDraftSave || !mounted) return;
    final flow = ref.read(driverRegistrationFlowControllerProvider);
    _draftImagePaths['idFront'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'id_front',
      base64Image: _idFrontB64,
      existingPath: _draftImagePaths['idFront'],
    );
    _draftImagePaths['idBack'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'id_back',
      base64Image: _idBackB64,
      existingPath: _draftImagePaths['idBack'],
    );
    _draftImagePaths['face'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'identity_face',
      base64Image: _faceB64,
      existingPath: _draftImagePaths['face'],
    );
    _draftImagePaths['licenseFront'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'license_front',
      base64Image: _licFrontB64,
      existingPath: _draftImagePaths['licenseFront'],
    );
    _draftImagePaths['licenseBack'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'license_back',
      base64Image: _licBackB64,
      existingPath: _draftImagePaths['licenseBack'],
    );
    _draftImagePaths['carFront'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_front',
      base64Image: _carFrontB64,
      existingPath: _draftImagePaths['carFront'],
    );
    _draftImagePaths['carBack'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_back',
      base64Image: _carBackB64,
      existingPath: _draftImagePaths['carBack'],
    );
    _draftImagePaths['carLeft'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_left',
      base64Image: _carLeftB64,
      existingPath: _draftImagePaths['carLeft'],
    );
    _draftImagePaths['carRight'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_right',
      base64Image: _carRightB64,
      existingPath: _draftImagePaths['carRight'],
    );

    final draft = DriverRegistrationDraft(
      step: flow.step,
      userUuid: flow.userUuid,
      carUuid: flow.carUuid,
      selectedCountryName: flow.selectedCountryName,
      selectedCountryPhoneCode: flow.selectedCountryPhoneCode,
      selectedDepartmentName: flow.selectedDepartmentName,
      selectedLocalityId: flow.selectedLocalityId,
      selectedLocalityLabel: flow.selectedLocalityLabel,
      selectedCountryId: flow.selectedCountryId,
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phoneLocal: _phoneLocalCtrl.text.trim(),
      birthDateIso: _birthDateCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      genderValue: _genderValue,
      documentNumber: _docNumberCtrl.text.trim(),
      documentExpireIso: _docExpireCtrl.text.trim(),
      licenseExpireIso: _licenseExpireCtrl.text.trim(),
      licenseCategoryId: _licenseCategory?.id,
      idFrontPath: _draftImagePaths['idFront'],
      idBackPath: _draftImagePaths['idBack'],
      facePath: _draftImagePaths['face'],
      licenseFrontPath: _draftImagePaths['licenseFront'],
      licenseBackPath: _draftImagePaths['licenseBack'],
      vehicleBrand: _vehicleBrandCtrl.text.trim(),
      vehicleModel: _vehicleModelCtrl.text.trim(),
      vehicleYear: _vehicleYearCtrl.text.trim(),
      vehicleColor: _vehicleColorCtrl.text.trim(),
      vehicleVin: _vehicleVinCtrl.text.trim(),
      vehiclePlate: _vehiclePlateCtrl.text.trim(),
      vehicleInsurance: _vehicleInsuranceCtrl.text.trim(),
      vehicleTitle: _vehicleTitleCtrl.text.trim(),
      carFrontPath: _draftImagePaths['carFront'],
      carBackPath: _draftImagePaths['carBack'],
      carLeftPath: _draftImagePaths['carLeft'],
      carRightPath: _draftImagePaths['carRight'],
    );
    await DriverRegistrationDraftStore.save(draft);
  }

  Future<void> _restoreDraftIntoForm(DriverRegistrationDraft draft) async {
    _suppressDraftSave = true;
    try {
      _firstNameCtrl.text = draft.firstName ?? '';
      _lastNameCtrl.text = draft.lastName ?? '';
      _emailCtrl.text = draft.email ?? '';
      _phoneLocalCtrl.text = draft.phoneLocal ?? '';
      _birthDateCtrl.text = draft.birthDateIso ?? '';
      _addressCtrl.text = draft.address ?? '';
      _genderValue = draft.genderValue;
      _docNumberCtrl.text = draft.documentNumber ?? '';
      _docExpireCtrl.text = draft.documentExpireIso ?? '';
      _licenseExpireCtrl.text = draft.licenseExpireIso ?? '';
      _vehicleBrandCtrl.text = draft.vehicleBrand ?? '';
      _vehicleModelCtrl.text = draft.vehicleModel ?? '';
      _vehicleYearCtrl.text = (draft.vehicleYear != null && draft.vehicleYear!.isNotEmpty)
          ? draft.vehicleYear!
          : '2020';
      _vehicleColorCtrl.text = draft.vehicleColor ?? '';
      _vehicleVinCtrl.text = draft.vehicleVin ?? '';
      _vehiclePlateCtrl.text = draft.vehiclePlate ?? '';
      _vehicleInsuranceCtrl.text = draft.vehicleInsurance ?? '';
      _vehicleTitleCtrl.text = draft.vehicleTitle ?? '';
      _draftImagePaths['idFront'] = draft.idFrontPath;
      _draftImagePaths['idBack'] = draft.idBackPath;
      _draftImagePaths['face'] = draft.facePath;
      _draftImagePaths['licenseFront'] = draft.licenseFrontPath;
      _draftImagePaths['licenseBack'] = draft.licenseBackPath;
      _draftImagePaths['carFront'] = draft.carFrontPath;
      _draftImagePaths['carBack'] = draft.carBackPath;
      _draftImagePaths['carLeft'] = draft.carLeftPath;
      _draftImagePaths['carRight'] = draft.carRightPath;
      _idFrontB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.idFrontPath,
          ) ??
          draft.idFrontB64;
      _idBackB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.idBackPath,
          ) ??
          draft.idBackB64;
      _faceB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.facePath,
          ) ??
          draft.faceB64;
      _licFrontB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.licenseFrontPath,
          ) ??
          draft.licenseFrontB64;
      _licBackB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.licenseBackPath,
          ) ??
          draft.licenseBackB64;
      _carFrontB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.carFrontPath,
          ) ??
          draft.carFrontB64;
      _carBackB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.carBackPath,
          ) ??
          draft.carBackB64;
      _carLeftB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.carLeftPath,
          ) ??
          draft.carLeftB64;
      _carRightB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.carRightPath,
          ) ??
          draft.carRightB64;
      final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
      notifier.restoreDraftState(
        step: draft.step,
        userUuid: draft.userUuid,
        carUuid: draft.carUuid,
        selectedCountryName: draft.selectedCountryName,
        selectedCountryPhoneCode: draft.selectedCountryPhoneCode,
        selectedDepartmentName: draft.selectedDepartmentName,
        selectedLocalityId: draft.selectedLocalityId,
        selectedLocalityLabel: draft.selectedLocalityLabel,
        selectedCountryId: draft.selectedCountryId,
        identityFaceImageB64: draft.faceB64,
      );
    } finally {
      _suppressDraftSave = false;
    }
  }

  List<String> _stepLabels(AppLocalizations l10n) => [
        l10n.driverRegStepData,
        l10n.driverRegStepIdentity,
        l10n.driverRegStepLicense,
        l10n.driverRegStepAccess,
        l10n.driverRegStepVehicle,
        l10n.driverRegStepPhotos,
      ];

  List<String> _visibleStepLabels(AppLocalizations l10n) {
    if (widget.addVehicleOnly) {
      return [l10n.driverRegStepVehicle, l10n.driverRegStepPhotos];
    }
    return _stepLabels(l10n);
  }

  int _visibleStepIndex(DriverRegistrationFlowState flow) {
    if (widget.addVehicleOnly) return (flow.step - 4).clamp(0, 1);
    return flow.step;
  }

  void _clearVehicleOnlyFields() {
    _vehicleBrandCtrl.clear();
    _vehicleModelCtrl.clear();
    _vehicleYearCtrl.text = '2020';
    _vehicleColorCtrl.clear();
    _vehicleVinCtrl.clear();
    _vehiclePlateCtrl.clear();
    _vehicleInsuranceCtrl.clear();
    _vehicleTitleCtrl.clear();
    _carFrontB64 = null;
    _carBackB64 = null;
    _carLeftB64 = null;
    _carRightB64 = null;
    _draftImagePaths['carFront'] = null;
    _draftImagePaths['carBack'] = null;
    _draftImagePaths['carLeft'] = null;
    _draftImagePaths['carRight'] = null;
  }

  List<MapEntry<String, String>> _genderChoices(AppLocalizations l10n) => [
        MapEntry('Male', l10n.driverProfileGenderMale),
        MapEntry('Female', l10n.driverProfileGenderFemale),
        MapEntry('Other', l10n.driverRegGenderOther),
      ];

  static const _carColorSuggestions = [
    'Negro',
    'Blanco',
    'Gris',
    'Plata',
    'Rojo',
    'Azul',
    'Verde',
    'Amarillo',
    'Naranja',
    'Violeta',
    'Marrón',
    'Beige',
    'Dorado',
    'Otro',
  ];

  String _localizedColor(BuildContext context, String color) {
    final l10n = AppLocalizations.of(context);
    switch (color) {
      case 'Negro':
        return l10n.driverRegColorBlack;
      case 'Blanco':
        return l10n.driverRegColorWhite;
      case 'Gris':
        return l10n.driverRegColorGray;
      case 'Plata':
        return l10n.driverRegColorSilver;
      case 'Rojo':
        return l10n.driverRegColorRed;
      case 'Azul':
        return l10n.driverRegColorBlue;
      case 'Verde':
        return l10n.driverRegColorGreen;
      case 'Amarillo':
        return l10n.driverRegColorYellow;
      case 'Naranja':
        return l10n.driverRegColorOrange;
      case 'Violeta':
        return l10n.driverRegColorViolet;
      case 'Marrón':
        return l10n.driverRegColorBrown;
      case 'Beige':
        return l10n.driverRegColorBeige;
      case 'Dorado':
        return l10n.driverRegColorGold;
      case 'Otro':
        return l10n.driverProfileGenderOther;
      default:
        return color;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
      final draft = await DriverRegistrationDraftStore.load();
      if (draft != null && mounted) {
        await _restoreDraftIntoForm(draft);
        if (draft.licenseCategoryId != null) {
          for (final item in DriverLicenseCategory.legacyBoliviaFallback) {
            if (item.id == draft.licenseCategoryId) {
              _licenseCategory = item;
              break;
            }
          }
        }
        setState(() {});
      }
      if (widget.addVehicleOnly) {
        _clearVehicleOnlyFields();
        notifier.resetFlow();
        await notifier.applyAddVehicleOnlyFromSession();
        if (!mounted) return;
      } else if (widget.resumeAfterLogin) {
        notifier.resetFlow();
        final done = await notifier.applyResumeFromApi();
        if (!mounted) return;
        if (done) {
          DriverRegistrationResumeGate.invalidate();
          context.goNamed(AppRouter.home);
        }
      } else {
        notifier.loadCountries();
      }
      unawaited(_persistDraft());
    });
  }

  @override
  void dispose() {
    unawaited(_persistDraft());
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneLocalCtrl.dispose();
    _birthDateCtrl.dispose();
    _addressCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    _docNumberCtrl.dispose();
    _docExpireCtrl.dispose();
    _licenseExpireCtrl.dispose();
    _vehicleBrandCtrl.dispose();
    _vehicleModelCtrl.dispose();
    _vehicleYearCtrl.dispose();
    _vehicleColorCtrl.dispose();
    _vehicleVinCtrl.dispose();
    _vehiclePlateCtrl.dispose();
    _vehicleInsuranceCtrl.dispose();
    _vehicleTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateToField(TextEditingController c, {bool future = false}) async {
    final now = DateTime.now();
    final initial = future
        ? DateTime(now.year + 3, now.month, now.day)
        : DateTime(now.year - 25, now.month, now.day);
    final first = future ? now : DateTime(1900);
    final last = future ? DateTime(now.year + 30) : now;
    final d = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (d == null) return;
    final iso =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    c.text = iso;
    setState(() {});
  }

  /// Compone E.164 simple: +[código país API][solo dígitos del número local].
  String _composeFullPhone(DriverRegistrationFlowState flow) {
    final code = flow.selectedCountryPhoneCode?.trim() ?? '';
    final digits = _phoneLocalCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (code.isEmpty) return digits.isEmpty ? '' : '+$digits';
    return '+$code$digits';
  }

  /// Feedback háptico al confirmar imagen (mejor sensación táctil).
  void _applyPickedImage(String? b64, void Function(String value) assign) {
    if (b64 == null) return;
    HapticFeedback.lightImpact();
    setState(() => assign(b64));
    unawaited(_persistDraft());
  }

  /// Línea legible: país · departamento · localidad (para resumen del paso Activar).
  String _formatServiceLocation(DriverRegistrationFlowState flow) {
    final parts = <String>[];
    final c = flow.selectedCountryName?.trim();
    if (c != null && c.isNotEmpty) parts.add(c);
    final d = flow.selectedDepartmentName?.trim();
    if (d != null && d.isNotEmpty) parts.add(d);
    final l = flow.selectedLocalityLabel?.trim();
    if (l != null && l.isNotEmpty) parts.add(l);
    if (parts.isEmpty) return '—';
    return parts.join(' · ');
  }

  /// Tema unificado para formularios del flujo (inputs rellenos, bordes redondeados).
  ThemeData _registrationInputTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.85)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  Future<void> _onPrimaryAction() async {
    final l10n = AppLocalizations.of(context);
    final flow = ref.read(driverRegistrationFlowControllerProvider);
    final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
    if (flow.loading) return;
    notifier.clearError();

    switch (flow.step) {
      case 0:
        if (!_formPersonal.currentState!.validate()) return;
        if (!flow.isBoliviaSelected) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackSelectCountryCoverage),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (flow.selectedLocalityId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackSelectDepartmentLocality),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (_passwordCtrl.text != _passwordConfirmCtrl.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackPasswordsMismatch),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        await notifier.submitPersonalInfo(
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          birthDateIso: _birthDateCtrl.text.trim(),
          phoneNumber: _composeFullPhone(flow),
          localityId: flow.selectedLocalityId!,
          address: _addressCtrl.text.trim(),
          genderApiValue: _genderValue ?? 'Other',
          password: _passwordCtrl.text,
        );
        unawaited(_persistDraft());
        return;
      case 1:
        if (!_formId.currentState!.validate()) return;
        if (_idFrontB64 == null ||
            _idBackB64 == null ||
            _faceB64 == null ||
            _docExpireCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackIdentityIncomplete),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final uuid = flow.userUuid;
        if (uuid == null) return;
        await notifier.submitIdentityDocuments(
          uuid: uuid,
          documentNumber: _docNumberCtrl.text.trim(),
          frontB64: _idFrontB64!,
          backB64: _idBackB64!,
          faceB64: _faceB64!,
          expireDateIso: _docExpireCtrl.text.trim(),
        );
        unawaited(_persistDraft());
        return;
      case 2:
        if (!_formLicense.currentState!.validate()) return;
        if (_licenseCategory == null ||
            _licFrontB64 == null ||
            _licBackB64 == null ||
            _licenseExpireCtrl.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.driverRegSnackLicenseIncomplete,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final uuid = flow.userUuid;
        if (uuid == null) return;
        await notifier.submitLicenseDocuments(
          uuid: uuid,
          documentNumber: _docNumberCtrl.text.trim(),
          licenseCategoryTypeId: _licenseCategory!.id,
          frontB64: _licFrontB64!,
          backB64: _licBackB64!,
          expireDateIso: _licenseExpireCtrl.text.trim(),
        );
        unawaited(_persistDraft());
        return;
      case 3:
        await notifier.completeLoginAndContinue(
          fullPhone: _composeFullPhone(flow),
          password: _passwordCtrl.text,
        );
        unawaited(_persistDraft());
        return;
      case 4:
        if (!_formVehicle.currentState!.validate()) return;
        if (flow.vehicleCatalogLoading ||
            flow.vehicleCatalogError != null ||
            flow.vehicleCatalog == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackVehicleCatalogNotReady),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final y = int.tryParse(_vehicleYearCtrl.text.trim());
        if (y == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.driverRegSnackVehicleYearInvalid),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        await notifier.submitVehicle(
          brand: _vehicleBrandCtrl.text.trim(),
          model: _vehicleModelCtrl.text.trim(),
          year: y,
          color: _vehicleColorCtrl.text.trim(),
          insurancePolicy: _vehicleInsuranceCtrl.text.trim(),
          licensePlate: _vehiclePlateCtrl.text.trim().toUpperCase(),
          titleDeed: _vehicleTitleCtrl.text.trim(),
          vin: _vehicleVinCtrl.text.trim().toUpperCase(),
        );
        unawaited(_persistDraft());
        return;
      case 5:
        if (_carFrontB64 == null ||
            _carBackB64 == null ||
            _carLeftB64 == null ||
            _carRightB64 == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.driverRegSnackVehiclePhotosIncomplete,
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final carId = flow.carUuid;
        if (carId == null) return;
        await notifier.submitVehicleImages(
          carId: carId,
          frontB64: _carFrontB64!,
          backB64: _carBackB64!,
          leftB64: _carLeftB64!,
          rightB64: _carRightB64!,
        );
        unawaited(_persistDraft());
        if (!mounted) return;
        final st = ref.read(driverRegistrationFlowControllerProvider);
        if (st.globalError != null) return;
        HapticFeedback.mediumImpact();
        if (widget.resumeAfterLogin || widget.addVehicleOnly) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                widget.addVehicleOnly
                    ? l10n.driverRegAddVehicleDoneTitle
                    : l10n.driverRegResumeDoneTitle,
              ),
              content: Text(
                widget.addVehicleOnly
                    ? l10n.driverRegAddVehicleDoneBody
                    : l10n.driverRegResumeDoneBody,
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    unawaited(DriverRegistrationDraftStore.clear());
                    unawaited(DriverRegistrationDraftMediaStore.clearAll());
                    ref.invalidate(driverOperationalProfileProvider);
                    DriverRegistrationResumeGate.invalidate();
                    if (context.mounted) context.goNamed(AppRouter.home);
                  },
                  child: Text(
                    widget.addVehicleOnly
                        ? l10n.driverRegAddVehicleDoneCta
                        : l10n.driverRegResumeDoneCta,
                  ),
                ),
              ],
            ),
          );
        } else {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surfaceCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(l10n.driverRegDoneTitle),
              content: Text(l10n.driverRegDoneBody),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    unawaited(DriverRegistrationDraftStore.clear());
                    unawaited(DriverRegistrationDraftMediaStore.clearAll());
                    unawaited(() async {
                      await ref
                          .read(driverRealtimeProvider.notifier)
                          .setOnline(false, forceOffline: true);
                      ref.invalidate(driverRealtimeProvider);
                      await ref.read(driverLoginControllerProvider.notifier).logout();
                      if (!mounted) return;
                      context.goNamed(AppRouter.login);
                    }());
                  },
                  child: Text(l10n.driverRegDoneGoLogin),
                ),
              ],
            ),
          );
        }
        return;
    }
  }

  void _goBack() {
    final flow = ref.read(driverRegistrationFlowControllerProvider);
    final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
    if (widget.addVehicleOnly && flow.step <= 4) {
      unawaited(_persistDraft());
      context.goNamed(AppRouter.home);
      return;
    }
    if (flow.step <= 0) {
      unawaited(_persistDraft());
      context.goNamed(AppRouter.login);
      return;
    }
    notifier.goToStep(flow.step - 1);
    unawaited(_persistDraft());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final flow = ref.watch(driverRegistrationFlowControllerProvider);
    final notifier = ref.read(driverRegistrationFlowControllerProvider.notifier);
    final steps = _visibleStepLabels(l10n);
    final visIdx = _visibleStepIndex(flow);
    final progressValue =
        steps.isEmpty ? 0.0 : (visIdx + 1).clamp(1, steps.length) / steps.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.addVehicleOnly
              ? l10n.driverRegAddVehicleTitle
              : l10n.driverRegTitle,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.driverRegStepCounter(
                          (visIdx + 1).toString(),
                          steps.length.toString(),
                        ),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        steps[visIdx.clamp(0, steps.length - 1)],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progressValue,
                      backgroundColor: AppColors.border.withValues(alpha: 0.45),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            if (flow.globalError != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _localizedFlowError(flow.globalError!, l10n),
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.stepSwitcher,
                switchInCurve: AppMotion.standard,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, anim) {
                  return FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, AppMotion.slideDySubtle),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: anim,
                          curve: AppMotion.standard,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey<int>(flow.step),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: _buildStep(flow, notifier),
                  ),
                ),
              ),
            ),
            _RegistrationBottomBar(
              loading: flow.loading,
              step: flow.step,
              lastStepIndex: widget.addVehicleOnly ? 5 : _stepLabels(l10n).length - 1,
              exitStepIndex: widget.addVehicleOnly ? 4 : 0,
              onBack: _goBack,
              onContinue: _onPrimaryAction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(DriverRegistrationFlowState flow, DriverRegistrationFlowController notifier) {
    switch (flow.step) {
      case 0:
        return _buildPersonalStep(flow, notifier);
      case 1:
        return _buildIdentityStep();
      case 2:
        return _buildLicenseStep();
      case 3:
        return _buildAccessBridgeStep(flow);
      case 4:
        return _buildVehicleStep(flow, notifier);
      case 5:
        return _buildVehiclePhotosStep();
      default:
        return const SizedBox.shrink();
    }
  }

  String _localizedFlowError(String raw, AppLocalizations l10n) {
    final msg = raw.trim();
    final low = msg.toLowerCase();
    if (low.contains('driver_id_bridge_missing') ||
        low.contains('legacy para asignar service types')) {
      return l10n.driverRegErrorVehicleServiceBridgeMissing;
    }
    if (low.contains('no se encontró el identificador de usuario')) {
      return l10n.driverRegErrorMissingUserId;
    }
    if (low.contains('espera a que cargue el catálogo del vehículo')) {
      return l10n.driverRegErrorVehicleCatalogLoading;
    }
    if (low.contains('catálogo del servidor no incluye tipo/categoría')) {
      return l10n.driverRegErrorVehicleCatalogIncomplete;
    }
    if (low.contains('completa tipo de vehículo y categoría')) {
      return l10n.driverRegErrorVehicleTypeCategoryRequired;
    }
    if (low.contains('selected category is invalid')) {
      return l10n.driverRegErrorVehicleCategoryInvalid;
    }
    if (low.contains('no services are configured for this category')) {
      return l10n.driverRegErrorVehicleNoServicesConfigured;
    }
    if (low.contains('servicio seleccionado que no aplica a la categoría')) {
      return l10n.driverRegErrorVehicleServiceNotAllowedForCategory;
    }
    if (low.contains('catálogo no trae código de servicio')) {
      return l10n.driverRegErrorVehicleServiceCodeMissing;
    }
    if (low.contains('sesión no disponible')) {
      return l10n.driverRegErrorSessionUnavailable;
    }
    return msg;
  }

  Widget _buildPersonalStep(
    DriverRegistrationFlowState flow,
    DriverRegistrationFlowController notifier,
  ) {
    final l10n = AppLocalizations.of(context);
    return Theme(
      data: _registrationInputTheme(context),
      child: Form(
        key: _formPersonal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIntroBanner(
              message: l10n.driverRegIntroPersonal,
            ),
            const SizedBox(height: 16),
            if (flow.loading && flow.countries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (flow.countries.isEmpty)
              OutlinedButton.icon(
                onPressed: () => notifier.loadCountries(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.driverRegRetryLoadCountries),
              ),
            if (flow.boliviaOnlyMessage != null) ...[
              const SizedBox(height: 8),
              RegistrationSoftInfoRow(text: flow.boliviaOnlyMessage!),
            ],
            const SizedBox(height: 12),
            RegistrationSectionCard(
              title: l10n.driverRegSectionOperationRegion,
              icon: Icons.public_rounded,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey<String>('country-${flow.selectedCountryName ?? 'none'}'),
                  initialValue: flow.selectedCountryName,
                  decoration: InputDecoration(labelText: l10n.driverRegFieldCountry),
                  items: flow.countries
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Text('${c.name}  (+${c.phoneCode})'),
                        ),
                      )
                      .toList(),
                  onChanged: flow.loading
                      ? null
                      : (v) {
                          notifier.selectCountry(v);
                          setState(() {});
                          unawaited(_persistDraft());
                        },
                  validator: (v) => v == null || v.isEmpty ? l10n.driverRegValidationSelectCountry : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  key: ValueKey<String>(
                    'dept-${flow.selectedCountryName ?? 'x'}-${flow.selectedDepartmentName ?? 'x'}',
                  ),
                  initialValue: flow.selectedDepartmentName,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldDepartment,
                    hintText: flow.isBoliviaSelected
                        ? null
                        : l10n.driverRegNoCoverageInCountry,
                  ),
                  items: flow.departments
                      .map((d) => DropdownMenuItem(value: d.name, child: Text(d.name)))
                      .toList(),
                  onChanged: (!flow.isBoliviaSelected || flow.departments.isEmpty)
                      ? null
                      : (v) {
                          notifier.selectDepartment(v);
                          setState(() {});
                          unawaited(_persistDraft());
                        },
                  validator: (v) {
                    if (!flow.isBoliviaSelected) return null;
                    return v == null || v.isEmpty ? l10n.driverRegValidationSelectDepartment : null;
                  },
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final locs = notifier.localitiesForSelectedDepartment();
                    final locOk = flow.selectedLocalityId != null &&
                        locs.any((l) => l.id == flow.selectedLocalityId);
                    return DropdownButtonFormField<int>(
                      key: ValueKey<String>(
                        'loc-${flow.selectedDepartmentName ?? 'x'}-${flow.selectedLocalityId ?? 0}',
                      ),
                      initialValue: locOk ? flow.selectedLocalityId : null,
                      decoration: InputDecoration(
                        labelText: l10n.driverRegFieldLocality,
                        hintText: flow.isBoliviaSelected && locs.isEmpty
                            ? l10n.driverRegChooseDepartmentFirst
                            : (!flow.isBoliviaSelected ? l10n.driverRegNoCoverageInCountry : null),
                      ),
                      items: locs
                          .map(
                            (l) => DropdownMenuItem(
                              value: l.id,
                              child: Text(l.name),
                            ),
                          )
                          .toList(),
                      onChanged: locs.isEmpty
                          ? null
                          : (id) {
                              if (id == null) return;
                              final loc = locs.firstWhere((e) => e.id == id);
                              notifier.selectLocality(loc);
                              setState(() {});
                              unawaited(_persistDraft());
                            },
                      validator: (v) {
                        if (!flow.isBoliviaSelected) return null;
                        return v == null ? l10n.driverRegValidationSelectLocality : null;
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionPersonalData,
              icon: Icons.person_outline_rounded,
              children: [
                TextFormField(
                  controller: _firstNameCtrl,
                  decoration: InputDecoration(labelText: l10n.driverRegFieldFirstName),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _lastNameCtrl,
                  decoration: InputDecoration(labelText: l10n.driverRegFieldLastName),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldEmail,
                    hintText: l10n.driverRegHintOptional,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _birthDateCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.driverProfileFieldBirthDate,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today_rounded),
                      onPressed: () => _pickDateToField(_birthDateCtrl),
                    ),
                  ),
                  onTap: () => _pickDateToField(_birthDateCtrl),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _genderValue,
                  decoration: InputDecoration(labelText: l10n.driverProfileFieldGender),
                  items: _genderChoices(l10n)
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _genderValue = v);
                    unawaited(_persistDraft());
                  },
                  validator: (v) => v == null ? l10n.driverRegValidationSelectOption : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionContact,
              icon: Icons.phone_android_rounded,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Text(
                        flow.selectedCountryPhoneCode != null
                            ? '+${flow.selectedCountryPhoneCode}'
                            : '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneLocalCtrl,
                        enabled: flow.selectedCountryPhoneCode != null,
                        decoration: InputDecoration(
                          labelText: l10n.driverRegFieldPhoneNumber,
                          hintText: flow.selectedCountryPhoneCode != null
                              ? l10n.driverRegHintLocalDigitsOnly
                              : l10n.driverRegChooseCountryFirst,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (flow.selectedCountryPhoneCode == null) {
                            return l10n.driverRegValidationSelectCountry;
                          }
                          final d = (v ?? '').replaceAll(RegExp(r'\D'), '');
                          if (d.length < 6) return l10n.driverRegValidationIncompleteNumber;
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionAddress,
              icon: Icons.home_work_outlined,
              children: [
                TextFormField(
                  controller: _addressCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldAddress,
                    hintText: l10n.driverRegHintAddressReference,
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionPassword,
              icon: Icons.lock_outline_rounded,
              children: [
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.driverLoginPassword,
                    hintText: l10n.driverRegHintMin8Chars,
                  ),
                  validator: (v) =>
                      v == null || v.length < 8 ? l10n.driverRegValidationMin8Chars : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordConfirmCtrl,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.driverRegFieldConfirmPassword),
                  validator: (v) =>
                      v == null || v.isEmpty ? l10n.driverRegValidationRequired : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityStep() {
    final l10n = AppLocalizations.of(context);
    return Theme(
      data: _registrationInputTheme(context),
      child: Form(
        key: _formId,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIntroBanner(message: l10n.driverRegIntroIdentity),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionIdentityDocument,
              icon: Icons.perm_identity_rounded,
              subtitle: l10n.driverRegSubtitleIdentityDocument,
              children: [
                TextFormField(
                  controller: _docNumberCtrl,
                  decoration: InputDecoration(labelText: l10n.driverRegFieldDocumentNumber),
                  keyboardType: TextInputType.text,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _docExpireCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldDocumentExpiry,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.event_rounded),
                      onPressed: () => _pickDateToField(_docExpireCtrl, future: true),
                    ),
                  ),
                  onTap: () => _pickDateToField(_docExpireCtrl, future: true),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionFrontBack,
              icon: Icons.chrome_reader_mode_outlined,
              subtitle: l10n.driverRegSubtitleOneImagePerSide,
              children: [
                _CarnetUploadTile(
                  kind: _CarnetSlotKind.idFront,
                  isSet: _idFrontB64 != null,
                  onTap: () async {
                    final b64 = await pickImageAsBase64(context);
                    _applyPickedImage(b64, (v) => _idFrontB64 = v);
                  },
                ),
                const SizedBox(height: 12),
                _CarnetUploadTile(
                  kind: _CarnetSlotKind.idBack,
                  isSet: _idBackB64 != null,
                  onTap: () async {
                    final b64 = await pickImageAsBase64(context);
                    _applyPickedImage(b64, (v) => _idBackB64 = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionProfilePhoto,
              icon: Icons.face_retouching_natural,
              subtitle: l10n.driverRegSubtitleProfilePhoto,
              children: [
                _ProfilePhotoCircleSlot(
                  base64Image: _faceB64,
                  onTap: () async {
                    final b64 = await pickImageAsBase64(
                      context,
                      kind: DriverRegistrationImageKind.facePortrait,
                    );
                    _applyPickedImage(b64, (v) => _faceB64 = v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseStep() {
    final l10n = AppLocalizations.of(context);
    final flow = ref.watch(driverRegistrationFlowControllerProvider);
    final licenseItems = flow.licenseCategories.isEmpty
        ? DriverLicenseCategory.legacyBoliviaFallback
        : flow.licenseCategories;
    return Theme(
      data: _registrationInputTheme(context),
      child: Form(
        key: _formLicense,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIntroBanner(message: l10n.driverRegIntroLicense),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionCategoryValidity,
              icon: Icons.category_outlined,
              subtitle: l10n.driverRegSubtitleCategoryValidity,
              children: [
                DropdownButtonFormField<DriverLicenseCategory>(
                  key: ValueKey<String>(
                    'lic-cat-${licenseItems.map((e) => e.id).join('-')}-${_licenseCategory?.id ?? 0}',
                  ),
                  initialValue: _licenseCategory,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldCategory,
                    hintText: l10n.driverRegHintCategoryExample,
                  ),
                  items: licenseItems
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Text(c.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _licenseCategory = v);
                    unawaited(_persistDraft());
                  },
                  validator: (v) => v == null ? l10n.driverRegValidationChooseCategory : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _licenseExpireCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldExpiry,
                    hintText: l10n.driverRegHintLicenseExpiryDate,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.event_rounded),
                      onPressed: () =>
                          _pickDateToField(_licenseExpireCtrl, future: true),
                    ),
                  ),
                  onTap: () => _pickDateToField(_licenseExpireCtrl, future: true),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationIndicateExpiryDate : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionLicenseFrontBack,
              icon: Icons.chrome_reader_mode_outlined,
              subtitle: l10n.driverRegSubtitleOneImagePerSide,
              children: [
                _CarnetUploadTile(
                  kind: _CarnetSlotKind.licenseFront,
                  isSet: _licFrontB64 != null,
                  onTap: () async {
                    final b64 = await pickImageAsBase64(context);
                    _applyPickedImage(b64, (v) => _licFrontB64 = v);
                  },
                ),
                const SizedBox(height: 12),
                _CarnetUploadTile(
                  kind: _CarnetSlotKind.licenseBack,
                  isSet: _licBackB64 != null,
                  onTap: () async {
                    final b64 = await pickImageAsBase64(context);
                    _applyPickedImage(b64, (v) => _licBackB64 = v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessBridgeStep(DriverRegistrationFlowState flow) {
    final l10n = AppLocalizations.of(context);
    final phone = _composeFullPhone(flow);
    final fullName = [
      _firstNameCtrl.text.trim(),
      _lastNameCtrl.text.trim(),
    ].where((s) => s.isNotEmpty).join(' ').trim();
    final location = _formatServiceLocation(flow);
    final email = _emailCtrl.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepHeroCard(
          icon: Icons.verified_user_outlined,
          title: l10n.driverRegSectionActivateAccount,
          subtitle: l10n.driverRegSubtitleReviewBeforeContinue,
        ),
        const SizedBox(height: 14),
        RegistrationSectionCard(
          title: l10n.driverRegSectionYourSummary,
          icon: Icons.fact_check_outlined,
          subtitle: l10n.driverRegSubtitleProfileWorkZone,
          children: [
            _InfoTileRow(
              icon: Icons.badge_outlined,
              label: l10n.driverRegFieldFullName,
              value: fullName.isEmpty ? '—' : fullName,
            ),
            const SizedBox(height: 12),
            _InfoTileRow(
              icon: Icons.phone_android_rounded,
              label: l10n.driverProfileFieldPhone,
              value: phone.isEmpty ? '—' : phone,
            ),
            const SizedBox(height: 12),
            _InfoTileRow(
              icon: Icons.place_outlined,
              label: l10n.driverRegFieldServiceArea,
              value: location,
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 12),
              _InfoTileRow(
                icon: Icons.mail_outline_rounded,
                label: l10n.driverProfileFieldEmail,
                value: email,
              ),
            ],
            const SizedBox(height: 14),
            _SoftStatusChip(
              icon: Icons.check_circle_outline_rounded,
              text: l10n.driverRegIdentityLicenseRegistered,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleStep(
    DriverRegistrationFlowState flow,
    DriverRegistrationFlowController notifier,
  ) {
    final l10n = AppLocalizations.of(context);

    return Theme(
      data: _registrationInputTheme(context),
      child: Form(
        key: _formVehicle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepIntroBanner(message: l10n.driverRegIntroVehicle),
            const SizedBox(height: 14),
            DriverVehicleCatalogSection(
              l10n: l10n,
              loading: flow.vehicleCatalogLoading,
              errorMessage: flow.vehicleCatalogError,
              catalog: flow.vehicleCatalog,
              selectedVehicleTypeId: flow.selectedVehicleTypeId,
              selectedVehicleCategoryId: flow.selectedVehicleCategoryId,
              selectedEnabledServiceTypeIds: flow.selectedEnabledServiceTypeIds,
              compatSelectedServiceTypeId: flow.compatSelectedServiceTypeId,
              catalogTransportMode: flow.catalogTransportMode,
              catalogManufacturerId: flow.catalogManufacturerId,
              catalogVehicleModelId: flow.catalogVehicleModelId,
              onReloadCatalog: notifier.loadVehicleCatalog,
              onSelectVehicleType: notifier.selectVehicleCatalogType,
              onSelectVehicleCategory: notifier.selectVehicleCatalogCategory,
              onToggleEnabledServiceType: notifier.toggleVehicleCatalogServiceType,
              onSelectCompatServiceType: notifier.selectCompatVehicleServiceType,
              onSetCatalogTransportMode: notifier.setCatalogTransportMode,
              onSetCatalogManufacturer: notifier.setCatalogManufacturerId,
              onSetCatalogVehicleModel: notifier.setCatalogVehicleModelId,
              onPickCatalogModel: (entry, manufacturerName) {
                setState(() {
                  _vehicleBrandCtrl.text = manufacturerName;
                  _vehicleModelCtrl.text = entry.name;
                  final y = entry.modelYearEnd ?? entry.modelYearStart;
                  if (y != null) _vehicleYearCtrl.text = '$y';
                });
              },
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionVehicleData,
              icon: Icons.label_outline_rounded,
              children: [
                if (flow.catalogVehicleModelId == null) ...[
                  TextFormField(
                    controller: _vehicleBrandCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.driverRegFieldBrand,
                      hintText: l10n.driverRegHintBrandExample,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _vehicleModelCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.driverRegFieldModel,
                      hintText: l10n.driverRegHintModelExample,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                  ),
                  const SizedBox(height: 10),
                ],
                TextFormField(
                  controller: _vehicleYearCtrl,
                  decoration: InputDecoration(labelText: l10n.driverRegFieldYear),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _vehicleColorCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldColor,
                    hintText: l10n.driverRegHintTypeOrPickColor,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _carColorSuggestions
                      .map(
                        (c) => FilterChip(
                          label: Text(_localizedColor(context, c), style: const TextStyle(fontSize: 12)),
                          selected: _vehicleColorCtrl.text.trim() == c,
                          onSelected: (selected) {
                            if (selected) _vehicleColorCtrl.text = c;
                            setState(() {});
                            unawaited(_persistDraft());
                          },
                          selectedColor: AppColors.primary.withValues(alpha: 0.22),
                          checkmarkColor: AppColors.onPrimary,
                          labelStyle: const TextStyle(color: AppColors.textPrimary),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionPlateVin,
              icon: Icons.pin_outlined,
              subtitle: l10n.driverRegSubtitlePlateUppercase,
              children: [
                TextFormField(
                  controller: _vehiclePlateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_UpperCasePlateFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldPlate,
                    hintText: l10n.driverRegHintPlateExample,
                    helperText: l10n.driverRegHelperUppercaseSaved,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _vehicleVinCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [_UpperCasePlateFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldVinChassis,
                    hintText: l10n.driverRegHintVin17Chars,
                    helperText: l10n.driverRegHelperVehicleDocumentReference,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            RegistrationSectionCard(
              title: l10n.driverRegSectionInsuranceOwnership,
              icon: Icons.description_outlined,
              subtitle: l10n.driverRegSubtitleInsuranceOwnership,
              children: [
                TextFormField(
                  controller: _vehicleInsuranceCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldInsurancePolicyNumber,
                    hintText: l10n.driverRegHintAsPolicy,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _vehicleTitleCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.driverRegFieldTitleDocData,
                    hintText: l10n.driverRegHintReferenceFromDocument,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.driverRegValidationRequired : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclePhotosStep() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepIntroBanner(message: l10n.driverRegIntroVehiclePhotos),
        const SizedBox(height: 14),
        RegistrationSectionCard(
          title: l10n.driverRegSectionVehicleViews,
          icon: Icons.grid_view_rounded,
          subtitle: l10n.driverRegSubtitleVehicleViews,
          children: [
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final small = w < 400;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: small ? 2 : 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: small ? 0.85 : 0.75,
                  children: [
                    _CarAngleCard(
                      title: l10n.driverRegPhotoFrontTitle,
                      hint: l10n.driverRegPhotoFrontHint,
                      icon: Icons.directions_car_filled_rounded,
                      isDone: _carFrontB64 != null,
                      previewBase64: _carFrontB64,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(
                          context,
                          kind: DriverRegistrationImageKind.vehicleAngle,
                        );
                        _applyPickedImage(b64, (v) => _carFrontB64 = v);
                      },
                    ),
                    _CarAngleCard(
                      title: l10n.driverRegPhotoRearTitle,
                      hint: l10n.driverRegPhotoRearHint,
                      icon: Icons.directions_car_rounded,
                      isDone: _carBackB64 != null,
                      previewBase64: _carBackB64,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(
                          context,
                          kind: DriverRegistrationImageKind.vehicleAngle,
                        );
                        _applyPickedImage(b64, (v) => _carBackB64 = v);
                      },
                    ),
                    _CarAngleCard(
                      title: l10n.driverRegPhotoLeftTitle,
                      hint: l10n.driverRegPhotoLeftHint,
                      icon: Icons.arrow_back_rounded,
                      isDone: _carLeftB64 != null,
                      previewBase64: _carLeftB64,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(
                          context,
                          kind: DriverRegistrationImageKind.vehicleAngle,
                        );
                        _applyPickedImage(b64, (v) => _carLeftB64 = v);
                      },
                    ),
                    _CarAngleCard(
                      title: l10n.driverRegPhotoRightTitle,
                      hint: l10n.driverRegPhotoRightHint,
                      icon: Icons.arrow_forward_rounded,
                      isDone: _carRightB64 != null,
                      previewBase64: _carRightB64,
                      onTap: () async {
                        final b64 = await pickImageAsBase64(
                          context,
                          kind: DriverRegistrationImageKind.vehicleAngle,
                        );
                        _applyPickedImage(b64, (v) => _carRightB64 = v);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Barra inferior fija: borde superior, sombra y botones redondeados alineados al resto del flujo.
class _RegistrationBottomBar extends StatelessWidget {
  const _RegistrationBottomBar({
    required this.loading,
    required this.step,
    required this.lastStepIndex,
    this.exitStepIndex = 0,
    required this.onBack,
    required this.onContinue,
  });

  final bool loading;
  final int step;
  final int lastStepIndex;
  /// Paso en el que "Atrás" se comporta como salida (cancelar) del flujo.
  final int exitStepIndex;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isFirst = step == exitStepIndex;
    final isLast = step == lastStepIndex;
    final isActivateStep = step == 3;
    final primaryLabel = isActivateStep
        ? l10n.driverRegActionActivate
        : (isLast ? l10n.driverRegActionFinish : l10n.driverRegActionContinue);
    final primaryIcon = isActivateStep
        ? Icons.verified_rounded
        : (isLast ? Icons.check_rounded : Icons.arrow_forward_rounded);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.4)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: loading ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.85),
                    ),
                    foregroundColor: AppColors.textPrimary,
                    backgroundColor: AppColors.surfaceCard,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFirst ? Icons.close_rounded : Icons.arrow_back_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(isFirst ? l10n.commonCancel : l10n.driverRegActionBack),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: loading ? null : onContinue,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    elevation: 0,
                    disabledBackgroundColor: AppColors.border.withValues(alpha: 0.6),
                    disabledForegroundColor: AppColors.textSecondary,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.25,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(primaryLabel),
                            const SizedBox(width: 8),
                            Icon(
                              primaryIcon,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIntroBanner extends StatelessWidget {
  const _StepIntroBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_outlined, size: 20, color: AppColors.primary.withValues(alpha: 0.95)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado positivo breve (sin tecnicismos).
class _SoftStatusChip extends StatelessWidget {
  const _SoftStatusChip({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.38,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Encabezado de paso (misma familia visual que las tarjetas de sección).
class _StepHeroCard extends StatelessWidget {
  const _StepHeroCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTileRow extends StatelessWidget {
  const _InfoTileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lado del documento a fotografiar (identidad o licencia).
enum _CarnetSlotKind { idFront, idBack, licenseFront, licenseBack }

class _CarnetUploadTile extends StatefulWidget {
  const _CarnetUploadTile({
    required this.kind,
    required this.isSet,
    required this.onTap,
  });

  final _CarnetSlotKind kind;
  final bool isSet;
  final VoidCallback onTap;

  @override
  State<_CarnetUploadTile> createState() => _CarnetUploadTileState();
}

class _CarnetUploadTileState extends State<_CarnetUploadTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, hint, miniIcon, miniAccent) = _metaForKind(widget.kind);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (h) => setState(() => _pressed = h),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSet
                    ? AppColors.success
                    : AppColors.border.withValues(alpha: 0.65),
                width: widget.isSet ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _MiniCarnetIllustration(icon: miniIcon, accent: miniAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hint,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.3,
                            color: AppColors.textSecondary.withValues(alpha: 0.95),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              widget.isSet
                                  ? Icons.check_circle_rounded
                                  : Icons.add_photo_alternate_outlined,
                              size: 16,
                              color: widget.isSet
                                  ? AppColors.success
                                  : AppColors.primary.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.isSet
                                  ? l10n.driverRegImageReady
                                  : l10n.driverRegTapToUpload,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.isSet
                                    ? AppColors.success
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  (String, String, IconData, Color) _metaForKind(_CarnetSlotKind k) {
    final l10n = AppLocalizations.of(context);
    switch (k) {
      case _CarnetSlotKind.idFront:
        return (
          l10n.driverRegDocFrontTitle,
          l10n.driverRegDocFrontHint,
          Icons.person_rounded,
          AppColors.primary.withValues(alpha: 0.85),
        );
      case _CarnetSlotKind.idBack:
        return (
          l10n.driverRegDocBackTitle,
          l10n.driverRegDocBackHint,
          Icons.qr_code_2_rounded,
          AppColors.textSecondary.withValues(alpha: 0.9),
        );
      case _CarnetSlotKind.licenseFront:
        return (
          l10n.driverRegLicenseFrontTitle,
          l10n.driverRegLicenseFrontHint,
          Icons.person_rounded,
          AppColors.primary.withValues(alpha: 0.85),
        );
      case _CarnetSlotKind.licenseBack:
        return (
          l10n.driverRegLicenseBackTitle,
          l10n.driverRegLicenseBackHint,
          Icons.qr_code_2_rounded,
          AppColors.textSecondary.withValues(alpha: 0.9),
        );
    }
  }
}

/// Miniatura de referencia para el lado del documento.
class _MiniCarnetIllustration extends StatelessWidget {
  const _MiniCarnetIllustration({
    required this.icon,
    required this.accent,
  });

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.inputFill,
            AppColors.surfaceCard,
          ],
        ),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 2,
            left: 4,
            right: 4,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: AppColors.border.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Icon(icon, size: 28, color: accent),
        ],
      ),
    );
  }
}

/// Foto de perfil con vista previa (base64).
class _ProfilePhotoCircleSlot extends StatefulWidget {
  const _ProfilePhotoCircleSlot({
    required this.base64Image,
    required this.onTap,
  });

  final String? base64Image;
  final VoidCallback onTap;

  @override
  State<_ProfilePhotoCircleSlot> createState() => _ProfilePhotoCircleSlotState();
}

class _ProfilePhotoCircleSlotState extends State<_ProfilePhotoCircleSlot> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasImage = widget.base64Image != null && widget.base64Image!.isNotEmpty;
    Uint8List? bytes;
    if (hasImage) {
      try {
        bytes = base64Decode(widget.base64Image!);
      } catch (_) {
        bytes = null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onTap,
                  onHighlightChanged: (h) => setState(() => _pressed = h),
                  splashColor: AppColors.primary.withValues(alpha: 0.15),
                  highlightColor: AppColors.primary.withValues(alpha: 0.06),
                  child: Ink(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasImage && bytes != null
                            ? AppColors.success
                            : AppColors.primary.withValues(alpha: 0.55),
                        width: hasImage && bytes != null ? 3 : 2,
                      ),
                    ),
                    child: ClipOval(
                      child: bytes != null
                          ? Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              width: 140,
                              height: 140,
                              gaplessPlayback: true,
                            )
                          : Container(
                              color: AppColors.inputFill,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.face_retouching_natural,
                                    size: 48,
                                    color: AppColors.textSecondary.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      l10n.driverRegTapToUpload,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary.withValues(alpha: 0.95),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          hasImage && bytes != null
              ? l10n.driverRegProfilePhotoReadyHint
              : l10n.driverRegProfilePhotoGuideHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.35,
            color: hasImage && bytes != null
                ? AppColors.success.withValues(alpha: 0.95)
                : AppColors.textSecondary,
            fontWeight: hasImage && bytes != null ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PhotoSlot extends StatefulWidget {
  const _PhotoSlot({
    required this.title,
    required this.isSet,
    required this.onTap,
  });

  final String title;
  final bool isSet;
  final VoidCallback onTap;

  @override
  State<_PhotoSlot> createState() => _PhotoSlotState();
}

class _PhotoSlotState extends State<_PhotoSlot> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (h) => setState(() => _pressed = h),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSet
                    ? AppColors.success
                    : AppColors.border.withValues(alpha: 0.65),
                width: widget.isSet ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    widget.isSet ? Icons.check_circle_rounded : Icons.add_a_photo_rounded,
                    color: widget.isSet ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          widget.isSet
                              ? l10n.driverRegImageReady
                              : l10n.driverRegTapToUpload,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isSet ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CarAngleCard extends StatefulWidget {
  const _CarAngleCard({
    required this.title,
    required this.hint,
    required this.icon,
    required this.isDone,
    this.previewBase64,
    required this.onTap,
  });

  final String title;
  final String hint;
  final IconData icon;
  final bool isDone;
  /// Miniatura de la foto elegida (mismo base64 que se envía al servidor).
  final String? previewBase64;
  final VoidCallback onTap;

  @override
  State<_CarAngleCard> createState() => _CarAngleCardState();
}

class _CarAngleCardState extends State<_CarAngleCard> {
  bool _pressed = false;

  Uint8List? _decodePreview(String? b64) {
    if (b64 == null || b64.isEmpty) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preview = _decodePreview(widget.previewBase64);
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (h) => setState(() => _pressed = h),
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withValues(alpha: 0.12),
          highlightColor: AppColors.primary.withValues(alpha: 0.06),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isDone
                    ? AppColors.success
                    : AppColors.border.withValues(alpha: 0.65),
                width: widget.isDone ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon, color: AppColors.primary, size: 22),
                      const Spacer(),
                      if (widget.isDone)
                        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                    ],
                  ),
                  if (preview != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        height: 72,
                        width: double.infinity,
                        child: Image.memory(
                          preview,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      preview != null
                          ? l10n.driverRegTapCardToReplacePhoto
                          : widget.hint,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preview != null
                        ? l10n.driverRegChangePhoto
                        : l10n.driverRegTakeOrChoosePhoto,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.isDone ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
