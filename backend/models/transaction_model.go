package models

import (
	"database/sql"
	"time"
)

type TransactionModel struct {
	Id              int            `json:"id"`
	CoinType        string         `json:"coin_type"`
	TransactionType string         `json:"transaction_type"`
	Amount          string         `json:"amount"`
	Status          string         `json:"status"`
	TransactionId   string         `json:"transaction_id"`
	MoreInfo        sql.NullString `json:"more_info"`
	CreatorId       int            `json:"creator_id"`
	Creator         User           `json:"creator"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
}

func (t *TransactionModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE transactions SET transaction_type=?,amount=?,status=?,transaction_id=?,more_info=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, t.TransactionType, t.Amount, t.Status, t.TransactionId, t.MoreInfo.String, currentTime, t.Id)
	return err
}
