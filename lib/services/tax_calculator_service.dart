import 'dart:math';

import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/utils/it_formatters.dart';

class TaxCalculatorService {
  // --- Regulatory constants for FY 2026-27 (New Regime) ---
  static const int fyStartYear = 2026;
  static const int fyStartMonth = 3; // March
  static const int fyMonthCount = 12;

  static const double standardDeduction = 75000;

  static const double rebateLimit =
      60000; // Max tax eligible for 87A full rebate
  static const double rebateIncomeThreshold =
      1200000; // Taxable income below which rebate applies
  static const double marginalReliefLimit =
      1270588; // Upper income limit for marginal relief

  static const double educationCessRate = 0.04;

  // --- New Regime Tax Slab Boundaries ---
  static const double _slab1 = 400000;
  static const double _slab2 = 800000;
  static const double _slab3 = 1200000;
  static const double _slab4 = 1600000;
  static const double _slab5 = 2000000;
  static const double _slab6 = 2400000;

  // --- Cumulative tax at each slab boundary ---
  static const double _taxAt2 = (_slab2 - _slab1) * 0.05; // 20,000
  static const double _taxAt3 = (_slab3 - _slab2) * 0.10 + _taxAt2; // 60,000
  static const double _taxAt4 = (_slab4 - _slab3) * 0.15 + _taxAt3; // 1,20,000
  static const double _taxAt5 = (_slab5 - _slab4) * 0.20 + _taxAt4; // 2,00,000
  static const double _taxAt6 = (_slab6 - _slab5) * 0.25 + _taxAt5; // 3,00,000

  TaxComputationResult compute(EmployeeInput input) {
    final List<MonthlySalaryRow> salaryRows = _buildMonthlyRows(input);

    final double monthlyTotal = salaryRows.fold<double>(
      0,
      (sum, row) => sum + row.grossPay,
    );
    final double totalSalaryIncome = monthlyTotal + input.otherIncome;
    final double taxableIncome = totalSalaryIncome - standardDeduction;

    final double taxOnIncome = _calculateTaxOnIncome(taxableIncome);

    // Full rebate u/s 87A if tax <= rebateLimit
    final double rebate87A = taxOnIncome <= rebateLimit ? taxOnIncome : 0;

    // Marginal relief: applicable when taxable income is between 12L and marginalReliefLimit
    final double marginalRelief = taxableIncome >= rebateIncomeThreshold &&
            taxableIncome <= marginalReliefLimit
        ? taxOnIncome - (taxableIncome - rebateIncomeThreshold)
        : 0;

    final double taxAfterRebate =
        max(0, taxOnIncome - rebate87A - marginalRelief);
    final double educationCess = taxAfterRebate * educationCessRate;
    final int netTaxPayable = (taxAfterRebate + educationCess).round();
    final int balanceTaxPayable = netTaxPayable - input.taxAlreadyPaid;
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
      balanceTaxPayable: balanceTaxPayable,
      tdsPerMonth: tdsPerMonth,
    );
  }

  List<MonthlySalaryRow> _buildMonthlyRows(EmployeeInput input) {
    final DateTime start = DateTime(fyStartYear, fyStartMonth);

    return List<MonthlySalaryRow>.generate(fyMonthCount, (index) {
      final DateTime monthDate = DateTime(start.year, start.month + index);
      final int month = monthDate.month;
      final int year = monthDate.year;

      // Use pre-increment BP for months before the increment month in the FY start year
      final int bp = year == fyStartYear && month < input.incrementMonth
          ? input.basicPayMarch2026
          : input.bpAfterIncrement;

      final double da = bp * (input.daPercent / 100);
      final double hra = min(bp * 4 / 100, 4000);
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
