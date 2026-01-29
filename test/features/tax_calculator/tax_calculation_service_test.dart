import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/features/tax_calculator/domain/models/tax_calculator_models.dart';
import 'package:finance_app/features/tax_calculator/domain/services/tax_calculation_service.dart';

void main() {
  final testConfig = TaxConfiguration(
    id: 'test',
    name: 'Test',
    singleSlabs: [
      TaxSlab(rate: 0.01, lowerLimit: 0, upperLimit: 500000),
      TaxSlab(rate: 0.10, lowerLimit: 500000, upperLimit: 700000),
      TaxSlab(rate: 0.20, lowerLimit: 700000, upperLimit: 1000000),
      TaxSlab(rate: 0.30, lowerLimit: 1000000, upperLimit: 2000000),
      TaxSlab(rate: 0.36, lowerLimit: 2000000, upperLimit: 5000000),
      TaxSlab(rate: 0.39, lowerLimit: 5000000, upperLimit: double.infinity),
    ],
    marriedSlabs: [
      TaxSlab(rate: 0.01, lowerLimit: 0, upperLimit: 600000),
      TaxSlab(rate: 0.10, lowerLimit: 600000, upperLimit: 800000),
      TaxSlab(rate: 0.20, lowerLimit: 800000, upperLimit: 1100000),
      TaxSlab(rate: 0.30, lowerLimit: 1100000, upperLimit: 2000000),
      TaxSlab(rate: 0.36, lowerLimit: 2000000, upperLimit: 5000000),
      TaxSlab(rate: 0.39, lowerLimit: 5000000, upperLimit: double.infinity),
    ],
  );

  group('TaxCalculationService Tests', () {
    test('Low income (Single, No SSF) - 1% tax in first slab', () {
      final inputs = TaxInputs(
        monthlyGrossSalary: 40000, // 480,000 annual
        isMarried: false,
        isEnrolledInSSF: false,
      );

      final result = TaxCalculationService.calculate(inputs, testConfig);

      expect(result.netTaxableIncome, 480000);
      expect(result.finalAnnualTax, 4800); // 1% of 480,000
      expect(result.monthlyTDS, 400);
    });

    test('Low income (Single, SSF) - 0% tax in first slab', () {
      final inputs = TaxInputs(
        monthlyGrossSalary: 40000, 
        isMarried: false,
        isEnrolledInSSF: true,
      );

      final result = TaxCalculationService.calculate(inputs, testConfig);

      expect(result.finalAnnualTax, 0);
    });

    test('Married thresholds should apply correctly', () {
      // Married limit is 600,000 for 0% (if SSF)
      final inputs = TaxInputs(
        monthlyGrossSalary: 45000, // 540,000 annual
        isMarried: true,
        isEnrolledInSSF: true,
      );

      final result = TaxCalculationService.calculate(inputs, testConfig);

      expect(result.finalAnnualTax, 0);
    });

    test('Deductions (CIT, Insurance) should reduce taxable income', () {
      final inputs = TaxInputs(
        monthlyGrossSalary: 100000, // 1,200,000 annual
        monthlyCITContribution: 25000, // 300,000 annual
        annualLifeInsurance: 25000,
        annualHealthInsurance: 5000,
        isMarried: false,
        isEnrolledInSSF: true,
      );

      final result = TaxCalculationService.calculate(inputs, testConfig);

      // Assessable: 1,200,000
      // Retirement: 300,000
      // Insurance: min(25000+5000, 40000) = 30,000
      // Net Taxable: 1,200,000 - 300,000 - 30,000 = 870,000
      
      expect(result.netTaxableIncome, 870000);
      
      // Slabs (Single, SSF):
      // 0-500k: 0%
      // 500k-700k (200k): 10% = 20,000
      // 700k-870k (170k): 20% = 34,000
      // Total: 54,000
      expect(result.finalAnnualTax, 54000);
    });

    test('Female tax rebate should apply', () {
       final inputs = TaxInputs(
        monthlyGrossSalary: 100000, // 1,200,000 annual
        isMarried: false,
        isEnrolledInSSF: true,
        hasFemaleTaxRebate: true,
      );

      final result = TaxCalculationService.calculate(inputs, testConfig);

      // Assessable: 1,200,000
      // Slabs:
      // 0-500k: 0
      // 500-700k: 20,000
      // 700k-1,000k: 60,000
      // 1,000k-1,200k: 60,000
      // Total before rebate: 140,000
      // Rebate: 14,000
      // Final Tax: 126,000
      
      expect(result.totalAnnualTax, 140000);
      expect(result.femaleTaxRebateAmount, 14000);
      expect(result.finalAnnualTax, 126000);
    });

    test('High income (Single) - should hit 36% and 39% slabs', () {
      final inputs = TaxInputs(
        monthlyGrossSalary: 600000, // 7,200,000 annual
        isMarried: false,
        isEnrolledInSSF: false, // No SSF for simplicity
      );

      final result = TaxCalculationService.calculate(inputs, testConfig);

      // Annual: 7,200,000
      // 1. 0-500k (500k) @ 1% = 5,000
      // 2. 500k-700k (200k) @ 10% = 20,000
      // 3. 700k-1,000k (300k) @ 20% = 60,000
      // 4. 1,000k-2,000k (1,000k) @ 30% = 300,000
      // 5. 2,000k-5,000k (3,000k) @ 36% = 1,080,000
      // 6. 5,000k-7,200k (2,200k) @ 39% = 858,000
      
      // Total: 5,000 + 20,000 + 60,000 + 300,000 + 1,080,000 + 858,000 = 2,323,000

      expect(result.netTaxableIncome, 7200000);
      expect(result.finalAnnualTax, 2323000);
    });
  });
}
