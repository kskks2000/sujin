import 'package:flutter/material.dart';
import 'package:tms_mobile/core/formatters/tms_labels.dart';
import 'package:tms_mobile/core/network/tms_api_client.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';
import 'package:tms_mobile/models/order_item.dart';
import 'package:tms_mobile/screens/order_create_screen.dart';
import 'package:tms_mobile/widgets/tms_ui.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.client});

  final TmsApiClient client;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.client.fetchOrders();
  }

  Future<void> _refresh() async {
    final next = widget.client.fetchOrders();
    setState(() {
      _future = next;
    });
    await next;
  }

  Future<void> _openCreateOrder() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OrderCreateScreen(client: widget.client),
        fullscreenDialog: true,
      ),
    );

    if (created != true || !mounted) {
      return;
    }

    await _refresh();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('오더가 등록되었습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _OrdersErrorState(
            message: localizeErrorMessage(snapshot.error!),
            onRetry: _refresh,
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!;
        final activeCount = orders
            .where(
              (order) =>
                  order.status != 'COMPLETED' && order.status != 'CANCELLED',
            )
            .length;
        final scheduledCount = orders
            .where((order) => order.serviceDate != null)
            .length;
        final completedCount = orders
            .where((order) => order.status == 'COMPLETED')
            .length;

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
                    _OrdersOverview(
                      totalCount: orders.length,
                      activeCount: activeCount,
                      scheduledCount: scheduledCount,
                      completedCount: completedCount,
                      onCreateOrder: _openCreateOrder,
                    ),
                    const SizedBox(height: 18),
                    if (orders.isEmpty)
                      _EmptyOrders(onCreateOrder: _openCreateOrder)
                    else
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: orders
                            .map(
                              (order) => SizedBox(
                                width: cardWidth,
                                child: _OrderCard(order: order),
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

class _OrdersOverview extends StatelessWidget {
  const _OrdersOverview({
    required this.totalCount,
    required this.activeCount,
    required this.scheduledCount,
    required this.completedCount,
    required this.onCreateOrder,
  });

  final int totalCount;
  final int activeCount;
  final int scheduledCount;
  final int completedCount;
  final VoidCallback onCreateOrder;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(22),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFEF7EE), Color(0xFFF4EEE4)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNarrow) ...[
                const SectionHeading(
                  title: '오더 데스크',
                  subtitle: '접수, 경로, 청구 기준을 확인하고 신규 오더를 바로 등록합니다.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onCreateOrder,
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('신규 오더 등록'),
                  ),
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: SectionHeading(
                        title: '오더 데스크',
                        subtitle: '접수, 경로, 청구 기준을 확인하고 신규 오더를 바로 등록합니다.',
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: onCreateOrder,
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('신규 오더 등록'),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  DetailChip(
                    label: '전체 $totalCount건',
                    icon: Icons.inventory_2_rounded,
                  ),
                  DetailChip(
                    label: '진행 $activeCount건',
                    icon: Icons.route_rounded,
                  ),
                  DetailChip(
                    label: '일정 확정 $scheduledCount건',
                    icon: Icons.calendar_month_rounded,
                  ),
                  DetailChip(
                    label: '완료 $completedCount건',
                    icon: Icons.task_alt_rounded,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderItem order;

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      order.orderNo,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.billToCompanyName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: localizeStatus(order.status),
                color: AppTheme.statusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mintWash.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _RouteRow(
                  icon: Icons.trip_origin_rounded,
                  color: AppColors.teal,
                  label: '상차지',
                  value: order.pickupName ?? '미정',
                ),
                const SizedBox(height: 10),
                _RouteRow(
                  icon: Icons.flag_rounded,
                  color: AppColors.clay,
                  label: '하차지',
                  value: order.deliveryName ?? '미정',
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
                label: order.shipperName ?? '화주 미지정',
                icon: Icons.outbox_rounded,
                dense: true,
              ),
              DetailChip(
                label: order.consigneeName ?? '수령처 미지정',
                icon: Icons.move_to_inbox_rounded,
                dense: true,
              ),
              DetailChip(
                label: order.cargoName ?? '화물명 미입력',
                icon: Icons.inventory_rounded,
                dense: true,
              ),
              DetailChip(
                label: order.cargoWeightKg != null
                    ? '${order.cargoWeightKg!.toStringAsFixed(0)} kg'
                    : '중량 미입력',
                icon: Icons.scale_rounded,
                dense: true,
              ),
              DetailChip(
                label: order.serviceDate != null
                    ? formatKoreanDate(order.serviceDate!)
                    : '서비스 일자 미정',
                icon: Icons.calendar_month_rounded,
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders({required this.onCreateOrder});

  final VoidCallback onCreateOrder;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 42,
            color: AppColors.teal.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            '등록된 오더가 없습니다.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            '신규 오더를 등록하면 여기에서 운송 조건과 상하차 정보를 함께 볼 수 있습니다.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onCreateOrder,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('첫 오더 등록'),
          ),
        ],
      ),
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  const _OrdersErrorState({required this.message, required this.onRetry});

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
                '오더 화면을 불러오지 못했습니다.',
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
