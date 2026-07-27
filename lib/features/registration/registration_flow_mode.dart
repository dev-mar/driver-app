/// Modos de lanzamiento del flujo de registro conductor.
import '../profile/profile_checklist_edit_policy.dart';

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

  bool get profileReadOnly => profileCompletionUx && profileEditPolicy.isReadOnlyView;

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
