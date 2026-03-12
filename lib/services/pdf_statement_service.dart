import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/utils/it_formatters.dart';

class PdfStatementService {
  /// Loads Noto Sans from bundled app assets — works offline in release APK.
  /// Noto Sans covers full Indian Unicode range including ₹ (U+20B9).
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
    // Load fonts ONCE and pass everywhere — this is the fix for ₹ rendering
    final pw.Font baseFont = await _loadRupeeFont();
    final pw.Font boldFont = await _loadRupeeFontBold();

    final pw.Document doc = pw.Document();

    // Base theme uses Noto Sans which supports ₹
    final pw.ThemeData theme = pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
    );

    // Reusable text styles — all inherit the theme font which supports ₹
    final pw.TextStyle sectionTitle = pw.TextStyle(
      font: boldFont,
      fontSize: 13,
      fontWeight: pw.FontWeight.bold,
    );

    final pw.TextStyle bodyStyle = pw.TextStyle(
      font: baseFont,
      fontSize: 10,
    );

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: theme,
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text(
            "HB's TAX CALCULATOR | FY 2026-27",
            style: pw.TextStyle(
              font: baseFont,
              fontSize: 9,
              color: PdfColors.grey700,
            ),
          ),
        ),
        build: (context) => [
          // ── Page Title ──────────────────────────────────────────────────
          pw.Text(
            'INCOME TAX STATEMENT 2026-27',
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1A237E'),
            ),
          ),
          pw.SizedBox(height: 8),

          // ── Employee Info Box ────────────────────────────────────────────
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Employee Name: ${result.input.name}',
                    style: bodyStyle),
                pw.Text('PEN: ${result.input.pen}', style: bodyStyle),
                pw.Text('PAN: ${result.input.pan}', style: bodyStyle),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ── Section 1: Monthly Salary Table ─────────────────────────────
          pw.Text('1. Monthly Salary Breakdown', style: sectionTitle),
          pw.SizedBox(height: 6),
          _salaryTable(result, baseFont: baseFont, boldFont: boldFont),
          pw.SizedBox(height: 16),

          // ── Section 2: Tax Computation Summary ──────────────────────────
          pw.Text('2. Tax Computation Summary', style: sectionTitle),
          pw.SizedBox(height: 6),
          _summaryTable(result, baseFont: baseFont, boldFont: boldFont),
          pw.SizedBox(height: 12),

          // ── TDS Per Month Highlight ──────────────────────────────────────
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E8EAF6'),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TDS Per Month',
                  style: pw.TextStyle(
                    font: boldFont,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                pw.Text(
                  ItFormatters.formatCurrency(result.tdsPerMonth),
                  style: pw.TextStyle(
                    font: boldFont,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    color: PdfColor.fromHex('#1A237E'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
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

  // ── Table Builders ─────────────────────────────────────────────────────────

  pw.Widget _salaryTable(
    TaxComputationResult result, {
    required pw.Font baseFont,
    required pw.Font boldFont,
  }) {
    final List<List<String>> rows = result.salaryRows.map((row) {
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

    return pw.TableHelper.fromTextArray(
      headers: ['Month', 'Basic Pay', 'DA%', 'DA', 'HRA', 'Gross Pay'],
      data: rows,
      border: pw.TableBorder.all(color: PdfColors.grey500),
      // Explicit font on header and cell styles — ensures ₹ renders correctly
      headerStyle: pw.TextStyle(
        font: boldFont,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
      cellStyle: pw.TextStyle(font: baseFont, fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _summaryTable(
    TaxComputationResult result, {
    required pw.Font baseFont,
    required pw.Font boldFont,
  }) {
    final List<List<String>> rows = [
      [
        'Total Salary Income',
        ItFormatters.formatCurrency(result.totalSalaryIncome)
      ],
      [
        'Standard Deduction',
        ItFormatters.formatCurrency(-result.standardDeduction)
      ],
      [
        'Taxable Income (New Regime)',
        ItFormatters.formatCurrency(result.taxableIncome)
      ],
      ['Tax on Total Income', ItFormatters.formatCurrency(result.taxOnIncome)],
      ['Rebate u/s 87A', ItFormatters.formatCurrency(result.rebate87A)],
      [
        'Marginal Relief u/s 87A',
        ItFormatters.formatCurrency(result.marginalRelief)
      ],
      ['Tax After Rebate', ItFormatters.formatCurrency(result.taxAfterRebate)],
      [
        'Education Cess @ 4%',
        ItFormatters.formatCurrency(result.educationCess)
      ],
      ['Net Tax Payable', ItFormatters.formatCurrency(result.netTaxPayable)],
      [
        'Tax Already Paid',
        ItFormatters.formatCurrency(result.input.taxAlreadyPaid)
      ],
      ['Remaining Months', result.input.remainingMonths.toString()],
      [
        'Balance Tax Payable',
        ItFormatters.formatCurrency(result.balanceTaxPayable)
      ],
    ];

    return pw.TableHelper.fromTextArray(
      headers: const ['Particulars', 'Amount'],
      data: rows,
      border: pw.TableBorder.all(color: PdfColors.grey500),
      headerStyle: pw.TextStyle(
        font: boldFont,
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
      cellStyle: pw.TextStyle(font: baseFont, fontSize: 10),
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
      },
    );
  }
}
