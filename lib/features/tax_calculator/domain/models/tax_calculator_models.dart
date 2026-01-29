import 'package:hive/hive.dart';

part 'tax_calculator_models.g.dart';

@HiveType(typeId: 7)
class TaxSlab extends HiveObject {
  @HiveField(0)
  final double rate;
  
  @HiveField(1)
  final double lowerLimit;
  
  @HiveField(2)
  final double upperLimit;

  TaxSlab({
    required this.rate,
    required this.lowerLimit,
    required this.upperLimit,
  });

  Map<String, dynamic> toMap() {
    return {
      'rate': rate,
      'lowerLimit': lowerLimit,
      'upperLimit': upperLimit,
    };
  }

  factory TaxSlab.fromMap(Map<String, dynamic> map) {
    return TaxSlab(
      rate: map['rate']?.toDouble() ?? 0.0,
      lowerLimit: map['lowerLimit']?.toDouble() ?? 0.0,
      upperLimit: map['upperLimit']?.toDouble() ?? 0.0,
    );
  }
}

@HiveType(typeId: 8)
class TaxConfiguration extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final List<TaxSlab> singleSlabs;
  
  @HiveField(3)
  final List<TaxSlab> marriedSlabs;
  
  @HiveField(4)
  final bool isDefault;

  TaxConfiguration({
    required this.id,
    required this.name,
    required this.singleSlabs,
    required this.marriedSlabs,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'singleSlabs': singleSlabs.map((s) => s.toMap()).toList(),
      'marriedSlabs': marriedSlabs.map((s) => s.toMap()).toList(),
      'isDefault': isDefault,
    };
  }

  factory TaxConfiguration.fromMap(Map<String, dynamic> map) {
    return TaxConfiguration(
      id: map['id'],
      name: map['name'],
      singleSlabs: (map['singleSlabs'] as List).map((s) => TaxSlab.fromMap(s)).toList(),
      marriedSlabs: (map['marriedSlabs'] as List).map((s) => TaxSlab.fromMap(s)).toList(),
      isDefault: map['isDefault'] ?? false,
    );
  }
}

class TaxInputs {
  final double monthlyGrossSalary;
  final double monthlyBasicSalary;
  final bool isMarried;
  final bool isEnrolledInSSF;
  final bool hasFemaleTaxRebate;
  final double monthlyCITContribution;
  final double monthlySSFContribution;
  final double annualLifeInsurance;
  final double annualHealthInsurance;
  final double annualIncentives;

  TaxInputs({
    this.monthlyGrossSalary = 0,
    this.monthlyBasicSalary = 0,
    this.isMarried = false,
    this.isEnrolledInSSF = false,
    this.hasFemaleTaxRebate = false,
    this.monthlyCITContribution = 0,
    this.monthlySSFContribution = 0,
    this.annualLifeInsurance = 0,
    this.annualHealthInsurance = 0,
    this.annualIncentives = 0,
  });

  TaxInputs copyWith({
    double? monthlyGrossSalary,
    double? monthlyBasicSalary,
    bool? isMarried,
    bool? isEnrolledInSSF,
    bool? hasFemaleTaxRebate,
    double? monthlyCITContribution,
    double? monthlySSFContribution,
    double? annualLifeInsurance,
    double? annualHealthInsurance,
    double? annualIncentives,
  }) {
    return TaxInputs(
      monthlyGrossSalary: monthlyGrossSalary ?? this.monthlyGrossSalary,
      monthlyBasicSalary: monthlyBasicSalary ?? this.monthlyBasicSalary,
      isMarried: isMarried ?? this.isMarried,
      isEnrolledInSSF: isEnrolledInSSF ?? this.isEnrolledInSSF,
      hasFemaleTaxRebate: hasFemaleTaxRebate ?? this.hasFemaleTaxRebate,
      monthlyCITContribution: monthlyCITContribution ?? this.monthlyCITContribution,
      monthlySSFContribution: monthlySSFContribution ?? this.monthlySSFContribution,
      annualLifeInsurance: annualLifeInsurance ?? this.annualLifeInsurance,
      annualHealthInsurance: annualHealthInsurance ?? this.annualHealthInsurance,
      annualIncentives: annualIncentives ?? this.annualIncentives,
    );
  }
}

class TaxSlabResult {
  final String slabName;
  final double taxableAmountInSlab;
  final double taxRate;
  final double taxAmount;

  TaxSlabResult({
    required this.slabName,
    required this.taxableAmountInSlab,
    required this.taxRate,
    required this.taxAmount,
  });
}

class TaxCalculationResult {
  final double annualAssessableIncome;
  final double retirementDeduction;
  final double insuranceDeduction;
  final double netTaxableIncome;
  final List<TaxSlabResult> slabResults;
  final double totalAnnualTax;
  final double annualCIT;
  final double annualSSF;
  final double femaleTaxRebateAmount;
  final double finalAnnualTax;
  final double monthlyTDS;
  final double monthlyInHandSalary;

  TaxCalculationResult({
    required this.annualAssessableIncome,
    required this.retirementDeduction,
    required this.insuranceDeduction,
    required this.netTaxableIncome,
    required this.slabResults,
    required this.totalAnnualTax,
    required this.annualCIT,
    required this.annualSSF,
    required this.femaleTaxRebateAmount,
    required this.finalAnnualTax,
    required this.monthlyTDS,
    required this.monthlyInHandSalary,
  });
}
