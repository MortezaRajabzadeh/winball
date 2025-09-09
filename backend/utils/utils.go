package utils

import (
	"bytes"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strconv"
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
	newBets := RemoveUserDemosFromGameBets(gameBets)
	if len(newBets) == 0 {
		return GetOneMinGameResultRandom()
	} else {
		var hasChoosenOneGameResult bool = true
		chooseMultipleHome, _ := isGameBetsIsMultiple(newBets)
		// for _, bet := range newBets {
		// userChoices := bet.UserChoices
		if chooseMultipleHome {
			hasChoosenOneGameResult = false
			// break
		}
		// }
		if hasChoosenOneGameResult {
			randomNumber := GetRandomNumberBetweenMinAndMax(0, 101)
			var userGameBetted string
			bytes, _ := json.Marshal(newBets[0].UserChoices)
			json.Unmarshal(bytes, &userGameBetted)
			userGameBetted = FilterImageStringPath(userGameBetted)
			if strings.ToLower(userGameBetted) == "red" || strings.ToLower(userGameBetted) == "green" || strings.ToLower(userGameBetted) == "purple" {
				if randomNumber <= configs.WIN_RATE {
					userGameBetted = getOneMinGameResultRandomByColor(userGameBetted)
				} else {
					userGameBetted = getOneMinGameResultRandomWithoutColor(userGameBetted)
				}
				return userGameBetted
			} else {
				if randomNumber > configs.WIN_RATE {
					userGameBetted = getOneMinGameResultRandomWithoutColor(userGameBetted)
				}
				return userGameBetted
			}
		} else {
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
					minimumKey = getOneMinGameResultRandomByColor(minimumKey)
				}
				return minimumKey
			}
		}
	}
	return GetOneMinGameResultRandom()
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
	case "red_black_30s":
		{
			return 31
		}
	case "red_black_3m":
		{
			return 181
		}
	case "red_black_5m":
		{
			return 301
		}
	}
	return 61
}
func GetDifferenceBetweenUserAmountAndDepositAmount(depositAmount, userInventoryAmount float64) float64 {
	return depositAmount - userInventoryAmount
}

// Red Black Game specific utility functions
func GetRedBlackGameResult() string {
	var results = []string{"red", "black"}
	randomInt := rand.Intn(len(results))
	return results[randomInt]
}

func GetRedBlackGameResultBaseOnBets(gameBets []models.UserBetModel) string {
	newBets := RemoveUserDemosFromGameBets(gameBets)
	if len(newBets) == 0 {
		return GetRedBlackGameResult()
	}

	// Calculate total amounts for red and black
	var redAmount, blackAmount float64
	for _, bet := range newBets {
		var userChoice string
		bytes, _ := json.Marshal(bet.UserChoices)
		json.Unmarshal(bytes, &userChoice)
		userChoice = FilterImageStringPath(userChoice)
		userChoice = strings.ToLower(strings.TrimSpace(userChoice))

		betAmount, _ := strconv.ParseFloat(bet.Amount, 64)
		switch userChoice {
		case "red":
			redAmount += betAmount
		case "black":
			blackAmount += betAmount
		}
	}

	// Generate random number for house edge
	randomNumber := GetRandomNumberBetweenMinAndMax(0, 101)

	// Apply house edge - favor the color with less betting
	if randomNumber > configs.WIN_RATE {
		// House wins - choose the color with more betting to lose
		if redAmount > blackAmount {
			return "black" // Red loses
		} else if blackAmount > redAmount {
			return "red" // Black loses
		} else {
			// Equal bets - random result
			return GetRedBlackGameResult()
		}
	} else {
		// Players win - choose the color with more betting to win
		if redAmount > blackAmount {
			return "red" // Red wins
		} else if blackAmount > redAmount {
			return "black" // Black wins  
		} else {
			// Equal bets - random result
			return GetRedBlackGameResult()
		}
	}
}

func SendGameResultToTelegram(gameHash string, result string) error {
	botToken := configs.TELEGRAM_BOT_TOKEN
	chatID := configs.TELEGRAM_CHAT_ID
	message := fmt.Sprintf("🔔 پیش‌بینی نتیجه بازی:\nHash: %s\nنتیجه: %s", gameHash, result)

	url := fmt.Sprintf("https://api.telegram.org/bot%s/sendMessage", botToken)
	payload := map[string]interface{}{
		"chat_id":    chatID,
		"text":       message,
		"parse_mode": "HTML",
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	resp, err := http.Post(url, "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	return nil
}
