package configs

// تنظیمات لاگینگ
const (
	// مسیر ذخیره‌سازی لاگ‌ها
	LOG_DIR = "logs"

	// تنظیمات فایل‌های لاگ
	MAX_LOG_SIZE_MB    = 50 * 1024 * 1024  // 50MB
	MAX_LOG_FILES      = 30                 // حداکثر تعداد فایل‌های لاگ
	LOG_RETENTION_DAYS = 30                 // مدت نگهداری لاگ‌ها (روز)
	LOG_CLEANUP_HOUR   = 3                  // ساعت پاکسازی خودکار (3 صبح)
	LOG_FILE_PREFIX    = "winball"          // پیشوند فایل‌های لاگ
	LOG_TIME_FORMAT    = "2006-01-02 15:04:05.000"  // فرمت زمان در لاگ‌ها

	// فعال/غیرفعال کردن انواع لاگ
	ENABLE_DEBUG_LOGS   = true
	ENABLE_INFO_LOGS    = true
	ENABLE_WARNING_LOGS = true
	ENABLE_ERROR_LOGS   = true
	ENABLE_GAME_LOGS    = true
	ENABLE_BET_LOGS     = true
	ENABLE_USER_LOGS    = true
	ENABLE_PAYMENT_LOGS = true
) 