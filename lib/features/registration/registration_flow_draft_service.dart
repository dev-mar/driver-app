import 'driver_registration_controller.dart';
import 'driver_registration_draft_media_store.dart';
import 'driver_registration_draft_store.dart';
import 'registration_flow_bindings.dart';
import 'registration_flow_draft.dart';

/// Persistencia y restauración del borrador local del registro.
class RegistrationFlowDraftService {
  RegistrationFlowDraftService({
    required this.form,
    required this.readFlow,
    required this.isMounted,
  });

  final RegistrationFlowBindings form;
  final DriverRegistrationFlowState Function() readFlow;
  final bool Function() isMounted;

  bool suppressDraftSave = false;

  RegistrationDraftPersistSnapshot capture() {
    return captureRegistrationDraftSnapshot(flow: readFlow(), form: form);
  }

  Future<void> commitSnapshot(RegistrationDraftPersistSnapshot d) async {
    final paths = Map<String, String?>.from(d.paths);
    paths['idFront'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'id_front',
      base64Image: d.idFrontB64,
      existingPath: paths['idFront'],
    );
    paths['idBack'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'id_back',
      base64Image: d.idBackB64,
      existingPath: paths['idBack'],
    );
    paths['face'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'identity_face',
      base64Image: d.faceB64,
      existingPath: paths['face'],
    );
    paths['licenseFront'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'license_front',
      base64Image: d.licFrontB64,
      existingPath: paths['licenseFront'],
    );
    paths['licenseBack'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'license_back',
      base64Image: d.licBackB64,
      existingPath: paths['licenseBack'],
    );
    paths['carFront'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_front',
      base64Image: d.carFrontB64,
      existingPath: paths['carFront'],
    );
    paths['carBack'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_back',
      base64Image: d.carBackB64,
      existingPath: paths['carBack'],
    );
    paths['carLeft'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_left',
      base64Image: d.carLeftB64,
      existingPath: paths['carLeft'],
    );
    paths['carRight'] = await DriverRegistrationDraftMediaStore.persistBase64(
      key: 'vehicle_right',
      base64Image: d.carRightB64,
      existingPath: paths['carRight'],
    );

    final f = d.flow;
    final draft = DriverRegistrationDraft(
      step: f.step,
      userUuid: f.userUuid,
      carUuid: f.carUuid,
      selectedCountryName: f.selectedCountryName,
      selectedCountryPhoneCode: f.selectedCountryPhoneCode,
      selectedDepartmentName: f.selectedDepartmentName,
      selectedLocalityId: f.selectedLocalityId,
      selectedLocalityLabel: f.selectedLocalityLabel,
      selectedCountryId: f.selectedCountryId,
      firstName: d.firstName,
      lastName: d.lastName,
      email: d.email,
      phoneLocal: d.phoneLocal,
      birthDateIso: d.birthDateIso,
      address: d.address,
      genderValue: d.genderValue,
      documentNumber: d.documentNumber,
      documentExpireIso: d.documentExpireIso,
      licenseExpireIso: d.licenseExpireIso,
      licenseCategoryId: d.licenseCategoryId,
      idFrontPath: paths['idFront'],
      idBackPath: paths['idBack'],
      facePath: paths['face'],
      licenseFrontPath: paths['licenseFront'],
      licenseBackPath: paths['licenseBack'],
      vehicleBrand: d.vehicleBrand,
      vehicleModel: d.vehicleModel,
      vehicleYear: d.vehicleYear,
      vehicleColor: d.vehicleColor,
      vehicleVin: d.vehicleVin,
      vehiclePlate: d.vehiclePlate,
      vehicleInsurance: d.vehicleInsurance,
      vehicleTitle: d.vehicleTitle,
      carFrontPath: paths['carFront'],
      carBackPath: paths['carBack'],
      carLeftPath: paths['carLeft'],
      carRightPath: paths['carRight'],
    );
    await DriverRegistrationDraftStore.save(draft);
    if (isMounted()) {
      form.draftImagePaths
        ..clear()
        ..addAll(paths);
    }
  }

  Future<void> persist() async {
    if (suppressDraftSave || !isMounted()) return;
    try {
      await commitSnapshot(capture());
    } catch (_) {}
  }

  Future<void> restoreIntoForm(
    DriverRegistrationDraft draft,
    DriverRegistrationFlowController notifier,
  ) async {
    suppressDraftSave = true;
    try {
      form.firstNameCtrl.text = draft.firstName ?? '';
      form.lastNameCtrl.text = draft.lastName ?? '';
      form.emailCtrl.text = draft.email ?? '';
      form.phoneLocalCtrl.text = draft.phoneLocal ?? '';
      form.birthDateCtrl.text = draft.birthDateIso ?? '';
      form.addressCtrl.text = draft.address ?? '';
      form.genderValue = draft.genderValue;
      form.docNumberCtrl.text = draft.documentNumber ?? '';
      form.docExpireCtrl.text = draft.documentExpireIso ?? '';
      form.licenseExpireCtrl.text = draft.licenseExpireIso ?? '';
      form.vehicleBrandCtrl.text = draft.vehicleBrand ?? '';
      form.vehicleModelCtrl.text = draft.vehicleModel ?? '';
      form.vehicleYearCtrl.text =
          (draft.vehicleYear != null && draft.vehicleYear!.isNotEmpty)
              ? draft.vehicleYear!
              : '2020';
      form.vehicleColorCtrl.text = draft.vehicleColor ?? '';
      form.vehicleVinCtrl.text = draft.vehicleVin ?? '';
      form.vehiclePlateCtrl.text = draft.vehiclePlate ?? '';
      form.vehicleInsuranceCtrl.text = draft.vehicleInsurance ?? '';
      form.vehicleTitleCtrl.text = draft.vehicleTitle ?? '';
      form.draftImagePaths['idFront'] = draft.idFrontPath;
      form.draftImagePaths['idBack'] = draft.idBackPath;
      form.draftImagePaths['face'] = draft.facePath;
      form.draftImagePaths['licenseFront'] = draft.licenseFrontPath;
      form.draftImagePaths['licenseBack'] = draft.licenseBackPath;
      form.draftImagePaths['carFront'] = draft.carFrontPath;
      form.draftImagePaths['carBack'] = draft.carBackPath;
      form.draftImagePaths['carLeft'] = draft.carLeftPath;
      form.draftImagePaths['carRight'] = draft.carRightPath;
      form.idFrontB64 =
          await DriverRegistrationDraftMediaStore.restoreBase64(draft.idFrontPath) ??
              draft.idFrontB64;
      form.idBackB64 =
          await DriverRegistrationDraftMediaStore.restoreBase64(draft.idBackPath) ??
              draft.idBackB64;
      form.faceB64 =
          await DriverRegistrationDraftMediaStore.restoreBase64(draft.facePath) ??
              draft.faceB64;
      form.licFrontB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.licenseFrontPath,
          ) ??
          draft.licenseFrontB64;
      form.licBackB64 = await DriverRegistrationDraftMediaStore.restoreBase64(
            draft.licenseBackPath,
          ) ??
          draft.licenseBackB64;
      form.carFrontB64 =
          await DriverRegistrationDraftMediaStore.restoreBase64(draft.carFrontPath) ??
              draft.carFrontB64;
      form.carBackB64 =
          await DriverRegistrationDraftMediaStore.restoreBase64(draft.carBackPath) ??
              draft.carBackB64;
      form.carLeftB64 =
          await DriverRegistrationDraftMediaStore.restoreBase64(draft.carLeftPath) ??
              draft.carLeftB64;
      form.carRightB64 =
          await DriverRegistrationDraftMediaStore.restoreBase64(draft.carRightPath) ??
              draft.carRightB64;
      if (!isMounted()) return;
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
      suppressDraftSave = false;
    }
  }

  Future<void> flushOnDispose() async {
    if (suppressDraftSave) return;
    try {
      if (isMounted()) {
        await commitSnapshot(capture());
      }
    } catch (_) {}
  }
}
