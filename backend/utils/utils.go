package utils

import (
	"bytes"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strings"
	"time"

	"github.com/khodehamid/winball_go_back/configs"
	"github.com/khodehamid/winball_go_back/models"
)

const ITEM_PER_PAGE = 50

// this function create 16 random string charactors.
func GetRandomString(randomLen int) string {
	const randomString = "abcdefghjkmnopqrstuvwxyzABCDEFGHJKMNOPQRSTUVWXYZ0123456789"
	random := rand.New(rand.NewSource(time.Now().UnixNano()))
	var result = ""
	for i := 0; i < randomLen; i++ {
		randomNumber := random.Intn(len(randomString))
		result += string(randomString[randomNumber])
	}
	return result
}
func ConvertAnyToString(value any) string {
	return fmt.Sprintf("%v", value)
}
func HandleErrors(w http.ResponseWriter, err error) {
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		w.Write([]byte(err.Error()))
	}
}
func GetOneMinGameResultRandom() string {
	var randomResult = []string{"redPurple0", "green1", "red2", "green3", "red4", "greenPurple5", "red6", "green7", "red8", "green9"}
	randomInt := rand.Intn(len(randomResult))
	return randomResult[randomInt]
}
func RemoveUserDemosFromGameBets(gameBets []models.UserBetModel) []models.UserBetModel {
	var newBets []models.UserBetModel
	for _, bet := range gameBets {
		if bet.Creator.IsDemoAccount == "0" {
			newBets = append(newBets, bet)
		}
	}
	return newBets
}

func isGameBetsIsMultiple(gameBets []models.UserBetModel) (bool, bool) {
	var allGameBets []string
	for _, bet := range gameBets {
		var userGameBetted string
		bytes, _ := json.Marshal(bet.UserChoices)
		json.Unmarshal(bytes, &userGameBetted)
		userGameBetted = FilterImageStringPath(userGameBetted)
		userGameBettedSlice := strings.Split(userGameBetted, ",")
		allGameBets = append(allGameBets, userGameBettedSlice...)
	}
	var betsCount map[string]int = map[string]int{}
	for _, userBet := range allGameBets {
		betsCount[userBet]++
	}
	var choosenOneHouseMultiple bool = false
	for _, v := range betsCount {
		if v > 1 {
			choosenOneHouseMultiple = true
			break
		}
	}
	return len(betsCount) > 1, choosenOneHouseMultiple
}

func GetOneMinModelBaseGameBets(gameBets []models.UserBetModel) string {
	fmt.Printf("\n🎲 GAME_CALCULATION_START: Total bets=%d\n", len(gameBets))
	
	newBets := RemoveUserDemosFromGameBets(gameBets)
	if len(newBets) == 0 {
		result := GetOneMinGameResultRandom()
		fmt.Printf("🎯 NO_REAL_BETS: Random result=%s\n", result)
		LogGameBetAnalysis(gameBets, result)
		return result
	} else {
		var hasChoosenOneGameResult bool = true
		chooseMultipleHome, _ := isGameBetsIsMultiple(newBets)
		
		if chooseMultipleHome {
			hasChoosenOneGameResult = false
		}
		
		if hasChoosenOneGameResult {
			randomNumber := GetRandomNumberBetweenMinAndMax(0, 101)
			var userGameBetted string
			bytes, _ := json.Marshal(newBets[0].UserChoices)
			json.Unmarshal(bytes, &userGameBetted)
			userGameBetted = FilterImageStringPath(userGameBetted)
			
			if strings.ToLower(userGameBetted) == "red" || strings.ToLower(userGameBetted) == "green" || strings.ToLower(userGameBetted) == "purple" {
				fmt.Printf("🌈 COLOR_BET: Choice=%s, Random=%d, ColorWinRate=%d%%\n", userGameBetted, randomNumber, configs.COLOR_WIN_RATE)
				if randomNumber <= configs.COLOR_WIN_RATE {
					result := getOneMinGameResultRandomByColor(userGameBetted)
					fmt.Printf("✅ COLOR_WIN: User chose %s, Result=%s\n", userGameBetted, result)
					LogGameBetAnalysis(gameBets, result)
					return result
				} else {
					result := getOneMinGameResultRandomWithoutColor(userGameBetted)
					fmt.Printf("❌ COLOR_LOSE: User chose %s, Result=%s\n", userGameBetted, result)
					LogGameBetAnalysis(gameBets, result)
					return result
				}
			} else {
				fmt.Printf("🔢 NUMBER_BET: Choice=%s, Random=%d, WinRate=%d%%\n", userGameBetted, randomNumber, configs.WIN_RATE)
				if randomNumber <= configs.WIN_RATE {
					fmt.Printf("✅ NUMBER_WIN: User chose %s, Result=%s\n", userGameBetted, userGameBetted)
					LogGameBetAnalysis(gameBets, userGameBetted)
					return userGameBetted
				} else {
					result := getOneMinGameResultRandomWithoutColor(userGameBetted)
					fmt.Printf("❌ NUMBER_LOSE: User chose %s, Result=%s\n", userGameBetted, result)
					LogGameBetAnalysis(gameBets, result)
					return result
				}
			}
		} else {
			fmt.Printf("🎯 MULTIPLE_BETS: House edge calculation\n")
			// user is selected more that 1 gamebets . here do the sum of the all selected game bets and return the minimum home!
			var gameBetsResultsAmount map[string]float64 = map[string]float64{}
			for _, bet := range newBets {
				var listOfUserBetResult []string
				json.Unmarshal([]byte(bet.UserChoices), &listOfUserBetResult)
				for _, userBetResult := range listOfUserBetResult {
					gameBetsResultsAmount[userBetResult] += float64(bet.Amount) / float64(len(listOfUserBetResult))
				}
			}
			if len(gameBetsResultsAmount) > 0 {
				var firstKey string = ""
				var minimumKey string = ""
				for k := range gameBetsResultsAmount {
					firstKey = k
					break
				}
				minimumAmount := gameBetsResultsAmount[firstKey]
				for k, v := range gameBetsResultsAmount {
					if v <= minimumAmount {
						minimumAmount = v
						minimumKey = k
					}
				}
				
				if minimumKey == "red" || minimumKey == "purple" || minimumKey == "green" {
					result := getOneMinGameResultRandomByColor(minimumKey)
					fmt.Printf("🏆 HOUSE_WINS: Minimum bet was %s (%.2f), Result=%s\n", minimumKey, minimumAmount, result)
					LogGameBetAnalysis(gameBets, result)
					return result
				}
				
				fmt.Printf("🏆 HOUSE_WINS: Minimum bet was %s (%.2f)\n", minimumKey, minimumAmount)
				LogGameBetAnalysis(gameBets, minimumKey)
				return minimumKey
			}
		}
	}
	
	result := GetOneMinGameResultRandom()
	fmt.Printf("🎯 FALLBACK: Random result=%s\n", result)
	LogGameBetAnalysis(gameBets, result)
	return result
}
func getOneMinGameResultRandomByColor(color string) string {
	var randomResult = []string{"redPurple0", "green1", "red2", "green3", "red4", "greenPurple5", "red6", "green7", "red8", "green9"}
	randomInt := rand.Intn(len(randomResult))
	randomColor := randomResult[randomInt]
	for !strings.Contains(strings.ToLower(randomColor), strings.ToLower(color)) {
		randomInt = rand.Intn(len(randomResult))
		randomColor = randomResult[randomInt]
	}
	return randomColor
}
func getOneMinGameResultRandomWithoutColor(color string) string {
	var randomResult = []string{"redPurple0", "green1", "red2", "green3", "red4", "greenPurple5", "red6", "green7", "red8", "green9"}
	randomInt := rand.Intn(len(randomResult))
	randomColor := randomResult[randomInt]
	for strings.Contains(strings.ToLower(randomColor), strings.ToLower(color)) {
		randomInt = rand.Intn(len(randomResult))
		randomColor = randomResult[randomInt]
	}
	return randomColor
}
func HashToSha256(value any) string {
	h := sha256.New()
	h.Write([]byte(ConvertAnyToString(value)))
	bs := h.Sum(nil)
	return fmt.Sprintf("%x", bs)
}
func FilterImageStringPath(imagePath string) string {
	var imagePathFiltered = strings.ReplaceAll(imagePath, "\"", "")
	imagePathFiltered = strings.ReplaceAll(imagePathFiltered, "[", "")
	imagePathFiltered = strings.ReplaceAll(imagePathFiltered, "]", "")
	imagePathFiltered = strings.ReplaceAll(imagePathFiltered, "'", "")
	imagePathFiltered = strings.Trim(imagePathFiltered, " ")
	imagePathFiltered = strings.Trim(imagePathFiltered, "\n")
	imagePathFiltered = strings.Trim(imagePathFiltered, "\r\n")
	return imagePathFiltered
}

// this function will create the random between [min,max)
func GetRandomNumberBetweenMinAndMax(min, max int) int {
	random := rand.New(rand.NewSource(time.Now().UnixMicro()))
	return random.Intn(max-min) + min
}
func GetGameDiffByGameType(gameType string) int {
	switch gameType {
	case "one_min_game":
		{
			return 61
		}
	case "three_min_game":
		{
			return 181
		}
	case "five_min_game":
		{
			return 301
		}
	}
	return 61
}
func GetDifferenceBetweenUserAmountAndDepositAmount(depositAmount, userInventoryAmount float64) float64 {
	return depositAmount - userInventoryAmount
}

// SendGameResultToTelegram ارسال نتیجه بازی به تلگرام
func SendGameResultToTelegram(gameHash string, result string) error {
	fmt.Printf("🔔 GAME_RESULT: Hash=%s, Result=%s\n", gameHash, result)
	
	botToken := configs.TELEGRAM_BOT_TOKEN
	chatID := configs.TELEGRAM_CHAT_ID
	
	if botToken == "" || chatID == "" {
		fmt.Println("⚠️ TELEGRAM: Bot token یا chat ID تنظیم نشده")
		return nil
	}
	
	message := fmt.Sprintf("🔔 پیش‌بینی نتیجه بازی:\nHash: %s\nنتیجه: %s", gameHash, result)
	
	url := fmt.Sprintf("https://api.telegram.org/bot%s/sendMessage", botToken)
	payload := map[string]interface{}{
		"chat_id": chatID,
		"text": message,
		"parse_mode": "HTML",
	}
	
	jsonData, err := json.Marshal(payload)
	if err != nil {
		fmt.Printf("❌ TELEGRAM_ERROR: Marshal error: %v\n", err)
		return err
	}
	
	fmt.Printf("📤 TELEGRAM: Sending to %s\n", url)
	resp, err := http.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		fmt.Printf("❌ TELEGRAM_ERROR: HTTP error: %v\n", err)
		return err
	}
	defer resp.Body.Close()
	
	fmt.Printf("✅ TELEGRAM: Response status: %s\n", resp.Status)
	return nil
}

// LogGameBetAnalysis لاگ تحلیل شرط‌بندی‌ها
func LogGameBetAnalysis(gameBets []models.UserBetModel, result string) {
	fmt.Printf("\n🎲 GAME_ANALYSIS: Total Bets=%d\n", len(gameBets))
	
	realBets := RemoveUserDemosFromGameBets(gameBets)
	fmt.Printf("👤 REAL_BETS: Count=%d (after removing demos)\n", len(realBets))
	
	if len(realBets) == 0 {
		fmt.Printf("🎯 DECISION: Random result (no real bets)\n")
		fmt.Printf("🏆 FINAL_RESULT: %s\n\n", result)
		return
	}
	
	chooseMultiple, _ := isGameBetsIsMultiple(realBets)
	fmt.Printf("🎮 BET_TYPE: Multiple=%v\n", chooseMultiple)
	
	if !chooseMultiple && len(realBets) > 0 {
		// فقط یک انتخاب
		var userGameBetted string
		bytes, _ := json.Marshal(realBets[0].UserChoices)
		json.Unmarshal(bytes, &userGameBetted)
		userGameBetted = FilterImageStringPath(userGameBetted)
		
		isColor := strings.ToLower(userGameBetted) == "red" || strings.ToLower(userGameBetted) == "green" || strings.ToLower(userGameBetted) == "purple"
		winRate := configs.WIN_RATE
		if isColor {
			winRate = configs.COLOR_WIN_RATE
		}
		
		fmt.Printf("🎯 SINGLE_BET: Choice=%s, IsColor=%v, WinRate=%d%%\n", userGameBetted, isColor, winRate)
	} else {
		// چندین انتخاب - محاسبه مجموع مبلغ هر گزینه
		var gameBetsResultsAmount map[string]float64 = map[string]float64{}
		for _, bet := range realBets {
			var listOfUserBetResult []string
			json.Unmarshal([]byte(bet.UserChoices), &listOfUserBetResult)
			for _, userBetResult := range listOfUserBetResult {
				gameBetsResultsAmount[userBetResult] += float64(bet.Amount) / float64(len(listOfUserBetResult))
			}
		}
		
		fmt.Printf("💰 MULTIPLE_BETS: Amounts per choice:\n")
		var minAmount float64 = -1
		var minKey string
		for choice, amount := range gameBetsResultsAmount {
			fmt.Printf("   %s: %.2f\n", choice, amount)
			if minAmount == -1 || amount < minAmount {
				minAmount = amount
				minKey = choice
			}
		}
		fmt.Printf("🎯 MINIMUM_AMOUNT: %s (%.2f) - This will WIN\n", minKey, minAmount)
	}
	
	fmt.Printf("🏆 FINAL_RESULT: %s\n\n", result)
}