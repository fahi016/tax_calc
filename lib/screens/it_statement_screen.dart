import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/services/pdf_statement_service.dart';
import 'package:tax_calc/utils/it_formatters.dart';
import 'package:tax_calc/main.dart';

class ItStatementScreen extends StatefulWidget {
  const ItStatementScreen({super.key, required this.result});

  final TaxComputationResult result;

  @override
  State<ItStatementScreen> createState() => _ItStatementScreenState();
}

class _ItStatementScreenState extends State<ItStatementScreen> {
  final PdfStatementService _pdfService = PdfStatementService();

  // ── PDF actions ─────────────────────────────────────────────────────────────
  Future<void> _download() async {
    try {
      final Uint8List bytes =
          await _withLoading(() => _pdfService.buildPdf(widget.result));
      if (!mounted) return;
      await Printing.layoutPdf(
        name: PdfStatementService.suggestedFileName(widget.result.input.name),
        onLayout: (_) async => bytes,
      );
    } catch (e) {
      _showError('$e');
    }
  }

  Future<void> _share() async {
    try {
      await _withLoading(() => _pdfService.sharePdf(widget.result));
    } catch (e) {
      _showError('$e');
    }
  }

  Future<T> _withLoading<T>(Future<T> Function() fn) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black45,
      builder: (_) => Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: kNavy)),
              SizedBox(width: 16),
              Text('Preparing PDF…',
                  style: TextStyle(
                      fontSize: 13, color: kNavy, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
    try {
      return await fn();
    } finally {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Error: $msg'),
      backgroundColor: kError,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final r = widget.result;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 3),
        child: Column(
          children: [
            AppBar(
              title: const Text('TAX STATEMENT'),
              actions: [
                IconButton(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined, size: 21),
                  tooltip: 'Share PDF',
                ),
                IconButton(
                  onPressed: _download,
                  icon: const Icon(Icons.download_outlined, size: 21),
                  tooltip: 'Download PDF',
                ),
                const SizedBox(width: 4),
              ],
            ),
            Container(height: 3, color: kGold),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            _buildIdentityCard(r),
            const SizedBox(height: 16),
            _buildSectionLabel('Monthly Salary Breakdown'),
            const SizedBox(height: 8),
            _buildSalaryTable(r),
            const SizedBox(height: 16),
            _buildSectionLabel('Tax Computation'),
            const SizedBox(height: 8),
            _buildTaxPanel(r),
            const SizedBox(height: 16),
            _buildTdsCard(r),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share_outlined, size: 17),
                    label: const Text('SHARE'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _download,
                    icon: const Icon(Icons.download_outlined, size: 17),
                    label: const Text('DOWNLOAD'),
                    style:
                        FilledButton.styleFrom(minimumSize: const Size(0, 50)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Identity card ─────────────────────────────────────────────────────────
  Widget _buildIdentityCard(TaxComputationResult r) {
    return Container(
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kNavyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold top stripe
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  r.input.name,
                  style: const TextStyle(
                    color: kSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Info chips row
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip('PEN -  ${r.input.pen}'),
                    _chip('PAN - ${r.input.pan}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: kGold.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kGoldLight,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
                color: kGold, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  // ── Salary table ─────────────────────────────────────────────────────────
  Widget _buildSalaryTable(TaxComputationResult r) {
    const TextStyle colHdr = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: kTextSecondary,
      letterSpacing: 0.6,
    );

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 18,
            headingRowHeight: 36,
            dataRowMinHeight: 34,
            dataRowMaxHeight: 34,
            dividerThickness: 1,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6FA)),
            dataRowColor: WidgetStateProperty.resolveWith((states) => null),
            columns: const [
              DataColumn(label: Text('MONTH', style: colHdr)),
              DataColumn(
                  label: Text('BASIC PAY', style: colHdr), numeric: true),
              DataColumn(label: Text('DA %', style: colHdr), numeric: true),
              DataColumn(label: Text('DA', style: colHdr), numeric: true),
              DataColumn(label: Text('HRA', style: colHdr), numeric: true),
              DataColumn(label: Text('GROSS', style: colHdr), numeric: true),
            ],
            rows: List.generate(r.salaryRows.length, (i) {
              final row = r.salaryRows[i];
              final bool other = row.isOtherIncome;
              final Color bg = other
                  ? const Color(0xFFFFFBEE)
                  : (i.isEven ? kSurface : const Color(0xFFF9FAFB));
              return DataRow(
                color: WidgetStateProperty.all(bg),
                cells: [
                  DataCell(Text(row.monthLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: other ? FontWeight.w600 : FontWeight.w500,
                        color: other ? kGold : kTextPrimary,
                      ))),
                  DataCell(Text(
                      other ? '—' : ItFormatters.formatCurrency(row.bp),
                      style: _cell(other))),
                  DataCell(Text(other ? '—' : '${row.daPercent}%',
                      style: _cell(other))),
                  DataCell(Text(
                      other ? '—' : ItFormatters.formatCurrency(row.da),
                      style: _cell(other))),
                  DataCell(Text(
                      other ? '—' : ItFormatters.formatCurrency(row.hra),
                      style: _cell(other))),
                  DataCell(Text(
                    ItFormatters.formatCurrency(row.grossPay),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: other ? kGold : kTextPrimary,
                    ),
                  )),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  TextStyle _cell(bool dimmed) => TextStyle(
      fontSize: 12,
      color: dimmed ? kTextMuted : kTextSecondary,
      fontWeight: FontWeight.w400);

  // ── Tax computation panel ─────────────────────────────────────────────────
  Widget _buildTaxPanel(TaxComputationResult r) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          // Group 1 — income
          _taxGroup([
            _TaxLine('Total Salary Income',
                ItFormatters.formatCurrency(r.totalSalaryIncome)),
            _TaxLine('Standard Deduction',
                '− ${ItFormatters.formatCurrency(r.standardDeduction)}',
                valueColor: kSuccess),
            _TaxLine(
                'Taxable Income', ItFormatters.formatCurrency(r.taxableIncome),
                bold: true),
          ]),
          _groupDivider(),
          // Group 2 — tax calc
          _taxGroup([
            _TaxLine('Tax on Total Income',
                ItFormatters.formatCurrency(r.taxOnIncome)),
            _TaxLine('Rebate u/s 87A',
                '− ${ItFormatters.formatCurrency(r.rebate87A)}',
                valueColor: kSuccess),
            _TaxLine('Marginal Relief u/s 87A',
                '− ${ItFormatters.formatCurrency(r.marginalRelief)}',
                valueColor: kSuccess),
            _TaxLine('Tax After Rebate',
                ItFormatters.formatCurrency(r.taxAfterRebate)),
            _TaxLine('Education Cess @ 4%',
                ItFormatters.formatCurrency(r.educationCess)),
            _TaxLine(
                'Net Tax Payable', ItFormatters.formatCurrency(r.netTaxPayable),
                bold: true),
          ]),
          _groupDivider(),
          // Group 3 — balance
          _taxGroup([
            _TaxLine('Tax Already Paid',
                '− ${ItFormatters.formatCurrency(r.input.taxAlreadyPaid)}',
                valueColor: kSuccess),
            _TaxLine('Remaining Months', r.input.remainingMonths.toString()),
            _TaxLine('Balance Tax Payable',
                ItFormatters.formatCurrency(r.balanceTaxPayable),
                bold: true),
          ]),
        ],
      ),
    );
  }

  Widget _taxGroup(List<_TaxLine> lines) {
    return Column(
      children: List.generate(lines.length, (i) {
        final line = lines[i];
        final bool last = i == lines.length - 1;
        return Container(
          decoration: BoxDecoration(
            color: line.bold ? const Color(0xFFF0F4FF) : kSurface,
            border: !last
                ? const Border(bottom: BorderSide(color: Color(0xFFF0F2F5)))
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Expanded(
                child: Text(line.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: line.bold ? FontWeight.w700 : FontWeight.w400,
                      color: kTextPrimary,
                    )),
              ),
              Text(
                line.value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: line.bold ? FontWeight.w700 : FontWeight.w500,
                  color: line.valueColor ?? (line.bold ? kNavy : kTextPrimary),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _groupDivider() => Container(height: 6, color: kBackground);

  // ── TDS highlight card ────────────────────────────────────────────────────
  Widget _buildTdsCard(TaxComputationResult r) {
    return Container(
      decoration: BoxDecoration(
        color: kNavy,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: kNavyLight),
      ),
      child: Column(
        children: [
          // Gold top stripe
          Container(
            height: 3,
            decoration: const BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'TDS PER MONTH',
                        style: TextStyle(
                          color: kGold,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      SizedBox(height: 3),
                    ],
                  ),
                ),
                Text(
                  ItFormatters.formatCurrency(r.tdsPerMonth),
                  style: const TextStyle(
                    color: kSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _TaxLine {
  const _TaxLine(this.label, this.value, {this.bold = false, this.valueColor});

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
}
