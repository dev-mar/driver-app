import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/driver_backend_config.dart';
import '../network/driver_api_client.dart';
import '../../gen_l10n/app_localizations.dart';

enum DriverAppVersionGateOutcome {
  ok,
  optionalUpdate,
  forceBlocked,
}

class DriverAppVersionGateResult {
  const DriverAppVersionGateResult._(this.outcome);

  final DriverAppVersionGateOutcome outcome;

  bool get canProceed => outcome != DriverAppVersionGateOutcome.forceBlocked;

  static const ok = DriverAppVersionGateResult._(DriverAppVersionGateOutcome.ok);
  static const optionalUpdate =
      DriverAppVersionGateResult._(DriverAppVersionGateOutcome.optionalUpdate);
  static const forceBlocked =
      DriverAppVersionGateResult._(DriverAppVersionGateOutcome.forceBlocked);
}

class _DriverAppVersionPolicy {
  const _DriverAppVersionPolicy({
    required this.minVersionCode,
    required this.minVersionName,
    required this.force,
    required this.storeUrl,
  });

  final int minVersionCode;
  final String minVersionName;
  final bool force;
  final String storeUrl;
}

/// Comprueba versión mínima contra backend (fail-open si red falla).
class DriverAppVersionGate {
  DriverAppVersionGate._();

  static bool _checkedThisProcess = false;
  static DriverAppVersionGateResult? _cachedResult;
  static _DriverAppVersionPolicy? _cachedPolicy;

  static Future<DriverAppVersionGateResult> ensureChecked() async {
    if (_checkedThisProcess && _cachedResult != null) {
      return _cachedResult!;
    }
    _checkedThisProcess = true;
    _cachedResult = await _evaluate();
    return _cachedResult!;
  }

  static Future<DriverAppVersionGateResult> _evaluate() async {
    if (kIsWeb || !Platform.isAndroid) {
      return DriverAppVersionGateResult.ok;
    }
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final localBuild = int.tryParse(packageInfo.buildNumber.trim()) ?? 0;
      final policy = await _fetchPolicy().timeout(
        const Duration(seconds: 4),
        onTimeout: () => null,
      );
      if (policy == null) return DriverAppVersionGateResult.ok;
      _cachedPolicy = policy;
      if (localBuild >= policy.minVersionCode) {
        return DriverAppVersionGateResult.ok;
      }
      if (policy.force) {
        return DriverAppVersionGateResult.forceBlocked;
      }
      return DriverAppVersionGateResult.optionalUpdate;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DriverAppVersionGate] fail-open: $e');
      }
      return DriverAppVersionGateResult.ok;
    }
  }

  static Future<_DriverAppVersionPolicy?> _fetchPolicy() async {
    final dio = DriverApiClient.createPublicDio(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
    );
    final response = await dio.get<Map<String, dynamic>>(
      '${DriverBackendConfig.baseUrl}/api/v2/config/app-version',
    );
    final body = response.data;
    if (body == null || body['success'] != true) return null;
    final data = body['data'];
    if (data is! Map) return null;
    final driver = data['driver'];
    if (driver is! Map) return null;
    final payload = Map<String, dynamic>.from(driver);
    final minCodeRaw = payload['min_version_code'];
    final minCode = minCodeRaw is num
        ? minCodeRaw.toInt()
        : int.tryParse('${payload['min_version_code']}') ?? 1;
    final storeUrl = payload['store_url']?.toString().trim() ?? '';
    if (storeUrl.isEmpty) return null;
    return _DriverAppVersionPolicy(
      minVersionCode: minCode,
      minVersionName: payload['min_version_name']?.toString() ?? '1.0.0',
      force: payload['force'] == true,
      storeUrl: storeUrl,
    );
  }

  static Future<void> showGateUi(
    BuildContext context,
    DriverAppVersionGateResult result,
  ) async {
    if (!context.mounted) return;
    final policy = _cachedPolicy ?? await _fetchPolicy();
    if (!context.mounted) return;
    if (policy == null) return;
    final l10n = AppLocalizations.of(context);

    if (result.outcome == DriverAppVersionGateOutcome.forceBlocked) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(l10n.driverAppUpdateRequiredTitle),
            content: Text(l10n.driverAppUpdateRequiredMessage),
            actions: [
              FilledButton(
                onPressed: () => _openStore(policy.storeUrl),
                child: Text(l10n.driverAppUpdateOpenStore),
              ),
            ],
          ),
        ),
      );
      return;
    }

    if (result.outcome == DriverAppVersionGateOutcome.optionalUpdate) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.driverAppUpdateOptionalTitle),
          content: Text(l10n.driverAppUpdateOptionalMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.driverAppUpdateLater),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _openStore(policy.storeUrl);
              },
              child: Text(l10n.driverAppUpdateOpenStore),
            ),
          ],
        ),
      );
    }
  }

  static Future<void> _openStore(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Devuelve `false` si la app debe quedarse bloqueada (update forzado).
  static Future<bool> runStartupCheck(BuildContext context) async {
    final result = await ensureChecked();
    if (!context.mounted) return false;
    if (!result.canProceed) {
      await showGateUi(context, result);
      return false;
    }
    if (result.outcome == DriverAppVersionGateOutcome.optionalUpdate) {
      await showGateUi(context, result);
      if (!context.mounted) return false;
    }
    return true;
  }
}
