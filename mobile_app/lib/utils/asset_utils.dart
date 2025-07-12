import 'package:flutter/services.dart';

class AssetUtils {
  /// بارگیری تصاویر اسلایدر از پوشه assets/images/slider
  static Future<List<String>> getSliderImages() async {
    try {
      // لیست ثابت تصاویر اسلایدر با نام‌های مرتب شده و فرمت JPEG
      final List<String> sliderImages = [
        'assets/images/slider/slider1.jpeg',
        'assets/images/slider/slider2.jpeg',
        'assets/images/slider/slider3.jpeg',
        'assets/images/slider/slider4.jpeg',
        'assets/images/slider/slider5.jpeg',
        'assets/images/slider/slider6.jpeg',
        'assets/images/slider/slider7.jpeg',
        'assets/images/slider/slider8.jpeg',
        'assets/images/slider/slider9.jpeg',
        'assets/images/slider/slider10.jpeg',
        'assets/images/slider/slider11.jpeg',
        'assets/images/slider/slider12.jpeg',
      ];
      
      return sliderImages;
    } catch (e) {
      // در صورت خطا، لیست فالبک را برگردان
      return [
        'assets/images/slider/slider1.jpeg',
        'assets/images/slider/slider2.jpeg',
        'assets/images/slider/slider3.jpeg',
        'assets/images/slider/slider4.jpeg',
      ];
    }
  }
}
