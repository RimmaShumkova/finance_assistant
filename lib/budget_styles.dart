import 'package:flutter/material.dart';

final Color yellow = Color(0xFFFFD700);

// текстовые стили
TextStyle headerTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 36,
  fontWeight: FontWeight.bold,
);

TextStyle subHeaderTextStyle = TextStyle(
  color: Colors.grey[400],
);

TextStyle hintTextStyle = TextStyle(
  color: Colors.grey,
);

TextStyle infoTextStyle = TextStyle(
  color: Colors.grey[500],
  fontSize: 12,
);

TextStyle categoryTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
);

TextStyle percentTextStyle = TextStyle(
  color: Colors.grey,
);

TextStyle amountTextStyle = TextStyle(
  color: Colors.grey[700],
);

TextStyle dialogTitleStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

TextStyle dialogButtonStyle(Color color, {bool bold = false}) => TextStyle(
      color: color,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );

// декорации
BoxDecoration categoryBoxDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
);

BoxDecoration dialogBoxDecoration = BoxDecoration(
  color: Colors.grey[900],
  borderRadius: BorderRadius.circular(20),
);

BoxDecoration textFieldDecoration = BoxDecoration(
  color: Colors.grey[800],
  borderRadius: BorderRadius.circular(12),
);

// кастомный диалог ввода 
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
            width: 280,
            padding: EdgeInsets.all(16),
            decoration: dialogBoxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: dialogTitleStyle),
                SizedBox(height: 12),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixText: suffix,
                    suffixStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Отмена",
                        style: dialogButtonStyle(Colors.grey[400]!),
                      ),
                    ),
                    SizedBox(width: 8),
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
