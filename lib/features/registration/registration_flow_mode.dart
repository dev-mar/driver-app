import '../profile/profile_checklist_edit_policy.dart';

/// Modos de lanzamiento del flujo de registro conductor.
class RegistrationFlowMode {
  const RegistrationFlowMode({
    required this.profileCompletionUx,
    required this.galleryCompletionOnly,
    required this.addVehicleOnly,
    required this.resumeAfterLogin,
    required this.openFromProfileStep,
    required this.profilePreselectedCountryId,
    required this.completeVehicleGalleryForAssetId,
    required this.profileSectionUiStatus,
  });

  final bool profileCompletionUx;
  final bool galleryCompletionOnly;
  final bool addVehicleOnly;
  final bool resumeAfterLogin;
  final int? openFromProfileStep;
  final int? profilePreselectedCountryId;
  final String? completeVehicleGalleryForAssetId;
  final String? profileSectionUiStatus;

  ProfileChecklistEditPolicy get profileEditPolicy =>
      ProfileChecklistEditPolicy.fromUiStatus(profileSectionUiStatus);

  /// Datos del bloque (número, fechas, catálogo): solo lectura en revisión o verificado.
  bool get profileFieldsReadOnly =>
      profileCompletionUx && profileEditPolicy.isReadOnlyView;

  /// Fotos bloqueadas solo cuando el bloque ya está verificado (texto verde).
  bool get profilePhotosLocked =>
      profileCompletionUx && profileEditPolicy == ProfileChecklistEditPolicy.locked;

  bool get profileCanSavePhotos {
    if (!profileCompletionUx || profilePhotosLocked) return false;
    final step = openFromProfileStep;
    return step == 1 || step == 2 || step == 4 || step == 5;
  }

  /// Todo el formulario congelado (verificado). En revisión las fotos siguen activas.
  bool get profileReadOnly => profilePhotosLocked;

  factory RegistrationFlowMode.fromLaunchParams({
    required bool resumeAfterLogin,
    required bool addVehicleOnly,
    required String? completeVehicleGalleryForAssetId,
    required int? openFromProfileStep,
    required int? profilePreselectedCountryId,
    String? profileSectionUiStatus,
  }) {
    final galleryId = completeVehicleGalleryForAssetId?.trim();
    final galleryCompletionOnly = galleryId != null && galleryId.isNotEmpty;
    final profileCompletionUx = openFromProfileStep != null &&
        !resumeAfterLogin &&
        !addVehicleOnly &&
        !galleryCompletionOnly;

    return RegistrationFlowMode(
      profileCompletionUx: profileCompletionUx,
      galleryCompletionOnly: galleryCompletionOnly,
      addVehicleOnly: addVehicleOnly,
      resumeAfterLogin: resumeAfterLogin,
      openFromProfileStep: openFromProfileStep,
      profilePreselectedCountryId: profilePreselectedCountryId,
      completeVehicleGalleryForAssetId: completeVehicleGalleryForAssetId,
      profileSectionUiStatus: profileSectionUiStatus,
    );
  }
}
