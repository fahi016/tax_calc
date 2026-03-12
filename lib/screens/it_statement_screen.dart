import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/services/pdf_statement_service.dart';
import 'package:tax_calc/utils/it_formatters.dart';

class ItStatementScreen extends StatefulWidget {
  const ItStatementScreen({super.key, required this.result});

  final TaxComputationResult result;

  @override
  State<ItStatementScreen> createState() => _ItStatementScreenState();
}

class _ItStatementScreenState extends State<ItStatementScreen> {
  final PdfStatementService _pdfService = PdfStatementService();

  Future<void> _downloadPdf() async {
    try {
      final Uint8List pdfBytes = await _runWithLoading(
        () => _pdfService.buildPdf(widget.result),
      );

      if (!mounted) {
        return;
      }

      await Printing.layoutPdf(
        name: PdfStatementService.suggestedFileName(widget.result.input.name),
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
      builder:
          (_) => const Dialog(
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
    final TaxComputationResult result = widget.result;

    return Scaffold(
      appBar: AppBar(title: const Text("HB's TAX CALCULATOR 2026-27")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(context, result),
            const SizedBox(height: 14),
            _buildSalaryTableCard(context, result),
            const SizedBox(height: 14),
            _buildSummaryCard(context, result),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _downloadPdf,
              child: const Text('DOWNLOAD PDF'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, TaxComputationResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'INCOME TAX CALCULATOR 2026-27',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _detailLine('Name', result.input.name),
            _detailLine('PEN', result.input.pen.toString()),
            _detailLine('PAN', result.input.pan),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryTableCard(BuildContext context, TaxComputationResult result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Salary Table',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith(
                  (_) => const Color(0xFFE8EAF6),
                ),
                columns: const [
                  DataColumn(label: Text('Month')),
                  DataColumn(label: Text('BP')),
                  DataColumn(label: Text('DA%')),
                  DataColumn(label: Text('DA')),
                  DataColumn(label: Text('HRA')),
                  DataColumn(label: Text('GP')),
                ],
                rows: List<DataRow>.generate(result.salaryRows.length, (index) {
                  final MonthlySalaryRow row = result.salaryRows[index];
                  return DataRow(
                    color: WidgetStateProperty.resolveWith((_) {
                      return index.isEven
                          ? const Color(0xFFF8F9FF)
                          : Colors.white;
                    }),
                    cells: [
                      DataCell(Text(row.monthLabel)),
                      DataCell(
                        Text(row.isOtherIncome ? '-' : ItFormatters.formatCurrency(row.bp)),
                      ),
                      DataCell(Text(row.isOtherIncome ? '-' : '${row.daPercent}%')),
                      DataCell(
                        Text(row.isOtherIncome ? '-' : ItFormatters.formatCurrency(row.da)),
                      ),
                      DataCell(
                        Text(row.isOtherIncome ? '-' : ItFormatters.formatCurrency(row.hra)),
                      ),
                      DataCell(Text(ItFormatters.formatCurrency(row.grossPay))),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, TaxComputationResult result) {
    final Color accent = Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _summaryRow(
              'Total Salary Income',
              ItFormatters.formatCurrency(result.totalSalaryIncome),
            ),
            _summaryRow(
              'Standard Deduction',
              ItFormatters.formatCurrency(-result.standardDeduction),
            ),
            _summaryRow(
              'Taxable Income (New Regime)',
              ItFormatters.formatCurrency(result.taxableIncome),
            ),
            const Divider(height: 22),
            _summaryRow(
              'Tax on Total Income',
              ItFormatters.formatCurrency(result.taxOnIncome),
            ),
            _summaryRow(
              'Rebate u/s 87A',
              ItFormatters.formatCurrency(result.rebate87A),
            ),
            _summaryRow(
              'Marginal Relief u/s 87A',
              ItFormatters.formatCurrency(result.marginalRelief),
            ),
            _summaryRow(
              'Tax After Rebate',
              ItFormatters.formatCurrency(result.taxAfterRebate),
            ),
            _summaryRow(
              'Education Cess @ 4%',
              ItFormatters.formatCurrency(result.educationCess),
            ),
            _summaryRow(
              'Net Tax Payable',
              ItFormatters.formatCurrency(result.netTaxPayable),
            ),
            _summaryRow(
              'Tax Already Paid',
              ItFormatters.formatCurrency(result.input.taxAlreadyPaid),
            ),
            _summaryRow('Remaining Months', result.input.remainingMonths.toString()),
            _summaryRow(
              'Balance Tax Payable',
              ItFormatters.formatCurrency(result.balanceTaxPayable),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EAF6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TDS Per Month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    ItFormatters.formatCurrency(result.tdsPerMonth),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Text(value, textAlign: TextAlign.right),
        ],
      ),
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value'),
    );
  }
}
