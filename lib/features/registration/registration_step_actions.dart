import 'package:flutter/material.dart';

/// Callbacks compartidos entre pasos del flujo de registro.
class RegistrationStepActions {
  const RegistrationStepActions({
    required this.onFormChanged,
    required this.persistDraft,
    required this.pickDateToField,
    required this.applyPickedImage,
  });

  final VoidCallback onFormChanged;
  final Future<void> Function() persistDraft;
  final Future<void> Function(
    TextEditingController c, {
    bool future,
    bool birthDate,
  }) pickDateToField;
  final void Function(String? b64, void Function(String value) assign)
  applyPickedImage;
}
