import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final Color yellow = const Color(0xFFFFD700);
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool _isValidPhone(String phone) {
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 10;
  }

  String _formatPhoneNumber(String value) {
    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (digits.isEmpty) return '';
    
    if (digits.length > 0 && (digits[0] == '7' || digits[0] == '8')) {
      digits = digits.substring(1);
    }
    
    String result = '+7';
    
    if (digits.length > 0) {
      result += ' (${digits.substring(0, digits.length > 3 ? 3 : digits.length)}';
    }
    
    if (digits.length >= 4) {
      result += ') ${digits.substring(3, digits.length > 6 ? 6 : digits.length)}';
    }
    
    if (digits.length >= 7) {
      result += '-${digits.substring(6, digits.length > 8 ? 8 : digits.length)}';
    }
    
    if (digits.length >= 9) {
      result += '-${digits.substring(8, digits.length > 10 ? 10 : digits.length)}';
    }
    
    return result;
  }

  void _sendCode() {
    if (!_isValidPhone(_phoneController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный номер телефона')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
      
      Navigator.pushReplacementNamed(
        context,
        '/otp-verification',
        arguments: _phoneController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              const Text(
                'Вход в аккаунт',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Введите номер телефона для входа или регистрации',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '+7 (___) ___-__-__',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Icon(Icons.phone, color: Colors.grey[400]),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _phoneController.value = TextEditingValue(
                        text: _formatPhoneNumber(value),
                        selection: TextSelection.collapsed(
                          offset: _formatPhoneNumber(value).length,
                        ),
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: yellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isLoading ? null : _sendCode,
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black.withOpacity(0.7),
                            ),
                          ),
                        )
                      : const Text(
                          'Получить код',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Нажимая «Получить код», вы соглашаетесь\nс условиями обработки данных',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}