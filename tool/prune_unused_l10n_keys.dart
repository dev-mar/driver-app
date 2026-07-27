// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

/// Elimina de app_en.arb y app_es.arb las claves que no aparecen en lib/ (excepto gen_l10n).
/// Uso: dart run tool/prune_unused_l10n_keys.dart
void main() {
  const enPath = 'lib/l10n/app_en.arb';
  const esPath = 'lib/l10n/app_es.arb';

  final en = _decodeArb(File(enPath));
  final es = _decodeArb(File(esPath));

  final allCode = _readLibDartSources();
  final keys = en.keys
      .where((k) => !k.startsWith('@') && k != '@@locale')
      .toList();

  final unused = <String>[];
  for (final k in keys) {
    if (!allCode.contains(k)) unused.add(k);
  }

  if (unused.isEmpty) {
    print('[prune_l10n] No hay claves huérfanas.');
    return;
  }

  for (final k in unused) {
    en.remove(k);
    es.remove(k);
    en.remove('@$k');
    es.remove('@$k');
  }

  _writeArb(File(enPath), en);
  _writeArb(File(esPath), es);

  print('[prune_l10n] Eliminadas ${unused.length} claves huérfanas.');
}

Map<String, dynamic> _decodeArb(File f) {
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

String _readLibDartSources() {
  final buffer = StringBuffer();
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    if (entity.path.contains('gen_l10n')) continue;
    buffer.writeln(entity.readAsStringSync());
  }
  return buffer.toString();
}

void _writeArb(File f, Map<String, dynamic> arb) {
  const encoder = JsonEncoder.withIndent('  ');
  f.writeAsStringSync('${encoder.convert(arb)}\n');
}
