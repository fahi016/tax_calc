import 'dart:math';

import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/utils/it_formatters.dart';

class TaxCalculatorService {
  // --- Regulatory constants for FY 2026-27 (New Regime) ---
  static const int fyStartYear = 2026;
  static const int fyStartMonth = 3; // March
  static const int fyMonthCount = 12;

  static const double standardDeduction = 75000;

  static const double rebateLimit = 60000;
  static const double rebateIncomeThreshold = 1200000;
  static const double marginalReliefLimit = 1270588;

  static const double educationCessRate = 0.04;

  // --- New Regime Tax Slab Boundaries ---
  static const double _slab1 = 400000;
  static const double _slab2 = 800000;
  static const double _slab3 = 1200000;
  static const double _slab4 = 1600000;
  static const double _slab5 = 2000000;
  static const double _slab6 = 2400000;

  static const double _taxAt2 = (_slab2 - _slab1) * 0.05;
  static const double _taxAt3 = (_slab3 - _slab2) * 0.10 + _taxAt2;
  static const double _taxAt4 = (_slab4 - _slab3) * 0.15 + _taxAt3;
  static const double _taxAt5 = (_slab5 - _slab4) * 0.20 + _taxAt4;
  static const double _taxAt6 = (_slab6 - _slab5) * 0.25 + _taxAt5;

  TaxComputationResult compute(EmployeeInput input) {
    final List<MonthlySalaryRow> salaryRows = _buildMonthlyRows(input);

    final double monthlyTotal = salaryRows.fold<double>(
      0,
      (sum, row) => sum + row.grossPay,
    );
    final double totalSalaryIncome = monthlyTotal + input.otherIncome;
    final double taxableIncome = totalSalaryIncome - standardDeduction;

    final double taxOnIncome = _calculateTaxOnIncome(taxableIncome);

    final double rebate87A = taxOnIncome <= rebateLimit ? taxOnIncome : 0;

    final double marginalRelief = taxableIncome >= rebateIncomeThreshold &&
            taxableIncome <= marginalReliefLimit
        ? taxOnIncome - (taxableIncome - rebateIncomeThreshold)
        : 0;

    final double taxAfterRebate =
        max(0, taxOnIncome - rebate87A - marginalRelief);
    final double educationCess = taxAfterRebate * educationCessRate;
    final int netTaxPayable = (taxAfterRebate + educationCess).round();

    // ── Relief u/s 89(1) ────────────────────────────────────────────────────
    // Deducted from Net Tax Payable only. Not part of taxable income computation.
    final int reliefUs89 = input.relief;
    final int taxAfterRelief = max(0, netTaxPayable - reliefUs89);

    // ── TDS ──────────────────────────────────────────────────────────────────
    final int balanceTaxPayable = taxAfterRelief - input.taxAlreadyPaid;
    final int tdsPerMonth = (balanceTaxPayable / input.remainingMonths).round();

    return TaxComputationResult(
      input: input,
      salaryRows: [
        ...salaryRows,
        MonthlySalaryRow(
          monthLabel: 'Other Income',
          bp: 0,
          daPercent: 0,
          da: 0,
          hra: 0,
          grossPay: input.otherIncome.toDouble(),
          isOtherIncome: true,
        ),
      ],
      totalSalaryIncome: totalSalaryIncome,
      standardDeduction: standardDeduction,
      taxableIncome: taxableIncome,
      taxOnIncome: taxOnIncome,
      rebate87A: rebate87A,
      marginalRelief: marginalRelief,
      taxAfterRebate: taxAfterRebate,
      educationCess: educationCess,
      netTaxPayable: netTaxPayable,
      reliefUs89: reliefUs89,
      taxAfterRelief: taxAfterRelief,
      balanceTaxPayable: balanceTaxPayable,
      tdsPerMonth: tdsPerMonth,
    );
  }

  List<MonthlySalaryRow> _buildMonthlyRows(EmployeeInput input) {
    final DateTime start = DateTime(fyStartYear, fyStartMonth);

    return List<MonthlySalaryRow>.generate(fyMonthCount, (index) {
      final DateTime monthDate = DateTime(start.year, start.month + index);

      final int incrementYear =
          input.nextIncrementDate >= 3 ? fyStartYear : fyStartYear + 1;
      final DateTime incrementFrom =
          DateTime(incrementYear, input.nextIncrementDate);

      final bool useOldBp = monthDate.isBefore(incrementFrom);
      final int bp =
          useOldBp ? input.basicPayMarch2026 : input.bpAfterIncrement;

      final double da = bp * (input.daPercent / 100);
      final double hra = _calculateHra(bp.toDouble(), input.localBodyType);
      final double grossPay = bp + da + hra;

      return MonthlySalaryRow(
        monthLabel: ItFormatters.formatMonth(monthDate),
        bp: bp.toDouble(),
        daPercent: input.daPercent,
        da: da,
        hra: hra,
        grossPay: grossPay,
      );
    });
  }

  double _calculateHra(double bp, String localBodyType) {
    switch (localBodyType) {
      case 'Corporation':
        return min(max(bp * 0.10, 2300), 10000);
      case 'Municipalities in Dist HQ':
        return min(max(bp * 0.08, 2000), 8000);
      case 'Municipalities':
        return min(max(bp * 0.06, 1500), 6000);
      case 'Panchayaths':
      default:
        return min(max(bp * 0.04, 1200), 4000);
    }
  }

  double _calculateTaxOnIncome(double taxableIncome) {
    if (taxableIncome <= _slab1) {
      return 0;
    } else if (taxableIncome <= _slab2) {
      return (taxableIncome - _slab1) * 0.05;
    } else if (taxableIncome <= _slab3) {
      return (taxableIncome - _slab2) * 0.10 + _taxAt2;
    } else if (taxableIncome <= _slab4) {
      return (taxableIncome - _slab3) * 0.15 + _taxAt3;
    } else if (taxableIncome <= _slab5) {
      return (taxableIncome - _slab4) * 0.20 + _taxAt4;
    } else if (taxableIncome <= _slab6) {
      return (taxableIncome - _slab5) * 0.25 + _taxAt5;
    } else {
      return (taxableIncome - _slab6) * 0.30 + _taxAt6;
    }
  }
}