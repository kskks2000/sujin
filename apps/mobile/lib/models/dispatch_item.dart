class DispatchItem {
  DispatchItem({
    required this.id,
    required this.dispatchNo,
    required this.orderId,
    required this.orderNo,
    required this.carrierCompanyName,
    required this.vehicleId,
    required this.vehicleNo,
    required this.driverId,
    required this.driverName,
    required this.assignedAt,
    required this.status,
    required this.freightAmount,
    required this.costAmount,
    required this.note,
  });

  final int id;
  final String dispatchNo;
  final int orderId;
  final String orderNo;
  final String carrierCompanyName;
  final int? vehicleId;
  final String? vehicleNo;
  final int? driverId;
  final String? driverName;
  final DateTime assignedAt;
  final String status;
  final double freightAmount;
  final double costAmount;
  final String? note;

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    return DispatchItem(
      id: json['id'] as int,
      dispatchNo: json['dispatch_no'] as String,
      orderId: json['order_id'] as int,
      orderNo: json['order_no'] as String,
      carrierCompanyName: json['carrier_company_name'] as String,
      vehicleId: json['vehicle_id'] as int?,
      vehicleNo: json['vehicle_no'] as String?,
      driverId: json['driver_id'] as int?,
      driverName: json['driver_name'] as String?,
      assignedAt: DateTime.parse(json['assigned_at'] as String),
      status: json['status'] as String,
      freightAmount: (json['freight_amount'] as num).toDouble(),
      costAmount: (json['cost_amount'] as num).toDouble(),
      note: json['note'] as String?,
    );
  }
}

