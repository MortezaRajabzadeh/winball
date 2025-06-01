package logger

import (
	"io"
	"os"
	"path/filepath"

	"github.com/khodehamid/winball_go_back/configs"
	"github.com/natefinch/lumberjack"
	"github.com/sirupsen/logrus"
)

var log = logrus.New()

// Init راه‌اندازی سیستم لاگینگ
func Init() error {
	// تنظیم فرمت با اطلاعات مفید
	log.SetFormatter(&logrus.JSONFormatter{
		TimestampFormat: "2006-01-02 15:04:05",
	})

	// تنظیم سطح لاگینگ
	logLevel, err := logrus.ParseLevel(configs.LOG_LEVEL)
	if err != nil {
		logLevel = logrus.InfoLevel
	}
	log.SetLevel(logLevel)

	// اطمینان از وجود دایرکتوری لاگ
	if err := os.MkdirAll(configs.LOG_DIR, 0755); err != nil {
		return err
	}

	// تنظیم چرخش لاگ‌ها
	lumberjackLogger := &lumberjack.Logger{
		Filename:   filepath.Join(configs.LOG_DIR, "app.log"),
		MaxSize:    configs.MAX_LOG_SIZE_MB,
		MaxBackups: configs.MAX_LOG_FILES,
		MaxAge:     configs.LOG_RETENTION_DAYS,
		Compress:   true,
	}
	
	// ارسال به کنسول و فایل
	mw := io.MultiWriter(os.Stdout, lumberjackLogger)
	log.SetOutput(mw)
	
	return nil
}

// توابع کمکی برای لاگینگ
func Info(module string, message string) {
	log.WithField("module", module).Info(message)
}

// InfoWithData لاگ اطلاعات با داده‌های اضافی
func InfoWithData(module string, message string, data map[string]interface{}) {
	fields := logrus.Fields{
		"module": module,
	}
	for k, v := range data {
		fields[k] = v
	}
	log.WithFields(fields).Info(message)
}

func Error(module string, message string, err error) {
	log.WithFields(logrus.Fields{
		"module": module,
		"error":  err,
	}).Error(message)
}

func Warn(module string, message string) {
	log.WithField("module", module).Warn(message)
}

func Debug(module string, message string, data map[string]interface{}) {
	fields := logrus.Fields{
		"module": module,
	}
	for k, v := range data {
		fields[k] = v
	}
	log.WithFields(fields).Debug(message)
} 