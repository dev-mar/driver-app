import '../../gen_l10n/app_localizations.dart';

/// Etiqueta amigable para tipos de servicio mostrados al usuario (API puede traer nombres legacy).
String displayServiceTypeName(String raw, AppLocalizations l10n, {String? code}) {
  final s = raw.trim().toLowerCase();
  final c = (code ?? '').trim().toLowerCase();
  if (s.contains('económico') ||
      s.contains('economico') ||
      s == 'economy' ||
      s.contains('economy') ||
      s.contains('economic')) {
    return l10n.serviceTypeNameStandard;
  }
  if (c.contains('moto') ||
      c.contains('motorbike') ||
      c.contains('two_wheel') ||
      s.contains('moto') ||
      s.contains('motorbike') ||
      s.contains('two_wheel') ||
      s.contains('two wheel') ||
      s.contains('dos ruedas')) {
    return l10n.serviceTypeNameMoto;
  }
  return raw.trim();
}

/// Lista de servicios (coma, punto medio, barra) con el mismo mapeo visual.
String displayEnabledServiceLabels(String? raw, AppLocalizations l10n) {
  final t = (raw ?? '').trim();
  if (t.isEmpty) return '';
  return t
      .split(RegExp(r'\s*[,·|/]\s*'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .map((part) => displayServiceTypeName(part, l10n))
      .join(' · ');
}
