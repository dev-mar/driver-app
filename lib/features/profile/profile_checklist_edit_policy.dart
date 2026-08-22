/// Política de edición para bloques de «Carga y verificaciones» (perfil conductor).
enum ProfileChecklistEditPolicy {
  editable,
  readOnly,
  locked;

  static ProfileChecklistEditPolicy fromUiStatus(String? uiStatus) {
    switch ((uiStatus ?? '').toLowerCase()) {
      case 'incomplete':
      case 'needs_attention':
        return ProfileChecklistEditPolicy.editable;
      case 'verified':
        return ProfileChecklistEditPolicy.locked;
      case 'pending_review':
      default:
        return ProfileChecklistEditPolicy.readOnly;
    }
  }

  bool get allowsSave => this == ProfileChecklistEditPolicy.editable;
  bool get isReadOnlyView => this != ProfileChecklistEditPolicy.editable;

  /// Fotos de CI / licencia / vehículo: editables hasta que el bloque esté verificado.
  bool get allowsPhotoEdit => this != ProfileChecklistEditPolicy.locked;
}

String checklistKeyForFlowStep(int flowStep) {
  switch (flowStep) {
    case 0:
      return 'personal_info';
    case 1:
      return 'identity';
    case 2:
      return 'license';
    case 4:
    case 5:
      return 'vehicle';
    default:
      return '';
  }
}
