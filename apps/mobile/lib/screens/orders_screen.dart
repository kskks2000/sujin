import 'package:flutter/material.dart';
import 'package:tms_mobile/core/formatters/tms_labels.dart';
import 'package:tms_mobile/core/network/tms_api_client.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';
import 'package:tms_mobile/models/order_item.dart';
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
        final scheduledCount = orders.where((order) => order.serviceDate != null).length;
        final activeCount = orders
            .where((order) => order.status != 'COMPLETED' && order.status != 'CANCELLED')
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
                    AppSurface(
                      padding: const EdgeInsets.all(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFEF7EE),
                          Color(0xFFF4EEE4),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeading(
                            title: '오더 데스크',
                            subtitle:
                                '운행일, 상하차 정보, 청구 주체를 한 화면에서 관리합니다.',
                            trailing: DetailChip(
                              label: '${orders.length}건',
                              icon: Icons.inventory_2_rounded,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              DetailChip(
                                label: '진행 $activeCount건',
                                icon: Icons.route_rounded,
                              ),
                              DetailChip(
                                label: '운행일 지정 $scheduledCount건',
                                icon: Icons.calendar_month_rounded,
                              ),
                              DetailChip(
                                label: '청구 정보 표시',
                                icon: Icons.account_balance_wallet_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (orders.isEmpty)
                      const _EmptyOrders()
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
                    Text(order.orderNo, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      order.billToCompanyName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink,
                      ),
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
                  label: '상차',
                  value: order.pickupName ?? '미지정',
                ),
                const SizedBox(height: 10),
                _RouteRow(
                  icon: Icons.flag_rounded,
                  color: AppColors.clay,
                  label: '하차',
                  value: order.deliveryName ?? '미지정',
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
              ),
              DetailChip(
                label: order.consigneeName ?? '수화인 미지정',
                icon: Icons.move_to_inbox_rounded,
              ),
              DetailChip(
                label: order.cargoName ?? '화물 미입력',
                icon: Icons.inventory_rounded,
              ),
              DetailChip(
                label: order.cargoWeightKg != null
                    ? '${order.cargoWeightKg!.toStringAsFixed(0)} kg'
                    : '중량 미입력',
                icon: Icons.scale_rounded,
              ),
              DetailChip(
                label: order.serviceDate != null
                    ? formatKoreanDate(order.serviceDate!)
                    : '운행일 미지정',
                icon: Icons.calendar_month_rounded,
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

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
          Text('등록된 오더가 없습니다', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '데모 데이터를 넣거나 새 오더를 등록하면 이 보드가 채워집니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _OrdersErrorState extends StatelessWidget {
  const _OrdersErrorState({
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
              Text('오더 화면을 불러올 수 없습니다', style: Theme.of(context).textTheme.headlineMedium),
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
