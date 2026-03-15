import 'package:flutter/material.dart';
import 'package:tms_mobile/core/formatters/tms_labels.dart';
import 'package:tms_mobile/core/network/tms_api_client.dart';
import 'package:tms_mobile/core/theme/app_theme.dart';
import 'package:tms_mobile/models/company_option.dart';
import 'package:tms_mobile/models/order_create_request.dart';
import 'package:tms_mobile/widgets/tms_ui.dart';

class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen({super.key, required this.client});

  final TmsApiClient client;

  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final _externalOrderNoController = TextEditingController();
  final _customerOrderNoController = TextEditingController();
  final _cargoNameController = TextEditingController();
  final _cargoQtyController = TextEditingController();
  final _cargoUnitController = TextEditingController(text: 'BOX');
  final _cargoWeightController = TextEditingController();
  final _cargoVolumeController = TextEditingController();
  final _palletCountController = TextEditingController();
  final _temperatureMinController = TextEditingController();
  final _temperatureMaxController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _remarkController = TextEditingController();

  final _pickupNameController = TextEditingController();
  final _pickupAddress1Controller = TextEditingController();
  final _pickupAddress2Controller = TextEditingController();
  final _pickupContactNameController = TextEditingController();
  final _pickupContactPhoneController = TextEditingController();
  final _pickupInstructionsController = TextEditingController();

  final _deliveryNameController = TextEditingController();
  final _deliveryAddress1Controller = TextEditingController();
  final _deliveryAddress2Controller = TextEditingController();
  final _deliveryContactNameController = TextEditingController();
  final _deliveryContactPhoneController = TextEditingController();
  final _deliveryInstructionsController = TextEditingController();

  late Future<List<CompanyOption>> _companiesFuture;

  int? _billToCompanyId;
  int? _shipperCompanyId;
  int? _consigneeCompanyId;
  DateTime? _serviceDate;
  String _serviceType = 'FTL';
  String? _vehicleTypeRequired;
  int _priority = 3;
  bool _requiresPod = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _companiesFuture = widget.client.fetchCompanies();
  }

  @override
  void dispose() {
    for (final controller in [
      _externalOrderNoController,
      _customerOrderNoController,
      _cargoNameController,
      _cargoQtyController,
      _cargoUnitController,
      _cargoWeightController,
      _cargoVolumeController,
      _palletCountController,
      _temperatureMinController,
      _temperatureMaxController,
      _specialInstructionsController,
      _remarkController,
      _pickupNameController,
      _pickupAddress1Controller,
      _pickupAddress2Controller,
      _pickupContactNameController,
      _pickupContactPhoneController,
      _pickupInstructionsController,
      _deliveryNameController,
      _deliveryAddress1Controller,
      _deliveryAddress2Controller,
      _deliveryContactNameController,
      _deliveryContactPhoneController,
      _deliveryInstructionsController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickServiceDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _serviceDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _serviceDate = picked;
      });
    }
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label을 입력해 주세요.';
    }
    return null;
  }

  String? _validateNumber(
    String? value, {
    bool allowDecimal = true,
    bool allowZero = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parsed = allowDecimal
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim());
    if (parsed == null) {
      return '숫자 형식으로 입력해 주세요.';
    }

    if (!allowZero) {
      if (parsed is double && parsed <= 0) {
        return '0보다 큰 값을 입력해 주세요.';
      }
      if (parsed is int && parsed <= 0) {
        return '0보다 큰 값을 입력해 주세요.';
      }
    }

    return null;
  }

  String? _textOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  double? _doubleOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return null;
    }
    return double.tryParse(text);
  }

  int? _intOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return null;
    }
    return int.tryParse(text);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_billToCompanyId == null) {
      setState(() {
        _errorMessage = '청구처를 선택해 주세요.';
      });
      return;
    }

    final temperatureMin = _doubleOrNull(_temperatureMinController);
    final temperatureMax = _doubleOrNull(_temperatureMaxController);
    if (temperatureMin != null &&
        temperatureMax != null &&
        temperatureMin > temperatureMax) {
      setState(() {
        _errorMessage = '온도 범위가 올바르지 않습니다. 최소 온도는 최대 온도보다 작거나 같아야 합니다.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final request = OrderCreateRequest(
        externalOrderNo: _textOrNull(_externalOrderNoController),
        customerOrderNo: _textOrNull(_customerOrderNoController),
        billToCompanyId: _billToCompanyId!,
        shipperCompanyId: _shipperCompanyId,
        consigneeCompanyId: _consigneeCompanyId,
        serviceType: _serviceType,
        priority: _priority,
        serviceDate: _serviceDate,
        cargoName: _textOrNull(_cargoNameController),
        cargoQty: _doubleOrNull(_cargoQtyController),
        cargoUnit: _textOrNull(_cargoUnitController),
        cargoWeightKg: _doubleOrNull(_cargoWeightController),
        cargoVolumeCbm: _doubleOrNull(_cargoVolumeController),
        palletCount: _intOrNull(_palletCountController),
        requiresPod: _requiresPod,
        vehicleTypeRequired: _vehicleTypeRequired,
        temperatureMin: temperatureMin,
        temperatureMax: temperatureMax,
        specialInstructions: _textOrNull(_specialInstructionsController),
        remark: _textOrNull(_remarkController),
        stops: [
          OrderStopDraft(
            sequenceNo: 1,
            stopType: 'PICKUP',
            name: _pickupNameController.text.trim(),
            addressLine1: _pickupAddress1Controller.text.trim(),
            addressLine2: _textOrNull(_pickupAddress2Controller),
            contactName: _textOrNull(_pickupContactNameController),
            contactPhone: _textOrNull(_pickupContactPhoneController),
            instructions: _textOrNull(_pickupInstructionsController),
          ),
          OrderStopDraft(
            sequenceNo: 2,
            stopType: 'DROPOFF',
            name: _deliveryNameController.text.trim(),
            addressLine1: _deliveryAddress1Controller.text.trim(),
            addressLine2: _textOrNull(_deliveryAddress2Controller),
            contactName: _textOrNull(_deliveryContactNameController),
            contactPhone: _textOrNull(_deliveryContactPhoneController),
            instructions: _textOrNull(_deliveryInstructionsController),
          ),
        ],
      );

      await widget.client.createOrder(request);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      setState(() {
        _errorMessage = localizeErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  List<DropdownMenuItem<int?>> _companyItems(
    List<CompanyOption> companies, {
    required String placeholder,
  }) {
    return [
      DropdownMenuItem<int?>(value: null, child: Text(placeholder)),
      ...companies.map(
        (company) => DropdownMenuItem<int?>(
          value: company.id,
          child: Text(company.name),
        ),
      ),
    ];
  }

  Widget _buildForm(
    BuildContext context,
    List<CompanyOption> companies,
    List<CompanyOption> shipperCompanies,
    List<CompanyOption> consigneeCompanies,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 980;

        return Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              AppSurface(
                padding: const EdgeInsets.all(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFEF7EE), Color(0xFFF4EEE4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SectionHeading(
                      title: '신규 오더 등록',
                      subtitle: '청구처, 운송 조건, 상하차 정보를 한 번에 입력합니다.',
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        DetailChip(
                          label: '청구처 필수',
                          icon: Icons.apartment_rounded,
                        ),
                        DetailChip(
                          label: '상차/하차 필수',
                          icon: Icons.route_rounded,
                        ),
                        DetailChip(
                          label: '저장 후 목록 반영',
                          icon: Icons.task_alt_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _FormSection(
                            title: '기본 정보',
                            subtitle: '청구처, 서비스 유형, 우선순위와 접수 번호를 등록합니다.',
                            child: _BasicInfoFields(
                              billToCompanyId: _billToCompanyId,
                              shipperCompanyId: _shipperCompanyId,
                              consigneeCompanyId: _consigneeCompanyId,
                              serviceType: _serviceType,
                              priority: _priority,
                              serviceDate: _serviceDate,
                              externalOrderNoController:
                                  _externalOrderNoController,
                              customerOrderNoController:
                                  _customerOrderNoController,
                              companies: companies,
                              shipperCompanies: shipperCompanies,
                              consigneeCompanies: consigneeCompanies,
                              onBillToChanged: (value) =>
                                  setState(() => _billToCompanyId = value),
                              onShipperChanged: (value) =>
                                  setState(() => _shipperCompanyId = value),
                              onConsigneeChanged: (value) =>
                                  setState(() => _consigneeCompanyId = value),
                              onServiceTypeChanged: (value) =>
                                  setState(() => _serviceType = value),
                              onPriorityChanged: (value) =>
                                  setState(() => _priority = value),
                              onPickServiceDate: _pickServiceDate,
                              companyItems: _companyItems,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _FormSection(
                            title: '화물 및 운송 조건',
                            subtitle: '화물 스펙, 요구 차종, 온도 조건, 운영 메모를 입력합니다.',
                            child: _CargoInfoFields(
                              cargoNameController: _cargoNameController,
                              cargoQtyController: _cargoQtyController,
                              cargoUnitController: _cargoUnitController,
                              cargoWeightController: _cargoWeightController,
                              cargoVolumeController: _cargoVolumeController,
                              palletCountController: _palletCountController,
                              temperatureMinController:
                                  _temperatureMinController,
                              temperatureMaxController:
                                  _temperatureMaxController,
                              specialInstructionsController:
                                  _specialInstructionsController,
                              remarkController: _remarkController,
                              vehicleTypeRequired: _vehicleTypeRequired,
                              requiresPod: _requiresPod,
                              onVehicleTypeChanged: (value) =>
                                  setState(() => _vehicleTypeRequired = value),
                              onRequiresPodChanged: (value) =>
                                  setState(() => _requiresPod = value),
                              numberValidator: _validateNumber,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _StopSection(
                            title: '상차지',
                            accent: AppColors.teal,
                            nameController: _pickupNameController,
                            address1Controller: _pickupAddress1Controller,
                            address2Controller: _pickupAddress2Controller,
                            contactNameController: _pickupContactNameController,
                            contactPhoneController:
                                _pickupContactPhoneController,
                            instructionsController:
                                _pickupInstructionsController,
                            validateRequired: _validateRequired,
                          ),
                          const SizedBox(height: 16),
                          _StopSection(
                            title: '하차지',
                            accent: AppColors.clay,
                            nameController: _deliveryNameController,
                            address1Controller: _deliveryAddress1Controller,
                            address2Controller: _deliveryAddress2Controller,
                            contactNameController:
                                _deliveryContactNameController,
                            contactPhoneController:
                                _deliveryContactPhoneController,
                            instructionsController:
                                _deliveryInstructionsController,
                            validateRequired: _validateRequired,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _FormSection(
                  title: '기본 정보',
                  subtitle: '청구처, 서비스 유형, 우선순위와 접수 번호를 등록합니다.',
                  child: _BasicInfoFields(
                    billToCompanyId: _billToCompanyId,
                    shipperCompanyId: _shipperCompanyId,
                    consigneeCompanyId: _consigneeCompanyId,
                    serviceType: _serviceType,
                    priority: _priority,
                    serviceDate: _serviceDate,
                    externalOrderNoController: _externalOrderNoController,
                    customerOrderNoController: _customerOrderNoController,
                    companies: companies,
                    shipperCompanies: shipperCompanies,
                    consigneeCompanies: consigneeCompanies,
                    onBillToChanged: (value) =>
                        setState(() => _billToCompanyId = value),
                    onShipperChanged: (value) =>
                        setState(() => _shipperCompanyId = value),
                    onConsigneeChanged: (value) =>
                        setState(() => _consigneeCompanyId = value),
                    onServiceTypeChanged: (value) =>
                        setState(() => _serviceType = value),
                    onPriorityChanged: (value) =>
                        setState(() => _priority = value),
                    onPickServiceDate: _pickServiceDate,
                    companyItems: _companyItems,
                  ),
                ),
                const SizedBox(height: 16),
                _FormSection(
                  title: '화물 및 운송 조건',
                  subtitle: '화물 스펙, 요구 차종, 온도 조건, 운영 메모를 입력합니다.',
                  child: _CargoInfoFields(
                    cargoNameController: _cargoNameController,
                    cargoQtyController: _cargoQtyController,
                    cargoUnitController: _cargoUnitController,
                    cargoWeightController: _cargoWeightController,
                    cargoVolumeController: _cargoVolumeController,
                    palletCountController: _palletCountController,
                    temperatureMinController: _temperatureMinController,
                    temperatureMaxController: _temperatureMaxController,
                    specialInstructionsController:
                        _specialInstructionsController,
                    remarkController: _remarkController,
                    vehicleTypeRequired: _vehicleTypeRequired,
                    requiresPod: _requiresPod,
                    onVehicleTypeChanged: (value) =>
                        setState(() => _vehicleTypeRequired = value),
                    onRequiresPodChanged: (value) =>
                        setState(() => _requiresPod = value),
                    numberValidator: _validateNumber,
                  ),
                ),
                const SizedBox(height: 16),
                _StopSection(
                  title: '상차지',
                  accent: AppColors.teal,
                  nameController: _pickupNameController,
                  address1Controller: _pickupAddress1Controller,
                  address2Controller: _pickupAddress2Controller,
                  contactNameController: _pickupContactNameController,
                  contactPhoneController: _pickupContactPhoneController,
                  instructionsController: _pickupInstructionsController,
                  validateRequired: _validateRequired,
                ),
                const SizedBox(height: 16),
                _StopSection(
                  title: '하차지',
                  accent: AppColors.clay,
                  nameController: _deliveryNameController,
                  address1Controller: _deliveryAddress1Controller,
                  address2Controller: _deliveryAddress2Controller,
                  contactNameController: _deliveryContactNameController,
                  contactPhoneController: _deliveryContactPhoneController,
                  instructionsController: _deliveryInstructionsController,
                  validateRequired: _validateRequired,
                ),
              ],
              const SizedBox(height: 16),
              _ActionSection(
                errorMessage: _errorMessage,
                isSubmitting: _isSubmitting,
                onCancel: () => Navigator.of(context).pop(),
                onSubmit: _submit,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('오더 상세 등록')),
        body: FutureBuilder<List<CompanyOption>>(
          future: _companiesFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: AppSurface(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '거래처 정보를 불러오지 못했습니다.',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizeErrorMessage(snapshot.error!),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _companiesFuture = widget.client.fetchCompanies();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final companies = snapshot.data!;
            final shipperCompanies = companies
                .where((company) => company.isShipper)
                .toList();
            final consigneeCompanies = companies
                .where((company) => company.isConsignee)
                .toList();

            return _buildForm(
              context,
              companies,
              shipperCompanies,
              consigneeCompanies,
            );
          },
        ),
      ),
    );
  }
}

class _BasicInfoFields extends StatelessWidget {
  const _BasicInfoFields({
    required this.billToCompanyId,
    required this.shipperCompanyId,
    required this.consigneeCompanyId,
    required this.serviceType,
    required this.priority,
    required this.serviceDate,
    required this.externalOrderNoController,
    required this.customerOrderNoController,
    required this.companies,
    required this.shipperCompanies,
    required this.consigneeCompanies,
    required this.onBillToChanged,
    required this.onShipperChanged,
    required this.onConsigneeChanged,
    required this.onServiceTypeChanged,
    required this.onPriorityChanged,
    required this.onPickServiceDate,
    required this.companyItems,
  });

  final int? billToCompanyId;
  final int? shipperCompanyId;
  final int? consigneeCompanyId;
  final String serviceType;
  final int priority;
  final DateTime? serviceDate;
  final TextEditingController externalOrderNoController;
  final TextEditingController customerOrderNoController;
  final List<CompanyOption> companies;
  final List<CompanyOption> shipperCompanies;
  final List<CompanyOption> consigneeCompanies;
  final ValueChanged<int?> onBillToChanged;
  final ValueChanged<int?> onShipperChanged;
  final ValueChanged<int?> onConsigneeChanged;
  final ValueChanged<String> onServiceTypeChanged;
  final ValueChanged<int> onPriorityChanged;
  final Future<void> Function() onPickServiceDate;
  final List<DropdownMenuItem<int?>> Function(
    List<CompanyOption> companies, {
    required String placeholder,
  })
  companyItems;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<int?>(
          initialValue: billToCompanyId,
          items: companyItems(companies, placeholder: '청구처를 선택하세요'),
          decoration: const InputDecoration(
            labelText: '청구처',
            prefixIcon: Icon(Icons.apartment_rounded),
          ),
          validator: (value) => value == null ? '청구처를 선택해 주세요.' : null,
          onChanged: onBillToChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          initialValue: shipperCompanyId,
          items: companyItems(
            shipperCompanies.isEmpty ? companies : shipperCompanies,
            placeholder: '화주 / 발송처를 선택하세요',
          ),
          decoration: const InputDecoration(
            labelText: '화주 / 발송처',
            prefixIcon: Icon(Icons.outbox_rounded),
          ),
          onChanged: onShipperChanged,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<int?>(
          initialValue: consigneeCompanyId,
          items: companyItems(
            consigneeCompanies.isEmpty ? companies : consigneeCompanies,
            placeholder: '수령처를 선택하세요',
          ),
          decoration: const InputDecoration(
            labelText: '수령처',
            prefixIcon: Icon(Icons.move_to_inbox_rounded),
          ),
          onChanged: onConsigneeChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: serviceType,
                decoration: const InputDecoration(
                  labelText: '서비스 유형',
                  prefixIcon: Icon(Icons.local_shipping_rounded),
                ),
                items: const [
                  DropdownMenuItem(value: 'FTL', child: Text('FTL')),
                  DropdownMenuItem(value: 'LTL', child: Text('LTL')),
                  DropdownMenuItem(value: 'EXPRESS', child: Text('EXPRESS')),
                  DropdownMenuItem(value: 'TRANSFER', child: Text('TRANSFER')),
                  DropdownMenuItem(value: 'RETURN', child: Text('RETURN')),
                  DropdownMenuItem(
                    value: 'DISTRIBUTION',
                    child: Text('DISTRIBUTION'),
                  ),
                ],
                onChanged: (value) => onServiceTypeChanged(value ?? 'FTL'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                initialValue: priority,
                decoration: const InputDecoration(
                  labelText: '우선순위',
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                items: List.generate(
                  5,
                  (index) => DropdownMenuItem(
                    value: index + 1,
                    child: Text('${index + 1}'),
                  ),
                ),
                onChanged: (value) => onPriorityChanged(value ?? 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: externalOrderNoController,
                decoration: const InputDecoration(
                  labelText: '외부 오더 번호',
                  prefixIcon: Icon(Icons.confirmation_number_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: customerOrderNoController,
                decoration: const InputDecoration(
                  labelText: '고객 오더 번호',
                  prefixIcon: Icon(Icons.receipt_long_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPickServiceDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: '서비스 일자',
              prefixIcon: Icon(Icons.calendar_month_rounded),
            ),
            child: Text(
              serviceDate == null
                  ? '날짜를 선택하세요'
                  : formatKoreanDate(serviceDate!),
            ),
          ),
        ),
      ],
    );
  }
}

class _CargoInfoFields extends StatelessWidget {
  const _CargoInfoFields({
    required this.cargoNameController,
    required this.cargoQtyController,
    required this.cargoUnitController,
    required this.cargoWeightController,
    required this.cargoVolumeController,
    required this.palletCountController,
    required this.temperatureMinController,
    required this.temperatureMaxController,
    required this.specialInstructionsController,
    required this.remarkController,
    required this.vehicleTypeRequired,
    required this.requiresPod,
    required this.onVehicleTypeChanged,
    required this.onRequiresPodChanged,
    required this.numberValidator,
  });

  final TextEditingController cargoNameController;
  final TextEditingController cargoQtyController;
  final TextEditingController cargoUnitController;
  final TextEditingController cargoWeightController;
  final TextEditingController cargoVolumeController;
  final TextEditingController palletCountController;
  final TextEditingController temperatureMinController;
  final TextEditingController temperatureMaxController;
  final TextEditingController specialInstructionsController;
  final TextEditingController remarkController;
  final String? vehicleTypeRequired;
  final bool requiresPod;
  final ValueChanged<String?> onVehicleTypeChanged;
  final ValueChanged<bool> onRequiresPodChanged;
  final String? Function(String? value, {bool allowDecimal, bool allowZero})
  numberValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: cargoNameController,
          decoration: const InputDecoration(
            labelText: '화물명',
            prefixIcon: Icon(Icons.inventory_2_rounded),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: cargoQtyController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => numberValidator(
                  value,
                  allowDecimal: true,
                  allowZero: false,
                ),
                decoration: const InputDecoration(
                  labelText: '수량',
                  prefixIcon: Icon(Icons.numbers_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cargoUnitController,
                decoration: const InputDecoration(
                  labelText: '단위',
                  prefixIcon: Icon(Icons.straighten_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: cargoWeightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    numberValidator(value, allowDecimal: true, allowZero: true),
                decoration: const InputDecoration(
                  labelText: '중량(kg)',
                  prefixIcon: Icon(Icons.scale_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: cargoVolumeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    numberValidator(value, allowDecimal: true, allowZero: true),
                decoration: const InputDecoration(
                  labelText: '부피(cbm)',
                  prefixIcon: Icon(Icons.inbox_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: palletCountController,
                keyboardType: TextInputType.number,
                validator: (value) => numberValidator(
                  value,
                  allowDecimal: false,
                  allowZero: true,
                ),
                decoration: const InputDecoration(
                  labelText: '팔레트 수량',
                  prefixIcon: Icon(Icons.grid_view_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String?>(
                initialValue: vehicleTypeRequired,
                decoration: const InputDecoration(
                  labelText: '요구 차종',
                  prefixIcon: Icon(Icons.local_shipping_rounded),
                ),
                items: const [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text('차종 선택 안 함'),
                  ),
                  DropdownMenuItem(value: 'CARGO_VAN', child: Text('카고 밴')),
                  DropdownMenuItem(value: 'BOX_TRUCK', child: Text('박스 트럭')),
                  DropdownMenuItem(value: 'WING_BODY', child: Text('윙바디')),
                  DropdownMenuItem(value: 'TRACTOR', child: Text('트랙터')),
                  DropdownMenuItem(value: 'TRAILER', child: Text('트레일러')),
                  DropdownMenuItem(value: 'REEFER', child: Text('냉장/냉동')),
                  DropdownMenuItem(value: 'FLATBED', child: Text('플랫베드')),
                  DropdownMenuItem(value: 'TANKER', child: Text('탱커')),
                  DropdownMenuItem(value: 'ETC', child: Text('기타')),
                ],
                onChanged: onVehicleTypeChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: temperatureMinController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    numberValidator(value, allowDecimal: true, allowZero: true),
                decoration: const InputDecoration(
                  labelText: '최소 온도(℃)',
                  prefixIcon: Icon(Icons.thermostat_rounded),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: temperatureMaxController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    numberValidator(value, allowDecimal: true, allowZero: true),
                decoration: const InputDecoration(
                  labelText: '최대 온도(℃)',
                  prefixIcon: Icon(Icons.thermostat_auto_rounded),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: requiresPod,
          title: const Text('POD 제출 필요'),
          subtitle: const Text('인수증 업로드가 필요한 오더일 때 활성화합니다.'),
          onChanged: onRequiresPodChanged,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: specialInstructionsController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '특이사항',
            prefixIcon: Icon(Icons.sticky_note_2_rounded),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: remarkController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: '운영 메모',
            prefixIcon: Icon(Icons.edit_note_rounded),
          ),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeading(title: title, subtitle: subtitle),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _StopSection extends StatelessWidget {
  const _StopSection({
    required this.title,
    required this.accent,
    required this.nameController,
    required this.address1Controller,
    required this.address2Controller,
    required this.contactNameController,
    required this.contactPhoneController,
    required this.instructionsController,
    required this.validateRequired,
  });

  final String title;
  final Color accent;
  final TextEditingController nameController;
  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;
  final TextEditingController instructionsController;
  final String? Function(String? value, String label) validateRequired;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(label: title, color: accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$title 상세 정보',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: '$title 명칭',
              prefixIcon: const Icon(Icons.location_city_rounded),
            ),
            validator: (value) => validateRequired(value, '$title 명칭'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: address1Controller,
            decoration: InputDecoration(
              labelText: '$title 주소',
              prefixIcon: const Icon(Icons.place_rounded),
            ),
            validator: (value) => validateRequired(value, '$title 주소'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: address2Controller,
            decoration: InputDecoration(
              labelText: '$title 상세 주소',
              prefixIcon: const Icon(Icons.apartment_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: contactNameController,
                  decoration: const InputDecoration(
                    labelText: '담당자명',
                    prefixIcon: Icon(Icons.person_pin_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: contactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '담당자 연락처',
                    prefixIcon: Icon(Icons.phone_rounded),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: instructionsController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: '$title 작업 지시사항',
              prefixIcon: const Icon(Icons.assignment_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.errorMessage,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final String? errorMessage;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(22),
      radius: 26,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFEEF9F4), Color(0xFFF8FBF2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('등록 실행', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            '저장하면 즉시 오더 데스크 목록에 반영됩니다.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.clay.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.clay),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting ? null : onCancel,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isSubmitting ? null : onSubmit,
                  icon: Icon(
                    isSubmitting
                        ? Icons.sync_rounded
                        : Icons.check_circle_rounded,
                  ),
                  label: Text(isSubmitting ? '등록 중...' : '오더 등록'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
