import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/screens/it_statement_screen.dart';
import 'package:tax_calc/services/pdf_statement_service.dart';
import 'package:tax_calc/services/tax_calculator_service.dart';
import 'package:tax_calc/utils/it_formatters.dart';

// Import brand tokens from main
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
  final TextEditingController _penController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _basicPayController = TextEditingController();
  final TextEditingController _incrementMonthController =
      TextEditingController();
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

  @override
  void dispose() {
    _nameController.dispose();
    _penController.dispose();
    _panController.dispose();
    _basicPayController.dispose();
    _incrementMonthController.dispose();
    _bpAfterIncrementController.dispose();
    _otherIncomeController.dispose();
    _taxAlreadyPaidController.dispose();
    _daPercentController.dispose();
    _remainingMonthsController.dispose();
    super.dispose();
  }

  void _viewStatement() {
    if (!_formKey.currentState!.validate()) return;

    final EmployeeInput input = EmployeeInput(
      name: _nameController.text.trim(),
      pen: int.parse(_penController.text.trim()),
      pan: _panController.text.trim().toUpperCase(),
      basicPayMarch2026: int.parse(_basicPayController.text.trim()),
      incrementMonth: int.parse(_incrementMonthController.text.trim()),
      bpAfterIncrement: int.parse(_bpAfterIncrementController.text.trim()),
      otherIncome: int.parse(_otherIncomeController.text.trim()),
      taxAlreadyPaid: int.parse(_taxAlreadyPaidController.text.trim()),
      daPercent: int.parse(_daPercentController.text.trim()),
      remainingMonths: int.parse(_remainingMonthsController.text.trim()),
    );

    final TaxComputationResult result = _calculatorService.compute(input);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItStatementScreen(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      // ── AppBar ────────────────────────────────────────────────────────────
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Column(
          children: [
            AppBar(
              title: const Text("HB's INCOME TAX CALCULATOR"),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: kGold.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    'FY 2026–27',
                    style: TextStyle(
                      color: kGoldLight,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              // ── Section: Employee Details ──────────────────────────────
              _SectionCard(
                title: 'Employee Details',
                child: Column(
                  children: [
                    _buildField(
                      controller: _nameController,
                      label: 'Full Name of Employee',
                      capitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _penController,
                            label: 'PEN',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) =>
                                _validateInt(v, name: 'PEN', min: 1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _panController,
                            label: 'PAN',
                            capitalization: TextCapitalization.characters,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9]')),
                              UpperCaseTextFormatter(),
                            ],
                            letterSpacing: 2.0,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'PAN is required';
                              if (!RegExp(r'^[A-Z0-9]{10}$')
                                  .hasMatch(v.trim().toUpperCase()))
                                return 'Must be 10 alphanumeric';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Section: Salary Details ────────────────────────────────
              _SectionCard(
                title: 'Salary Details',
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _basicPayController,
                            label: 'Basic Pay — Mar 2026',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            prefixText: '₹ ',
                            validator: (v) =>
                                _validateInt(v, name: 'Basic Pay', min: 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _daPercentController,
                            label: 'DA Percentage',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            suffixText: '%',
                            validator: (v) =>
                                _validateInt(v, name: 'DA %', min: 0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _incrementMonthController,
                            label: 'Increment Month',
                            hint: '1 – 12',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) => _validateInt(v,
                                name: 'Increment Month', min: 1, max: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _bpAfterIncrementController,
                            label: 'BP After Increment',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            prefixText: '₹ ',
                            validator: (v) => _validateInt(v,
                                name: 'BP After Increment', min: 0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Section: Tax Details ───────────────────────────────────
              _SectionCard(
                title: 'Tax Details',
                child: Column(
                  children: [
                    _buildField(
                      controller: _otherIncomeController,
                      label: 'Other Income  (Arrears / Surrender / etc.)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixText: '₹ ',
                      validator: (v) =>
                          _validateInt(v, name: 'Other Income', min: 0),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _taxAlreadyPaidController,
                            label: 'Tax Already Paid',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            prefixText: '₹ ',
                            validator: (v) => _validateInt(v,
                                name: 'Tax Already Paid', min: 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _remainingMonthsController,
                            label: 'Remaining Months',
                            hint: '1 – 12',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (v) => _validateInt(v,
                                name: 'Remaining Months', min: 1, max: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Submit button ──────────────────────────────────────────
              FilledButton(
                onPressed: _viewStatement,
                style: FilledButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: kSurface,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ).copyWith(
                  overlayColor:
                      WidgetStateProperty.all(kGold.withOpacity(0.12)),
                ),
                child: const Text('VIEW STATEMENT'),
              ),

              const SizedBox(height: 20),

              // ── Footer note ────────────────────────────────────────────
              const Center(
                child: Text(
                  "HB's Income Tax Calculator •  FY 2026–27",
                  style: TextStyle(
                    color: kTextMuted,
                    fontSize: 11,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Field builder ──────────────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextCapitalization capitalization = TextCapitalization.none,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? prefixText,
    String? suffixText,
    double? letterSpacing,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textCapitalization: capitalization,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: 14,
        color: kTextPrimary,
        fontWeight: FontWeight.w500,
        letterSpacing: letterSpacing,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
        prefixStyle: const TextStyle(
            color: kTextSecondary, fontSize: 13, fontWeight: FontWeight.w500),
        suffixStyle: const TextStyle(
            color: kTextSecondary, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      validator: validator,
    );
  }

  // ── Validator ──────────────────────────────────────────────────────────────
  String? _validateInt(String? value,
      {required String name, required int min, int? max}) {
    if (value == null || value.trim().isEmpty) return '$name is required';
    final int? n = int.tryParse(value.trim());
    if (n == null) return 'Enter a valid number';
    if (n < min) return 'Minimum value is $min';
    if (max != null && n > max) return 'Maximum value is $max';
    return null;
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header with gold left border
          Container(
            decoration: const BoxDecoration(
              color: kBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              border: Border(
                bottom: BorderSide(color: kBorder),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}
