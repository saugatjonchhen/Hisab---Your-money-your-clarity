import '../models/tax_calculator_models.dart';
import 'dart:math';

class TaxCalculationService {
  // Constants for Nepal Tax Rules (FY 2080/81 standard usually)
  static const double maxRetirementDeduction = 500000;
  static const double maxInsuranceDeduction = 40000;
  static const double femaleRebateRate = 0.10; // 10% rebate

  static TaxCalculationResult calculate(TaxInputs inputs, TaxConfiguration config) {
    // 1. Annual Assessable Income
    final double annualAssessableIncome = (inputs.monthlyGrossSalary * 12) + inputs.annualIncentives;

    // 2. Annual Deductions
    final double annualCIT = inputs.monthlyCITContribution * 12;
    final double annualSSF = inputs.monthlySSFContribution * 12;
    
    final double retirementDeduction = min(annualCIT + annualSSF, maxRetirementDeduction);
    final double insuranceDeduction = min(inputs.annualLifeInsurance + inputs.annualHealthInsurance, maxInsuranceDeduction);

    // 3. Net Taxable Income
    final double netTaxableIncome = max(0, annualAssessableIncome - retirementDeduction - insuranceDeduction);

    // 4. Slab-wise Tax Calculation
    final List<TaxSlabResult> slabResults = [];
    final List<TaxSlab> activeSlabs = inputs.isMarried ? config.marriedSlabs : config.singleSlabs;
    
    double remainingIncome = netTaxableIncome;
    double totalTaxBeforeRebate = 0;

    for (int i = 0; i < activeSlabs.length; i++) {
        final slab = activeSlabs[i];
        final double slabSize = slab.upperLimit - slab.lowerLimit;
        final double taxableInSlab = min(remainingIncome, slabSize);
        
        double rate = slab.rate;
        // Special rule for first slab in Nepal (0% if SSF, 1% if not)
        if (i == 0) {
          rate = inputs.isEnrolledInSSF ? 0.0 : 0.01;
        }

        if (taxableInSlab > 0) {
            final double taxInSlab = taxableInSlab * rate;
            slabResults.add(TaxSlabResult(
                slabName: 'Slab ${i + 1} (${(rate * 100).toInt()}%)',
                taxableAmountInSlab: taxableInSlab,
                taxRate: rate,
                taxAmount: taxInSlab,
            ));
            totalTaxBeforeRebate += taxInSlab;
            remainingIncome -= taxableInSlab;
        } else {
             slabResults.add(TaxSlabResult(
                slabName: 'Slab ${i + 1} (${(rate * 100).toInt()}%)',
                taxableAmountInSlab: 0,
                taxRate: rate,
                taxAmount: 0,
            ));
        }
    }

    // Handle any remaining income above the last defined slab
    if (remainingIncome > 0) {
        // We assume 36% for anything above the last slab if it's 2,000,000 as per common Nepal rules,
        // or we could just use the last slab's rate if we want to be truly generic.
        // For Nepal, 36% is standard for the very top bracket.
        const double topRate = 0.36; 
        final double taxInSlab = remainingIncome * topRate;
        slabResults.add(TaxSlabResult(
            slabName: 'Top Slab (36%)',
            taxableAmountInSlab: remainingIncome,
            taxRate: topRate,
            taxAmount: taxInSlab,
        ));
        totalTaxBeforeRebate += taxInSlab;
    }

    // 5. Female Tax Rebate
    double femaleTaxRebateAmount = 0;
    if (inputs.hasFemaleTaxRebate) {
        femaleTaxRebateAmount = totalTaxBeforeRebate * femaleRebateRate;
    }

    final double finalAnnualTax = totalTaxBeforeRebate - femaleTaxRebateAmount;
    final double monthlyTDS = finalAnnualTax / 12;

    // 6. Monthly In-Hand Salary
    // Monthly In-Hand = Monthly Gross - Monthly Tax (TDS) - Monthly CIT - Monthly SSF
    final double monthlyInHandSalary = inputs.monthlyGrossSalary - monthlyTDS - inputs.monthlyCITContribution - inputs.monthlySSFContribution;

    return TaxCalculationResult(
      annualAssessableIncome: annualAssessableIncome,
      retirementDeduction: retirementDeduction,
      insuranceDeduction: insuranceDeduction,
      netTaxableIncome: netTaxableIncome,
      slabResults: slabResults,
      totalAnnualTax: totalTaxBeforeRebate,
      annualCIT: annualCIT,
      annualSSF: annualSSF,
      femaleTaxRebateAmount: femaleTaxRebateAmount,
      finalAnnualTax: finalAnnualTax,
      monthlyTDS: monthlyTDS,
      monthlyInHandSalary: monthlyInHandSalary,
    );
  }
}
