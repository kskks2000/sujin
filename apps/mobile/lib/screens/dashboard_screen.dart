import 'package:flutter/material.dart';
import 'package:tms_mobile/core/formatters/tms_labels.dart';
import 'package:tms_mobile/core/network/tms_api_client.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';
import 'package:tms_mobile/models/dashboard_summary.dart';
import 'package:tms_mobile/models/session.dart';
import 'package:tms_mobile/widgets/tms_ui.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.client, required this.session});

  final TmsApiClient client;
  final Session session;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.client.fetchDashboardSummary();
  }

  Future<void> _refresh() async {
    final next = widget.client.fetchDashboardSummary();
    setState(() {
      _future = next;
    });
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _ErrorState(
            message: localizeErrorMessage(snapshot.error!),
            onRetry: _refresh,
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = snapshot.data!;
        return PageReveal(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 960;
                final isPhone = !isWide && constraints.maxWidth < 520;
                final gridColumns = isWide ? 3 : 2;
                final listPadding = isPhone ? 16.0 : 24.0;

                return ListView(
                  padding: EdgeInsets.fromLTRB(listPadding, listPadding, listPadding, 32),
                  children: [
                    _HeroPanel(
                      summary: summary,
                      session: widget.session,
                    ),
                    SizedBox(height: isPhone ? 16 : 20),
                    const SectionHeading(
                      title: '운영 현황',
                      subtitle: '오더 흐름, 배차 강도, 자원 가용 상태를 확인합니다.',
                    ),
                    SizedBox(height: isPhone ? 10 : 12),
                    GridView.count(
                      crossAxisCount: gridColumns,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: isWide ? 1.12 : 1.04,
                      children: [
                        MetricTile(
                          label: '전체 오더',
                          value: summary.totalOrders.toString(),
                          icon: Icons.inventory_2_rounded,
                          accent: AppColors.teal,
                          note: '플랫폼 등록 건수',
                          compact: !isWide,
                        ),
                        MetricTile(
                          label: '진행 오더',
                          value: summary.activeOrders.toString(),
                          icon: Icons.route_rounded,
                          accent: AppColors.gold,
                          note: '현재 운행 중',
                          compact: !isWide,
                        ),
                        MetricTile(
                          label: '완료',
                          value: summary.completedOrders.toString(),
                          icon: Icons.task_alt_rounded,
                          accent: const Color(0xFF2F8C66),
                          note: '정상 종료 건수',
                          compact: !isWide,
                        ),
                        MetricTile(
                          label: '배차',
                          value: summary.activeDispatchesCount.toString(),
                          icon: Icons.local_shipping_rounded,
                          accent: AppColors.teal,
                          note: '실시간 배차 현황',
                          compact: !isWide,
                        ),
                        MetricTile(
                          label: '차량',
                          value: summary.availableVehicles.toString(),
                          icon: Icons.airport_shuttle_rounded,
                          accent: AppColors.clay,
                          note: '운영 가능 차량',
                          compact: !isWide,
                        ),
                        MetricTile(
                          label: '기사',
                          value: summary.availableDrivers.toString(),
                          icon: Icons.badge_rounded,
                          accent: AppColors.gold,
                          note: '배정 가능 기사',
                          compact: !isWide,
                        ),
                      ],
                    ),
                    SizedBox(height: isPhone ? 16 : 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _OrderPanel(orders: summary.recentOrders),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _DispatchPanel(dispatches: summary.activeDispatches),
                          ),
                        ],
                      )
                    else ...[
                      _OrderPanel(orders: summary.recentOrders),
                      const SizedBox(height: 16),
                      _DispatchPanel(dispatches: summary.activeDispatches),
                    ],
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.summary,
    required this.session,
  });

  final DashboardSummary summary;
  final Session session;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 960;
    final isPhone = !isWide && MediaQuery.sizeOf(context).width < 520;

    return AppSurface(
      padding: EdgeInsets.all(isPhone ? 18 : 24),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF358D85),
          Color(0xFF68CBBB),
          Color(0xFFA5F2E1),
        ],
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _HeroCopy(
                    summary: summary,
                    session: session,
                  ),
                ),
                const SizedBox(width: 20),
                _HeroSignal(summary: summary),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroCopy(summary: summary, session: session),
                const SizedBox(height: 18),
                _HeroSignal(summary: summary),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({
    required this.summary,
    required this.session,
  });

  final DashboardSummary summary;
  final Session session;

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.sizeOf(context).width < 520;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TmsLogo(
          size: 48,
          light: true,
          showCaption: false,
        ),
        SizedBox(height: isPhone ? 10 : 14),
        Text(
          '${session.userName}님, 다시 오셨네요',
          style: (isPhone
                  ? Theme.of(context).textTheme.headlineMedium
                  : Theme.of(context).textTheme.displaySmall)
              ?.copyWith(color: AppColors.midnight),
        ),
        SizedBox(height: isPhone ? 8 : 10),
        Text(
          '현재 실시간 보드에는 진행 중 오더 ${summary.activeOrders}건과 배차 ${summary.activeDispatchesCount}건이 반영되어 있습니다.',
          maxLines: isPhone ? 2 : null,
          overflow: isPhone ? TextOverflow.ellipsis : TextOverflow.visible,
          style: (isPhone
                  ? Theme.of(context).textTheme.bodyMedium
                  : Theme.of(context).textTheme.bodyLarge)
              ?.copyWith(color: AppColors.midnight.withValues(alpha: 0.78)),
        ),
        SizedBox(height: isPhone ? 12 : 18),
        Wrap(
          spacing: isPhone ? 8 : 10,
          runSpacing: isPhone ? 8 : 10,
          children: [
            _DarkChip(
              label: localizeUserRole(session.userRole),
              icon: Icons.badge_rounded,
              dense: isPhone,
            ),
            _DarkChip(
              label: session.baseUrl.replaceFirst('http://', ''),
              icon: Icons.link_rounded,
              dense: isPhone,
            ),
            _DarkChip(
              label: 'Redis 캐시 연결됨',
              icon: Icons.flash_on_rounded,
              dense: isPhone,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroSignal extends StatelessWidget {
  const _HeroSignal({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          _SignalCard(
            title: '진행 배차',
            value: summary.activeDispatchesCount.toString(),
          ),
          const SizedBox(height: 10),
          _SignalCard(
            title: '가용 자원',
            value: '차량 ${summary.availableVehicles}대 / 기사 ${summary.availableDrivers}명',
          ),
          const SizedBox(height: 10),
          _SignalCard(
            title: '완료율',
            value: summary.totalOrders == 0
                ? '0%'
                : '${((summary.completedOrders / summary.totalOrders) * 100).round()}%',
          ),
        ],
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  const _OrderPanel({required this.orders});

  final List<DashboardOrderPreview> orders;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: '최근 오더',
            subtitle: '최신 접수 현황과 경로 스냅샷입니다.',
            trailing: DetailChip(
              label: '${orders.length}건',
              icon: Icons.inventory_2_rounded,
            ),
          ),
          const SizedBox(height: 14),
          if (orders.isEmpty)
            const _EmptyMessage(message: '최근 등록된 오더가 없습니다.')
          else
            ...orders.map((order) => _OrderRow(order: order)),
        ],
      ),
    );
  }
}

class _DispatchPanel extends StatelessWidget {
  const _DispatchPanel({required this.dispatches});

  final List<DashboardDispatchPreview> dispatches;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(
            title: '진행 배차',
            subtitle: '배정된 자산과 함께 현재 실행 중인 배차입니다.',
            trailing: DetailChip(
              label: '${dispatches.length}건 진행',
              icon: Icons.local_shipping_rounded,
            ),
          ),
          const SizedBox(height: 14),
          if (dispatches.isEmpty)
            const _EmptyMessage(message: '현재 진행 중인 배차가 없습니다.')
          else
            ...dispatches.map((dispatch) => _DispatchRow(dispatch: dispatch)),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final DashboardOrderPreview order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              StatusBadge(
                label: localizeStatus(order.status),
                color: AppTheme.statusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(order.billToCompanyName),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trip_origin_rounded, size: 16, color: AppColors.teal),
              const SizedBox(width: 8),
              Expanded(child: Text(order.pickupName ?? '미지정')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.south_rounded, size: 16, color: AppColors.slate),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryName ?? '미지정',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DispatchRow extends StatelessWidget {
  const _DispatchRow({required this.dispatch});

  final DashboardDispatchPreview dispatch;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dispatch.dispatchNo,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              StatusBadge(
                label: localizeStatus(dispatch.status),
                color: AppTheme.statusColor(dispatch.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${dispatch.orderNo}  |  ${dispatch.carrierCompanyName}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DetailChip(
                label: dispatch.vehicleNo ?? '배정 차량 없음',
                icon: Icons.airport_shuttle_rounded,
              ),
              DetailChip(
                label: dispatch.driverName ?? '배정 기사 없음',
                icon: Icons.badge_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  const _DarkChip({
    required this.label,
    required this.icon,
    this.dense = false,
  });

  final String label;
  final IconData icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 12,
        vertical: dense ? 7 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: dense ? 13 : 14, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.midnight,
              fontSize: dense ? 11 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.14),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.midnight.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.midnight,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
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
                '관제 대시보드를 불러올 수 없습니다',
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
