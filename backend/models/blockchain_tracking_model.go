package models

import (
	"database/sql"
	"time"
)

type BlockchainTrackingModel struct {
	Id              int       `json:"id"`
	WalletAddress   string    `json:"wallet_address"`
	LastProcessedLT string    `json:"last_processed_lt"`
	LastProcessedHash string  `json:"last_processed_hash"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
}

func (bt *BlockchainTrackingModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE blockchain_tracking SET last_processed_lt=?, last_processed_hash=?, updated_at=? WHERE id=?"
	_, err := db.Exec(query, bt.LastProcessedLT, bt.LastProcessedHash, currentTime, bt.Id)
	return err
} 