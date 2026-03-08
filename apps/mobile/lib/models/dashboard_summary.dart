class DashboardSummary {
  DashboardSummary({
    required this.totalOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.activeDispatchesCount,
    required this.availableVehicles,
    required this.availableDrivers,
    required this.recentOrders,
    required this.activeDispatches,
  });

  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final int activeDispatchesCount;
  final int availableVehicles;
  final int availableDrivers;
  final List<DashboardOrderPreview> recentOrders;
  final List<DashboardDispatchPreview> activeDispatches;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalOrders: json['total_orders'] as int? ?? 0,
      activeOrders: json['active_orders'] as int? ?? 0,
      completedOrders: json['completed_orders'] as int? ?? 0,
      activeDispatchesCount: json['active_dispatches_count'] as int? ?? 0,
      availableVehicles: json['available_vehicles'] as int? ?? 0,
      availableDrivers: json['available_drivers'] as int? ?? 0,
      recentOrders: (json['recent_orders'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(DashboardOrderPreview.fromJson)
          .toList(),
      activeDispatches: (json['active_dispatches'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>()
          .map(DashboardDispatchPreview.fromJson)
          .toList(),
    );
  }
}

class DashboardOrderPreview {
  DashboardOrderPreview({
    required this.id,
    required this.orderNo,
    required this.billToCompanyName,
    required this.pickupName,
    required this.deliveryName,
    required this.status,
  });

  final int id;
  final String orderNo;
  final String billToCompanyName;
  final String? pickupName;
  final String? deliveryName;
  final String status;

  factory DashboardOrderPreview.fromJson(Map<String, dynamic> json) {
    return DashboardOrderPreview(
      id: json['id'] as int,
      orderNo: json['order_no'] as String,
      billToCompanyName: json['bill_to_company_name'] as String,
      pickupName: json['pickup_name'] as String?,
      deliveryName: json['delivery_name'] as String?,
      status: json['status'] as String,
    );
  }
}

class DashboardDispatchPreview {
  DashboardDispatchPreview({
    required this.id,
    required this.dispatchNo,
    required this.orderNo,
    required this.carrierCompanyName,
    required this.vehicleNo,
    required this.driverName,
    required this.status,
  });

  final int id;
  final String dispatchNo;
  final String orderNo;
  final String carrierCompanyName;
  final String? vehicleNo;
  final String? driverName;
  final String status;

  factory DashboardDispatchPreview.fromJson(Map<String, dynamic> json) {
    return DashboardDispatchPreview(
      id: json['id'] as int,
      dispatchNo: json['dispatch_no'] as String,
      orderNo: json['order_no'] as String,
      carrierCompanyName: json['carrier_company_name'] as String,
      vehicleNo: json['vehicle_no'] as String?,
      driverName: json['driver_name'] as String?,
      status: json['status'] as String,
    );
  }
}

