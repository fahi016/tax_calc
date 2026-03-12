import 'package:flutter_test/flutter_test.dart';
import 'package:tax_calc/models/it_statement_models.dart';
import 'package:tax_calc/services/tax_calculator_service.dart';

void main() {
  test('FY 2026-27 sample calculation matches expected output', () {
    final TaxCalculatorService service = TaxCalculatorService();

    const EmployeeInput input = EmployeeInput(
      name: 'Sample Employee',
      pen: 123456,
      pan: 'ABCDE1234F',
      basicPayMarch2026: 118100,
      incrementMonth: 9,
      bpAfterIncrement: 120900,
      otherIncome: 100000,
      taxAlreadyPaid: 0,
      daPercent: 35,
      remainingMonths: 12,
    );

    final result = service.compute(input);

    expect(result.totalSalaryIncome.round(), 2083900);
    expect(result.taxableIncome.round(), 2008900);
    expect(result.taxOnIncome.round(), 202225);
    expect(result.rebate87A.round(), 0);
    expect(result.marginalRelief.round(), 0);
    expect(result.educationCess.round(), 8089);
    expect(result.netTaxPayable, 210314);
    expect(result.tdsPerMonth, 17526);
    expect(result.salaryRows.length, 13);
  });
}
