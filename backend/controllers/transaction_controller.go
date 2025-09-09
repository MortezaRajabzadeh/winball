package controllers

import (
	"database/sql"
	"fmt"
	"strconv"
	"time"

	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

func getTransactionsWithConditions(query string, db *sql.DB, args ...any) ([]models.TransactionModel, error) {
	var transactions []models.TransactionModel
	rows, err := db.Query(query, args...)
	if err == nil {
		var transactionModel models.TransactionModel
		for rows.Next() {
			if err = rows.Scan(&transactionModel.Id, &transactionModel.CoinType, &transactionModel.TransactionType, &transactionModel.Amount, &transactionModel.Status, &transactionModel.TransactionId, &transactionModel.MoreInfo, &transactionModel.CreatorId, &transactionModel.CreatedAt, &transactionModel.UpdatedAt); err != nil {
				return transactions, err
			}
			transactionModel.Creator, _ = GetUserWithId(transactionModel.CreatorId, db)
			transactions = append(transactions, transactionModel)
		}
	}
	return transactions, err
}
func CreateTransaction(coinType, transactionType, amount, status, transactionId string, moreInfo any, creatorId int, db *sql.DB) (models.TransactionModel, error) {
	tempTransaction := transactionId
	transactionsWithId, err := GetTransactionWithTransactionId(tempTransaction, db)
	if err == nil {
		// for len(transactionsWithId) > 0 {
		// 	tempTransaction = utils.GetRandomString(16)
		// 	transactionsWithId, _ = GetTransactionWithTransactionId(tempTransaction, db)
		// }
		if len(transactionsWithId) == 0 {
			user, err := GetUserWithId(creatorId, db)
			if err == nil {
				oldTonInventory, err := strconv.ParseFloat(user.TonInventory, 64)
				if err == nil {
					increasedAmount, err := strconv.ParseFloat(amount, 64)
					if err == nil {
						newTonInventory := oldTonInventory + increasedAmount
						user.TonInventory = utils.ConvertAnyToString(newTonInventory)
						err = user.Save(db)
						query := "INSERT INTO transactions (coin_type,transaction_type,amount,status,transaction_id,more_info,creator_id) VALUES (?,?,?,?,?,?,?)"
						result, err := db.Exec(query, coinType, transactionType, amount, status, transactionId, moreInfo, creatorId)
						if err == nil {
							if increasedAmount > 0 {
								DoReferalThings(user, increasedAmount, "ton", db)
							}
							lastInsertedId, _ := result.LastInsertId()
							return getTransactionById(int(lastInsertedId), db)
						}
					}
				}
			}
		}
	}

	return models.TransactionModel{}, err
}
func GetTransactionsByCreatorId(creatorId int, db *sql.DB) ([]models.TransactionModel, error) {
	query := "SELECT * FROM transactions WHERE creator_id=?"
	return getTransactionsWithConditions(query, db, creatorId)
}
func GetTransactionWithTransactionId(transactionId string, db *sql.DB) ([]models.TransactionModel, error) {
	query := "SELECT * FROM transactions WHERE transaction_id=?"
	return getTransactionsWithConditions(query, db, transactionId)
}
func GetTransactionsWithStatus(status string, db *sql.DB) ([]models.TransactionModel, error) {
	query := "SELECT * FROM transactions WHERE status=?"
	return getTransactionsWithConditions(query, db, status)
}
func GetTransactionsByTransactionTypeAndStatusAndPage(transactionType, status string, page int, db *sql.DB) ([]models.TransactionModel, error) {
	query := "SELECT * FROM transactions WHERE transaction_type=? AND status=? ORDER BY created_at DESC LIMIT ? OFFSET ?"
	return getTransactionsWithConditions(query, db, transactionType, status, utils.ITEM_PER_PAGE, (page-1)*utils.ITEM_PER_PAGE)
}
func GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus(transactionType, coinType, status string, creatorId int, db *sql.DB) ([]models.TransactionModel, error) {
	query := "SELECT * FROM transactions WHERE transaction_type=? AND coin_type=? AND status=? AND creator_id=?"
	return getTransactionsWithConditions(query, db, transactionType, coinType, status, creatorId)
}
func GetFirstTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus(transactionType, coinType, status string, creatorId int, db *sql.DB) ([]models.TransactionModel, error) {
	transactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus(transactionType, coinType, status, creatorId, db)
	if err == nil && len(transactions) > 0 {
		return []models.TransactionModel{transactions[0]}, err
	}
	return []models.TransactionModel{}, err
}
func getTransactionById(transactionId int, db *sql.DB) (models.TransactionModel, error) {
	query := "SELECT * FROM transactions WHERE id=?"
	transactions, err := getTransactionsWithConditions(query, db, transactionId)
	if err == nil && len(transactions) > 0 {
		return transactions[0], err
	}
	return models.TransactionModel{}, err
}
func GetLastDepositTransaction(db *sql.DB) (models.TransactionModel, error) {
	query := "SELECT * FROM transactions WHERE transaction_type=? ORDER BY created_at desc LIMIT 1"
	transactions, err := getTransactionsWithConditions(query, db, "deposit")
	if err == nil && len(transactions) > 0 {
		return transactions[0], err
	}
	return models.TransactionModel{}, err
}
func GetLastTransaction(db *sql.DB) (models.TransactionModel, error) {
	query := "SELECT * FROM transactions ORDER BY created_at desc LIMIT 1"
	transactions, err := getTransactionsWithConditions(query, db)
	if err == nil && len(transactions) > 0 {
		return transactions[0], err
	}
	return models.TransactionModel{}, err
}
func GetTransactionsAmountPerConditions(transactionType, coinType string, daysBefore int, db *sql.DB) float64 {
	hoursBefore := time.Duration(daysBefore * -24)
	var currentTime = time.Now().Add(time.Hour * hoursBefore)
	query := "SELECT SUM(amount) FROM transactions WHERE transaction_type=? AND coin_type=? AND status=? AND updated_at>=? "
	var outgoingTonAmountPerDay string
	rows, err := db.Query(query, transactionType, coinType, "success", currentTime)
	var outgoingTonAmountPerDayFloat float64
	if err == nil {
		for rows.Next() {
			if err = rows.Scan(&outgoingTonAmountPerDay); err != nil {
				return 0
			}
			outgoingTonAmountPerDayFloat, _ = strconv.ParseFloat(outgoingTonAmountPerDay, 64)
		}
	} else {
		fmt.Println(err.Error())
	}
	return outgoingTonAmountPerDayFloat
}
func DoReferalThings(payer models.User, amount float64, coinType string, db *sql.DB) {
	invitations, err := GetInvitationByInvitedId(payer.UserUniqueNumber, db)
	if len(invitations) > 0 && err == nil {
		invitation := invitations[0]
		firstInvitorUser := invitation.Invitor
		//first invitor user takes 1% of the amount .
		AddAmountToUserInventoryByCoinType(amount, 0.01, firstInvitorUser, coinType, db)
		invitations, err = GetInvitationByInvitedId(firstInvitorUser.UserUniqueNumber, db)
		if len(invitations) > 0 && err == nil {
			invitation = invitations[0]
			secondInvitorUser := invitation.Invitor
			AddAmountToUserInventoryByCoinType(amount, 0.003, secondInvitorUser, coinType, db)
			//second invitor user takes 0.5% of the amount.
			invitations, err = GetInvitationByInvitedId(secondInvitorUser.UserUniqueNumber, db)
			if len(invitations) > 0 && err == nil {
				invitation = invitations[0]
				thirdInvitorUser := invitation.Invitor
				AddAmountToUserInventoryByCoinType(amount, 0.001, thirdInvitorUser, coinType, db)
				//second invitor user takes 0.25% of the amount.
			}
		}
	}
}
func GetSumOfTheTransactionsAmount(transactions []models.TransactionModel) float64 {
	var sum float64 = 0
	if len(transactions) > 0 {
		for _, t := range transactions {
			tAmount, _ := strconv.ParseFloat(t.Amount, 64)
			sum += tAmount
		}
	}
	return sum
}
func GetSumOfTheTransactionsByTransactionTypeAndUserId(transactionType string, userId int, db *sql.DB) float64 {
	query := "SELECT * FROM transactions WHERE transaction_type=? AND creator_id=? AND status=?"
	transactions, err := getTransactionsWithConditions(query, db, transactionType, userId, "success")
	if err == nil {
		return GetSumOfTheTransactionsAmount(transactions)
	}
	return 0
}
