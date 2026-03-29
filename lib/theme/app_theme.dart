import 'package:flutter/material.dart';

class AppTheme {
  // ==================== ОСНОВНЫЕ ЦВЕТА ====================
  static const Color black = Color(0xFF111111);
  static const Color blackCard = Color(0xFF1C1C1E);
  static const Color blackSecondary = Color(0xFF2C2C2E);
  static const Color blackLighter = Color(0xFF282828);
  static const Color yellow = Color(0xFFFDB913);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF8E8E93);
  static const Color greyLight = Color(0xFFC6C6C8);
  static const Color green = Color(0xFF34C759);
  static const Color red = Color(0xFFFF3B30);
  
  static Color get yellowLight => yellow.withOpacity(0.1);
  static Color get yellowBorder => yellow.withOpacity(0.5);
  static Color get greenLight => green.withOpacity(0.15);
  static Color get redLight => red.withOpacity(0.15);
  
  // ==================== ТЕКСТОВЫЕ СТИЛИ ====================
  static const TextStyle titleLarge = TextStyle(
    color: white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle titleMedium = TextStyle(
    color: white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle titleSmall = TextStyle(
    color: white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    color: white,
    fontSize: 36,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    color: white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    color: white,
    fontSize: 16,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    color: greyLight,
    fontSize: 14,
  );
  
  static const TextStyle bodySmall = TextStyle(
    color: grey,
    fontSize: 12,
  );
  
  static const TextStyle bodyXSmall = TextStyle(
    color: grey,
    fontSize: 11,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle accentText = TextStyle(
    color: yellow,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle statLabel = TextStyle(
    color: grey,
    fontSize: 12,
  );
  
  static const TextStyle statValue = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  
  // ==================== СТИЛИ ДЛЯ APP BAR ====================
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: black,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: white),
    iconTheme: IconThemeData(color: white),
  );
  
  static const TextStyle appBarTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: white,
    fontSize: 18,
  );
  
  static const TextStyle appBarMonthStyle = TextStyle(
    fontSize: 16,
    color: yellow,
    fontWeight: FontWeight.w500,
  );
  
  // ==================== СТИЛИ ДЛЯ ПОЛЕЙ ВВОДА ====================
  static InputDecoration inputDecoration({
    String? hintText,
    String? suffixText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium,
      suffixText: suffixText,
      suffixStyle: const TextStyle(color: white, fontWeight: FontWeight.bold),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: blackCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
  
  static InputDecoration otpInputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: blackCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(12),
    );
  }
  
  // ==================== СТИЛИ КНОПОК ====================
  static ButtonStyle get yellowButtonLarge => ElevatedButton.styleFrom(
    backgroundColor: yellow,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: buttonLarge,
  );

  static ButtonStyle get yellowButtonMedium => ElevatedButton.styleFrom(
    backgroundColor: yellow,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: buttonSmall,
  );

  static ButtonStyle get yellowButtonSmall => ElevatedButton.styleFrom(
    backgroundColor: yellow,
    foregroundColor: Colors.black,
    padding: const EdgeInsets.symmetric(vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: buttonSmall,
  );

  static ButtonStyle get outlinedButton => ElevatedButton.styleFrom(
    backgroundColor: blackCard,
    foregroundColor: white,
    elevation: 0,
    side: BorderSide(color: yellowBorder, width: 1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    padding: const EdgeInsets.symmetric(vertical: 20),
    textStyle: buttonSmall,
  );

  static ButtonStyle get retryButton => ElevatedButton.styleFrom(
    backgroundColor: yellow,
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
  
  // ==================== СТИЛИ ДЛЯ SNACKBAR ====================
  static SnackBar successSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: blackCard,
      behavior: SnackBarBehavior.floating,
    );
  }
  
  static SnackBar errorSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: red,
      behavior: SnackBarBehavior.floating,
    );
  }
  
  // ==================== ПРОГРЕСС ====================
  static Widget get smallProgress => SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
      strokeWidth: 2,
      valueColor: AlwaysStoppedAnimation<Color>(black.withOpacity(0.7)),
    ),
  );

  static Widget get mediumProgress => SizedBox(
    height: 30,
    width: 30,
    child: const CircularProgressIndicator(
      strokeWidth: 2,
      color: yellow,
    ),
  );
  // ==================== ДЕКОРАЦИИ ====================
  static BoxDecoration cardDecoration({
    double radius = 16,
    Color? color,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? blackCard,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: withShadow ? [
        const BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
      ] : null,
    );
  }
  
  static BoxDecoration get gradientCard => BoxDecoration(
    gradient: LinearGradient(
      colors: [blackCard, blackSecondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: yellowBorder, width: 1),
  );
  
  static BoxDecoration get iconCircle => BoxDecoration(
    color: yellowLight,
    shape: BoxShape.circle,
  );
  
  static BoxDecoration statusBadge({required bool isSuccess}) {
    return BoxDecoration(
      color: isSuccess ? greenLight : redLight,
      borderRadius: BorderRadius.circular(12),
    );
  }
  
  static BoxDecoration get darkContainer => const BoxDecoration(
    color: Color(0xFF282828),
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  );
  
  // ==================== ТЕКСТ ДЛЯ СТАТИСТИКИ ====================
  static Widget buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: statLabel),
        const SizedBox(height: 4),
        Text(value, style: statValue.copyWith(color: color)),
      ],
    );
  }
  
  // ==================== ДИАЛОГ ====================
  static Future<double?> showCustomInputDialog({
    required BuildContext context,
    required String title,
    required String initialValue,
    required String suffix,
  }) async {
    final controller = TextEditingController(text: initialValue);
    
    return showGeneralDialog<double>(
      context: context,
      barrierLabel: "Input",
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: cardDecoration(radius: 20, color: const Color(0xFF121212)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: titleSmall),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    style: const TextStyle(color: white, fontSize: 16),
                    decoration: inputDecoration(suffixText: suffix),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Отмена", style: TextStyle(color: grey)),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            double.tryParse(controller.text.replaceAll(',', '.')) ?? 0,
                          );
                        },
                        child: const Text("ОК", style: TextStyle(color: yellow, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: child,
        );
      },
    );
  }
  
  // ==================== ТЕМА ДЛЯ MATERIAL APP ====================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      primaryColor: yellow,
      colorScheme: const ColorScheme.dark(
        primary: yellow,
        secondary: yellow,
        surface: blackCard,
        background: black,
        error: red,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: white,
        onBackground: white,
      ),
      appBarTheme: appBarTheme,
      cardTheme: CardThemeData(
        color: blackCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: yellow,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blackCard,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        hintStyle: bodyMedium,
      ),
    );
  }
}
