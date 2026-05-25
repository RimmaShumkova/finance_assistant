import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool _isValidPhone(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '').length >= 10;

  String _formatPhoneNumber(String value) {
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    if (digits[0] == '7' || digits[0] == '8') digits = digits.substring(1);
    String result = '+7';
    if (digits.isNotEmpty)
      result +=
          ' (${digits.substring(0, digits.length > 3 ? 3 : digits.length)}';
    if (digits.length >= 4)
      result +=
          ') ${digits.substring(3, digits.length > 6 ? 6 : digits.length)}';
    if (digits.length >= 7)
      result +=
          '-${digits.substring(6, digits.length > 8 ? 8 : digits.length)}';
    if (digits.length >= 9)
      result +=
          '-${digits.substring(8, digits.length > 10 ? 10 : digits.length)}';
    return result;
  }

  Future<void> _sendCode() async {
    if (!_isValidPhone(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppTheme.errorSnackBar('Введите корректный номер телефона'),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _apiService.register(_phoneController.text);
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(
        context,
        '/otp-verification',
        arguments: _phoneController.text,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppTheme.errorSnackBar(error.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Вход в аккаунт', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Введите номер телефона для входа или регистрации',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              Container(
                decoration: AppTheme.cardDecoration(
                  radius: 16,
                  withShadow: false,
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppTheme.white, fontSize: 18),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: AppTheme.inputDecoration(
                    hintText: '+7 (___) ___-__-__',
                    prefixIcon: Icon(Icons.phone, color: AppTheme.grey),
                  ),
                  onChanged: (value) => setState(() {
                    _phoneController.value = TextEditingValue(
                      text: _formatPhoneNumber(value),
                      selection: TextSelection.collapsed(
                        offset: _formatPhoneNumber(value).length,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppTheme.yellowButtonLarge,
                  onPressed: _sendCode,
                  child: _isLoading
                      ? AppTheme.smallProgress
                      : const Text('Получить код', style: AppTheme.buttonLarge),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Нажимая «Получить код», вы соглашаетесь\nс условиями обработки данных',
                  textAlign: TextAlign.center,
                  style: AppTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
