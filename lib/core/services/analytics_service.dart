import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Logs a screen view event.
  Future<void> logScreenView(String screenName) async {
    if (kDebugMode) print('Analytics: logScreenView($screenName)');
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Logs a generic feature usage event.
  Future<void> logFeatureUsage(String featureName, {Map<String, dynamic>? parameters}) async {
    if (kDebugMode) print('Analytics: logFeatureUsage($featureName, $parameters)');
    await _analytics.logEvent(
      name: 'feature_usage',
      parameters: {
        'feature_name': featureName,
        ...?parameters,
      },
    );
  }

  /// Logs when a new transaction is added.
  Future<void> logTransactionAdded({
    required String category,
    required double amount,
    required String type,
  }) async {
    if (kDebugMode) print('Analytics: logTransactionAdded($category, $amount, $type)');
    await _analytics.logEvent(
      name: 'add_transaction',
      parameters: {
        'category': category,
        'amount': amount,
        'type': type,
      },
    );
  }

  /// Logs when a tax calculation is performed.
  Future<void> logTaxCalculated({required String configuration}) async {
    if (kDebugMode) print('Analytics: logTaxCalculated($configuration)');
    await _analytics.logEvent(
      name: 'calculate_tax',
      parameters: {
        'configuration': configuration,
      },
    );
  }

  /// Logs when a budget plan is created or updated.
  Future<void> logBudgetAction(String action) async {
    if (kDebugMode) print('Analytics: logBudgetAction($action)');
    await _analytics.logEvent(
      name: 'budget_action',
      parameters: {
        'action': action,
      },
    );
  }
}
