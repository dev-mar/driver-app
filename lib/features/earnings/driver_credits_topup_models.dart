class DriverTopupPackage {
  const DriverTopupPackage({
    required this.id,
    required this.amount,
    required this.title,
    this.instructions,
    this.qrImageUrl,
  });

  final String id;
  final double amount;
  final String title;
  final String? instructions;
  final String? qrImageUrl;

  factory DriverTopupPackage.fromJson(Map<String, dynamic> json) {
    return DriverTopupPackage(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0,
      title: json['title']?.toString() ?? '',
      instructions: json['instructions']?.toString(),
      qrImageUrl: json['qrImageUrl']?.toString() ?? json['qr_image_url']?.toString(),
    );
  }
}

class DriverTopupTicket {
  const DriverTopupTicket({
    required this.id,
    required this.declaredAmount,
    required this.status,
    this.packageTitle,
    this.createdAt,
    this.rejectionReason,
  });

  final String id;
  final double declaredAmount;
  final String status;
  final String? packageTitle;
  final DateTime? createdAt;
  final String? rejectionReason;

  factory DriverTopupTicket.fromJson(Map<String, dynamic> json) {
    DateTime? created;
    final raw = json['createdAt'] ?? json['created_at'];
    if (raw != null) created = DateTime.tryParse(raw.toString());
    return DriverTopupTicket(
      id: json['id']?.toString() ?? '',
      declaredAmount: (json['declaredAmount'] is num)
          ? (json['declaredAmount'] as num).toDouble()
          : (json['declared_amount'] is num)
              ? (json['declared_amount'] as num).toDouble()
              : 0,
      status: json['status']?.toString() ?? '',
      packageTitle: json['packageTitle']?.toString() ?? json['package_title']?.toString(),
      createdAt: created,
      rejectionReason:
          json['rejectionReason']?.toString() ?? json['rejection_reason']?.toString(),
    );
  }
}

class DriverTopupCatalog {
  const DriverTopupCatalog({
    required this.enabled,
    required this.canSubmit,
    required this.maxSubmitsPerDay,
    required this.submitsToday,
    this.helpText,
    this.blockReason,
    this.pendingTicket,
    this.packages = const [],
    this.tickets = const [],
  });

  final bool enabled;
  final bool canSubmit;
  final int maxSubmitsPerDay;
  final int submitsToday;
  final String? helpText;
  final String? blockReason;
  final DriverTopupTicket? pendingTicket;
  final List<DriverTopupPackage> packages;
  final List<DriverTopupTicket> tickets;

  factory DriverTopupCatalog.fromJson(Map<String, dynamic> json) {
    DriverTopupTicket? pending;
    final p = json['pendingTicket'] ?? json['pending_ticket'];
    if (p is Map) pending = DriverTopupTicket.fromJson(Map<String, dynamic>.from(p));
    return DriverTopupCatalog(
      enabled: json['enabled'] == true,
      canSubmit: json['canSubmit'] == true || json['can_submit'] == true,
      maxSubmitsPerDay: (json['maxSubmitsPerCalendarDay'] as num?)?.toInt() ??
          (json['max_submits_per_calendar_day'] as num?)?.toInt() ??
          2,
      submitsToday: (json['submitsToday'] as num?)?.toInt() ??
          (json['submits_today'] as num?)?.toInt() ??
          0,
      helpText: json['helpText']?.toString() ?? json['help_text']?.toString(),
      blockReason: json['blockReason']?.toString() ?? json['block_reason']?.toString(),
      pendingTicket: pending,
      packages: (json['packages'] is List)
          ? (json['packages'] as List)
              .whereType<Map>()
              .map((e) => DriverTopupPackage.fromJson(Map<String, dynamic>.from(e)))
              .where((e) => e.id.isNotEmpty)
              .toList()
          : const [],
      tickets: (json['tickets'] is List)
          ? (json['tickets'] as List)
              .whereType<Map>()
              .map((e) => DriverTopupTicket.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}
