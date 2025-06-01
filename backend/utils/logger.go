package utils

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"time"
)

var (
	infoLogger    *log.Logger
	errorLogger   *log.Logger
	warningLogger *log.Logger
	debugLogger   *log.Logger
)

// انواع مختلف لاگ
const (
	LOG_INFO    = "INFO"
	LOG_ERROR   = "ERROR"
	LOG_WARNING = "WARNING"
	LOG_DEBUG   = "DEBUG"
)

// ساختار لاگ
type LogEntry struct {
	Timestamp time.Time
	Level     string
	Function  string
	Message   string
	Data      map[string]interface{}
}

// InitLogger راه‌اندازی سیستم لاگینگ
func InitLogger(logDir string, maxSizeMB int, maxFiles int, retentionDays int) error {
	// ایجاد دایرکتوری لاگ اگر وجود ندارد
	if err := os.MkdirAll(logDir, 0755); err != nil {
		return fmt.Errorf("failed to create log directory: %v", err)
	}

	// ایجاد فایل‌های لاگ
	currentTime := time.Now().Format("2006-01-02")
	logFile := filepath.Join(logDir, fmt.Sprintf("app_%s.log", currentTime))
	file, err := os.OpenFile(logFile, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0666)
	if err != nil {
		return fmt.Errorf("failed to open log file: %v", err)
	}

	// تنظیم لاگرها
	infoLogger = log.New(file, "INFO: ", log.Ldate|log.Ltime)
	errorLogger = log.New(file, "ERROR: ", log.Ldate|log.Ltime)
	warningLogger = log.New(file, "WARNING: ", log.Ldate|log.Ltime)
	debugLogger = log.New(file, "DEBUG: ", log.Ldate|log.Ltime)

	return nil
}

// CloseLogger بستن فایل‌های لاگ
func CloseLogger() {
	// اینجا می‌توانیم کدهای مربوط به بستن فایل‌های لاگ را اضافه کنیم
}

// LogInfo ثبت لاگ اطلاعاتی
func LogInfo(context string, message string) {
	if infoLogger != nil {
		infoLogger.Printf("[%s] %s", context, message)
	}
}

// LogError ثبت لاگ خطا
func LogError(context string, message string, err error) {
	if errorLogger != nil {
		errorLogger.Printf("[%s] %s: %v", context, message, err)
	}
}

// LogWarning ثبت لاگ هشدار
func LogWarning(context string, message string) {
	if warningLogger != nil {
		warningLogger.Printf("[%s] %s", context, message)
	}
}

// LogDebug ثبت لاگ دیباگ
func LogDebug(context string, message string) {
	if debugLogger != nil {
		debugLogger.Printf("[%s] %s", context, message)
	}
}

// LogWithDetails ثبت لاگ با جزئیات
func LogWithDetails(context string, message string, details map[string]interface{}) {
	if infoLogger != nil {
		infoLogger.Printf("[%s] %s | Details: %+v", context, message, details)
	}
}

// لاگ کردن با جزئیات
func LogWithDetailsOld(level string, message string, data map[string]interface{}) {
	entry := LogEntry{
		Timestamp: time.Now(),
		Level:     level,
		Function:  GetFunctionName(2),
		Message:   message,
		Data:      data,
	}

	// تبدیل دیتا به JSON برای نمایش بهتر
	dataJSON, _ := json.Marshal(entry.Data)
	
	// فرمت پیام لاگ
	logMessage := fmt.Sprintf("[%s][%s][%s] %s | Data: %s",
		entry.Timestamp.Format("2006-01-02 15:04:05"),
		entry.Level,
		entry.Function,
		entry.Message,
		string(dataJSON),
	)

	// نمایش در کنسول
	fmt.Println(logMessage)

	// ذخیره در فایل
	logToFile(logMessage)
}

// لاگ اطلاعات
func LogInfoOld(message string, data map[string]interface{}) {
	LogWithDetailsOld(LOG_INFO, message, data)
}

// لاگ خطا
func LogErrorOld(message string, err error, data map[string]interface{}) {
	if data == nil {
		data = make(map[string]interface{})
	}
	data["error"] = err.Error()
	LogWithDetailsOld(LOG_ERROR, message, data)
}

// لاگ هشدار
func LogWarningOld(message string, data map[string]interface{}) {
	LogWithDetailsOld(LOG_WARNING, message, data)
}

// لاگ دیباگ
func LogDebugOld(message string, data map[string]interface{}) {
	LogWithDetailsOld(LOG_DEBUG, message, data)
}

// ذخیره لاگ در فایل
func logToFile(message string) {
	// ساخت نام فایل بر اساس تاریخ
	fileName := fmt.Sprintf("logs/winball_%s.log", time.Now().Format("2006-01-02"))
	
	// اطمینان از وجود دایرکتوری logs
	if err := os.MkdirAll("logs", 0755); err != nil {
		fmt.Printf("Error creating logs directory: %v\n", err)
		return
	}
	
	// باز کردن فایل در حالت append
	f, err := os.OpenFile(fileName, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		fmt.Printf("Error opening log file: %v\n", err)
		return
	}
	defer f.Close()
	
	// نوشتن در فایل
	if _, err := f.WriteString(message + "\n"); err != nil {
		fmt.Printf("Error writing to log file: %v\n", err)
	}
}

// دریافت نام تابع فراخواننده
func GetFunctionName(skip int) string {
	pc, _, _, ok := runtime.Caller(skip)
	if !ok {
		return "unknown"
	}
	return runtime.FuncForPC(pc).Name()
} 