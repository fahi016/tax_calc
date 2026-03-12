class EmployeeInput {
  const EmployeeInput({
    required this.name,
    required this.pen,
    required this.pan,
    required this.basicPayMarch2026,
    required this.incrementMonth,
    required this.bpAfterIncrement,
    required this.otherIncome,
    required this.taxAlreadyPaid,
    required this.daPercent,
    required this.remainingMonths,
  });

  final String name;
  final int pen;
  final String pan;
  final int basicPayMarch2026;
  final int incrementMonth;
  final int bpAfterIncrement;
  final int otherIncome;
  final int taxAlreadyPaid;
  final int daPercent;
  final int remainingMonths;
}

class MonthlySalaryRow {
  const MonthlySalaryRow({
    required this.monthLabel,
    required this.bp,
    required this.daPercent,
    required this.da,
    required this.hra,
    required this.grossPay,
    this.isOtherIncome = false,
  });

  final String monthLabel;
  final double bp;
  final int daPercent;
  final double da;
  final double hra;
  final double grossPay;
  final bool isOtherIncome;
}

class TaxComputationResult {
  const TaxComputationResult({
    required this.input,
    required this.salaryRows,
    required this.totalSalaryIncome,
    required this.standardDeduction,
    required this.taxableIncome,
    required this.taxOnIncome,
    required this.rebate87A,
    required this.marginalRelief,
    required this.taxAfterRebate,
    required this.educationCess,
    required this.netTaxPayable,
    required this.balanceTaxPayable,
    required this.tdsPerMonth,
  });

  final EmployeeInput input;
  final List<MonthlySalaryRow> salaryRows;
  final double totalSalaryIncome;
  final double standardDeduction;
  final double taxableIncome;
  final double taxOnIncome;
  final double rebate87A;
  final double marginalRelief;
  final double taxAfterRebate;
  final double educationCess;
  final int netTaxPayable;
  final int balanceTaxPayable;
  final int tdsPerMonth;
}
