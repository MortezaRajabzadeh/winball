package controllers

import (
	"database/sql"
	"errors"

	"github.com/khodehamid/winball_go_back/configs"
	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

func getWithdrawsWithConditions(query string, db *sql.DB, args ...any) ([]models.WithdrawModel, error) {
	var withdraws []models.WithdrawModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var withdraw models.WithdrawModel
			if err = rows.Scan(&withdraw.Id, &withdraw.Amount, &withdraw.WalletAddress, &withdraw.CoinType, &withdraw.Status, &withdraw.CreatorId, &withdraw.TransactionId, &withdraw.CreatedAt, &withdraw.UpdatedAt); err != nil {
				return withdraws, err
			}
			withdraw.Creator, _ = GetUserWithId(withdraw.CreatorId, db)
			withdraws = append(withdraws, withdraw)
		}
	}
	return withdraws, err
}

func CreateWithdraw(amount float32, walletAddress, coinType string, creatorId int, db *sql.DB) (models.WithdrawModel, error) {
	creator, err := GetUserWithId(creatorId, db)
	if err == nil && creator.Id > 0 {
		userInventory := GetUserInventoryByCoinType(coinType, creator)
		if userInventory >= amount {
			withdrawAmount := amount
			withdrawableAmount := GetWithdrawableAmount(coinType, creatorId, db)
			if withdrawableAmount <= configs.WITHDRAWABLE_LESS_THAN {
				transactionId := utils.GetRandomString(16)
				query := "INSERT INTO withdraws (amount,wallet_address,coin_type,creator_id,transaction_id) VALUES (?,?,?,?,?)"
				result, err := db.Exec(query, amount, walletAddress, coinType, creatorId, transactionId)
				if err == nil {
					CreateTransaction(coinType, "withdraw", utils.ConvertAnyToString(withdrawAmount), "pending", transactionId, nil, creatorId, db)
					lastInsertedId, _ := result.LastInsertId()
					return GetWithdrawById(int(lastInsertedId), db)
				}
			} else {
				return models.WithdrawModel{}, errors.New("Please play our games until the unfinshed flow got to zero!")
			}
		} else {
			return models.WithdrawModel{}, errors.New("you cannot withdraw more that your inventory")
		}
	}

	return models.WithdrawModel{}, err
}
func GetWithdrawByCreator(creatorId int, db *sql.DB) ([]models.WithdrawModel, error) {
	query := "SELECT * FROM withdraws WHERE creator_id=?"
	return getWithdrawsWithConditions(query, db, creatorId)
}
func GetWithdrawByTransactionId(transactionId string, db *sql.DB) ([]models.WithdrawModel, error) {
	query := "SELECT * FROM withdraws WHERE transaction_id=?"
	return getWithdrawsWithConditions(query, db, transactionId)
}
func GetWithdrawById(withdrawId int, db *sql.DB) (models.WithdrawModel, error) {
	query := "SELECT * FROM withdraws WHERE id=?"
	withdraws, err := getWithdrawsWithConditions(query, db, withdrawId)
	if err == nil && len(withdraws) > 0 {
		return withdraws[0], err
	}
	return models.WithdrawModel{}, err
}
func GetWithdrawsByStatusAndPage(status string, page int, db *sql.DB) ([]models.WithdrawModel, error) {
	query := "SELECT * FROM withdraws WHERE status=? ORDER BY created_at DESC LIMIT ? OFFSET ?"
	return getWithdrawsWithConditions(query, db, status, utils.ITEM_PER_PAGE, (page-1)*utils.ITEM_PER_PAGE)
}
