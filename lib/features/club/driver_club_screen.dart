import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/compliance/driver_legal_links.dart';
import '../../core/config/driver_club_config.dart';
import '../../core/network/driver_profile_api_providers.dart';
import '../../core/theme/app_foundation.dart';
import '../../core/theme/app_motion.dart';
import '../../core/utils/money_formatter.dart';
import '../../gen_l10n/app_localizations.dart';
import 'club_colors.dart';
import 'driver_club_controller.dart';
import 'driver_club_models.dart';
import 'widgets/club_benefit_tile.dart';
import 'widgets/club_section_card.dart';
import 'widgets/club_status_badge.dart';
import 'widgets/club_whatsapp_icon.dart';

class DriverClubScreen extends ConsumerStatefulWidget {
  const DriverClubScreen({super.key});

  @override
  ConsumerState<DriverClubScreen> createState() => _DriverClubScreenState();
}

class _DriverClubScreenState extends ConsumerState<DriverClubScreen> {
  final _claimCtrl = TextEditingController();

  @override
  void dispose() {
    _claimCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLanding(String anchor) async {
    HapticFeedback.lightImpact();
    final url = DriverClubConfig.sectionUrl(Localizations.localeOf(context), anchor);
    await openDriverExternalUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(driverClubControllerProvider);
    final hub = state.hub;
    final profile = ref.watch(driverMeProfileDataProvider);
    final firstName = (profile.asData?.value['first_name'] ?? '').toString().trim();

    return Scaffold(
      backgroundColor: ClubColors.canvas,
      appBar: AppBar(
        backgroundColor: ClubColors.canvas,
        foregroundColor: ClubColors.text,
        title: Text(l10n.driverClubTitle),
      ),
      body: RefreshIndicator(
        color: ClubColors.violet,
        onRefresh: () => ref.read(driverClubControllerProvider.notifier).load(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppFoundation.spacingLg,
                AppFoundation.spacingSm,
                AppFoundation.spacingLg,
                AppFoundation.spacing2xl,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (state.loading && hub == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: CircularProgressIndicator(color: ClubColors.violet),
                      ),
                    ),
                  if (state.error != null && hub == null)
                    Text(
                      state.error!,
                      style: const TextStyle(color: ClubColors.coral),
                    ),
                  if (hub != null) ...[
                    _ClubHero(
                      l10n: l10n,
                      firstName: firstName,
                      tier: hub.tier,
                      onHowItWorks: () => _openLanding(DriverClubConfig.hubAnchor),
                    ),
                    const SizedBox(height: AppFoundation.spacingLg),
                    _ClubWalletCard(
                      hub: hub,
                      l10n: l10n,
                      onLearn: () => _openLanding(DriverClubConfig.walletAnchor),
                    ),
                    const SizedBox(height: AppFoundation.spacingLg),
                    _ClubReferralsCard(
                      hub: hub,
                      l10n: l10n,
                      claiming: state.claiming,
                      claimCtrl: _claimCtrl,
                      claimError: state.error,
                      onLearn: () => _openLanding(DriverClubConfig.inviteAnchor),
                      onClaim: () async {
                        final code = _claimCtrl.text.trim();
                        if (code.isEmpty) return;
                        HapticFeedback.lightImpact();
                        final ok = await ref
                            .read(driverClubControllerProvider.notifier)
                            .claim(code);
                        if (!context.mounted) return;
                        if (ok) {
                          _claimCtrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.driverClubClaimOk)),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: AppFoundation.spacingLg),
                    _ClubLevelsCard(
                      l10n: l10n,
                      currentCode: hub.tier?.code,
                      catalog: hub.tierCatalog,
                      qualification: hub.qualification,
                      onLearn: () => _openLanding(DriverClubConfig.levelsAnchor),
                    ),
                    const SizedBox(height: AppFoundation.spacingXl),
                    Text(
                      l10n.driverClubBenefitsTitle,
                      style: const TextStyle(
                        color: ClubColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppFoundation.spacingMd),
                    Row(
                      children: [
                        Expanded(
                          child: ClubBenefitTile(
                            title: l10n.driverClubChallengesTitle,
                            blurb: l10n.driverClubChallengesBlurb,
                            icon: Icons.flash_on_outlined,
                            accent: ClubColors.sky,
                            onTap: () => _openLanding(DriverClubConfig.levelsAnchor),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ClubBenefitTile(
                            title: l10n.driverClubAdsTitle,
                            blurb: l10n.driverClubAdsBlurb,
                            icon: Icons.directions_car_filled_outlined,
                            accent: ClubColors.coral,
                            onTap: () => _openLanding(DriverClubConfig.adsAnchor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubHero extends StatelessWidget {
  const _ClubHero({
    required this.l10n,
    required this.firstName,
    required this.onHowItWorks,
    this.tier,
  });

  final AppLocalizations l10n;
  final String firstName;
  final VoidCallback onHowItWorks;
  final DriverClubTier? tier;

  @override
  Widget build(BuildContext context) {
    final hello = firstName.isEmpty
        ? l10n.driverClubHeroHello
        : l10n.driverClubHeroHelloName(firstName);
    final badgeLabel = (tier?.displayName ?? '').trim().isNotEmpty
        ? tier!.displayName
        : l10n.driverClubHeroBadge;
    final badgeColor = ClubColors.fromHex(tier?.colorHex);
    final badgeUrl = (tier?.badgeUrl ?? '').trim();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.screenEntrance,
      curve: AppMotion.standard,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 16),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppFoundation.spacingXl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppFoundation.radiusLg),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A1F5C),
              Color(0xFF12101C),
              Color(0xFF0E2A24),
            ],
          ),
          border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (badgeUrl.isNotEmpty)
                    ClipOval(
                      child: Image.network(
                        badgeUrl,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.workspace_premium_rounded,
                          size: 16,
                          color: badgeColor,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 16,
                      color: badgeColor,
                    ),
                  const SizedBox(width: 6),
                  Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hello,
              style: const TextStyle(
                color: ClubColors.text,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.driverClubHeroTagline,
              style: const TextStyle(color: ClubColors.muted, height: 1.35),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: ClubColors.violetDeep,
                foregroundColor: Colors.white,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: onHowItWorks,
              child: Text(
                l10n.driverClubHowItWorks,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubWalletCard extends StatelessWidget {
  const _ClubWalletCard({
    required this.hub,
    required this.l10n,
    required this.onLearn,
  });

  final DriverClubHub hub;
  final AppLocalizations l10n;
  final VoidCallback onLearn;

  @override
  Widget build(BuildContext context) {
    final w = hub.wallet;
    final money = formatMoney(w.balance, currencyCode: w.currencyCode);
    String? expiryLabel;
    if (w.expiresAt != null && !w.expired && w.balance > 0) {
      final local = w.expiresAt!.toLocal();
      expiryLabel = l10n.driverClubExpiresOn(
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}',
      );
    }
    return ClubSectionCard(
      accent: ClubColors.teal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: ClubColors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.driverClubWalletTitle,
                style: const TextStyle(
                  color: ClubColors.muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            money,
            style: const TextStyle(
              color: ClubColors.text,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            w.balance > 0 && !w.expired
                ? (expiryLabel ?? l10n.driverClubWalletLiveHint)
                : l10n.driverClubWalletEmptyHint,
            style: const TextStyle(color: ClubColors.muted, height: 1.3),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onLearn,
            style: TextButton.styleFrom(
              foregroundColor: ClubColors.teal,
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
            child: Text(l10n.driverClubLearnOnWeb),
          ),
        ],
      ),
    );
  }
}

class _ClubReferralsCard extends StatelessWidget {
  const _ClubReferralsCard({
    required this.hub,
    required this.l10n,
    required this.claiming,
    required this.claimCtrl,
    required this.onClaim,
    required this.onLearn,
    this.claimError,
  });

  final DriverClubHub hub;
  final AppLocalizations l10n;
  final bool claiming;
  final TextEditingController claimCtrl;
  final VoidCallback onClaim;
  final VoidCallback onLearn;
  final String? claimError;

  @override
  Widget build(BuildContext context) {
    final code = hub.referralCode ?? '—';
    return ClubSectionCard(
      accent: ClubColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverClubInviteTitle,
            style: const TextStyle(
              color: ClubColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.driverClubInviteSubtitle,
            style: const TextStyle(color: ClubColors.muted, height: 1.35),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: l10n.driverClubYourCode,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: ClubColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ClubColors.gold.withValues(alpha: 0.35)),
              ),
              child: SelectableText(
                code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ClubColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: ClubColors.gold,
                    foregroundColor: const Color(0xFF1A1400),
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    HapticFeedback.lightImpact();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.driverClubCodeCopied)),
                    );
                  },
                  icon: const Icon(Icons.content_copy_rounded, size: 18),
                  label: Text(l10n.driverClubCopyCode),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ClubColors.text,
                    side: BorderSide(color: ClubColors.gold.withValues(alpha: 0.5)),
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    final text = Uri.encodeComponent(
                      l10n.driverClubWhatsappShare(code),
                    );
                    final uri = Uri.parse('https://wa.me/?text=$text');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  icon: const ClubWhatsAppIcon(size: 18),
                  label: Text(l10n.driverClubShareWhatsapp),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onLearn,
              style: TextButton.styleFrom(
                foregroundColor: ClubColors.gold,
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
              ),
              child: Text(l10n.driverClubLearnOnWeb),
            ),
          ),
          if (hub.myClaimStatus == null) ...[
            Text(
              l10n.driverClubEnterCodeHint,
              style: const TextStyle(color: ClubColors.muted),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: claimCtrl,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: ClubColors.text),
              decoration: InputDecoration(
                hintText: l10n.driverClubEnterCodeHint,
                filled: true,
                fillColor: ClubColors.cardHi,
              ),
            ),
            if (claimError != null) ...[
              const SizedBox(height: 6),
              Text(claimError!, style: const TextStyle(color: ClubColors.coral)),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: claiming ? null : onClaim,
                child: claiming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.driverClubClaimCta),
              ),
            ),
          ],
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              collapsedIconColor: ClubColors.muted,
              iconColor: ClubColors.gold,
              title: Text(
                l10n.driverClubInviteesTitle,
                style: const TextStyle(
                  color: ClubColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              children: [
                if (hub.invitees.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.driverClubInviteesEmpty,
                      style: const TextStyle(color: ClubColors.muted),
                    ),
                  ),
                for (final inv in hub.invitees)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    minVerticalPadding: 10,
                    leading: CircleAvatar(
                      backgroundColor: ClubColors.violet.withValues(alpha: 0.2),
                      foregroundColor: ClubColors.violet,
                      child: Text(
                        inv.displayName.isNotEmpty
                            ? inv.displayName[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(
                      inv.displayName,
                      style: const TextStyle(color: ClubColors.text),
                    ),
                    trailing: ClubStatusBadge(status: inv.uiStatus),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubLevelsCard extends StatelessWidget {
  const _ClubLevelsCard({
    required this.l10n,
    required this.catalog,
    required this.onLearn,
    this.currentCode,
    this.qualification,
  });

  final AppLocalizations l10n;
  final String? currentCode;
  final List<DriverClubTier> catalog;
  final DriverClubQualification? qualification;
  final VoidCallback onLearn;

  String _tripsLabel(DriverClubTier tier) {
    final min = tier.tripsMin ?? 0;
    final max = tier.tripsMax;
    if (max == null) return l10n.driverClubTripsFrom(min);
    return l10n.driverClubTripsRange(min, max);
  }

  String _ratingLabel(DriverClubTier tier) {
    final r = tier.minRating;
    if (r == null) return l10n.driverClubRatingNone;
    final text = r.toStringAsFixed(r.truncateToDouble() == r ? 0 : 2);
    return l10n.driverClubRatingFrom(text);
  }

  @override
  Widget build(BuildContext context) {
    if (catalog.isEmpty) return const SizedBox.shrink();
    final q = qualification;
    final ratingText = q?.averageRating != null
        ? l10n.driverClubMonthRatingValue(
            q!.averageRating!.toStringAsFixed(2),
          )
        : l10n.driverClubMonthRatingEmpty;
    return ClubSectionCard(
      accent: ClubColors.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.driverClubLevelsTitle,
            style: const TextStyle(
              color: ClubColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.driverClubLevelsHint,
            style: const TextStyle(color: ClubColors.muted, height: 1.35),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.driverClubMonthTripsValue(q?.completedTripCount ?? 0),
            style: const TextStyle(
              color: ClubColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ratingText,
            style: const TextStyle(color: ClubColors.muted),
          ),
          const SizedBox(height: 14),
          for (final tier in catalog) ...[
            _ClubLevelRow(
              tier: tier,
              selected: tier.code == currentCode,
              tripsLabel: _tripsLabel(tier),
              ratingLabel: _ratingLabel(tier),
            ),
            const SizedBox(height: 8),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onLearn,
              style: TextButton.styleFrom(
                foregroundColor: ClubColors.gold,
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
              ),
              child: Text(l10n.driverClubLearnOnWeb),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubLevelRow extends StatelessWidget {
  const _ClubLevelRow({
    required this.tier,
    required this.selected,
    required this.tripsLabel,
    required this.ratingLabel,
  });

  final DriverClubTier tier;
  final bool selected;
  final String tripsLabel;
  final String ratingLabel;

  @override
  Widget build(BuildContext context) {
    final color = ClubColors.fromHex(tier.colorHex, fallback: ClubColors.gold);
    final badgeUrl = (tier.badgeUrl ?? '').trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: selected ? color.withValues(alpha: 0.14) : ClubColors.cardHi,
        border: Border.all(
          color: selected ? color.withValues(alpha: 0.55) : ClubColors.border,
        ),
      ),
      child: Row(
        children: [
          if (badgeUrl.isNotEmpty)
            ClipOval(
              child: Image.network(
                badgeUrl,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Icon(
                  Icons.workspace_premium_rounded,
                  size: 18,
                  color: color,
                ),
              ),
            )
          else
            Icon(Icons.workspace_premium_rounded, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier.displayName,
                  style: TextStyle(
                    color: selected ? color : ClubColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$tripsLabel · $ratingLabel',
                  style: const TextStyle(
                    color: ClubColors.muted,
                    fontSize: 12,
                    height: 1.25,
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
