import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../../login/driver_realtime_controller.dart';

/// Abre el sheet modal de chat contextual del viaje activo.
Future<void> showDriverTripChatSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String tripId,
}) async {
  if (!driverTripChatPhaseActive(
    ref.read(driverRealtimeProvider).activeTrip?.status,
  )) {
    return;
  }

  final controller = ref.read(driverRealtimeProvider.notifier);
  final l10n = AppLocalizations.of(context);
  final textController = TextEditingController();
  final quickTemplates = <Map<String, String>>[
    {'code': 'I_AM_AT_PICKUP', 'label': l10n.driverTripChatTemplateArrived},
    {
      'code': 'CANNOT_FIND_PASSENGER',
      'label': l10n.driverTripChatTemplateCannotFind,
    },
    {
      'code': 'PLEASE_CONFIRM_LOCATION',
      'label': l10n.driverTripChatTemplateConfirmLocation,
    },
  ];

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final mq = MediaQuery.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            bottom: mq.viewInsets.bottom,
            left: 10,
            right: 10,
            top: 8,
          ),
          child: FractionallySizedBox(
            heightFactor: 0.82,
            child: DriverTripChatPanel(
              tripId: tripId,
              l10n: l10n,
              textController: textController,
              quickTemplates: quickTemplates,
              onSend: (text) {
                controller.sendTripChatText(tripId: tripId, text: text);
                textController.clear();
              },
              bottomInset: mq.viewPadding.bottom,
              onClose: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
    );
  } finally {
    textController.dispose();
  }
}

/// Contenido del panel de chat (mensajes, plantillas rápidas, composer).
class DriverTripChatPanel extends ConsumerWidget {
  const DriverTripChatPanel({
    super.key,
    required this.tripId,
    required this.l10n,
    required this.textController,
    required this.quickTemplates,
    required this.onSend,
    required this.onClose,
    this.bottomInset = 0,
  });

  final String tripId;
  final AppLocalizations l10n;
  final TextEditingController textController;
  final List<Map<String, String>> quickTemplates;
  final ValueChanged<String> onSend;
  final VoidCallback onClose;
  final double bottomInset;

  String _formatTime(DateTime? dt) {
    if (dt == null) return l10n.driverTripChatNow;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _tripChatErrorMessage(String code) {
    if (code == '42P01' || code == 'TRIP_CHAT_STORAGE_UNAVAILABLE') {
      return l10n.driverTripChatErrorStorage;
    }
    if (code == 'TRIP_CHAT_NOT_AVAILABLE') {
      return l10n.driverTripChatErrorPhase;
    }
    return l10n.driverTripChatErrorSendReceive;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rt = ref.watch(driverRealtimeProvider);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 10, 14, 12 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.driverTripChatTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (rt.online || rt.connecting)
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      (rt.online || rt.connecting)
                          ? l10n.driverTripChatOnline
                          : l10n.driverTripChatOffline,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: (rt.online || rt.connecting)
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              Text(
                l10n.driverTripChatSubtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: quickTemplates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final it = quickTemplates[index];
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      onPressed: () {
                        textController.text = it['label']!;
                        textController.selection = TextSelection.collapsed(
                          offset: textController.text.length,
                        );
                      },
                      child: Text(
                        it['label']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                ),
              ),
              if (rt.tripChatErrorCode != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _tripChatErrorMessage(rt.tripChatErrorCode!),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.45),
                    ),
                  ),
                  child: rt.chatMessages.isEmpty
                      ? Center(
                          child: Text(
                            l10n.driverTripChatEmptyState,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: rt.chatMessages.length,
                          itemBuilder: (context, index) {
                            final msg = rt.chatMessages[index];
                            final mine = msg.senderRole == 'driver';
                            return Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 280),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? AppColors.primary.withValues(alpha: 0.2)
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft: Radius.circular(mine ? 14 : 4),
                                    bottomRight: Radius.circular(mine ? 4 : 14),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.messageText,
                                      style: const TextStyle(height: 1.25),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${mine ? 'Tú' : 'Pasajero'} · ${_formatTime(msg.createdAt)}',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.textSecondary
                                            .withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.55),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textController,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: l10n.driverTripChatMessageHint,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 40,
                        child: FilledButton(
                          onPressed: () {
                            final t = textController.text.trim();
                            if (t.isEmpty) return;
                            onSend(t);
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: const Size(44, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: const Icon(Icons.send_rounded, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
