package economy

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"strings"
	"sync"
	"time"
	
	"github.com/khodehamid/winball_go_back/configs"
	"github.com/khodehamid/winball_go_back/logger"
	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

// EconomyManager مدیریت اقتصاد بازی
type EconomyManager struct {
	DB *sql.DB
	lossStreakCache  map[int]userLossStreakCacheItem
	cacheMutex       sync.RWMutex
}

// ساختار برای نگهداری اطلاعات کش شده رگه‌های باخت
type userLossStreakCacheItem struct {
	Streak    int
	ExpiresAt time.Time
}

// تنظیمات نرخ برد
const (
	// نرخ‌های پایه
	BaseWinRate = 30      // نرخ پایه برد برای اعداد
	BaseColorWinRate = 35 // نرخ پایه برد برای رنگ‌ها

	// کاهش نرخ برد برای انتخاب‌های چندتایی
	MultiChoiceNumberPenalty = 10  // درصد کاهش برای هر انتخاب اضافی در اعداد
	MultiChoiceColorPenalty = 8   // درصد کاهش برای هر انتخاب اضافی در رنگ‌ها

	// حداقل نرخ برد
	MinNumberWinRate = 10   // حداقل نرخ برد برای اعداد
	MinColorWinRate = 15   // حداقل نرخ برد برای رنگ‌ها
)

// NewEconomyManager ایجاد یک نمونه جدید از مدیریت اقتصادی
func NewEconomyManager(db *sql.DB) *EconomyManager {
	return &EconomyManager{
		DB: db,
		lossStreakCache: make(map[int]userLossStreakCacheItem),
	}
}

// GetHouseStatus بررسی وضعیت سود و زیان خانه
func (em *EconomyManager) GetHouseStatus() (float64, error) {
	// محاسبه کل سود/ضرر خانه از مجموع تراکنش‌ها
	var totalProfit float64
	
	// بررسی کل شرط‌های پرداخت شده
	query := "SELECT SUM(CAST(end_game_result AS DECIMAL)) FROM user_bets WHERE bet_status='closed'"
	row := em.DB.QueryRow(query)
	var totalWinnings sql.NullFloat64
	if err := row.Scan(&totalWinnings); err != nil {
		return 0, err
	}
	
	// بررسی کل ورودی‌های کاربران
	query = "SELECT SUM(amount) FROM user_bets"
	row = em.DB.QueryRow(query)
	var totalBets sql.NullFloat64
	if err := row.Scan(&totalBets); err != nil {
		return 0, err
	}
	
	// خانه از شرط‌ها پول دریافت می‌کند و به برندگان پرداخت می‌کند
	if totalBets.Valid && totalWinnings.Valid {
		totalProfit = totalBets.Float64 - totalWinnings.Float64
	}
	
	logger.Info("ECONOMY", fmt.Sprintf("وضعیت خانه: کل شرط‌ها=%f، کل پرداخت‌ها=%f، سود/زیان=%f", 
		totalBets.Float64, totalWinnings.Float64, totalProfit))
	
	return totalProfit, nil
}

// GetHouseStatusPeriod بررسی وضعیت سود و زیان خانه در دوره مشخص
func (em *EconomyManager) GetHouseStatusPeriod(days int) (float64, error) {
	// محاسبه کل سود/ضرر خانه از تراکنش‌های دوره مشخص
	var totalProfit float64
	
	// محاسبه تاریخ شروع دوره
	periodStart := time.Now().AddDate(0, 0, -days).Format("2006-01-02 15:04:05")
	
	// بررسی کل شرط‌های پرداخت شده در دوره
	query := "SELECT SUM(CAST(end_game_result AS DECIMAL)) FROM user_bets WHERE bet_status='closed' AND created_at >= ?"
	row := em.DB.QueryRow(query, periodStart)
	var totalWinnings sql.NullFloat64
	if err := row.Scan(&totalWinnings); err != nil {
		return 0, err
	}
	
	// بررسی کل ورودی‌های کاربران در دوره
	query = "SELECT SUM(amount) FROM user_bets WHERE created_at >= ?"
	row = em.DB.QueryRow(query, periodStart)
	var totalBets sql.NullFloat64
	if err := row.Scan(&totalBets); err != nil {
		return 0, err
	}
	
	// خانه از شرط‌ها پول دریافت می‌کند و به برندگان پرداخت می‌کند
	if totalBets.Valid && totalWinnings.Valid {
		totalProfit = totalBets.Float64 - totalWinnings.Float64
	}
	
	logger.Info("ECONOMY", fmt.Sprintf("وضعیت خانه در %d روز گذشته: کل شرط‌ها=%f، کل پرداخت‌ها=%f، سود/زیان=%f", 
		days, totalBets.Float64, totalWinnings.Float64, totalProfit))
	
	return totalProfit, nil
}

// GetHouseStatusDaily وضعیت خانه در 24 ساعت گذشته
func (em *EconomyManager) GetHouseStatusDaily() (float64, error) {
	return em.GetHouseStatusPeriod(1)
}

// GetHouseStatusWeekly وضعیت خانه در 7 روز گذشته  
func (em *EconomyManager) GetHouseStatusWeekly() (float64, error) {
	return em.GetHouseStatusPeriod(7)
}

// GetHouseStatusMonthly وضعیت خانه در 30 روز گذشته
func (em *EconomyManager) GetHouseStatusMonthly() (float64, error) {
	return em.GetHouseStatusPeriod(30)
}

// CalculateEffectiveWinRates محاسبه نرخ برد مؤثر بر اساس وضعیت خانه
func (em *EconomyManager) CalculateEffectiveWinRates() (int, int) {
	houseStatus, err := em.GetHouseStatus()
	if err != nil {
		logger.Error("ECONOMY", "خطا در محاسبه وضعیت خانه", err)
		return configs.WIN_RATE, configs.COLOR_WIN_RATE
	}
	
	baseWinRate := configs.WIN_RATE
	baseColorWinRate := configs.COLOR_WIN_RATE
	
	if houseStatus > 10000 {
		adjustment := int(houseStatus / 5000)
		if adjustment > 5 {
			adjustment = 5
		}
		
		effectiveRate := baseWinRate + adjustment
		effectiveColorRate := baseColorWinRate + adjustment
		
		logger.Info("ECONOMY", fmt.Sprintf("افزایش نرخ برد - عدد: %d به %d, رنگ: %d به %d (سود خانه=%f)", 
			baseWinRate, effectiveRate, baseColorWinRate, effectiveColorRate, houseStatus))
		
		return effectiveRate, effectiveColorRate
	} 
	
	if houseStatus < -5000 {
		adjustment := int(-houseStatus / 5000)
		if adjustment > 3 {
			adjustment = 3
		}
		
		effectiveRate := baseWinRate - adjustment
		if effectiveRate < MinNumberWinRate {
			effectiveRate = MinNumberWinRate
		}
		
		effectiveColorRate := baseColorWinRate - adjustment
		if effectiveColorRate < MinColorWinRate {
			effectiveColorRate = MinColorWinRate
		}
		
		logger.Info("ECONOMY", fmt.Sprintf("کاهش نرخ برد - عدد: %d به %d, رنگ: %d به %d (زیان خانه=%f)", 
			baseWinRate, effectiveRate, baseColorWinRate, effectiveColorRate, houseStatus))
		
		return effectiveRate, effectiveColorRate
	}
	
	return baseWinRate, baseColorWinRate
}

// CalculateEffectiveWinRatesWithPeriod محاسبه نرخ برد مؤثر بر اساس وضعیت خانه در دوره مشخص
func (em *EconomyManager) CalculateEffectiveWinRatesWithPeriod(periodDays int) (int, int) {
	houseStatus, err := em.GetHouseStatusPeriod(periodDays)
	if err != nil {
		logger.Error("ECONOMY", "خطا در محاسبه وضعیت خانه", err)
		return configs.WIN_RATE, configs.COLOR_WIN_RATE
	}
	
	baseWinRate := configs.WIN_RATE
	baseColorWinRate := configs.COLOR_WIN_RATE
	
	// حدود کمتری برای دوره‌های کوتاه‌تر
	var profitThreshold, lossThreshold float64
	switch {
	case periodDays == 1:  // روزانه
		profitThreshold = 2000  // 2K profit
		lossThreshold = -1000   // 1K loss
	case periodDays == 7:  // هفتگی
		profitThreshold = 10000  // 10K profit  
		lossThreshold = -5000    // 5K loss
	default:               // ماهانه یا بیشتر
		profitThreshold = 30000  // 30K profit
		lossThreshold = -15000   // 15K loss
	}
	
	if houseStatus > profitThreshold {
		adjustment := int(houseStatus / (profitThreshold / 2))
		if adjustment > 5 {
			adjustment = 5
		}
		
		effectiveRate := baseWinRate + adjustment
		effectiveColorRate := baseColorWinRate + adjustment
		
		logger.Info("ECONOMY", fmt.Sprintf("افزایش نرخ برد (%d روزه) - عدد: %d به %d, رنگ: %d به %d (سود خانه=%f)", 
			periodDays, baseWinRate, effectiveRate, baseColorWinRate, effectiveColorRate, houseStatus))
		
		return effectiveRate, effectiveColorRate
	} 
	
	if houseStatus < lossThreshold {
		adjustment := int(-houseStatus / (-lossThreshold / 2))
		if adjustment > 3 {
			adjustment = 3
		}
		
		effectiveRate := baseWinRate - adjustment
		if effectiveRate < MinNumberWinRate {
			effectiveRate = MinNumberWinRate
		}
		
		effectiveColorRate := baseColorWinRate - adjustment
		if effectiveColorRate < MinColorWinRate {
			effectiveColorRate = MinColorWinRate
		}
		
		logger.Info("ECONOMY", fmt.Sprintf("کاهش نرخ برد (%d روزه) - عدد: %d به %d, رنگ: %d به %d (زیان خانه=%f)", 
			periodDays, baseWinRate, effectiveRate, baseColorWinRate, effectiveColorRate, houseStatus))
		
		return effectiveRate, effectiveColorRate
	}
	
	return baseWinRate, baseColorWinRate
}

// تابع کمکی برای استخراج اولین انتخاب از userChoices (آرایه یا رشته)
func extractFirstChoice(userChoices string) string {
	userChoices = strings.TrimSpace(userChoices)
	if strings.HasPrefix(userChoices, "[") {
		var arr []string
		if err := json.Unmarshal([]byte(userChoices), &arr); err == nil && len(arr) > 0 {
			return arr[0]
		}
	}
	return userChoices
}

// DetermineGameResult تعیین نتیجه بازی بر اساس شرط‌ها و اقتصاد بازی
func (em *EconomyManager) DetermineGameResult(gameBets []models.UserBetModel) string {
	logger.Info("ECONOMY_DEBUG", fmt.Sprintf("DetermineGameResult called. gameBets count: %d", len(gameBets)))
	if len(gameBets) == 0 {
		logger.Info("ECONOMY_DEBUG", "No gameBets. Returning random result.")
		return utils.GetOneMinGameResultRandom()
	}

	newBets := utils.RemoveUserDemosFromGameBets(gameBets)
	logger.Info("ECONOMY_DEBUG", fmt.Sprintf("After RemoveUserDemosFromGameBets. newBets count: %d", len(newBets)))
	if len(newBets) == 0 {
		logger.Info("ECONOMY_DEBUG", "No real bets after removing demos. Returning random result.")
		return utils.GetOneMinGameResultRandom()
	}

	// محاسبه نرخ‌های برد موثر با توجه به وضعیت اقتصادی
	effectiveRate, effectiveColorRate := em.CalculateEffectiveWinRatesWithPeriod(configs.ECONOMY_PERIOD_DAYS)
	logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Effective rates (%d-day period): number=%d, color=%d", configs.ECONOMY_PERIOD_DAYS, effectiveRate, effectiveColorRate))
	
	chooseMultipleHome, isColorBet := utils.IsGameBetsIsMultiple(newBets)
	logger.Info("ECONOMY_DEBUG", fmt.Sprintf("chooseMultipleHome=%v, isColorBet=%v", chooseMultipleHome, isColorBet))
	
	// اگر فقط یک انتخاب داریم
	if !chooseMultipleHome {
		randomNumber := utils.GetRandomNumberBetweenMinAndMax(0, 101)
		userGameBetted := utils.FilterImageStringPath(extractFirstChoice(newBets[0].UserChoices))
		logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Single bet. userGameBetted=%s, randomNumber=%d", userGameBetted, randomNumber))
		if strings.ToLower(userGameBetted) == "red" || strings.ToLower(userGameBetted) == "green" || strings.ToLower(userGameBetted) == "purple" {
			if randomNumber <= effectiveColorRate {
				logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Returning userGameBetted=%s (color win)", userGameBetted))
				return userGameBetted
			}
			logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Returning random without color=%s", userGameBetted))
			return utils.GetOneMinGameResultRandomWithoutColor(userGameBetted)
		} else {
			if randomNumber <= effectiveRate {
				logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Returning userGameBetted=%s (number win)", userGameBetted))
				return userGameBetted
			}
			logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Returning random without color=%s", userGameBetted))
			return utils.GetOneMinGameResultRandomWithoutColor(userGameBetted)
		}
	}

	// منطق جدید برای شرط‌های چندتایی
	numChoices := len(newBets)
	var adjustedRate int
	
	if isColorBet {
		adjustedRate = effectiveColorRate - ((numChoices - 1) * MultiChoiceColorPenalty)
		if adjustedRate < MinColorWinRate {
			adjustedRate = MinColorWinRate
		}
	} else {
		adjustedRate = effectiveRate - ((numChoices - 1) * MultiChoiceNumberPenalty)
		if adjustedRate < MinNumberWinRate {
			adjustedRate = MinNumberWinRate
		}
	}

	randomNumber := utils.GetRandomNumberBetweenMinAndMax(0, 101)
	logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Multi bet. adjustedRate=%d, randomNumber=%d", adjustedRate, randomNumber))
	if randomNumber <= adjustedRate {
		// انتخاب تصادفی یکی از شرط‌های کاربر
		winningBet := newBets[utils.GetRandomNumberBetweenMinAndMax(0, len(newBets))]
		result := utils.FilterImageStringPath(extractFirstChoice(winningBet.UserChoices))
		logger.Info("ECONOMY_DEBUG", fmt.Sprintf("Returning winningBet result=%s", result))
		return result
	}

	logger.Info("ECONOMY_DEBUG", "Returning random result (no user bet wins)")
	// اگر نبرد، یک نتیجه تصادفی غیر از انتخاب‌های کاربر برمی‌گردانیم
	return utils.GetOneMinGameResultRandomWithoutUserChoices(newBets)
}

// LogEconomicImpact ثبت تأثیر اقتصادی یک تصمیم
func (em *EconomyManager) LogEconomicImpact(gameId int, result string, playerWon bool, betType string) {
	// ثبت تأثیر اقتصادی در لاگ‌ها
	status := "برد کاربر"
	if !playerWon {
		status = "برد خانه"
	}
	
	// تنها برای لاگ‌های توسعه‌دهنده
	logData := map[string]interface{}{
		"game_id": gameId,
		"result": result,
		"status": status,
		"bet_type": betType,
		"timestamp": time.Now().Format("2006-01-02 15:04:05"),
	}
	logger.Debug("ECONOMY_IMPACT", fmt.Sprintf("بازی %d: نتیجه=%s, وضعیت=%s, نوع شرط=%s, زمان=%s",
		gameId, result, status, betType, time.Now().Format("2006-01-02 15:04:05")), logData)
}

// GetUserLossStreak محاسبه تعداد باخت‌های پشت سر هم کاربر
func (em *EconomyManager) GetUserLossStreak(userId int) int {
	if userId == 0 {
		return 0
	}
	
	// جستجوی آخرین بازی‌های کاربر به ترتیب زمان
	query := `
		SELECT ub.bet_status, ub.end_game_result, ub.amount
		FROM user_bets ub
		WHERE ub.creator_id = ? AND ub.bet_status = 'closed'
		ORDER BY ub.created_at DESC
		LIMIT 10
	`
	
	rows, err := em.DB.Query(query, userId)
	if err != nil {
		logger.Error("ECONOMY", "خطا در بررسی تاریخچه بازی کاربر", err)
		return 0
	}
	defer rows.Close()
	
	streak := 0
	for rows.Next() {
		var status string
		var result sql.NullString
		var amount float64
		
		if err := rows.Scan(&status, &result, &amount); err != nil {
			logger.Error("ECONOMY", "خطا در خواندن تاریخچه بازی", err)
			break
		}
		
		// بررسی نتیجه شرط
		if status == "closed" {
			if !result.Valid || result.String == "0" {
				// باخت
				streak++
			} else {
				// برد - پایان رگه باخت
				break
			}
		}
	}
	
	if streak > 0 {
		logger.Info("ECONOMY", fmt.Sprintf("کاربر %d دارای %d باخت پشت سر هم است", userId, streak))
	}
	
	return streak
}

// GetUserLossStreakWithCache محاسبه تعداد باخت‌های پشت سر هم کاربر با استفاده از کش
func (em *EconomyManager) GetUserLossStreakWithCache(userId int) int {
	if userId == 0 {
		return 0
	}
	
	// ابتدا بررسی کش
	em.cacheMutex.RLock()
	cachedItem, exists := em.lossStreakCache[userId]
	em.cacheMutex.RUnlock()
	
	now := time.Now()
	if exists && cachedItem.ExpiresAt.After(now) {
		logger.Debug("ECONOMY_CACHE", fmt.Sprintf("استفاده از کش برای رگه باخت کاربر %d: %d", userId, cachedItem.Streak), map[string]interface{}{"cached": true, "user_id": userId, "streak": cachedItem.Streak})
		return cachedItem.Streak
	}
	
	// اگر در کش نبود یا منقضی شده بود، محاسبه کنیم
	streak := em.GetUserLossStreak(userId)
	
	// ذخیره در کش
	em.cacheMutex.Lock()
	em.lossStreakCache[userId] = userLossStreakCacheItem{
		Streak:    streak,
		ExpiresAt: now.Add(5 * time.Minute), // کش برای 5 دقیقه
	}
	em.cacheMutex.Unlock()
	
	logger.Debug("ECONOMY_CACHE", fmt.Sprintf("محاسبه و ذخیره در کش رگه باخت کاربر %d: %d", userId, streak), map[string]interface{}{"cached": false, "user_id": userId, "streak": streak})
	
	return streak
}

// CleanExpiredCacheItems پاکسازی آیتم‌های منقضی شده از کش
func (em *EconomyManager) CleanExpiredCacheItems() {
	now := time.Now()
	em.cacheMutex.Lock()
	defer em.cacheMutex.Unlock()
	
	var expiredCount int
	for userId, item := range em.lossStreakCache {
		if item.ExpiresAt.Before(now) {
			delete(em.lossStreakCache, userId)
			expiredCount++
		}
	}
	
	if expiredCount > 0 {
		logger.Debug("ECONOMY_CACHE", fmt.Sprintf("پاکسازی %d آیتم منقضی شده از کش", expiredCount), map[string]interface{}{"expired_count": expiredCount})
	}
} 