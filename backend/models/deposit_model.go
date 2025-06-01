package models

import (
	"database/sql"
	"time"
)

type DepositModel struct {
	Id            int       `json:"id"`
	Amount        float64   `json:"amount"`
	CreatorId     int       `json:"creator_id"`
	Creator       User      `json:"creator"`
	Status        string    `json:"status"`
	TransactionId string    `json:"transaction_id"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

func (d *DepositModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	var query = "UPDATE deposits SET status=?,transaction_id=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, d.Status, d.TransactionId, currentTime, d.Id)
	return err
}
