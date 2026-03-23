import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/screens/it_statement_screen.dart';
import 'package:tax_calc/services/tax_calculator_service.dart';
import 'package:tax_calc/utils/it_formatters.dart';
import 'package:tax_calc/main.dart';

class ItDataEntryScreen extends StatefulWidget {
  const ItDataEntryScreen({super.key});

  @override
  State<ItDataEntryScreen> createState() => _ItDataEntryScreenState();
}

class _ItDataEntryScreenState extends State<ItDataEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TaxCalculatorService _calculatorService = TaxCalculatorService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _penController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _basicPayController = TextEditingController();
  final TextEditingController _bpAfterIncrementController =
      TextEditingController();
  final TextEditingController _otherIncomeController =
      TextEditingController(text: '0');
  final TextEditingController _taxAlreadyPaidController =
      TextEditingController(text: '0');
  final TextEditingController _daPercentController =
      TextEditingController(text: '35');
  final TextEditingController _remainingMonthsController =
      TextEditingController(text: '12');

  int? _selectedIncrementMonth;
  String _selectedLocalBody = 'Panchayaths';

  static const List<String> _localBodyOptions = [
    'Panchayaths',
    'Municipalities',
    'Municipalities in Dist HQ',
    'Corporation'
  ];
  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _basicPayController.addListener(_autoCalcBp);
  }

  void _autoCalcBp() {
    final int? bp = int.tryParse(_basicPayController.text.trim());
    if (bp == null) return;
    final int calculated = _calcBpAfterIncrement(bp);
    if (calculated > 0) {
      final String newVal = calculated.toString();
      if (_bpAfterIncrementController.text != newVal) {
        _bpAfterIncrementController.text = newVal;
        _bpAfterIncrementController.selection =
            TextSelection.fromPosition(TextPosition(offset: newVal.length));
      }
    }
  }

  static int _calcBpAfterIncrement(int bp) {
    if (bp < 27900) return bp + 700;
    if (bp < 31100) return bp + 800;
    if (bp < 38300) return bp + 900;
    if (bp < 42300) return bp + 1000;
    if (bp < 47800) return bp + 1100;
    if (bp < 52600) return bp + 1200;
    if (bp < 56500) return bp + 1300;
    if (bp < 60700) return bp + 1400;
    if (bp < 65200) return bp + 1500;
    if (bp < 70000) return bp + 1600;
    if (bp < 79000) return bp + 1800;
    if (bp < 89000) return bp + 2000;
    if (bp < 97800) return bp + 2200;
    if (bp < 115300) return bp + 2500;
    if (bp < 140500) return bp + 2800;
    if (bp < 149800) return bp + 3100;
    if (bp < 166800) return bp + 3400;
    return 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _penController.dispose();
    _panController.dispose();
    _institutionController.dispose();
    _basicPayController.dispose();
    _bpAfterIncrementController.dispose();
    _otherIncomeController.dispose();
    _taxAlreadyPaidController.dispose();
    _daPercentController.dispose();
    _remainingMonthsController.dispose();
    super.dispose();
  }

  void _viewStatement() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIncrementMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select an increment month'),
        backgroundColor: kError,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    final EmployeeInput input = EmployeeInput(
      name: _nameController.text.trim(),
      pen: int.parse(_penController.text.trim()),
      pan: _panController.text.trim().toUpperCase(),
      designation: _designationController.text.trim(),
      institution: _institutionController.text.trim(),
      localBodyType: _selectedLocalBody,
      basicPayMarch2026: int.parse(_basicPayController.text.trim()),
      nextIncrementDate: _selectedIncrementMonth!,
      bpAfterIncrement: int.parse(_bpAfterIncrementController.text.trim()),
      otherIncome: int.parse(_otherIncomeController.text.trim()),
      taxAlreadyPaid: int.parse(_taxAlreadyPaidController.text.trim()),
      daPercent: int.parse(_daPercentController.text.trim()),
      remainingMonths: int.parse(_remainingMonthsController.text.trim()),
    );
    final TaxComputationResult result = _calculatorService.compute(input);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ItStatementScreen(result: result),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              _buildHeroHeader(),
              const SizedBox(height: 20),
              // ── Employee Details ──────────────────────────────────────────
              _buildSection(
                icon: Icons.person_outline_rounded,
                title: 'Employee Details',
                color: kPrimary,
                children: [
                  _field(_nameController, 'Full Name',
                      icon: Icons.badge_outlined,
                      caps: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null),
                  _gap(),
                  _field(_designationController, 'Designation',
                      icon: Icons.work_outline_rounded,
                      caps: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Designation is required'
                          : null),
                  _gap(),
                  _field(_penController, 'PEN',
                      icon: Icons.tag_rounded,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => _validateInt(v, name: 'PEN', min: 1)),
                  _gap(),
                  _field(_panController, 'PAN',
                      icon: Icons.credit_card_outlined,
                      caps: TextCapitalization.characters,
                      letterSpacing: 1.8,
                      formatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                        UpperCaseTextFormatter(),
                      ], validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'PAN required';
                    if (!RegExp(r'^[A-Z0-9]{10}$')
                        .hasMatch(v.trim().toUpperCase()))
                      return '10 alphanumeric chars';
                    return null;
                  }),
                  _gap(),
                  _field(_institutionController, 'Institution / Office Name',
                      icon: Icons.account_balance_outlined,
                      caps: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Institution required'
                          : null),
                  _gap(),
                  _styledDropdown<String>(
                    label: 'Local Body Type',
                    icon: Icons.location_city_outlined,
                    value: _selectedLocalBody,
                    items: _localBodyOptions,
                    itemLabel: (s) => s,
                    onChanged: (v) => setState(() => _selectedLocalBody = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ── Salary Details ────────────────────────────────────────────
              _buildSection(
                icon: Icons.payments_outlined,
                title: 'Salary Details',
                color: kAccent,
                children: [
                  _field(_basicPayController, 'Basic Pay — Mar 2026',
                      icon: Icons.currency_rupee_rounded,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      prefix: '₹ ',
                      validator: (v) =>
                          _validateInt(v, name: 'Basic Pay', min: 0)),
                  _gap(),
                  _field(_daPercentController, 'DA %',
                      icon: Icons.percent_rounded,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      suffix: '%',
                      validator: (v) => _validateInt(v, name: 'DA %', min: 0)),
                  _gap(),
                  _styledDropdown<int>(
                    label: 'Increment Month',
                    icon: Icons.calendar_month_outlined,
                    value: _selectedIncrementMonth,
                    items: List.generate(12, (i) => i + 1),
                    itemLabel: (i) => _monthNames[i - 1],
                    onChanged: (v) =>
                        setState(() => _selectedIncrementMonth = v),
                    validator: (_) =>
                        _selectedIncrementMonth == null ? 'Select month' : null,
                  ),
                  _gap(),
                  _field(_bpAfterIncrementController, 'BP After Increment',
                      icon: Icons.trending_up_rounded,
                      hint: 'Auto-calculated',
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      prefix: '₹ ',
                      validator: (v) =>
                          _validateInt(v, name: 'BP After Increment', min: 0)),
                  _gap(),
                  _field(_otherIncomeController,
                      'Other Income (Arrears / Surrender / Festival Allowance etc.)',
                      icon: Icons.add_circle_outline_rounded,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      prefix: '₹ ',
                      validator: (v) =>
                          _validateInt(v, name: 'Other Income', min: 0)),
                ],
              ),
              const SizedBox(height: 16),
              // ── Tax Details ───────────────────────────────────────────────
              _buildSection(
                icon: Icons.receipt_long_outlined,
                title: 'Tax Details',
                color: const Color(0xFF6A1B9A),
                children: [
                  _field(_taxAlreadyPaidController, 'Tax Already Paid',
                      icon: Icons.check_circle_outline_rounded,
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      prefix: '₹ ',
                      validator: (v) =>
                          _validateInt(v, name: 'Tax Already Paid', min: 0)),
                  _gap(),
                  _field(_remainingMonthsController, 'Remaining Months',
                      icon: Icons.hourglass_bottom_rounded,
                      hint: '1 – 12',
                      type: TextInputType.number,
                      formatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => _validateInt(v,
                          name: 'Remaining Months', min: 1, max: 12)),
                ],
              ),
              const SizedBox(height: 28),
              _buildSubmitButton(),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.account_balance_rounded,
              size: 17, color: Colors.white),
        ),
        const SizedBox(width: 10),
        const Text("HB's Income Tax Calculator"),
      ]),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF00ACC1), Color(0xFF00897B)]),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: const Text('FY 2026–27',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
        ),
      ],
    );
  }

  // ── Hero header ───────────────────────────────────────────────────────────────
  Widget _buildHeroHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3C6E), Color(0xFF2A5298)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('NEW REGIME',
                style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2)),
            const SizedBox(height: 6),
            const Text('Tax Statement\n2026 – 27',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.25)),
          ]),
        ),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Icon(Icons.calculate_outlined,
              color: Colors.white, size: 32),
        ),
      ]),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            border: Border(bottom: BorderSide(color: color.withOpacity(0.15))),
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 10),
            Text(title,
                style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w700)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ]),
    );
  }

  // ── Text field ────────────────────────────────────────────────────────────────
  Widget _field(
    TextEditingController controller,
    String label, {
    IconData? icon,
    String? hint,
    TextCapitalization caps = TextCapitalization.none,
    TextInputType type = TextInputType.text,
    List<TextInputFormatter>? formatters,
    String? prefix,
    String? suffix,
    double? letterSpacing,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: caps,
      keyboardType: type,
      inputFormatters: formatters,
      style: TextStyle(
          fontSize: 14,
          color: kTextPrimary,
          fontWeight: FontWeight.w500,
          letterSpacing: letterSpacing),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: kTextMuted, fontSize: 13),
        prefixIcon:
            icon != null ? Icon(icon, size: 18, color: kTextMuted) : null,
        prefixText: prefix,
        suffixText: suffix,
      ),
      validator: validator,
    );
  }

  // ── Styled dropdown ───────────────────────────────────────────────────────────
  Widget _styledDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: kTextMuted),
      ),
      style: const TextStyle(
          fontSize: 14, color: kTextPrimary, fontWeight: FontWeight.w500),
      dropdownColor: kSurface,
      icon:
          const Icon(Icons.keyboard_arrow_down_rounded, color: kTextSecondary),
      items: items
          .map((item) =>
              DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  SizedBox _gap() => const SizedBox(height: 14);

  // ── Submit button ─────────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF1A3C6E), Color(0xFF2A5298)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF1A3C6E).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _viewStatement,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.1),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('VIEW TAX STATEMENT',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8)),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return Center(
      child: Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.lock_outline_rounded, size: 12, color: kTextMuted),
        SizedBox(width: 5),
        Text("HB's Income Tax Calculator  •  FY 2026–27",
            style: TextStyle(color: kTextMuted, fontSize: 11)),
      ]),
    );
  }

  // ── Validators ────────────────────────────────────────────────────────────────
  String? _validateInt(String? value,
      {required String name, required int min, int? max}) {
    if (value == null || value.trim().isEmpty) return '$name is required';
    final int? n = int.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < min) return 'Min value is $min';
    if (max != null && n > max) return 'Max value is $max';
    return null;
  }
}
