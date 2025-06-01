-- جدول جدید برای ذخیره آخرین LT پردازش شده از بلاکچین
CREATE TABLE `blockchain_tracking` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `wallet_address` varchar(255) NOT NULL UNIQUE,
  `last_processed_lt` varchar(255) NOT NULL DEFAULT '0',
  `last_processed_hash` varchar(255),
  `created_at` datetime DEFAULT (now()),
  `updated_at` datetime DEFAULT (now())
);

-- وارد کردن رکورد پیش‌فرض برای کیف پول کازینو
-- توجه: 'YOUR_CASINO_WALLET_ADDRESS' را با آدرس واقعی کیف پول کازینو جایگزین کنید
-- INSERT INTO `blockchain_tracking` (`wallet_address`, `last_processed_lt`, `last_processed_hash`) 
-- VALUES ('YOUR_CASINO_WALLET_ADDRESS', '0', ''); 