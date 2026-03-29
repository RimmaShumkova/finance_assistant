import 'package:flutter/material.dart';

final Color yellow = Color(0xFFFFD700);
final Color blackBackground = Color(0xFF121212);
final Color darkGreyCard = Color(0xFF1E1E1E);
final Color greyText = Color(0xFFB0B0B0);
final Color lightGreyText = Color(0xFFDDDDDD);

// Текстовые стили
TextStyle headerTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 36,
  fontWeight: FontWeight.bold,
  letterSpacing: 0.5,
);

TextStyle subHeaderTextStyle = TextStyle(
  color: greyText,
  fontSize: 16,
);

TextStyle hintTextStyle = TextStyle(
  color: greyText,
  fontSize: 14,
);

TextStyle infoTextStyle = TextStyle(
  color: greyText,
  fontSize: 12,
);

TextStyle categoryTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: lightGreyText,
  fontSize: 16,
);

TextStyle percentTextStyle = TextStyle(
  color: greyText,
  fontSize: 14,
);

TextStyle amountTextStyle = TextStyle(
  color: greyText,
  fontSize: 14,
);

TextStyle dialogTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

TextStyle dialogButtonStyle(Color color, {bool bold = false}) => TextStyle(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: 14,
    );

// Декорации
BoxDecoration categoryBoxDecoration = BoxDecoration(
  color: darkGreyCard,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 6,
      offset: Offset(0, 3),
    ),
  ],
);

BoxDecoration dialogBoxDecoration = BoxDecoration(
  color: blackBackground,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: Colors.black38,
      blurRadius: 10,
      offset: Offset(0, 5),
    ),
  ],
);

BoxDecoration textFieldDecoration = BoxDecoration(
  color: Color(0xFF1C1C1C),
  borderRadius: BorderRadius.circular(12),
);

// Кастомный диалог ввода
Future<double?> showCustomInputDialog({
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
    transitionDuration: Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            padding: EdgeInsets.all(20),
            decoration: dialogBoxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: dialogTitleStyle),
                SizedBox(height: 16),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1C1C1C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixText: suffix,
                    suffixStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Отмена",
                        style: dialogButtonStyle(greyText),
                      ),
                    ),
                    SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                            context,
                            double.tryParse(
                                    controller.text.replaceAll(',', '.')) ??
                                0);
                      },
                      child: Text(
                        "ОК",
                        style: dialogButtonStyle(yellow, bold: true),
                      ),
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

// Стили для слайдера
SliderThemeData sliderTheme = SliderThemeData(
  activeTrackColor: yellow,
  inactiveTrackColor: Colors.grey[800],
  thumbColor: yellow,
  overlayColor: yellow.withOpacity(0.2),
  trackHeight: 6,
  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
  overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
);
