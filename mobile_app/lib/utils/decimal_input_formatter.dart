import 'package:flutter/services.dart';

/// فرمت‌کننده ورودی اعشاری که هم نقطه و هم کاما را به عنوان جداکننده اعشاری می‌پذیرد
/// این کلاس برای حل مشکل ورودی اعشاری در دستگاه‌های iOS با لوکیل‌های مختلف طراحی شده است
class DecimalInputFormatter extends TextInputFormatter {
  final int? maxDigitsAfterDecimal;
  final bool allowNegative;

  DecimalInputFormatter({
    this.maxDigitsAfterDecimal,
    this.allowNegative = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // اگر ورودی خالی باشد، آن را بپذیریم
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // تبدیل کاما به نقطه برای یکپارچه‌سازی پردازش
    String normalizedText = newValue.text.replaceAll(',', '.');
    
    // محاسبه موقعیت جدید مکان‌نما با در نظر گرفتن تغییرات
    int selectionOffset = newValue.selection.end;
    int commasBeforeCursor = newValue.text.substring(0, selectionOffset).split(',').length - 1;
    // تنظیم موقعیت مکان‌نما در صورت تبدیل کاما به نقطه
    selectionOffset = selectionOffset;

    // اگر مقدار منفی مجاز نباشد و کاربر - وارد کرده باشد، آن را حذف کنیم
    if (!allowNegative && normalizedText.startsWith('-')) {
      return oldValue;
    }

    // الگوی regex ساده‌تر برای اعتبارسنجی اعداد اعشاری
    String pattern = allowNegative 
        ? r'^-?\d*\.?\d*$' 
        : r'^\d*\.?\d*$';
    RegExp regex = RegExp(pattern);

    if (!regex.hasMatch(normalizedText)) {
      return oldValue;
    }

    // بررسی شرایط شروع با نقطه (اضافه کردن صفر قبل از نقطه)
    if (normalizedText == '.') {
      normalizedText = '0.';
      selectionOffset++;
    }

    // بررسی محدودیت تعداد ارقام بعد از جداکننده اعشاری
    if (maxDigitsAfterDecimal != null && normalizedText.contains('.')) {
      List<String> parts = normalizedText.split('.');
      if (parts.length == 2 && parts[1].length > maxDigitsAfterDecimal!) {
        // محدود کردن تعداد ارقام اعشاری
        return TextEditingValue(
          text: '${parts[0]}.${parts[1].substring(0, maxDigitsAfterDecimal!)}',
          selection: TextSelection.collapsed(
            offset: min(selectionOffset, parts[0].length + maxDigitsAfterDecimal! + 1),
          ),
        );
      }
    }

    // اگر ورودی با وضعیت قبلی مساوی است اما کاما به نقطه تبدیل شده است
    // موقعیت مکان‌نما را حفظ کنیم
    if (normalizedText != newValue.text) {
      return TextEditingValue(
        text: normalizedText,
        selection: TextSelection.collapsed(offset: selectionOffset),
      );
    }

    return newValue;
  }
  
  // متد کمکی برای محاسبه حداقل بین دو عدد
  int min(int a, int b) => a < b ? a : b;
}

/// مبدل کلیدی که به راحتی استفاده از DecimalInputFormatter را امکان‌پذیر می‌کند
extension DecimalTextInputFormatter on List<TextInputFormatter> {
  /// افزودن فرمت‌کننده اعشاری به لیست فرمت‌کننده‌ها
  List<TextInputFormatter> withDecimal({
    int? maxDigitsAfterDecimal,
    bool allowNegative = false,
  }) {
    add(DecimalInputFormatter(
      maxDigitsAfterDecimal: maxDigitsAfterDecimal,
      allowNegative: allowNegative,
    ));
    return this;
  }
} 