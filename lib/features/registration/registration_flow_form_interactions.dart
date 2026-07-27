import 'package:flutter/material.dart';

typedef RegistrationPersistDraft = Future<void> Function();
typedef RegistrationSetState = void Function(VoidCallback fn);

Future<void> pickRegistrationDateToField({
  required BuildContext context,
  required TextEditingController controller,
  required RegistrationSetState setState,
  required RegistrationPersistDraft persistDraft,
  required bool Function() isMounted,
  bool future = false,
  /// Fecha de nacimiento: tope = mayoría de edad (18 años).
  bool birthDate = false,
}) async {
  final now = DateTime.now();
  final majorityCutoff = DateTime(now.year - 18, now.month, now.day);
  final initial = future
      ? DateTime(now.year + 3, now.month, now.day)
      : DateTime(now.year - 25, now.month, now.day);
  final first = future ? now : DateTime(1900);
  final last = future
      ? DateTime(now.year + 30)
      : (birthDate ? majorityCutoff : now);
  final safeInitial = initial.isAfter(last) ? last : initial;
  final d = await showDatePicker(
    context: context,
    initialDate: safeInitial,
    firstDate: first,
    lastDate: last,
  );
  if (d == null || !isMounted()) return;
  controller.text = d.toIso8601String().split('T').first;
  setState(() {});
  await persistDraft();
}

void applyRegistrationPickedImage({
  required String? b64,
  required void Function(String value) assign,
  required RegistrationSetState setState,
  required RegistrationPersistDraft persistDraft,
}) {
  if (b64 == null || b64.isEmpty) return;
  setState(() => assign(b64));
  persistDraft();
}
