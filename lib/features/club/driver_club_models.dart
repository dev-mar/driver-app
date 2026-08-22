class DriverClubWallet {
  const DriverClubWallet({
    required this.balance,
    this.expiresAt,
    required this.expired,
    this.currencyCode = 'BOB',
  });

  final double balance;
  final DateTime? expiresAt;
  final bool expired;
  final String currencyCode;

  factory DriverClubWallet.fromJson(Map<String, dynamic> json) {
    final exp = json['expiresAt'] ?? json['expires_at'];
    return DriverClubWallet(
      balance: _asDouble(json['balance']) ?? 0,
      expiresAt: exp is String ? DateTime.tryParse(exp) : null,
      expired: json['expired'] == true,
      currencyCode: (json['currencyCode'] ?? json['currency_code'] ?? 'BOB')
          .toString(),
    );
  }
}

class DriverClubCampaign {
  const DriverClubCampaign({
    this.countryId,
    required this.directBonusAmount,
    required this.cascadeBonusAmount,
    required this.activationTripGoal,
    required this.fulfillmentDays,
    required this.referralCreditTtlDays,
    required this.clubCommissionSharePercent,
  });

  final String? countryId;
  final double directBonusAmount;
  final double cascadeBonusAmount;
  final int activationTripGoal;
  final int fulfillmentDays;
  final int referralCreditTtlDays;
  final double clubCommissionSharePercent;

  factory DriverClubCampaign.fromJson(Map<String, dynamic> json) {
    return DriverClubCampaign(
      countryId: json['countryId']?.toString() ?? json['country_id']?.toString(),
      directBonusAmount: _asDouble(json['directBonusAmount'] ?? json['direct_bonus_amount']) ?? 0,
      cascadeBonusAmount: _asDouble(json['cascadeBonusAmount'] ?? json['cascade_bonus_amount']) ?? 0,
      activationTripGoal: _asInt(json['activationTripGoal'] ?? json['activation_trip_goal']) ?? 20,
      fulfillmentDays: _asInt(json['fulfillmentDays'] ?? json['fulfillment_days']) ?? 14,
      referralCreditTtlDays:
          _asInt(json['referralCreditTtlDays'] ?? json['referral_credit_ttl_days']) ?? 30,
      clubCommissionSharePercent: _asDouble(
            json['clubCommissionSharePercent'] ?? json['club_commission_share_percent'],
          ) ??
          50,
    );
  }
}

class DriverClubInvitee {
  const DriverClubInvitee({
    required this.referredId,
    required this.displayName,
    required this.uiStatus,
    required this.eligibleTripCount,
    required this.tripGoal,
  });

  final String referredId;
  final String displayName;
  final String uiStatus;
  final int eligibleTripCount;
  final int tripGoal;

  factory DriverClubInvitee.fromJson(Map<String, dynamic> json) {
    return DriverClubInvitee(
      referredId: (json['referredId'] ?? json['referred_id'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['display_name'] ?? 'Conductor').toString(),
      uiStatus: (json['uiStatus'] ?? json['ui_status'] ?? 'pending').toString(),
      eligibleTripCount: _asInt(json['eligibleTripCount'] ?? json['eligible_trip_count']) ?? 0,
      tripGoal: _asInt(json['tripGoal'] ?? json['trip_goal']) ?? 20,
    );
  }
}

class DriverClubTier {
  const DriverClubTier({
    required this.code,
    required this.displayName,
    required this.colorHex,
    this.badgeUrl,
    this.tripsMin,
    this.tripsMax,
    this.minRating,
  });

  final String code;
  final String displayName;
  final String colorHex;
  final String? badgeUrl;
  final int? tripsMin;
  final int? tripsMax;
  final double? minRating;

  factory DriverClubTier.fromJson(Map<String, dynamic> json) {
    return DriverClubTier(
      code: (json['code'] ?? 'start').toString(),
      displayName: (json['displayName'] ?? json['display_name'] ?? 'Texi Start').toString(),
      colorHex: (json['colorHex'] ?? json['color_hex'] ?? '#B7B3CC').toString(),
      badgeUrl: json['badgeUrl']?.toString() ?? json['badge_url']?.toString(),
      tripsMin: _asInt(json['tripsMin'] ?? json['trips_min']),
      tripsMax: _asInt(json['tripsMax'] ?? json['trips_max']),
      minRating: _asDouble(json['minRating'] ?? json['min_rating']),
    );
  }
}

class DriverClubQualification {
  const DriverClubQualification({
    this.timezone,
    this.periodStart,
    this.periodEnd,
    required this.completedTripCount,
    this.averageRating,
    required this.ratingsCount,
    this.lifetimeAverageRating,
    required this.lifetimeRatingsCount,
  });

  final String? timezone;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final int completedTripCount;
  final double? averageRating;
  final int ratingsCount;
  final double? lifetimeAverageRating;
  final int lifetimeRatingsCount;

  factory DriverClubQualification.fromJson(Map<String, dynamic> json) {
    final start = json['periodStart'] ?? json['period_start'];
    final end = json['periodEnd'] ?? json['period_end'];
    return DriverClubQualification(
      timezone: json['timezone']?.toString(),
      periodStart: start is String ? DateTime.tryParse(start) : null,
      periodEnd: end is String ? DateTime.tryParse(end) : null,
      completedTripCount: _asInt(json['completedTripCount'] ?? json['completed_trip_count']) ?? 0,
      averageRating: _asDouble(json['averageRating'] ?? json['average_rating']),
      ratingsCount: _asInt(json['ratingsCount'] ?? json['ratings_count']) ?? 0,
      lifetimeAverageRating: _asDouble(
        json['lifetimeAverageRating'] ?? json['lifetime_average_rating'],
      ),
      lifetimeRatingsCount:
          _asInt(json['lifetimeRatingsCount'] ?? json['lifetime_ratings_count']) ?? 0,
    );
  }
}

class DriverClubHub {
  const DriverClubHub({
    required this.programEnabled,
    this.referralCode,
    this.shareUrl,
    required this.wallet,
    required this.campaign,
    this.myClaimStatus,
    required this.invitees,
    required this.n2Count,
    this.tier,
    this.tierCatalog = const [],
    this.qualification,
  });

  final bool programEnabled;
  final String? referralCode;
  final String? shareUrl;
  final DriverClubWallet wallet;
  final DriverClubCampaign campaign;
  final String? myClaimStatus;
  final List<DriverClubInvitee> invitees;
  final int n2Count;
  final DriverClubTier? tier;
  final List<DriverClubTier> tierCatalog;
  final DriverClubQualification? qualification;

  factory DriverClubHub.fromJson(Map<String, dynamic> json) {
    final walletRaw = json['wallet'];
    final campaignRaw = json['campaign'];
    final inviteesRaw = json['invitees'];
    final n2 = json['n2'];
    final myClaim = json['myClaim'] ?? json['my_claim'];
    final tierRaw = json['tier'];
    final catalogRaw = json['tierCatalog'] ?? json['tier_catalog'];
    final qualRaw = json['qualification'];
    return DriverClubHub(
      programEnabled: json['programEnabled'] == true || json['program_enabled'] == true,
      referralCode: json['referralCode']?.toString() ?? json['referral_code']?.toString(),
      shareUrl: json['shareUrl']?.toString() ?? json['share_url']?.toString(),
      wallet: walletRaw is Map
          ? DriverClubWallet.fromJson(Map<String, dynamic>.from(walletRaw))
          : const DriverClubWallet(balance: 0, expired: false),
      campaign: campaignRaw is Map
          ? DriverClubCampaign.fromJson(Map<String, dynamic>.from(campaignRaw))
          : const DriverClubCampaign(
              directBonusAmount: 150,
              cascadeBonusAmount: 40,
              activationTripGoal: 20,
              fulfillmentDays: 14,
              referralCreditTtlDays: 30,
              clubCommissionSharePercent: 50,
            ),
      myClaimStatus: myClaim is Map ? myClaim['status']?.toString() : null,
      invitees: inviteesRaw is List
          ? inviteesRaw
              .whereType<Map>()
              .map((e) => DriverClubInvitee.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      n2Count: n2 is Map ? (_asInt(n2['count']) ?? 0) : 0,
      tier: tierRaw is Map
          ? DriverClubTier.fromJson(Map<String, dynamic>.from(tierRaw))
          : null,
      tierCatalog: catalogRaw is List
          ? catalogRaw
              .whereType<Map>()
              .map((e) => DriverClubTier.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      qualification: qualRaw is Map
          ? DriverClubQualification.fromJson(Map<String, dynamic>.from(qualRaw))
          : null,
    );
  }
}

double? _asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
