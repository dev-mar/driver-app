class DriverCompanyPayoutException implements Exception {
  DriverCompanyPayoutException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => message;
}

class DriverCompanyPayoutItem {
  const DriverCompanyPayoutItem({
    required this.receivableId,
    required this.tripId,
    required this.amount,
    required this.source,
    this.createdAt,
    this.campaignCode,
    this.campaignName,
  });

  final String receivableId;
  final String tripId;
  final double amount;
  final String source;
  final DateTime? createdAt;
  final String? campaignCode;
  final String? campaignName;

  factory DriverCompanyPayoutItem.fromJson(Map<String, dynamic> json) {
    return DriverCompanyPayoutItem(
      receivableId: json['receivableId']?.toString() ?? '',
      tripId: json['tripId']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      source: json['source']?.toString() ?? 'campaign',
      createdAt: _toDate(json['createdAt']),
      campaignCode: json['campaignCode']?.toString(),
      campaignName: json['campaignName']?.toString(),
    );
  }
}

class DriverCompanyPayoutRequest {
  const DriverCompanyPayoutRequest({
    required this.id,
    required this.amount,
    required this.status,
    this.currencyCode = 'BOB',
    this.rejectReasonCode,
    this.rejectNote,
    this.createdAt,
    this.reviewedAt,
    this.paidAt,
    this.items = const [],
  });

  final String id;
  final double amount;
  final String status;
  final String currencyCode;
  final String? rejectReasonCode;
  final String? rejectNote;
  final DateTime? createdAt;
  final DateTime? reviewedAt;
  final DateTime? paidAt;
  final List<DriverCompanyPayoutItem> items;

  bool get isOpen => status == 'in_review' || status == 'approved';
  bool get isPaid => status == 'paid';
  bool get isRejected => status == 'rejected';

  factory DriverCompanyPayoutRequest.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return DriverCompanyPayoutRequest(
      id: json['id']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      status: json['status']?.toString() ?? '',
      currencyCode: json['currencyCode']?.toString() ?? 'BOB',
      rejectReasonCode: json['rejectReasonCode']?.toString(),
      rejectNote: json['rejectNote']?.toString(),
      createdAt: _toDate(json['createdAt']),
      reviewedAt: _toDate(json['reviewedAt']),
      paidAt: _toDate(json['paidAt']),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => DriverCompanyPayoutItem.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
    );
  }
}

class DriverCompanyPayoutSnapshot {
  const DriverCompanyPayoutSnapshot({
    required this.collectibleTotal,
    required this.currencyCode,
    required this.items,
    required this.canSubmit,
    this.blockReason,
    this.openRequest,
    this.history = const [],
  });

  final double collectibleTotal;
  final String currencyCode;
  final List<DriverCompanyPayoutItem> items;
  final bool canSubmit;
  final String? blockReason;
  final DriverCompanyPayoutRequest? openRequest;
  final List<DriverCompanyPayoutRequest> history;

  factory DriverCompanyPayoutSnapshot.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final rawHistory = json['history'];
    final open = json['openRequest'];
    return DriverCompanyPayoutSnapshot(
      collectibleTotal: _toDouble(json['collectibleTotal']),
      currencyCode: json['currencyCode']?.toString() ?? 'BOB',
      canSubmit: json['canSubmit'] == true,
      blockReason: json['blockReason']?.toString(),
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => DriverCompanyPayoutItem.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
      openRequest: open is Map
          ? DriverCompanyPayoutRequest.fromJson(Map<String, dynamic>.from(open))
          : null,
      history: rawHistory is List
          ? rawHistory
              .whereType<Map>()
              .map((e) => DriverCompanyPayoutRequest.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList()
          : const [],
    );
  }
}

double _toDouble(Object? raw) {
  if (raw is num) return raw.toDouble();
  return double.tryParse(raw?.toString() ?? '') ?? 0;
}

DateTime? _toDate(Object? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw.toString());
}
