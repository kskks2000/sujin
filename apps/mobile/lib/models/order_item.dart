class OrderItem {
  OrderItem({
    required this.id,
    required this.orderNo,
    required this.billToCompanyName,
    required this.shipperName,
    required this.consigneeName,
    required this.pickupName,
    required this.deliveryName,
    required this.status,
    required this.serviceDate,
    required this.cargoName,
    required this.cargoWeightKg,
  });

  final int id;
  final String orderNo;
  final String billToCompanyName;
  final String? shipperName;
  final String? consigneeName;
  final String? pickupName;
  final String? deliveryName;
  final String status;
  final DateTime? serviceDate;
  final String? cargoName;
  final double? cargoWeightKg;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderNo: json['order_no'] as String,
      billToCompanyName: json['bill_to_company_name'] as String,
      shipperName: json['shipper_name'] as String?,
      consigneeName: json['consignee_name'] as String?,
      pickupName: json['pickup_name'] as String?,
      deliveryName: json['delivery_name'] as String?,
      status: json['status'] as String,
      serviceDate: json['service_date'] != null
          ? DateTime.parse(json['service_date'] as String)
          : null,
      cargoName: json['cargo_name'] as String?,
      cargoWeightKg: (json['cargo_weight_kg'] as num?)?.toDouble(),
    );
  }
}

