package models

import (
	"database/sql"
	"time"
)

type LevelModel struct {
	Id           int       `json:"id"`
	LevelTag     string    `json:"level_tag"`
	ExpToUpgrade float64   `json:"exp_to_upgrade"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

func (l *LevelModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE levels SET level_tag=?,exp_to_upgrade=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, l.LevelTag, l.ExpToUpgrade, currentTime, l.Id)
	return err
}
