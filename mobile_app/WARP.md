# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## نمای کلی پروژه

این پروژه یک اپلیکیشن Flutter است که بات تلگرام WinBall را پیاده‌سازی می‌کند - یک پلتفرم بازی کازینو آنلاین که انواع بازی‌های شرط‌بندی ارائه می‌دهد. اپلیکیشن به عنوان Mini App تلگرام عمل می‌کند و برای دسکتاپ محدودیت دارد.

## دستورات رایج توسعه

### راه‌اندازی اولیه
```bash
# نصب dependencies
flutter pub get

# اجرای code generation برای models
dart run build_runner build

# اجرای با watch mode
dart run build_runner watch --delete-conflicting-outputs
```

### ساخت و دیپلوی
```bash
# ساخت برای وب (PWA غیرفعال)
flutter build web --pwa-strategy=none

# تست اپلیکیشن
flutter test

# بررسی کد و lint
flutter analyze

# فرمت کردن کد
dart format .
```

### اجرای اپلیکیشن
```bash
# اجرای در حالت توسعه
flutter run -d web-server

# اجرای با پورت مشخص
flutter run -d web-server --web-port=3000
```

## ساختار معماری

### ساختار اصلی
```
lib/
├── bloc/                   # مدیریت state با BLoC pattern
│   ├── app_bloc/          # BLoC اصلی اپلیکیشن
│   └── authentication_bloc/
├── configs/               # پیکربندی‌های اصلی اپ
├── models/               # مدل‌های داده
├── screens/              # صفحات اپلیکیشن
├── widgets/              # widget های قابل استفاده مجدد
├── utils/                # utility functions
└── main.dart            # نقطه ورود برنامه

packages/                # کتابخانه‌های محلی
├── *_repository/        # Repository pattern برای data layer
└── database_repository_functions/
```

### الگوی معماری
- **State Management**: BLoC pattern (flutter_bloc)
- **Data Layer**: Repository pattern با packages جداگانه
- **Navigation**: Named routes با MaterialApp
- **Platform Detection**: تشخیص و محدودسازی دسکتاپ

### Repository Packages
پروژه از Repository pattern استفاده می‌کند با packages جداگانه:
- `user_repository` - مدیریت کاربران
- `one_min_game_repository` - بازی‌های یک دقیقه‌ای
- `transaction_repository` - تراکنش‌های مالی
- `network_repository` - ارتباط با API
- `database_repository_functions` - عملیات پایگاه داده

## تنظیمات مهم

### Bot Configuration
فایل `lib/configs/app_configs.dart` حاوی تنظیمات اصلی:
- `botUsername`: نام کاربری بات تلگرام
- `casinoWalletAddress`: آدرس کیف پول کازینو
- Supported cryptocurrencies (فعلاً فقط TON)

### پلتفرم محدودیت‌ها
- اپلیکیشن برای دسکتاپ محدود شده است
- برای دسکتاپ QR code نمایش داده می‌شود
- فقط بر روی موبایل کامل عمل می‌کند

## Game Types
انواع بازی‌های پشتیبانی شده:
- Red & Green (1min, 3min, 5min)
- Red & Black (30s, 3min, 5min)

## دیپلوی
پس از build، فایل‌های خروجی در `build/web/` باید به `/var/www/winball.xyz` سرور منتقل شوند.

## Dependencies مهم
- `telegram_web_app`: ادغام با Telegram Mini Apps
- `flutter_bloc`: مدیریت state
- `web_socket_channel`: ارتباط real-time
- `qr_flutter`: تولید QR code
- `cached_network_image`: مدیریت تصاویر
- `firebase_*`: آنالیتیکس و performance monitoring
