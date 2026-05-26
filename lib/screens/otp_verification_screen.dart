import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/push_notification_service.dart';
import '../theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  int _timerSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_timerSeconds > 0) {
            _timerSeconds--;
            _startTimer();
          } else {
            _canResend = true;
          }
        });
      }
    });
  }

  Future<void> _resendCode() async {
    final String? phoneNumber =
        ModalRoute.of(context)?.settings.arguments as String?;
    if (phoneNumber == null) return;
    setState(() {
      _isLoading = true;
      _timerSeconds = 60;
      _canResend = false;
    });
    try {
      await _apiService.resendVerificationCode(phoneNumber);
      if (!mounted) return;
      setState(() => _isLoading = false);
      _startTimer();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppTheme.successSnackBar('Код отправлен повторно'));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _canResend = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppTheme.errorSnackBar(error.toString()));
    }
  }

  Future<void> _verifyCode() async {
    final String? phoneNumber =
        ModalRoute.of(context)?.settings.arguments as String?;
    String code = _otpControllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppTheme.errorSnackBar('Введите код из 6 цифр'));
      return;
    }
    if (phoneNumber == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppTheme.errorSnackBar('Номер телефона не найден'));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _apiService.verifyCode(phoneNumber: phoneNumber, code: code);
      try {
        await PushNotificationService.instance.registerCurrentDevice();
      } catch (error) {
        debugPrint('Failed to register push token: $error');
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(AppTheme.errorSnackBar(error.toString()));
    }
  }

  @override
  void dispose() {
    for (var c in _otpControllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String? phoneNumber =
        ModalRoute.of(context)?.settings.arguments as String?;
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
              const Text('Подтверждение', style: AppTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Введите код из SMS, отправленный на номер',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                phoneNumber ?? '+7 (___) ___-__-__',
                style: AppTheme.accentText,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 50,
                    height: 70,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: AppTheme.otpInputDecoration(),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5)
                          _focusNodes[index + 1].requestFocus();
                        if (value.isEmpty && index > 0)
                          _focusNodes[index - 1].requestFocus();
                        if (index == 5 && value.isNotEmpty) _verifyCode();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    if (!_canResend)
                      Text(
                        'Отправить код повторно через $_timerSeconds сек',
                        style: AppTheme.bodySmall,
                      ),
                    if (_canResend)
                      TextButton(
                        onPressed: _resendCode,
                        child: const Text(
                          'Отправить код повторно',
                          style: AppTheme.accentText,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppTheme.yellowButtonLarge,
                  onPressed: _verifyCode,
                  child: _isLoading
                      ? AppTheme.smallProgress
                      : const Text('Подтвердить', style: AppTheme.buttonLarge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
