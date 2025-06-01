package controllers

import (
	"database/sql"
	"fmt"
	"net/url"

	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
	"github.com/xssnick/tonutils-go/tlb"
)

func getDepositsByConditions(query string, db *sql.DB, args ...any) ([]models.DepositModel, error) {
	rows, err := db.Query(query, args...)
	var deposits []models.DepositModel
	if err == nil {
		for rows.Next() {
			var deposit models.DepositModel
			if err = rows.Scan(&deposit.Id, &deposit.Amount, &deposit.CreatorId, &deposit.Status, &deposit.TransactionId, &deposit.CreatedAt, &deposit.UpdatedAt); err != nil {
				return deposits, err
			}
			deposit.Creator, _ = GetUserWithId(deposit.CreatorId, db)
			deposits = append(deposits, deposit)
		}
	}
	return deposits, err
}
func CreateDeposit(amount float32, creatorId int, db *sql.DB) (models.DepositModel, error) {
	var transactionId string = utils.GetRandomString(16)
	deposits, err := GetDepositByTransactionId(transactionId, db)
	for len(deposits) > 0 {
		transactionId = utils.GetRandomString(16)
		deposits, err = GetDepositByTransactionId(transactionId, db)
	}
	if len(deposits) == 0 && err == nil {
		query := "INSERT INTO deposits (amount,creator_id,transaction_id) VALUES (?,?,?)"
		result, err := db.Exec(query, amount, creatorId, transactionId)
		if err == nil {
			lastInsertedId, err := result.LastInsertId()
			if err == nil {
				return GetDepositById(int(lastInsertedId), db)
			}
		}
	}
	return models.DepositModel{}, err
}
func GetDeposits(db *sql.DB) ([]models.DepositModel, error) {
	query := "SELECT * FROM deposits"
	return getDepositsByConditions(query, db)
}
func GetDepositByTransactionId(transactionId string, db *sql.DB) ([]models.DepositModel, error) {
	query := "SELECT * FROM deposts WHERE transaction_id=?"
	return getDepositsByConditions(query, db, transactionId)
}
func GetDepositById(depositId int, db *sql.DB) (models.DepositModel, error) {
	query := "SELECT * FROM deposits WHERE id=?"
	deposits, err := getDepositsByConditions(query, db, depositId)
	if len(deposits) > 0 && err == nil {
		return deposits[0], err
	}
	return models.DepositModel{}, err
}
func GetDepositsByUserId(creatorId string, db *sql.DB) ([]models.DepositModel, error) {
	query := "SELECT * FROM deposts WHERE creator_id=?"
	return getDepositsByConditions(query, db, creatorId)
}
func CreatePaymentLink(address, userInvitorCode, amount string) string {
	return fmt.Sprintf("https://app.tonkeeper.com/transfer/%s?text=pay-%s&amount=%s", address, url.PathEscape(userInvitorCode), tlb.MustFromTON(amount).Nano().String())
}
