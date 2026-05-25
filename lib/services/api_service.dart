import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense_category.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.phoneNumber,
    required this.isNewUser,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  final String userId;
  final String phoneNumber;
  final bool isNewUser;
  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: json['user_id'] as String,
      phoneNumber: json['phone_number'] as String,
      isNewUser: json['is_new_user'] as bool,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresInSeconds: json['expires_in_seconds'] as int,
    );
  }
}

class BudgetSummary {
  const BudgetSummary({
    required this.monthlyIncome,
    required this.currency,
    required this.spentTotal,
    required this.remainingTotal,
    required this.categories,
  });

  final double monthlyIncome;
  final String currency;
  final double spentTotal;
  final double remainingTotal;
  final List<ExpenseCategory> categories;

  factory BudgetSummary.fromJson(Map<String, dynamic> json) {
    return BudgetSummary(
      monthlyIncome: _readMoney(json['monthly_income']),
      currency: json['currency'] as String,
      spentTotal: _readMoney(json['spent_total']),
      remainingTotal: _readMoney(json['remaining_total']),
      categories: (json['categories'] as List)
          .map((item) =>
              ExpenseCategory.fromBudgetSummary(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _phoneNumberKey = 'auth_phone_number';

  Future<void> register(String phoneNumber) async {
    await _post('/auth/register', body: {'phone_number': phoneNumber});
  }

  Future<void> resendVerificationCode(String phoneNumber) async {
    await _post(
      '/auth/resend-verification-code',
      body: {'phone_number': phoneNumber},
    );
  }

  Future<AuthSession> verifyCode({
    required String phoneNumber,
    required String code,
  }) async {
    final data = await _post(
      '/auth/verify-code',
      body: {'phone_number': phoneNumber, 'code': code},
    ) as Map<String, dynamic>;
    final session = AuthSession.fromJson(data);
    await _saveSession(session);
    return session;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<bool> hasSession() async => (await getAccessToken()) != null;

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_phoneNumberKey);
  }

  Future<void> updateBudgetSettings({
    required double monthlyIncome,
    required List<ExpenseCategory> categories,
  }) async {
    await _put(
      '/budget/settings',
      authorized: true,
      body: {
        'monthly_income': _money(monthlyIncome),
        'currency': 'RUB',
        'categories': _budgetCategoriesPayload(
          monthlyIncome: monthlyIncome,
          categories: categories,
        ),
      },
    );
  }

  Future<BudgetSummary> getBudgetSummary() async {
    final data = await _get('/budget/summary', authorized: true)
        as Map<String, dynamic>;
    return BudgetSummary.fromJson(data);
  }

  Future<List<Transaction>> getTransactions() async {
    final data = await _get('/transactions', authorized: true) as List<dynamic>;
    return data
        .map((item) => Transaction.fromApi(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<BudgetNotification>> getNotifications() async {
    final data = await _get('/notifications', authorized: true) as List<dynamic>;
    return data
        .map((item) => BudgetNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<FinancialGoal>> getGoals() async {
    final data = await _get('/goals', authorized: true) as List<dynamic>;
    return data
        .map((item) => FinancialGoal.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<FinancialGoal> createGoal({
    required String title,
    required double targetAmount,
    double currentAmount = 0,
  }) async {
    final data = await _post(
      '/goals',
      authorized: true,
      body: {
        'title': title,
        'target_amount': _money(targetAmount),
        'current_amount': _money(currentAmount),
      },
    ) as Map<String, dynamic>;
    return FinancialGoal.fromJson(data);
  }

  Future<FinancialGoal> addGoalContribution({
    required String goalId,
    required double amount,
  }) async {
    final data = await _post(
      '/goals/$goalId/contributions',
      authorized: true,
      body: {'amount': _money(amount)},
    ) as Map<String, dynamic>;
    return FinancialGoal.fromJson(data);
  }

  Future<void> registerDemoDeviceToken() async {
    await _post(
      '/notifications/device-token',
      authorized: true,
      body: {
        'token': 'web_demo_token_for_backend_test_123456789',
        'platform': 'android',
      },
    );
  }

  Future<void> _saveSession(AuthSession session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, session.accessToken);
    await prefs.setString(_refreshTokenKey, session.refreshToken);
    await prefs.setString(_phoneNumberKey, session.phoneNumber);
  }

  Future<dynamic> _get(String path, {bool authorized = false}) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(authorized: authorized),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> _post(
    String path, {
    required Map<String, dynamic> body,
    bool authorized = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(authorized: authorized),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<dynamic> _put(
    String path, {
    required Map<String, dynamic> body,
    bool authorized = false,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(authorized: authorized),
      body: jsonEncode(body),
    );
    return _decodeResponse(response);
  }

  Future<Map<String, String>> _headers({required bool authorized}) async {
    final headers = {'Content-Type': 'application/json'};
    if (authorized) {
      final token = await getAccessToken();
      if (token == null) {
        throw const ApiException('Нужно войти в аккаунт.');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic _decodeResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    final decoded = body.isEmpty ? null : jsonDecode(body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded ?? <String, dynamic>{};
    }

    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];
      if (detail is Map<String, dynamic>) {
        throw ApiException(
          detail['message'] as String? ?? 'Ошибка запроса.',
          code: detail['code'] as String?,
          statusCode: response.statusCode,
        );
      }
      if (detail is String) {
        throw ApiException(detail, statusCode: response.statusCode);
      }
    }

    throw ApiException(
      'Ошибка запроса: ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  String _money(double value) => value.toStringAsFixed(2);

  List<Map<String, dynamic>> _budgetCategoriesPayload({
    required double monthlyIncome,
    required List<ExpenseCategory> categories,
  }) {
    final percents = categories
        .map((category) => ((category.budget / monthlyIncome) * 100).round())
        .toList();
    if (percents.isNotEmpty) {
      percents[percents.length - 1] += 100 - percents.reduce((a, b) => a + b);
    }

    return [
      for (var index = 0; index < categories.length; index++)
        {
          'code': categories[index].code,
          'name': categories[index].name,
          'percent': percents[index].clamp(0, 100),
          'kind': categories[index].kind,
        },
    ];
  }
}

double _readMoney(dynamic value) {
  if (value is num) return value.toDouble();
  return double.parse(value.toString());
}
