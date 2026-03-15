class CompanyOption {
  const CompanyOption({
    required this.id,
    required this.name,
    required this.isShipper,
    required this.isConsignee,
    required this.isCarrier,
  });

  final int id;
  final String name;
  final bool isShipper;
  final bool isConsignee;
  final bool isCarrier;

  factory CompanyOption.fromJson(Map<String, dynamic> json) {
    return CompanyOption(
      id: json['id'] as int,
      name: json['name'] as String,
      isShipper: json['is_shipper'] as bool? ?? false,
      isConsignee: json['is_consignee'] as bool? ?? false,
      isCarrier: json['is_carrier'] as bool? ?? false,
    );
  }
}
