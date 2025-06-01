package models

import (
	"database/sql"
	"time"
)

type WithdrawModel struct {
	Id            int       `json:"id"`
	Amount        float32   `json:"amount"`
	WalletAddress string    `json:"wallet_address"`
	CoinType      string    `json:"coin_type"`
	Status        string    `json:"status"`
	CreatorId     int       `json:"creator_id"`
	Creator       User      `json:"creator"`
	TransactionId string    `json:"transaction_id"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

func (w *WithdrawModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE withdraws SET status=?,transaction_id=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, w.Status, w.TransactionId, currentTime, w.Id)
	return err
}
