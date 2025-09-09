package controllers

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/khodehamid/winball_go_back/configs"
	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

func getUserBetsByConditions(query string, db *sql.DB, args ...any) ([]models.UserBetModel, error) {
	var userBets []models.UserBetModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var userBet models.UserBetModel
			if err = rows.Scan(&userBet.Id, &userBet.GameId, &userBet.UserChoices, &userBet.EndGameResult, &userBet.BetStatus, &userBet.CreatorId, &userBet.Amount, &userBet.CoinType, &userBet.CreatedAt, &userBet.UpdatedAt); err != nil {
				return userBets, err
			}
			userBet.Game, _ = GetOneMinGameWithId(userBet.GameId, db)
			userBet.Creator, _ = GetUserWithId(userBet.CreatorId, db)
			userBets = append(userBets, userBet)
		}
	}
	return userBets, err
}
func CreateUserBet(gameId, creatorId int, userChoices, amount, coinType string, db *sql.DB) (models.UserBetModel, error) {
	userBets, err := getUserBetsByStatus(creatorId, "open", db)
	if err == nil && len(userBets) == 0 {
		user, err := GetUserWithId(creatorId, db)
		if err == nil {
			var userInventory float64
			switch coinType {
			case "ton":
				{
					userInventory, _ = strconv.ParseFloat(user.TonInventory, 32)
				}
			case "stars":
				{
					userInventory, _ = strconv.ParseFloat(user.StarsInventory, 32)
				}
			case "usdt":
				{
					userInventory, _ = strconv.ParseFloat(user.UsdtInventory, 32)
				}
			case "btc":
				{
					userInventory, _ = strconv.ParseFloat(user.BtcInventory, 32)
				}
			case "cusd":
				{
					userInventory, _ = strconv.ParseFloat(user.CusdInventory, 32)
				}
			}
			amountFloat, err := strconv.ParseFloat(amount, 32)
			//TODO this works only for ton
			userInventory -= (amountFloat * configs.TonBaseFactor)
			if userInventory < 0 {
				if userInventory >= -3000 {
					userInventory = 0
				}
			}

			if err == nil && userInventory >= 0 {
				// if userInventory >= amountFloat {
				query := "INSERT INTO user_bets (game_id,user_choices,creator_id,amount,coin_type) VALUES (?,?,?,?,?)"
				result, err := db.Exec(query, gameId, userChoices, creatorId, amount, coinType)
				if err == nil {
					switch coinType {
					case "ton":
						{
							// DoReferalThings(user, amountFloat*configs.TonBaseFactor, "ton", db)
							// userInventory -= (amountFloat * configs.TonBaseFactor)
							user.TonInventory = utils.ConvertAnyToString(userInventory)
						}
					case "stars":
						{
							// userInventory -= amountFloat
							user.StarsInventory = utils.ConvertAnyToString(userInventory)
						}
					case "usdt":
						{
							// userInventory -= amountFloat
							user.UsdtInventory = utils.ConvertAnyToString(userInventory)
						}
					case "btc":
						{
							// userInventory -= amountFloat
							user.BtcInventory = utils.ConvertAnyToString(userInventory)
						}
					case "cusd":
						{
							// userInventory -= amountFloat
							user.CusdInventory = utils.ConvertAnyToString(userInventory)
						}
					}
					user.Save(db)
				}
				if err == nil {
					lastInsertedId, _ := result.LastInsertId()
					return GetUserBetById(int(lastInsertedId), db)
				}
				// } else {
				// 	return models.UserBetModel{}, errors.New("your wallet doesn't support this amount of bet  please deposit into your account")
				// }
			} else {
				fmt.Println(userInventory)
				if err != nil {
					fmt.Println(err.Error())
				}
				fmt.Println(userInventory)
				return models.UserBetModel{}, errors.New("your inventory is less than this amount")
			}
		}
	} else if len(userBets) > 0 {
		return models.UserBetModel{}, errors.New("you have an open bet . you cannot create another one")
	}

	return models.UserBetModel{}, err

}
func GetUserBets(userId int, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE creator_id=?"
	return getUserBetsByConditions(query, db, userId)
}
func GetUserBetsByGameId(gameId, userId int, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE game_id=? AND creator_id=?"
	return getUserBetsByConditions(query, db, gameId, userId)
}
func GetTwoLastUserBets(creatorId int, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE creator_id=? ORDER BY created_at DESC LIMIT 2"
	return getUserBetsByConditions(query, db, creatorId)
}
func GetUserBetById(betId int, db *sql.DB) (models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE id=?"
	userBets, err := getUserBetsByConditions(query, db, betId)
	if err == nil && len(userBets) > 0 {
		return userBets[0], err
	}
	return models.UserBetModel{}, err
}
func GetBetsByGameId(gameId int, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE game_id=? AND bet_status=?"
	return getUserBetsByConditions(query, db, gameId, "open")
}
func isUserBetIsValidByTheRules(userChoices []string) bool {
	var colorPicked int = 0
	for _, bet := range userChoices {
		if bet == "red" || bet == "green" || bet == "purple" {
			colorPicked++
		}
	}
	return colorPicked <= 1 && len(userChoices)-colorPicked <= 5
}
func CalculateUserBetEndGameResult(gameHash string, db *sql.DB) {
	var userBetChoices []string
	games, err := GetGameWithGameHash(gameHash, db)
	if err == nil && len(games) > 0 {
		game := games[0]
		userBets, err := GetBetsByGameId(game.Id, db)
		if err == nil && len(userBets) > 0 {
			for _, bet := range userBets {
				var betTotalAmount float32 = 0.0
				json.Unmarshal([]byte(bet.UserChoices), &userBetChoices)
				if isUserBetIsValidByTheRules(userBetChoices) {
					unitAmount := bet.Amount / float32(len(userBetChoices))
					for _, userChoice := range userBetChoices {
						if userChoice != "" {
							if userChoice == game.GameResult.String {
								fmt.Println(userChoice)
								// this user was winner
								betTotalAmount += (unitAmount * configs.GameResultPossibilities[userChoice])
							} else if strings.Contains(strings.ToLower(game.GameResult.String), strings.ToLower(userChoice)) {
								betTotalAmount += (unitAmount * configs.GameResultPossibilities[userChoice])
							}
						}
					}
					bet.BetStatus = "closed"
					bet.EndGameResult.String = utils.ConvertAnyToString(betTotalAmount)
					bet.Save(db)
					var userInventory float64
					switch bet.CoinType {
					case "ton":
						{
							userInventory, err = strconv.ParseFloat(bet.Creator.TonInventory, 32)
						}
					case "stars":
						{
							userInventory, err = strconv.ParseFloat(bet.Creator.StarsInventory, 32)
						}
					case "usdt":
						{
							userInventory, err = strconv.ParseFloat(bet.Creator.UsdtInventory, 32)
						}
					case "btc":
						{
							userInventory, err = strconv.ParseFloat(bet.Creator.BtcInventory, 32)
						}
					case "cusd":
						{
							userInventory, err = strconv.ParseFloat(bet.Creator.CusdInventory, 32)
						}
					}
					if err == nil {
						if bet.CoinType == "ton" {
							userInventory += float64(betTotalAmount * configs.TonBaseFactor)
						} else {
							userInventory += float64(betTotalAmount)
						}
					}
					switch bet.CoinType {
					case "ton":
						{
							bet.Creator.TonInventory = utils.ConvertAnyToString(userInventory)
						}
					case "stars":
						{
							bet.Creator.StarsInventory = utils.ConvertAnyToString(userInventory)
						}
					case "usdt":
						{
							bet.Creator.UsdtInventory = utils.ConvertAnyToString(userInventory)
						}
					case "btc":
						{
							bet.Creator.BtcInventory = utils.ConvertAnyToString(userInventory)
						}
					case "cusd":
						{
							bet.Creator.CusdInventory = utils.ConvertAnyToString(userInventory)
						}
					}
					if betTotalAmount == 0 {
						DoReferalThings(bet.Creator, float64(bet.Amount)*configs.TonBaseFactor, "ton", db)
					}
					bet.Creator.Save(db)
				} else {
					bet.EndGameResult.String = utils.ConvertAnyToString(betTotalAmount)
					if betTotalAmount == 0 {
						DoReferalThings(bet.Creator, float64(bet.Amount)*configs.TonBaseFactor, "ton", db)
					}
					bet.BetStatus = "closed"
					bet.Save(db)
				}
			}
		}
	}
}
func getUserBetsByStatus(userId int, status string, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE bet_status=? AND creator_id=?"
	return getUserBetsByConditions(query, db, status, userId)
}
func getUserBetsByStatusAndCoinType(userId int, status, coinType string, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE bet_status=? AND creator_id=? AND coin_type=?"
	return getUserBetsByConditions(query, db, status, userId, coinType)
}
func GetUserBetsPerPage(userId, page int, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE creator_id=? ORDER BY created_at DESC LIMIT ? OFFSET ?"
	return getUserBetsByConditions(query, db, userId, utils.ITEM_PER_PAGE, (page-1)*utils.ITEM_PER_PAGE)
}
func GetLosersCount(db *sql.DB) int {
	query := "SELECT COUNT(*) FROM user_bets WHERE end_game_result=0 AND bet_status=?"
	var losersCount int
	rows, err := db.Query(query, "closed")
	if err == nil {
		for rows.Next() {
			if err = rows.Scan(&losersCount); err != nil {
				fmt.Println(err)
				return losersCount
			}
		}
	}
	return losersCount
}
func GetWinnerCount(db *sql.DB) int {
	query := "SELECT COUNT(*) FROM user_bets WHERE end_game_result>0 AND bet_status=?"
	var losersCount int
	rows, err := db.Query(query, "closed")
	if err == nil {
		for rows.Next() {
			if err = rows.Scan(&losersCount); err != nil {
				return losersCount
			}
		}
	}
	return losersCount
}
func GetUserBetsCount(userId int, db *sql.DB) int {
	query := "SELECT COUNT(*) FROM user_bets WHERE creator_id=?"
	var userBetCount int
	rows, err := db.Query(query, userId)
	if err == nil {
		for rows.Next() {
			if err = rows.Scan(&userBetCount); err != nil {
				return userBetCount
			}
		}
	}
	return userBetCount
}
func GetUserTotalWins(userId int, db *sql.DB) int {
	query := "SELECT COUNT(*) FROM user_bets WHERE end_game_result>0 AND creator_id=?"
	var totalWins int
	rows, err := db.Query(query, userId)
	if err == nil {
		for rows.Next() {
			if err = rows.Scan(&totalWins); err != nil {
				return totalWins
			}
		}
	}
	return totalWins
}
func GetWithdrawableAmount(coinType string, userId int, db *sql.DB) float32 {
	var totalAmount float32 = 0
	bets, err := getUserBetsByStatusAndCoinType(userId, "closed", coinType, db)
	if err == nil && len(bets) > 0 {
		for _, bet := range bets {
			totalAmount += bet.Amount
		}
	}
	wholeDepositAmount := GetSumOfTheTransactionsByTransactionTypeAndUserId("deposit", userId, db)
	if err == nil {
		totalAmount = float32(wholeDepositAmount/configs.TonBaseFactor) - totalAmount
	}
	if totalAmount < 0 {
		totalAmount = 0
	}
	return totalAmount
}
func GetAllUserBetsByGameId(gameId int, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE game_id=?"
	return getUserBetsByConditions(query, db, gameId)
}
func GetOpenUserBetsByGameId(gameId int, db *sql.DB) ([]models.UserBetModel, error) {
	query := "SELECT * FROM user_bets WHERE game_id=? AND bet_status=?"
	return getUserBetsByConditions(query, db, gameId, "open")
}
