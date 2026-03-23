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
      barrierColor: Colors.black38,
      builder: (_) => Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: kPrimary)),
            SizedBox(width: 16),
            Text('Preparing PDF…',
                style: TextStyle(
                    fontSize: 14,
                    color: kTextPrimary,
                    fontWeight: FontWeight.w500)),
          ]),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      backgroundColor: kBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            _buildEmployeeCard(r),
            const SizedBox(height: 16),
            _buildTdsHeroCard(r),
            const SizedBox(height: 16),
            _buildSectionHeader(Icons.table_rows_outlined,
                'Monthly Salary Breakdown', kPrimary),
            const SizedBox(height: 8),
            _buildSalaryTable(r),
            const SizedBox(height: 16),
            _buildSectionHeader(Icons.calculate_outlined, 'Tax Computation',
                const Color(0xFF6A1B9A)),
            const SizedBox(height: 8),
            _buildTaxPanel(r),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('Tax Statement'),
      actions: [
        IconButton(
          onPressed: _share,
          icon: const Icon(Icons.ios_share_rounded, size: 20),
          tooltip: 'Share PDF',
        ),
        IconButton(
          onPressed: _download,
          icon: const Icon(Icons.download_rounded, size: 20),
          tooltip: 'Download PDF',
        ),
        const SizedBox(width: 4),
      ],
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
    );
  }

  // ── Employee card ─────────────────────────────────────────────────────────────
  Widget _buildEmployeeCard(TaxComputationResult r) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3C6E), Color(0xFF2A5298)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(children: [
        Positioned(
          right: -20,
          top: -20,
          child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05))),
        ),
        Positioned(
          right: 30,
          bottom: -30,
          child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04))),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    r.input.name.isNotEmpty
                        ? r.input.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(r.input.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(r.input.designation,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w400)),
                  ])),
            ]),
            const SizedBox(height: 14),
            Container(height: 0.5, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 14),
            if (r.input.institution.isNotEmpty) ...[
              Row(children: [
                const Icon(Icons.account_balance_outlined,
                    size: 13, color: Colors.white54),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(r.input.institution,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12))),
              ]),
              const SizedBox(height: 8),
            ],
            Row(children: [
              _infoPill('PEN  ${r.input.pen}'),
              const SizedBox(width: 8),
              _infoPill('PAN  ${r.input.pan}'),
              const Spacer(),
              _infoPill('FY 2026–27', accent: true),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _infoPill(String text, {bool accent = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent
            ? const Color(0xFF00897B).withOpacity(0.25)
            : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: accent
                ? const Color(0xFF00897B).withOpacity(0.5)
                : Colors.white.withOpacity(0.2)),
      ),
      child: Text(text,
          style: TextStyle(
              color: accent ? const Color(0xFF80CBC4) : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }

  // ── TDS hero card ─────────────────────────────────────────────────────────────
  Widget _buildTdsHeroCard(TaxComputationResult r) {
    final bool hasRelief = r.reliefUs89 > 0;
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
      child: Column(children: [
        Container(
          height: 4,
          decoration: const BoxDecoration(
            gradient:
                LinearGradient(colors: [Color(0xFF00ACC1), Color(0xFF00897B)]),
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TDS PER MONTH',
                    style: TextStyle(
                        color: kTextMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(ItFormatters.formatCurrency(r.tdsPerMonth),
                    style: const TextStyle(
                        color: kPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ]),
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: kAccentLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_outlined,
                    color: kAccent, size: 26),
              ),
            ]),
            const SizedBox(height: 16),
            Container(height: 0.5, color: kBorder),
            const SizedBox(height: 14),
            // Row 1: Net Tax | Paid | Balance
            Row(children: [
              _summaryChip('Net Tax',
                  ItFormatters.formatCurrency(r.netTaxPayable), kPrimary),
              const SizedBox(width: 8),
              _summaryChip('Paid',
                  ItFormatters.formatCurrency(r.input.taxAlreadyPaid), kAccent),
              const SizedBox(width: 8),
              _summaryChip(
                  'Balance',
                  ItFormatters.formatCurrency(r.balanceTaxPayable),
                  r.balanceTaxPayable > 0 ? kHighlight : kAccent),
            ]),
           
          
          ]),
        ),
      ]),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Text(label,
              style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
          const SizedBox(height: 4),
          FittedBox(
              child: Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()]))),
        ]),
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(IconData icon, String title, Color color) {
    return Row(children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(
              color: kTextPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
    ]);
  }

  // ── Salary table ──────────────────────────────────────────────────────────────
  Widget _buildSalaryTable(TaxComputationResult r) {
    const TextStyle colHdr = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kTextSecondary,
        letterSpacing: 0.5);
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowHeight: 38,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 36,
          dividerThickness: 0.5,
          headingRowColor: WidgetStateProperty.all(kSurfaceAlt),
          columns: const [
            DataColumn(label: Text('MONTH', style: colHdr)),
            DataColumn(label: Text('BASIC PAY', style: colHdr), numeric: true),
            DataColumn(label: Text('DA %', style: colHdr), numeric: true),
            DataColumn(label: Text('DA', style: colHdr), numeric: true),
            DataColumn(label: Text('HRA', style: colHdr), numeric: true),
            DataColumn(label: Text('GROSS', style: colHdr), numeric: true),
          ],
          rows: List.generate(r.salaryRows.length, (i) {
            final row = r.salaryRows[i];
            final bool other = row.isOtherIncome;
            final Color bg =
                other ? kHighlightBg : (i.isEven ? kSurface : kSurfaceAlt);
            return DataRow(
              color: WidgetStateProperty.all(bg),
              cells: [
                DataCell(Text(row.monthLabel,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            other ? FontWeight.w700 : FontWeight.w500,
                        color: other ? kHighlight : kTextPrimary))),
                DataCell(Text(
                    other ? '—' : ItFormatters.formatCurrency(row.bp),
                    style: _cellStyle(other))),
                DataCell(Text(other ? '—' : '${row.daPercent}%',
                    style: _cellStyle(other))),
                DataCell(Text(
                    other ? '—' : ItFormatters.formatCurrency(row.da),
                    style: _cellStyle(other))),
                DataCell(Text(
                    other ? '—' : ItFormatters.formatCurrency(row.hra),
                    style: _cellStyle(other))),
                DataCell(Text(ItFormatters.formatCurrency(row.grossPay),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: other ? kHighlight : kPrimary,
                        fontFeatures: const [
                          FontFeature.tabularFigures()
                        ]))),
              ],
            );
          }),
        ),
      ),
    );
  }

  TextStyle _cellStyle(bool dimmed) => TextStyle(
      fontSize: 12,
      color: dimmed ? kTextMuted : kTextSecondary,
      fontWeight: FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()]);

  // ── Tax panel ─────────────────────────────────────────────────────────────────
  Widget _buildTaxPanel(TaxComputationResult r) {
    final bool hasRelief = r.reliefUs89 > 0;
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        // Group 1 — income
        _taxGroup([
          _TaxLine('Total Salary Income',
              ItFormatters.formatCurrency(r.totalSalaryIncome)),
          _TaxLine('Standard Deduction',
              '− ${ItFormatters.formatCurrency(r.standardDeduction)}',
              valueColor: kSuccess),
          _TaxLine(
              'Taxable Income', ItFormatters.formatCurrency(r.taxableIncome),
              bold: true, highlight: true),
        ], isFirst: true),
        _groupDivider(),
        // Group 2 — tax computation
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
              bold: true, highlight: true),
        ]),
        _groupDivider(),
        // Group 3 — relief + TDS
        _taxGroup([
          if (hasRelief)
            _TaxLine(
              'Relief for Salary Arrears u/s 89',
              '− ${ItFormatters.formatCurrency(r.reliefUs89)}',
              valueColor: kSuccess,
            ),
          if (hasRelief)
            _TaxLine('Tax After Relief',
                ItFormatters.formatCurrency(r.taxAfterRelief),
                bold: true, highlight: true),
          _TaxLine('Tax Already Paid',
              '− ${ItFormatters.formatCurrency(r.input.taxAlreadyPaid)}',
              valueColor: kSuccess),
          _TaxLine('Remaining Months', r.input.remainingMonths.toString()),
          _TaxLine('Balance Tax Payable',
              ItFormatters.formatCurrency(r.balanceTaxPayable),
              bold: true,
              highlight: true,
              highlightColor: kHighlight),
        ], isLast: true),
      ]),
    );
  }

  Widget _taxGroup(List<_TaxLine> lines,
      {bool isFirst = false, bool isLast = false}) {
    return Column(
        children: List.generate(lines.length, (i) {
      final line = lines[i];
      final bool last = i == lines.length - 1;
      final Color highlightColor =
          line.highlightColor ?? const Color(0xFFF0F4FF);
      return Container(
        decoration: BoxDecoration(
          color: line.highlight ? highlightColor.withOpacity(0.12) : kSurface,
          borderRadius: isFirst && i == 0
              ? const BorderRadius.vertical(top: Radius.circular(13))
              : isLast && last
                  ? const BorderRadius.vertical(bottom: Radius.circular(13))
                  : null,
          border: !last
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFF0F2F7), width: 1))
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
              child: Text(line.label,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight:
                          line.bold ? FontWeight.w700 : FontWeight.w400,
                      color: kTextPrimary))),
          Text(line.value,
              style: TextStyle(
                  fontSize: 13.5,
                  fontWeight:
                      line.bold ? FontWeight.w700 : FontWeight.w500,
                  color: line.valueColor ??
                      (line.bold ? kPrimary : kTextPrimary),
                  fontFeatures: const [FontFeature.tabularFigures()])),
        ]),
      );
    }));
  }

  Widget _groupDivider() => Container(height: 6, color: kBackground);

  // ── Action buttons ────────────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _share,
          icon: const Icon(Icons.ios_share_rounded, size: 18),
          label: const Text('SHARE PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            side: const BorderSide(color: kPrimary, width: 1.5),
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1A3C6E), Color(0xFF2A5298)]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF1A3C6E).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _download,
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox(
                height: 52,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('DOWNLOAD',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5)),
                    ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _TaxLine {
  const _TaxLine(this.label, this.value,
      {this.bold = false,
      this.valueColor,
      this.highlight = false,
      this.highlightColor});
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;
  final bool highlight;
  final Color? highlightColor;
}