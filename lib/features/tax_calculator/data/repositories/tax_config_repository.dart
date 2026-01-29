import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/tax_calculator_models.dart';
import 'package:uuid/uuid.dart';

class TaxConfigRepository {
  static const String _boxName = 'tax_configs';
  static const String _defaultConfigId = 'nepal_fy_2081_82';

  Future<Box<TaxConfiguration>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<TaxConfiguration>(_boxName);
    }
    return await Hive.openBox<TaxConfiguration>(_boxName);
  }

  Future<List<TaxConfiguration>> getAllConfigs() async {
    final box = await _getBox();
    
    // Always ensure default config is up to date with hardcoded values
    final defaultConfig = _createDefaultConfig();
    await box.put(_defaultConfigId, defaultConfig);
    
    return box.values.toList();
  }

  Future<void> saveConfig(TaxConfiguration config) async {
    final box = await _getBox();
    await box.put(config.id, config);
  }

  Future<void> deleteConfig(String id) async {
    if (id == _defaultConfigId) return; // Cannot delete default
    final box = await _getBox();
    await box.delete(id);
  }

  TaxConfiguration _createDefaultConfig() {
    return TaxConfiguration(
      id: _defaultConfigId,
      name: 'Nepal FY 2081/82 (Default)',
      isDefault: true,
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
  }
}
