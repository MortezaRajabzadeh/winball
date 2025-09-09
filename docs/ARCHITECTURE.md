# راهنمای یکپارچه معماری و قوانین توسعه – winBall

این سند «منبع واحد حقیقت» است و جایگزین تمامی راهنماهای تکراری قبلی می‌شود. هر تغییر مهم باید فقط در این فایل اعمال شود.

## 1) نمای کلی و اصول
- **ماهیت**: Telegram Web App برای بازی‌های زمان‌دار (۱/۳/۵ دقیقه)
- **پشته**: Frontend=Flutter (M3/Dark), Backend=Go (Monolith + MVC), DB=MySQL, Realtime=WebSocket, Chain=TON
- **الگوها**: Frontend=BLoC + Repository Pattern + ماژولار؛ Backend=Controllers/Models/Routes/Services/Utils/Middleware

## 2) قرارداد واحد مبلغ و تبدیل‌ها
- واحد مرجع ذخیره‌سازی کیف‌پول: nanoTON = TON × 1,000,000,000 (TonBaseFactor)
- ثابت‌ها: `TonBaseFactor=1_000_000_000` (در Go: `configs.TonBaseFactor`, در Flutter: `AppConfigs.tonBaseFactor`)
- نمایش در UI: به TON با دو رقم اعشار
- قراردادهای پایگاه‌داده و API:
  - `users.ton_inventory`: nanoTON (BIGINT/DECIMAL(20,0))
  - `user_bets.amount`: TON (DECIMAL(10,3)) – فرانت مقدار TON می‌فرستد، بک‌اند برای محاسبات به nanoTON تبدیل می‌کند
  - `withdraws.amount`: nanoTON – فرانت برای برداشت، مقدار TON × TonBaseFactor ارسال می‌کند
  - `transactions.amount`: TON – برای گزارش‌گیری و خوانایی
- قواعد گرد کردن:
  - ورودی کاربر (TON): حداکثر ۳ رقم اعشار، روی ۳ رقم validate شود
  - نمایش UI: 2 رقم اعشار؛ تاریخچه شرط: 3 رقم
- قوانین اعتبارسنجی مبلغ:
  - حداقل شرط: 0.01 TON
  - حداقل برداشت: مطابق `site_settings.min_withdraw_amount` (TON)
  - نسبت Stars↔TON: `TonToStarsCount = 1000`

## 3) بازی و Real-time
- پیام‌های وب‌سوکت (Server→Client):
  - `GAME_CREATED`: { game_type, id, each_game_unique_number, seconds }
  - `GAME_UPDATED`: { id, game_type, game_result, seconds }
- پنجره مجاز ثبت شرط: تا 15 ثانیه مانده به نتیجه (client-side و server-side enforce)
- حلقه بازی (خلاصه): ایجاد بازی → Broadcast → Sleep(duration) → محاسبه نتیجه → تسویه موجودی‌ها → Broadcast نتیجه
- ضرایب نتایج (نمونه):
  - «رنگ ساده»: red=1.95, green=1.95, purple=4.49
  - «رقمی»: redPurple0/green1/.../green9 = 9.75
- اقتصاد: `WIN_RATE=40%`, `COLOR_WIN_RATE=30%`؛ مالک تغییر: تیم اقتصاد. هر تغییر باید ADR داشته باشد.

## 4) امنیت و احراز هویت
- JWT الزامی برای همه Endpointهای محافظت‌شده (Bearer <token>)
- طول عمر توکن: 24h (پیشنهادی) + قابلیت Refresh (در صورت نیاز پروژه)
- Rate Limiting (الزامی):
  - POST `/bets`: 10 req/min per IP
  - POST `/withdraws`: 3 req/min per User و per IP (هر دو)
  - `/auth/*`: 5 req/min per IP
  - WebSocket: حداکثر 3 اتصال همزمان per IP، cooldown اتصال مجدد: 5s
- ورودی‌ها: همه ورودی‌ها با Prepared Statements (DB) و Validation سمت سرور (مبالغ، آدرس کیف پول، الگوها) بررسی شوند.
- لاگ‌گیری: Structured (Info/Error/Debug) + Correlation-ID در درخواست‌ها
- خطاهای بحرانی: اطلاع‌رسانی از طریق Telegram Bot به ادمین‌ها

## 5) داده و پایگاه‌داده
- انواع عددی برای مبالغ: از `VARCHAR` به `DECIMAL/BIGINT` مهاجرت کنید (در اسکیماهای جدید الزام)
- ایدمپوتنسی تراکنش‌ها: `transactions.transaction_id` یکتا؛ درخواست‌های پرداخت/برداشت باید idempotent باشند
- شاخص‌ها: روی ستون‌های `creator_id`, `game_id`, `transaction_id` ایندکس ایجاد شود

## 6) Frontend (Flutter)
- BLoC اجباری برای صفحات/کامپوننت‌های پیچیده؛ ساختار پوشه‌ها به‌صورت feature-based
- Repository Pattern برای هر feature (user_repository, transaction_repository, ...)
- Dark Theme (Material 3)؛ تشخیص پلتفرم و نمایش QR در دسکتاپ برای هدایت به موبایل
- قوانین تبدیل مبلغ: استفاده از `AppConfigs.tonBaseFactor`؛ پرداخت TONKeeper با nanoTON؛ نمایش با TON

## 7) Backend (Go)
- Monolith + MVC؛ لایه‌ها واضح و وابستگی‌ها کنترل‌شده باشند
- Middleware: JWT Validation + Rate Limiter + Logging
- Services/Jobs: عملیات زنجیره TON و پردازش‌های سنگین به‌صورت Job-based با Retry/Backoff
- Realtime: WebSocket Broadcaster با payloadهای مستند شده بالا

## 8) تست، انتشار، محیط‌ها
- تست‌ها: واحد (Economy, Conversion), یکپارچه (CRUD+WS), e2e (واریز/شرط/نتیجه/برداشت)
- Build وب Flutter:
  - `flutter build web --release --web-renderer canvaskit`
  - دیپلوی به `/var/www/winball.xyz` (Production)
- محیط‌ها: DEV/QA/PROD با `.env.example` شامل: DB, WS_URL, BOT_TOKEN, SUPABASE_*

## 9) Governance & ADR
- هر تصمیم معماری کلیدی (واحد مبلغ، نرخ‌ها، WS schema، سیاست کارمزد) باید یک ADR در `docs/adr/*` داشته باشد
- PR Template با چک‌لیست: امنیت، شِما، مستندات، تست‌ها

## 10) بهینه‌سازی و مدیریت قوانین (Rule Optimization)
- حذف قوانین/سیاست‌های تکراری، اولویت‌بندی تغییرات: Critical/High/Medium/Low (الهام‌گرفته از راهنمای PMD)
- دوره‌ای: مرور Hit Count قوانین، تشخیص تعارض قوانین بالادستی (الهام‌گرفته از Cisco Rule Optimization)

### منابع بیرونی
- Cisco Secure Firewall – Rule Optimization: [secure.cisco.com](https://secure.cisco.com/secure-firewall/v7.0/docs/rule-optimization)
- PMD – Rule Guidelines (اولویت‌بندی قوانین): [pmd.github.io](https://pmd.github.io/pmd/pmd_userdocs_extending_rule_guidelines.html)
- Optimal decision (تصمیم بهینه): [Wikipedia](https://en.wikipedia.org/wiki/Optimal_decision) 