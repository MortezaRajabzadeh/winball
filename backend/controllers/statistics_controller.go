package controllers

import (
	"database/sql"
	"strconv"

	"github.com/khodehamid/winball_go_back/models"
)

func GetSiteStatistics(db *sql.DB) (models.StatisticsModel, error) {
	usersCountString := GetUsersCount(db)
	if usersCountString == "" {
		usersCountString = "0"
	}
	usersCount, err := strconv.Atoi(usersCountString)
	outgoingTonAmountPerDay := GetTransactionsAmountPerConditions("withdraw", "ton", 1, db)
	outgoingTonAmountPerMonth := GetTransactionsAmountPerConditions("withdraw", "ton", 30, db)
	outgoingTonAmountPerYear := GetTransactionsAmountPerConditions("withdraw", "ton", 365, db)
	incomeTonAmountPerDay := GetTransactionsAmountPerConditions("deposit", "ton", 1, db)
	incomeTonAmountPerMonth := GetTransactionsAmountPerConditions("deposit", "ton", 30, db)
	incomeTonAmountPerYear := GetTransactionsAmountPerConditions("deposit", "ton", 365, db)
	outgoingStarsAmountPerDay := GetTransactionsAmountPerConditions("withdraw", "stars", 1, db)
	outgoingStarsAmountPerMonth := GetTransactionsAmountPerConditions("withdraw", "stars", 30, db)
	outgoingStarsAmountPerYear := GetTransactionsAmountPerConditions("withdraw", "stars", 365, db)
	incomeStarsAmountPerDay := GetTransactionsAmountPerConditions("deposit", "stars", 1, db)
	incomeStarsAmountPerMonth := GetTransactionsAmountPerConditions("deposit", "stars", 30, db)
	incomeStarsAmountPerYear := GetTransactionsAmountPerConditions("deposit", "stars", 365, db)

	return models.StatisticsModel{UsersCount: usersCount, OutgoingTonAmountPerDay: outgoingTonAmountPerDay, IncomeTonAmountPerDay: incomeTonAmountPerDay, OutgoingTonAmountPerMonth: outgoingTonAmountPerMonth, IncomeTonAmountPerMonth: incomeTonAmountPerMonth, OutgoingTonAmountPerYear: outgoingTonAmountPerYear, IncomeTonAmountPerYear: incomeTonAmountPerYear, WinnerCount: GetWinnerCount(db), LosersCount: GetLosersCount(db), OutgoingStarsAmountPerDay: outgoingStarsAmountPerDay, IncomeStarsAmountPerDay: incomeStarsAmountPerDay, OutgoingStarsAmountPerMonth: outgoingStarsAmountPerMonth, IncomeStarsAmountPerMonth: incomeStarsAmountPerMonth, OutgoingStarsAmountPerYear: outgoingStarsAmountPerYear, IncomeStarsAmountPerYear: incomeStarsAmountPerYear}, err
}
