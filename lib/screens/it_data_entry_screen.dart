import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/screens/it_statement_screen.dart';
import 'package:tax_calc/services/pdf_statement_service.dart';
import 'package:tax_calc/services/tax_calculator_service.dart';
import 'package:tax_calc/utils/it_formatters.dart';

class ItDataEntryScreen extends StatefulWidget {
  const ItDataEntryScreen({super.key});

  @override
  State<ItDataEntryScreen> createState() => _ItDataEntryScreenState();
}

class _ItDataEntryScreenState extends State<ItDataEntryScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TaxCalculatorService _calculatorService = TaxCalculatorService();
  final PdfStatementService _pdfService = PdfStatementService();

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

  Future<void> _viewStatement() async {
    final TaxComputationResult? result = _calculateResult();
    if (result == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItStatementScreen(result: result),
      ),
    );
  }

  Future<void> _downloadPdfDirectly() async {
    final TaxComputationResult? result = _calculateResult();
    if (result == null) {
      return;
    }
    await _buildAndPrintPdf(result);
  }

  TaxComputationResult? _calculateResult() {
    if (!_formKey.currentState!.validate()) {
      return null;
    }

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

    return _calculatorService.compute(input);
  }

  Future<void> _buildAndPrintPdf(TaxComputationResult result) async {
    try {
      final Uint8List pdfBytes = await _runWithLoading(
        () => _pdfService.buildPdf(result),
      );

      if (!mounted) {
        return;
      }

      await Printing.layoutPdf(
        name: PdfStatementService.suggestedFileName(result.input.name),
        onLayout: (_) async => pdfBytes,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to generate PDF: $error')),
      );
    }
  }

  Future<T> _runWithLoading<T>(Future<T> Function() action) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      ),
    );

    try {
      return await action();
    } finally {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HB's TAX CALCULATOR 2026-27")),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionCard(
                title: 'Employee Details',
                child: Column(
                  children: [
                    _buildNameField(),
                    const SizedBox(height: 12),
                    _buildPenField(),
                    const SizedBox(height: 12),
                    _buildPanField(),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Salary & Tax Inputs',
                child: Column(
                  children: [
                    _buildNumberField(
                      controller: _basicPayController,
                      label: 'Basic Pay on March 2026',
                      min: 0,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _incrementMonthController,
                      label: 'Next Increment Month (1-12)',
                      min: 1,
                      max: 12,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _bpAfterIncrementController,
                      label: 'BP After Increment',
                      min: 0,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _otherIncomeController,
                      label: 'Any Other Income – Surrender/Arrears etc',
                      min: 0,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _taxAlreadyPaidController,
                      label: 'Tax Already Paid',
                      min: 0,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _daPercentController,
                      label: 'DA %',
                      min: 0,
                    ),
                    const SizedBox(height: 12),
                    _buildNumberField(
                      controller: _remainingMonthsController,
                      label: 'Remaining Months',
                      min: 1,
                      max: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _viewStatement,
                child: const Text('VIEW IT STATEMENT'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _downloadPdfDirectly,
                child: const Text('DOWNLOAD PDF'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        labelText: 'Name of Employee',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Name of Employee is required';
        }
        return null;
      },
    );
  }

  Widget _buildPenField() {
    return TextFormField(
      controller: _penController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        labelText: 'PEN',
        border: OutlineInputBorder(),
      ),
      validator: (value) => _validateInteger(
        value,
        fieldName: 'PEN',
        min: 1,
      ),
    );
  }

  Widget _buildPanField() {
    return TextFormField(
      controller: _panController,
      textCapitalization: TextCapitalization.characters,
      inputFormatters: [
        LengthLimitingTextInputFormatter(10),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        UpperCaseTextFormatter(),
      ],
      decoration: const InputDecoration(
        labelText: 'PAN',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'PAN is required';
        }
        final String pan = value.trim().toUpperCase();
        if (!RegExp(r'^[A-Z0-9]{10}$').hasMatch(pan)) {
          return 'PAN must be 10 alphanumeric characters';
        }
        return null;
      },
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required int min,
    int? max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => _validateInteger(
        value,
        fieldName: label,
        min: min,
        max: max,
      ),
    );
  }

  String? _validateInteger(
    String? value, {
    required String fieldName,
    required int min,
    int? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final int? parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '$fieldName must be a valid number';
    }
    if (parsed < min) {
      return '$fieldName must be at least $min';
    }
    if (max != null && parsed > max) {
      return '$fieldName must be at most $max';
    }
    return null;
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
