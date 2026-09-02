import '../../gen_l10n/app_localizations.dart';

bool isTwoWheelerVehicleTypeDisplay({String? code, String? label}) {
  final c = (code ?? '').trim().toLowerCase();
  if (c == 'two_wheeler' ||
      c == 'motorcycle' ||
      c.contains('two_wheel') ||
      c.contains('motorbike')) {
    return true;
  }
  final l = (label ?? '').trim().toLowerCase();
  if (l.isEmpty) return false;
  return l.contains('dos ruedas') ||
      l.contains('two wheel') ||
      l.contains('two-wheel') ||
      l.contains('two_wheel');
}

/// Etiqueta visible del tipo de vehículo. No cambia códigos ni persistencia.
String displayVehicleTypeLabel({
  String? code,
  String? fallbackLabel,
  required AppLocalizations l10n,
}) {
  if (isTwoWheelerVehicleTypeDisplay(code: code, label: fallbackLabel)) {
    return l10n.driverRegCatalogTransportMoto;
  }
  return (fallbackLabel ?? '').trim();
}
