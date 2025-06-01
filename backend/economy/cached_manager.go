package economy

import (
	"database/sql"
	"strings"
	"sync"
	"time"
	
	"github.com/khodehamid/winball_go_back/logger"
	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

// CachedEconomyManager نسخه بهینه‌شده برای تعداد کاربر بالا
type CachedEconomyManager struct {
	*EconomyManager
	
	// Cache برای محاسبات اقتصادی
	houseStatusCache  map[int]cachedHouseStatus // key = period days
	cacheMutex        sync.RWMutex
	lastCacheUpdate   time.Time
	
	// تنظیمات cache
	cacheTimeout      time.Duration
}

type cachedHouseStatus struct {
	ProfitLoss float64
	ExpiresAt  time.Time
}

// NewCachedEconomyManager ایجاد Economy Manager بهینه‌شده
func NewCachedEconomyManager(db *sql.DB) *CachedEconomyManager {
	return &CachedEconomyManager{
		EconomyManager:   NewEconomyManager(db),
		houseStatusCache: make(map[int]cachedHouseStatus),
		cacheTimeout:     2 * time.Minute, // Cache برای 2 دقیقه
	}
}

// GetHouseStatusPeriodCached محاسبه سود/زیان با cache
func (cem *CachedEconomyManager) GetHouseStatusPeriodCached(days int) (float64, error) {
	// بررسی cache
	cem.cacheMutex.RLock()
	cached, exists := cem.houseStatusCache[days]
	cem.cacheMutex.RUnlock()
	
	now := time.Now()
	if exists && cached.ExpiresAt.After(now) {
		logger.Debug("ECONOMY_CACHE", "استفاده از cache برای وضعیت خانه", map[string]interface{}{
			"period_days": days,
			"cached_result": cached.ProfitLoss,
		})
		return cached.ProfitLoss, nil
	}
	
	// محاسبه جدید
	result, err := cem.EconomyManager.GetHouseStatusPeriod(days)
	if err != nil {
		return result, err
	}
	
	// ذخیره در cache
	cem.cacheMutex.Lock()
	cem.houseStatusCache[days] = cachedHouseStatus{
		ProfitLoss: result,
		ExpiresAt:  now.Add(cem.cacheTimeout),
	}
	cem.cacheMutex.Unlock()
	
	logger.Debug("ECONOMY_CACHE", "محاسبه جدید و ذخیره در cache", map[string]interface{}{
		"period_days": days,
		"result": result,
		"cache_timeout": cem.cacheTimeout,
	})
	
	return result, nil
}

// CalculateEffectiveWinRatesOptimized محاسبه بهینه‌شده نرخ برد
func (cem *CachedEconomyManager) CalculateEffectiveWinRatesOptimized(periodDays int) (int, int) {
	houseStatus, err := cem.GetHouseStatusPeriodCached(periodDays)
	if err != nil {
		logger.Error("ECONOMY", "خطا در محاسبه وضعیت خانه", err)
		return 10, 30 // مقادیر پیش‌فرض
	}
	
	// استفاده از منطق موجود
	return cem.calculateRatesFromStatus(houseStatus, periodDays)
}

// calculateRatesFromStatus محاسبه نرخ از وضعیت
func (cem *CachedEconomyManager) calculateRatesFromStatus(houseStatus float64, periodDays int) (int, int) {
	baseWinRate := 10
	baseColorWinRate := 30
	
	var profitThreshold, lossThreshold float64
	switch {
	case periodDays == 1:
		profitThreshold = 2000
		lossThreshold = -1000
	case periodDays == 7:
		profitThreshold = 10000
		lossThreshold = -5000
	default:
		profitThreshold = 30000
		lossThreshold = -15000
	}
	
	if houseStatus > profitThreshold {
		adjustment := int(houseStatus / (profitThreshold / 2))
		if adjustment > 5 {
			adjustment = 5
		}
		return baseWinRate + adjustment, baseColorWinRate + adjustment
	}
	
	if houseStatus < lossThreshold {
		adjustment := int(-houseStatus / (-lossThreshold / 2))
		if adjustment > 3 {
			adjustment = 3
		}
		
		effectiveRate := baseWinRate - adjustment
		if effectiveRate < 10 {
			effectiveRate = 10
		}
		
		effectiveColorRate := baseColorWinRate - adjustment
		if effectiveColorRate < 15 {
			effectiveColorRate = 15
		}
		
		return effectiveRate, effectiveColorRate
	}
	
	return baseWinRate, baseColorWinRate
}

// DetermineGameResultOptimized تعیین نتیجه بهینه‌شده
func (cem *CachedEconomyManager) DetermineGameResultOptimized(gameBets []models.UserBetModel, periodDays int) string {
	if len(gameBets) == 0 {
		return cem.EconomyManager.getOneMinGameResultRandomWithoutUserChoices([]models.UserBetModel{})
	}

	// استفاده از cache برای محاسبه نرخ‌ها
	effectiveRate, effectiveColorRate := cem.CalculateEffectiveWinRatesOptimized(periodDays)
	
	// باقی منطق مشابه EconomyManager اصلی
	newBets := removeUserDemosFromGameBets(gameBets)
	if len(newBets) == 0 {
		return cem.EconomyManager.getOneMinGameResultRandomWithoutUserChoices([]models.UserBetModel{})
	}
	
	chooseMultipleHome, isColorBet := cem.EconomyManager.isGameBetsIsMultiple(newBets)
	
	if !chooseMultipleHome {
		randomNumber := getRandomNumberBetweenMinAndMax(0, 101)
		userGameBetted := filterImageStringPath(extractFirstChoice(newBets[0].UserChoices))
		
		if isColorChoice(userGameBetted) {
			if randomNumber <= effectiveColorRate {
				return userGameBetted
			}
			return cem.EconomyManager.getOneMinGameResultRandomWithoutColor(userGameBetted)
		} else {
			if randomNumber <= effectiveRate {
				return userGameBetted
			}
			return cem.EconomyManager.getOneMinGameResultRandomWithoutColor(userGameBetted)
		}
	}
	
	// منطق شرط‌های چندتایی
	numChoices := len(newBets)
	var adjustedRate int
	
	if isColorBet {
		adjustedRate = effectiveColorRate - ((numChoices - 1) * 8)
		if adjustedRate < 15 {
			adjustedRate = 15
		}
	} else {
		adjustedRate = effectiveRate - ((numChoices - 1) * 10)
		if adjustedRate < 10 {
			adjustedRate = 10
		}
	}

	randomNumber := getRandomNumberBetweenMinAndMax(0, 101)
	if randomNumber <= adjustedRate {
		winningBet := newBets[getRandomNumberBetweenMinAndMax(0, len(newBets))]
		return filterImageStringPath(extractFirstChoice(winningBet.UserChoices))
	}

	return cem.EconomyManager.getOneMinGameResultRandomWithoutUserChoices(newBets)
}

// CleanExpiredEconomyCache پاکسازی cache منقضی شده
func (cem *CachedEconomyManager) CleanExpiredEconomyCache() {
	now := time.Now()
	cem.cacheMutex.Lock()
	defer cem.cacheMutex.Unlock()
	
	var expiredCount int
	for period, cached := range cem.houseStatusCache {
		if cached.ExpiresAt.Before(now) {
			delete(cem.houseStatusCache, period)
			expiredCount++
		}
	}
	
	if expiredCount > 0 {
		logger.Debug("ECONOMY_CACHE", "پاکسازی cache اقتصادی", map[string]interface{}{
			"expired_count": expiredCount,
		})
	}
}

// StartCacheCleanup شروع job پاکسازی cache
func (cem *CachedEconomyManager) StartCacheCleanup() {
	// پاکسازی loss streak cache
	cem.EconomyManager.StartCacheCleanupJob()
	
	// پاکسازی economy cache
	go func() {
		ticker := time.NewTicker(5 * time.Minute)
		defer ticker.Stop()
		
		for range ticker.C {
			cem.CleanExpiredEconomyCache()
		}
	}()
}

// توابع کمکی
func isColorChoice(choice string) bool {
	choice = strings.ToLower(choice)
	return choice == "red" || choice == "green" || choice == "purple"
}

// باقی توابع کمکی که در utils هستند اما اینجا نیاز داریم
func removeUserDemosFromGameBets(gameBets []models.UserBetModel) []models.UserBetModel {
	return utils.RemoveUserDemosFromGameBets(gameBets)
}

func getRandomNumberBetweenMinAndMax(min, max int) int {
	return utils.GetRandomNumberBetweenMinAndMax(min, max)
}

func filterImageStringPath(s string) string {
	return utils.FilterImageStringPath(s)
} 