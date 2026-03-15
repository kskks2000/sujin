class OrderStopDraft {
  const OrderStopDraft({
    required this.sequenceNo,
    required this.stopType,
    required this.name,
    required this.addressLine1,
    this.contactName,
    this.contactPhone,
    this.addressLine2,
    this.instructions,
  });

  final int sequenceNo;
  final String stopType;
  final String name;
  final String addressLine1;
  final String? contactName;
  final String? contactPhone;
  final String? addressLine2;
  final String? instructions;

  Map<String, dynamic> toJson() {
    return {
      'sequence_no': sequenceNo,
      'stop_type': stopType,
      'name': name,
      'address_line1': addressLine1,
      if (contactName != null && contactName!.isNotEmpty)
        'contact_name': contactName,
      if (contactPhone != null && contactPhone!.isNotEmpty)
        'contact_phone': contactPhone,
      if (addressLine2 != null && addressLine2!.isNotEmpty)
        'address_line2': addressLine2,
      if (instructions != null && instructions!.isNotEmpty)
        'instructions': instructions,
    };
  }
}

class OrderCreateRequest {
  const OrderCreateRequest({
    required this.billToCompanyId,
    required this.stops,
    this.externalOrderNo,
    this.customerOrderNo,
    this.shipperCompanyId,
    this.consigneeCompanyId,
    this.serviceType = 'FTL',
    this.priority = 3,
    this.serviceDate,
    this.cargoName,
    this.cargoQty,
    this.cargoUnit,
    this.cargoWeightKg,
    this.cargoVolumeCbm,
    this.palletCount,
    this.requiresPod = false,
    this.vehicleTypeRequired,
    this.temperatureMin,
    this.temperatureMax,
    this.specialInstructions,
    this.remark,
  });

  final int billToCompanyId;
  final List<OrderStopDraft> stops;
  final String? externalOrderNo;
  final String? customerOrderNo;
  final int? shipperCompanyId;
  final int? consigneeCompanyId;
  final String serviceType;
  final int priority;
  final DateTime? serviceDate;
  final String? cargoName;
  final double? cargoQty;
  final String? cargoUnit;
  final double? cargoWeightKg;
  final double? cargoVolumeCbm;
  final int? palletCount;
  final bool requiresPod;
  final String? vehicleTypeRequired;
  final double? temperatureMin;
  final double? temperatureMax;
  final String? specialInstructions;
  final String? remark;

  Map<String, dynamic> toJson() {
    return {
      'bill_to_company_id': billToCompanyId,
      'service_type': serviceType,
      'priority': priority,
      'requires_pod': requiresPod,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      if (externalOrderNo != null && externalOrderNo!.isNotEmpty)
        'external_order_no': externalOrderNo,
      if (customerOrderNo != null && customerOrderNo!.isNotEmpty)
        'customer_order_no': customerOrderNo,
      if (shipperCompanyId != null) 'shipper_company_id': shipperCompanyId,
      if (consigneeCompanyId != null)
        'consignee_company_id': consigneeCompanyId,
      if (serviceDate != null) 'service_date': _formatDate(serviceDate!),
      if (cargoName != null && cargoName!.isNotEmpty) 'cargo_name': cargoName,
      if (cargoQty != null) 'cargo_qty': cargoQty,
      if (cargoUnit != null && cargoUnit!.isNotEmpty) 'cargo_unit': cargoUnit,
      if (cargoWeightKg != null) 'cargo_weight_kg': cargoWeightKg,
      if (cargoVolumeCbm != null) 'cargo_volume_cbm': cargoVolumeCbm,
      if (palletCount != null) 'pallet_count': palletCount,
      if (vehicleTypeRequired != null && vehicleTypeRequired!.isNotEmpty)
        'vehicle_type_required': vehicleTypeRequired,
      if (temperatureMin != null) 'temperature_min': temperatureMin,
      if (temperatureMax != null) 'temperature_max': temperatureMax,
      if (specialInstructions != null && specialInstructions!.isNotEmpty)
        'special_instructions': specialInstructions,
      if (remark != null && remark!.isNotEmpty) 'remark': remark,
    };
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
