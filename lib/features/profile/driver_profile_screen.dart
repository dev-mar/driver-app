import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/network/driver_api_client.dart';
import '../../core/network/driver_profile_api_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/ui/driver_secondary_scaffold.dart';
import '../../core/ui/texi_circular_avatar.dart';
import '../../gen_l10n/app_localizations.dart';
import 'profile_checklist_edit_policy.dart';

enum _ProfileLoadError { noSession, emptyResponse, badFormat }

String _formatBirthDateLocalized(
  String raw,
  Locale locale,
  String emptyPlaceholder,
) {
  final t = raw.trim();
  if (t.isEmpty) return emptyPlaceholder;
  final d = DateTime.tryParse(t);
  if (d == null) return t;
  return DateFormat.yMMMMd(locale.toString()).format(d);
}

String _mapProfileLoadError(Object? error, AppLocalizations l10n) {
  if (error is _ProfileLoadError) {
    switch (error) {
      case _ProfileLoadError.noSession:
        return l10n.driverProfileErrorNoSession;
      case _ProfileLoadError.emptyResponse:
        return l10n.driverProfileErrorEmpty;
      case _ProfileLoadError.badFormat:
        return l10n.driverProfileErrorBadFormat;
    }
  }
  final s = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  if (s == '__PROFILE_FAIL__' || s == 'PROFILE_REQUEST_FAILED') {
    return l10n.commonError;
  }
  return s;
}

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  late Future<_ProfileScreenData> _futureProfile;

  @override
  void initState() {
    super.initState();
    _futureProfile = _fetchProfileAndCredits();
  }

  Future<_ProfileScreenData> _fetchProfileAndCredits({bool forceRefresh = false}) async {
    final meService = DriverMeProfileService(DriverApiClient());
    final creditsService = DriverAppCreditsService(DriverApiClient());
    try {
      final data = await meService.fetchData(forceRefresh: forceRefresh);
      final profile = _DriverProfileViewModel.fromJson(data);

      _DriverAppCreditsVm? credits;
      try {
        final creditsData =
            await creditsService.fetchData(forceRefresh: forceRefresh);
        credits = _DriverAppCreditsVm.fromJson(creditsData);
      } catch (_) {
        credits = null;
      }

      return _ProfileScreenData(profile: profile, credits: credits);
    } on DriverApiSessionException {
      throw _ProfileLoadError.noSession;
    } on DriverApiResponseException catch (e) {
      if (e.code == 'empty_response') {
        throw _ProfileLoadError.emptyResponse;
      }
      if (e.code == 'bad_format') {
        throw _ProfileLoadError.badFormat;
      }
      throw Exception(e.code);
    } on DioException catch (e) {
      final body = e.response?.data;
      final msg = body is Map ? body['message']?.toString() : null;
      throw Exception(msg ?? e.message ?? 'network');
    }
  }

  Future<void> _reload() async {
    setState(() {
      _futureProfile = _fetchProfileAndCredits(forceRefresh: true);
    });
    await _futureProfile;
  }

  void _goHome(BuildContext context) {
    context.goNamed(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        _goHome(context);
      },
      child: DriverSecondaryScaffold(
        title: l10n.driverProfileTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: l10n.driverProfileBack,
          onPressed: () => _goHome(context),
        ),
        actions: [
          IconButton(
            tooltip: l10n.driverProfileRefreshTooltip,
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        body: FutureBuilder<_ProfileScreenData>(
        future: _futureProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _ProfileLoadingState();
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 32),
                    const SizedBox(height: 10),
                    Text(
                      _mapProfileLoadError(snapshot.error, l10n),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.driverProfileRetry),
                    ),
                  ],
                ),
              ),
            );
          }
          final bundle = snapshot.data!;
          final p = bundle.profile;
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _StaggeredFadeSlide(
                  index: 0,
                  child: _ProfileHeaderCard(profile: p, l10n: l10n),
                ),
                const SizedBox(height: 14),
                _StaggeredFadeSlide(
                  index: 1,
                  child: _DriverAppCreditsCard(
                    credits: bundle.credits,
                    l10n: l10n,
                    locale: locale,
                  ),
                ),
                const SizedBox(height: 14),
                _StaggeredFadeSlide(
                  index: 2,
                  child: p.registrationChecklist == null || p.registrationChecklist!.isEmpty
                      ? _VerificationStatusCard(l10n: l10n)
                      : _RegistrationOnboardingChecklist(
                          l10n: l10n,
                          items: p.registrationChecklist!,
                          onOpenStep: (flowStep, uiStatus) {
                            context.pushNamed(
                              AppRouter.register,
                              extra: <String, dynamic>{
                                'openFromProfileStep': flowStep,
                                'profileSectionUiStatus': uiStatus,
                                if (p.registrationCountryId != null)
                                  'profilePreselectedCountryId':
                                      p.registrationCountryId,
                              },
                            );
                          },
                        ),
                ),
                const SizedBox(height: 14),
                _StaggeredFadeSlide(
                  index: 3,
                  child: _ProfileInfoCard(
                    title: l10n.driverProfileSectionPersonal,
                    children: [
                      _InfoRow(
                        label: l10n.driverProfileFieldReferralCode,
                        value: p.referralCode ?? '',
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                        copyable: (p.referralCode ?? '').trim().isNotEmpty,
                        copyTooltip: l10n.driverProfileCopyReferralCode,
                        copiedMessage: l10n.driverProfileReferralCopied,
                      ),
                      _InfoRow(
                        label: l10n.driverProfileFieldName,
                        value: p.displayName(l10n),
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                      ),
                      _InfoRow(
                        label: l10n.driverProfileFieldBirthDate,
                        value: _formatBirthDateLocalized(
                          p.birthDate,
                          locale,
                          l10n.driverProfileValueEmpty,
                        ),
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                      ),
                      _InfoRow(
                        label: l10n.driverProfileFieldGender,
                        value: p.localizedGender(l10n),
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StaggeredFadeSlide(
                  index: 4,
                  child: _ProfileInfoCard(
                    title: l10n.driverProfileSectionContact,
                    children: [
                      _InfoRow(
                        label: l10n.driverProfileFieldPhone,
                        value: p.phoneNumber,
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                      ),
                      _InfoRow(
                        label: l10n.driverProfileFieldEmail,
                        value: p.email,
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StaggeredFadeSlide(
                  index: 5,
                  child: _ProfileInfoCard(
                    title: l10n.driverProfileSectionLocation,
                    children: [
                      _InfoRow(
                        label: l10n.driverProfileFieldAddress,
                        value: p.address,
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                      ),
                      _InfoRow(
                        label: l10n.driverProfileFieldLocality,
                        value: p.locality,
                        emptyPlaceholder: l10n.driverProfileValueEmpty,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _StaggeredFadeSlide(
                  index: 6,
                  child: _ProfileSettingsTile(
                    label: l10n.driverSettingsTitle,
                    onTap: () => context.pushNamed(AppRouter.settings),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      ),
    );
  }
}

class _ProfileScreenData {
  const _ProfileScreenData({required this.profile, this.credits});

  final _DriverProfileViewModel profile;
  final _DriverAppCreditsVm? credits;
}

class _DriverAppCreditsVm {
  const _DriverAppCreditsVm({
    required this.balance,
  });

  final double balance;

  factory _DriverAppCreditsVm.fromJson(Map<String, dynamic> json) {
    return _DriverAppCreditsVm(
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class _DriverAppCreditsCard extends StatelessWidget {
  const _DriverAppCreditsCard({
    required this.credits,
    required this.l10n,
    required this.locale,
  });

  final _DriverAppCreditsVm? credits;
  final AppLocalizations l10n;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern(locale.toString());
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverAppCreditsTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (credits == null)
            Text(
              l10n.driverAppCreditsUnavailable,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.9),
                fontSize: 13,
              ),
            )
          else ...[
            Text(
              l10n.driverAppCreditsBalance(fmt.format(credits!.balance)),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.profile, required this.l10n});

  final _DriverProfileViewModel profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          _PremiumProfileAvatar(profile: profile, l10n: l10n),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName(l10n),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.driverProfileRoleSubtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ProfileBadge(
                      icon: Icons.verified_rounded,
                      label: l10n.driverProfileBadgeActive,
                    ),
                    _ProfileBadge(
                      icon: Icons.shield_outlined,
                      label: l10n.driverProfileBadgeSecure,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar con borde tipo “ring”, foto de red o iniciales elegantes si falla o no hay URL.
class _PremiumProfileAvatar extends StatelessWidget {
  const _PremiumProfileAvatar({required this.profile, required this.l10n});

  final _DriverProfileViewModel profile;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final url = profile.pictureProfile;
    const size = 64.0;

    Widget inner() {
      if (url == null || url.isEmpty) {
        return _InitialsAvatar(profile: profile, size: size, l10n: l10n);
      }
      // Backend suele devolver Base64 como data URL (`resolvePictureForClient`);
      // `Image.network` no carga esquema `data:`.
      if (url.startsWith('data:') && url.contains('base64,')) {
        try {
          final i = url.indexOf('base64,');
          final b64 = url.substring(i + 7);
          final bytes = base64Decode(b64);
          return ClipOval(
            child: Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _InitialsAvatar(
                  profile: profile,
                  size: size,
                  l10n: l10n,
                );
              },
            ),
          );
        } catch (_) {
          return _InitialsAvatar(profile: profile, size: size, l10n: l10n);
        }
      }
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size,
              height: size,
              color: AppColors.primary.withValues(alpha: 0.12),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary.withValues(alpha: 0.85),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _InitialsAvatar(profile: profile, size: size, l10n: l10n);
          },
        ),
      );
    }

    return TexiCircularAvatar.profileRing(
      innerDiameter: size,
      image: inner(),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.profile,
    required this.size,
    required this.l10n,
  });

  final _DriverProfileViewModel profile;
  final double size;
  final AppLocalizations l10n;

  String _initials() {
    String firstChar(String s) =>
        s.isEmpty ? '' : s.substring(0, 1).toUpperCase();

    final a = profile.firstName.trim();
    final b = profile.lastName.trim();
    if (a.isNotEmpty && b.isNotEmpty) {
      return '${firstChar(a)}${firstChar(b)}';
    }
    final full = profile.displayName(l10n).trim();
    if (full.length >= 2) {
      return full.substring(0, 2).toUpperCase();
    }
    if (full.isNotEmpty) return firstChar(full);
    return 'TX';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2E3A4A),
            const Color(0xFF1E2733),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.onPrimary.withValues(alpha: 0.98),
          fontSize: size * 0.28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ProfileSettingsTile extends StatelessWidget {
  const _ProfileSettingsTile({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.tune_rounded,
                color: AppColors.textPrimary.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: AppColors.textSecondary.withValues(alpha: 0.95),
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.emptyPlaceholder,
    this.copyable = false,
    this.copyTooltip,
    this.copiedMessage,
  });

  final String label;
  final String value;
  final String emptyPlaceholder;
  final bool copyable;
  final String? copyTooltip;
  final String? copiedMessage;

  Future<void> _copy(BuildContext context) async {
    final text = value.trim();
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    final msg = copiedMessage;
    if (!context.mounted || msg == null || msg.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final show = value.trim().isEmpty ? emptyPlaceholder : value;
    final canCopy = copyable && value.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 118,
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                show,
                style: TextStyle(
                  color: AppColors.textPrimary.withValues(
                    alpha: value.trim().isEmpty ? 0.55 : 1,
                  ),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
            ),
            if (canCopy)
              IconButton(
                tooltip: copyTooltip ?? label,
                onPressed: () => _copy(context),
                icon: Icon(
                  Icons.copy_rounded,
                  size: 18,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRegistrationChecklistItem {
  const _ProfileRegistrationChecklistItem({
    required this.key,
    required this.uiStatus,
    this.complianceStatus,
  });

  final String key;
  final String uiStatus;
  final String? complianceStatus;
}

int _flowStepForChecklistKey(String key) {
  switch (key) {
    case 'personal_info':
      return 0;
    case 'identity':
      return 1;
    case 'license':
      return 2;
    case 'vehicle':
      return 4;
    default:
      return 0;
  }
}

String _checklistKeyTitle(AppLocalizations l10n, String key) {
  switch (key) {
    case 'personal_info':
      return l10n.driverProfileSectionOnboardingPersonal;
    case 'identity':
      return l10n.driverProfileSectionOnboardingIdentity;
    case 'license':
      return l10n.driverProfileSectionOnboardingLicense;
    case 'vehicle':
      return l10n.driverProfileSectionOnboardingVehicle;
    default:
      return key;
  }
}

String _checklistStatusLabel(AppLocalizations l10n, String ui) {
  switch (ui) {
    case 'incomplete':
      return l10n.driverProfileOnboardingStatusIncomplete;
    case 'pending_review':
      return l10n.driverProfileOnboardingStatusPending;
    case 'verified':
      return l10n.driverProfileOnboardingStatusVerified;
    case 'needs_attention':
      return l10n.driverProfileOnboardingStatusAction;
    default:
      return l10n.driverProfileOnboardingStatusPending;
  }
}

({Color bg, Color fg, IconData icon}) _checklistStatusStyle(String ui) {
  switch (ui) {
    case 'verified':
      return (
        bg: const Color(0xFF1B5E20).withValues(alpha: 0.22),
        fg: const Color(0xFFA5D6A7),
        icon: Icons.verified_outlined
      );
    case 'incomplete':
      return (
        bg: const Color(0xFF6D4C41).withValues(alpha: 0.2),
        fg: const Color(0xFFFFCC80),
        icon: Icons.edit_note_rounded
      );
    case 'needs_attention':
      return (
        bg: const Color(0xFFB71C1C).withValues(alpha: 0.22),
        fg: const Color(0xFFFFAB91),
        icon: Icons.info_outline_rounded
      );
    case 'pending_review':
    default:
      return (
        bg: const Color(0xFF1565C0).withValues(alpha: 0.22),
        fg: const Color(0xFF90CAF9),
        icon: Icons.schedule_rounded
      );
  }
}

class _RegistrationOnboardingChecklist extends StatelessWidget {
  const _RegistrationOnboardingChecklist({
    required this.l10n,
    required this.items,
    required this.onOpenStep,
  });

  final AppLocalizations l10n;
  final List<_ProfileRegistrationChecklistItem> items;
  final void Function(int flowStep, String uiStatus) onOpenStep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverProfileOnboardingTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ChecklistRow(
              l10n: l10n,
              item: items[i],
              onOpenStep: onOpenStep,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.l10n,
    required this.item,
    required this.onOpenStep,
  });

  final AppLocalizations l10n;
  final _ProfileRegistrationChecklistItem item;
  final void Function(int flowStep, String uiStatus) onOpenStep;

  String _tapHint(AppLocalizations l10n) {
    switch (ProfileChecklistEditPolicy.fromUiStatus(item.uiStatus)) {
      case ProfileChecklistEditPolicy.editable:
        return l10n.driverProfileOnboardingTapEditable;
      case ProfileChecklistEditPolicy.readOnly:
        if (item.key == 'identity' ||
            item.key == 'license' ||
            item.key == 'vehicle') {
          return l10n.driverProfileOnboardingTapEditPhotos;
        }
        return l10n.driverProfileOnboardingTapViewOnly;
      case ProfileChecklistEditPolicy.locked:
        return l10n.driverProfileOnboardingTapLocked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _checklistKeyTitle(l10n, item.key);
    final st = _checklistStatusStyle(item.uiStatus);
    final label = _checklistStatusLabel(l10n, item.uiStatus);
    final step = _flowStepForChecklistKey(item.key);
    final locked =
        ProfileChecklistEditPolicy.fromUiStatus(item.uiStatus) ==
            ProfileChecklistEditPolicy.locked;
    return Material(
      color: AppColors.surface.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: locked ? null : () => onOpenStep(step, item.uiStatus),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: st.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(st.icon, size: 20, color: st.fg),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    if (!locked) ...[
                      const SizedBox(height: 2),
                      Text(
                        _tapHint(l10n),
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.9),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: st.bg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: st.fg,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!locked) ...[
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VerificationStatusCard extends StatelessWidget {
  const _VerificationStatusCard({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF5A6A80).withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xFF90A4C2), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.driverProfileVerificationTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.driverProfileVerificationBody,
                  style: TextStyle(
                    color: AppColors.textSecondary.withValues(alpha: 0.95),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF9FB2CB)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.8,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingState extends StatefulWidget {
  const _ProfileLoadingState();

  @override
  State<_ProfileLoadingState> createState() => _ProfileLoadingStateState();
}

class _ProfileLoadingStateState extends State<_ProfileLoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_pulse.value);
        final base = Color.lerp(
          AppColors.surface,
          AppColors.primary.withValues(alpha: 0.09),
          t,
        )!;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _SkeletonBlock(height: 110, baseColor: base),
            const SizedBox(height: 12),
            _SkeletonBlock(height: 86, baseColor: base),
            const SizedBox(height: 12),
            _SkeletonBlock(height: 160, baseColor: base),
            const SizedBox(height: 12),
            _SkeletonBlock(height: 120, baseColor: base),
          ],
        );
      },
    );
  }
}

/// Bloque placeholder con brillo animado (pulso suave tipo apps premium).
class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, required this.baseColor});

  final double height;
  final Color baseColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            AppColors.surface,
            baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

/// Entrada suave escalonada al cargar el perfil (estilo apps modernas).
class _StaggeredFadeSlide extends StatefulWidget {
  const _StaggeredFadeSlide({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggeredFadeSlide> createState() => _StaggeredFadeSlideState();
}

class _StaggeredFadeSlideState extends State<_StaggeredFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: AppMotion.standard);
    _slide = Tween<Offset>(
      begin: Offset(0, AppMotion.slideDySubtle),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: AppMotion.standard));
    Future<void>.delayed(
      Duration(
        milliseconds: AppMotion.staggerItem.inMilliseconds * widget.index,
      ),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class _DriverProfileViewModel {
  _DriverProfileViewModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.locality,
    required this.gender,
    required this.birthDate,
    required this.pictureProfile,
    this.referralCode,
    this.registrationChecklist,
    this.registrationCountryId,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String locality;
  final String gender;
  final String birthDate;
  final String? pictureProfile;
  final String? referralCode;
  final List<_ProfileRegistrationChecklistItem>? registrationChecklist;
  final int? registrationCountryId;

  String displayName(AppLocalizations l10n) {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return l10n.driverProfileDefaultName;
    return '$f $l'.trim();
  }

  String localizedGender(AppLocalizations l10n) {
    final g = gender.trim().toLowerCase();
    if (g == 'male') return l10n.driverProfileGenderMale;
    if (g == 'female') return l10n.driverProfileGenderFemale;
    if (g == 'other') return l10n.driverProfileGenderOther;
    if (gender.trim().isEmpty) return l10n.driverProfileValueEmpty;
    return gender;
  }

  factory _DriverProfileViewModel.fromJson(Map<String, dynamic> json) {
    String read(String key) => json[key]?.toString() ?? '';
    final picture = json['picture_profile']?.toString();
    int? countryId;
    final rc = json['registration_country_id'];
    if (rc is int) {
      countryId = rc;
    } else if (rc is num) {
      countryId = rc.toInt();
    } else {
      final s = read('registration_country_id');
      if (s.isNotEmpty) {
        countryId = int.tryParse(s);
      }
    }

    List<_ProfileRegistrationChecklistItem>? checklist;
    final rawList = json['registration_checklist'];
    if (rawList is List) {
      final list = <_ProfileRegistrationChecklistItem>[];
      for (final e in rawList) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        list.add(
          _ProfileRegistrationChecklistItem(
            key: m['key']?.toString() ?? '',
            uiStatus: m['ui_status']?.toString() ?? 'incomplete',
            complianceStatus: m['compliance_status']?.toString(),
          ),
        );
      }
      checklist = list;
    }
    final rawReferral = json['club_referral_code'] ?? json['referralCode'];
    final referral = rawReferral?.toString().trim();
    return _DriverProfileViewModel(
      firstName: read('first_name'),
      lastName: read('last_name'),
      email: read('email'),
      phoneNumber: read('phone_number'),
      address: read('address'),
      locality: read('locality'),
      gender: read('gender'),
      birthDate: read('birth_date'),
      pictureProfile: (picture == null || picture.isEmpty) ? null : picture,
      referralCode: (referral == null || referral.isEmpty) ? null : referral,
      registrationChecklist: checklist,
      registrationCountryId: countryId,
    );
  }
}
