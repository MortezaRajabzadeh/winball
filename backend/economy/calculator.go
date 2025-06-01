package economy

import (
	"fmt"
	"time"
	
	"github.com/khodehamid/winball_go_back/database"
	"github.com/khodehamid/winball_go_back/logger"
)

var (
	economyCalculatorRunning = false
	globalCachedEconomyManager *CachedEconomyManager
)

// StartEconomyCalculator شروع محاسب اقتصادی پیش‌زمینه
func StartEconomyCalculator() {
	if economyCalculatorRunning {
		fmt.Println("⚠️ Economy Calculator already running")
		return
	}
	
	economyCalculatorRunning = true
	fmt.Println("📊 Starting Economy Calculator background job...")
	
	go func() {
		db, err := database.GetDatabase()
		if err != nil {
			logger.Error("ECONOMY_JOB", "خطا در اتصال به database", err)
			return
		}
		defer db.Close()
		
		globalCachedEconomyManager = NewCachedEconomyManager(db)
		
		// شروع پاکسازی cache
		globalCachedEconomyManager.StartCacheCleanup()
		
		// محاسبه هر 2 دقیقه
		ticker := time.NewTicker(2 * time.Minute)
		defer ticker.Stop()
		
		// محاسبه اولیه
		preCalculateEconomyData()
		
		for range ticker.C {
			preCalculateEconomyData()
		}
	}()
}

// preCalculateEconomyData پیش‌محاسبه داده‌های اقتصادی
func preCalculateEconomyData() {
	if globalCachedEconomyManager == nil {
		return
	}
	
	logger.Info("ECONOMY_JOB", "شروع پیش‌محاسبه داده‌های اقتصادی")
	
	// محاسبه و cache کردن وضعیت‌های مختلف
	periods := []int{1, 7, 30} // روزانه، هفتگی، ماهانه
	
	for _, period := range periods {
		start := time.Now()
		
		profit, err := globalCachedEconomyManager.GetHouseStatusPeriodCached(period)
		if err != nil {
			logger.Error("ECONOMY_JOB", fmt.Sprintf("خطا در محاسبه وضعیت %d روزه", period), err)
			continue
		}
		
		// محاسبه نرخ‌های موثر برای این دوره
		winRate, colorRate := globalCachedEconomyManager.CalculateEffectiveWinRatesOptimized(period)
		
		duration := time.Since(start)
		
		logger.Info("ECONOMY_JOB", fmt.Sprintf("محاسبه %d روزه: سود=%f، نرخ عدد=%d، نرخ رنگ=%d، زمان=%v", 
			period, profit, winRate, colorRate, duration))
	}
	
	logger.Info("ECONOMY_JOB", "پایان پیش‌محاسبه داده‌های اقتصادی")
}

// GetGlobalCachedEconomyManager دریافت Economy Manager کش‌شده
func GetGlobalCachedEconomyManager() *CachedEconomyManager {
	return globalCachedEconomyManager
}

// StopEconomyCalculator متوقف کردن محاسب اقتصادی
func StopEconomyCalculator() {
	economyCalculatorRunning = false
	fmt.Println("🛑 Economy Calculator stopped")
} 