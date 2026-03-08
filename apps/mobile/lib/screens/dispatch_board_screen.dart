import 'package:flutter/material.dart';
import 'package:tms_mobile/core/formatters/tms_labels.dart';
import 'package:tms_mobile/core/network/tms_api_client.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';
import 'package:tms_mobile/models/dispatch_item.dart';
import 'package:tms_mobile/widgets/tms_ui.dart';

class DispatchBoardScreen extends StatefulWidget {
  const DispatchBoardScreen({super.key, required this.client});

  final TmsApiClient client;

  @override
  State<DispatchBoardScreen> createState() => _DispatchBoardScreenState();
}

class _DispatchBoardScreenState extends State<DispatchBoardScreen> {
  late Future<List<DispatchItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.client.fetchDispatches();
  }

  Future<void> _refresh() async {
    final next = widget.client.fetchDispatches();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DispatchItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _DispatchErrorState(
            message: localizeErrorMessage(snapshot.error!),
            onRetry: _refresh,
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final dispatches = snapshot.data!;
        final liveCount = dispatches
            .where(
              (dispatch) =>
                  dispatch.status != 'COMPLETED' &&
                  dispatch.status != 'CANCELLED' &&
                  dispatch.status != 'REJECTED',
            )
            .length;
        final margin = dispatches.fold<double>(
          0,
          (sum, dispatch) => sum + dispatch.freightAmount - dispatch.costAmount,
        );

        return PageReveal(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 1080;
                final cardWidth = isWide
                    ? (constraints.maxWidth - 12) / 2
                    : constraints.maxWidth;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  children: [
                    AppSurface(
                      padding: const EdgeInsets.all(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEAF5F1),
                          Color(0xFFF6F1E8),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeading(
                            title: '배차 보드',
                            subtitle:
                                '운송사 실행 현황, 배정 자산, 마진 흐름을 한 화면에서 확인합니다.',
                            trailing: DetailChip(
                              label: '${dispatches.length}건',
                              icon: Icons.local_shipping_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              DetailChip(
                                label: '진행 $liveCount건',
                                icon: Icons.route_rounded,
                              ),
                              DetailChip(
                                label: formatCompactKrw(margin),
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                              const DetailChip(
                                label: '운송사 스냅샷 준비됨',
                                icon: Icons.photo_filter_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (dispatches.isEmpty)
                      const _EmptyDispatches()
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: dispatches
                            .map(
                              (dispatch) => SizedBox(
                                width: cardWidth,
                                child: _DispatchCard(item: dispatch),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _DispatchCard extends StatelessWidget {
  const _DispatchCard({required this.item});

  final DispatchItem item;

  @override
  Widget build(BuildContext context) {
    final margin = item.freightAmount - item.costAmount;
    return AppSurface(
      padding: const EdgeInsets.all(20),
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.dispatchNo, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '${item.orderNo}  |  ${item.carrierCompanyName}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: localizeStatus(item.status),
                color: AppTheme.statusColor(item.status),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.skyWash.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                DetailChip(
                  label: item.vehicleNo ?? '배정 차량 없음',
                  icon: Icons.airport_shuttle_rounded,
                ),
                DetailChip(
                  label: item.driverName ?? '배정 기사 없음',
                  icon: Icons.badge_rounded,
                ),
                DetailChip(
                  label: formatKoreanDateTime(item.assignedAt),
                  icon: Icons.schedule_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DetailChip(
                label: '운임 ${formatCompactKrw(item.freightAmount)}',
                icon: Icons.north_east_rounded,
              ),
              DetailChip(
                label: '원가 ${formatCompactKrw(item.costAmount)}',
                icon: Icons.south_west_rounded,
              ),
              DetailChip(
                label: '마진 ${formatCompactKrw(margin)}',
                icon: Icons.query_stats_rounded,
              ),
              if (item.note != null && item.note!.isNotEmpty)
                DetailChip(
                  label: item.note!,
                  icon: Icons.sticky_note_2_rounded,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyDispatches extends StatelessWidget {
  const _EmptyDispatches();

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_rounded,
            size: 42,
            color: AppColors.teal.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text('등록된 배차가 없습니다', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '운송사를 배정하면 실행 보드에 배차가 표시됩니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _DispatchErrorState extends StatelessWidget {
  const _DispatchErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppSurface(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '배차 화면을 불러올 수 없습니다',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
