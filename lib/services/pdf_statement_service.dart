import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/utils/it_formatters.dart';

class PdfStatementService {
  Future<pw.Font> _loadRupeeFont() async {
    final ByteData data =
        await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    return pw.Font.ttf(data);
  }

  Future<pw.Font> _loadRupeeFontBold() async {
    final ByteData data =
        await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
    return pw.Font.ttf(data);
  }

  Future<Uint8List> buildPdf(TaxComputationResult result) async {
    final pw.Font base = await _loadRupeeFont();
    final pw.Font bold = await _loadRupeeFontBold();

    final pw.Document doc = pw.Document();
    final pw.ThemeData theme = pw.ThemeData.withFont(base: base, bold: bold);

    // ── Style constants ──────────────────────────────────────────────────────
    const double sectionSize = 7.5;
    const double cellSize = 7.5;
    const double headerSize = 8;

    final pw.TextStyle sectionStyle = pw.TextStyle(
      font: bold,
      fontSize: sectionSize,
      fontWeight: pw.FontWeight.bold,
      color: PdfColor.fromHex('#6B7280'),
      letterSpacing: 0.8,
    );
    final pw.TextStyle cellStyle = pw.TextStyle(font: base, fontSize: cellSize);
    final pw.TextStyle cellBoldStyle = pw.TextStyle(
        font: bold, fontSize: cellSize, fontWeight: pw.FontWeight.bold);
    final pw.TextStyle hdrStyle = pw.TextStyle(
      font: bold,
      fontSize: headerSize,
      fontWeight: pw.FontWeight.bold,
    );

    // ── Salary table data ────────────────────────────────────────────────────
    final List<List<String>> salaryData = result.salaryRows.map((row) {
      if (row.isOtherIncome) {
        return <String>[
          row.monthLabel,
          '-',
          '-',
          '-',
          '-',
          ItFormatters.formatCurrency(row.grossPay),
        ];
      }
      return <String>[
        row.monthLabel,
        ItFormatters.formatCurrency(row.bp),
        '${row.daPercent}%',
        ItFormatters.formatCurrency(row.da),
        ItFormatters.formatCurrency(row.hra),
        ItFormatters.formatCurrency(row.grossPay),
      ];
    }).toList();

    // ── Tax summary rows ─────────────────────────────────────────────────────
    final List<_SummaryRow> summaryRows = [
      _SummaryRow('Total Salary Income',
          ItFormatters.formatCurrency(result.totalSalaryIncome)),
      _SummaryRow('Standard Deduction',
          '- ${ItFormatters.formatCurrency(result.standardDeduction)}'),
      _SummaryRow('Taxable Income (New Regime)',
          ItFormatters.formatCurrency(result.taxableIncome),
          bold: true, topBorder: true),
      _SummaryRow('Tax on Total Income',
          ItFormatters.formatCurrency(result.taxOnIncome),
          topBorder: true),
      _SummaryRow(
          'Rebate u/s 87A', ItFormatters.formatCurrency(result.rebate87A)),
      _SummaryRow('Marginal Relief u/s 87A',
          ItFormatters.formatCurrency(result.marginalRelief)),
      _SummaryRow('Tax After Rebate',
          ItFormatters.formatCurrency(result.taxAfterRebate)),
      _SummaryRow('Education Cess @ 4%',
          ItFormatters.formatCurrency(result.educationCess)),
      _SummaryRow(
          'Net Tax Payable', ItFormatters.formatCurrency(result.netTaxPayable),
          bold: true, topBorder: true),
      _SummaryRow('Tax Already Paid',
          ItFormatters.formatCurrency(result.input.taxAlreadyPaid),
          topBorder: true),
      _SummaryRow('Remaining Months', result.input.remainingMonths.toString()),
      _SummaryRow('Balance Tax Payable',
          ItFormatters.formatCurrency(result.balanceTaxPayable),
          bold: true, topBorder: true),
    ];

    doc.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          theme: theme,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // ── ROW 0: Header bar ─────────────────────────────────────────
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#0D1B2A'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        result.input.name,
                        style: pw.TextStyle(
                          font: bold,
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('PEN: ${result.input.pen}',
                          style: pw.TextStyle(
                              font: base,
                              fontSize: 8,
                              color: const PdfColor(1, 1, 1, 0.7))),
                      pw.SizedBox(height: 2),
                      pw.Text('PAN: ${result.input.pan}',
                          style: pw.TextStyle(
                              font: base,
                              fontSize: 8,
                              color: const PdfColor(1, 1, 1, 0.7))),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // ── ROW 1: Salary Table (full width) ─────────────────────────
            pw.Text('MONTHLY SALARY BREAKDOWN', style: sectionStyle),
            pw.SizedBox(height: 3),
            pw.TableHelper.fromTextArray(
              headers: ['Month', 'Basic Pay', 'DA %', 'DA', 'HRA', 'Gross Pay'],
              data: salaryData,
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              headerStyle: hdrStyle,
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.blueGrey100),
              cellStyle: cellStyle,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.centerRight,
              },
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            ),
            pw.SizedBox(height: 8),

            // ── ROW 2: Tax Summary (left) + TDS block (right) ────────────
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // LEFT: Tax computation summary table
                pw.Expanded(
                  flex: 62,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TAX COMPUTATION SUMMARY', style: sectionStyle),
                      pw.SizedBox(height: 3),
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.grey400, width: 0.5),
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(3)),
                        ),
                        child: pw.Column(
                          children: summaryRows.asMap().entries.map((entry) {
                            final int i = entry.key;
                            final _SummaryRow row = entry.value;
                            final bool isLast = i == summaryRows.length - 1;

                            return pw.Container(
                              decoration: pw.BoxDecoration(
                                color: row.bold
                                    ? PdfColor.fromHex('#EEF2FF')
                                    : (i.isEven
                                        ? PdfColors.white
                                        : PdfColor.fromHex('#F7F8FA')),
                                border: pw.Border(
                                  top: row.topBorder && i > 0
                                      ? const pw.BorderSide(
                                          color: PdfColors.grey400, width: 0.5)
                                      : pw.BorderSide.none,
                                  bottom: !isLast
                                      ? const pw.BorderSide(
                                          color: PdfColors.grey300, width: 0.3)
                                      : pw.BorderSide.none,
                                ),
                              ),
                              padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3.2),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Expanded(
                                    child: pw.Text(row.label,
                                        style: row.bold
                                            ? cellBoldStyle
                                            : cellStyle),
                                  ),
                                  pw.Text(row.value,
                                      style:
                                          row.bold ? cellBoldStyle : cellStyle),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 10),

                // RIGHT: TDS highlight + key figures
                pw.Expanded(
                  flex: 38,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TDS SUMMARY', style: sectionStyle),
                      pw.SizedBox(height: 3),

                      // TDS per month — main highlight
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#0D1B2A'),
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(4)),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'TDS PER MONTH',
                              style: pw.TextStyle(
                                font: bold,
                                fontSize: 7,
                                color: const PdfColor(1, 1, 1, 0.6),
                                letterSpacing: 1.0,
                              ),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              ItFormatters.formatCurrency(result.tdsPerMonth),
                              style: pw.TextStyle(
                                font: bold,
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 6),

                      // Key figures recap box
                      pw.Container(
                        width: double.infinity,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                              color: PdfColors.grey400, width: 0.5),
                          borderRadius:
                              const pw.BorderRadius.all(pw.Radius.circular(3)),
                        ),
                        child: pw.Column(
                          children: [
                            _keyFigureRow(
                              'Net Tax Payable',
                              ItFormatters.formatCurrency(result.netTaxPayable),
                              base: base,
                              bold: bold,
                              cellSize: cellSize,
                              topRadius: true,
                            ),
                            _keyFigureRow(
                              'Tax Already Paid',
                              ItFormatters.formatCurrency(
                                  result.input.taxAlreadyPaid),
                              base: base,
                              bold: bold,
                              cellSize: cellSize,
                            ),
                            _keyFigureRow(
                              'Balance Tax Payable',
                              ItFormatters.formatCurrency(
                                  result.balanceTaxPayable),
                              base: base,
                              bold: bold,
                              cellSize: cellSize,
                              highlight: true,
                            ),
                            _keyFigureRow(
                              'Remaining Months',
                              result.input.remainingMonths.toString(),
                              base: base,
                              bold: bold,
                              cellSize: cellSize,
                              bottomRadius: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Footer ────────────────────────────────────────────────────
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 3),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                "HB's TAX CALCULATOR  •  FY 2026–27  •  Generated on ${_todayFormatted()}",
                style: pw.TextStyle(
                    font: base, fontSize: 7, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// Builds a single key-figure row for the right-side recap box.
  pw.Widget _keyFigureRow(
    String label,
    String value, {
    required pw.Font base,
    required pw.Font bold,
    required double cellSize,
    bool highlight = false,
    bool topRadius = false,
    bool bottomRadius = false,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: highlight ? PdfColor.fromHex('#EEF2FF') : PdfColors.white,
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style: highlight
                  ? pw.TextStyle(
                      font: bold,
                      fontSize: cellSize,
                      fontWeight: pw.FontWeight.bold)
                  : pw.TextStyle(font: base, fontSize: cellSize)),
          pw.Text(value,
              style: highlight
                  ? pw.TextStyle(
                      font: bold,
                      fontSize: cellSize,
                      fontWeight: pw.FontWeight.bold)
                  : pw.TextStyle(font: base, fontSize: cellSize)),
        ],
      ),
    );
  }

  Future<void> sharePdf(TaxComputationResult result) async {
    final Uint8List bytes = await buildPdf(result);
    await Printing.sharePdf(
      bytes: bytes,
      filename: suggestedFileName(result.input.name),
    );
  }

  Future<void> generateAndPrint(TaxComputationResult result) async {
    final Uint8List bytes = await buildPdf(result);
    await Printing.layoutPdf(
      name: suggestedFileName(result.input.name),
      onLayout: (_) async => bytes,
    );
  }

  static String suggestedFileName(String employeeName) {
    final String normalized = employeeName
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_]'), '');
    final String safeName = normalized.isEmpty ? 'Employee' : normalized;
    return 'IT_Statement_${safeName}_2026-27.pdf';
  }

  static String _todayFormatted() {
    final DateTime now = DateTime.now();
    const List<String> months = [
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
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _SummaryRow {
  const _SummaryRow(this.label, this.value,
      {this.bold = false, this.topBorder = false});

  final String label;
  final String value;
  final bool bold;
  final bool topBorder;
}
