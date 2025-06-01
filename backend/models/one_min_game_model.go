package models

import (
	"database/sql"
	"time"
)

type OneMinGameModel struct {
	Id                   int            `json:"id"`
	GameType             string         `json:"game_type"`
	GameHash             string         `json:"game_hash"`
	GameResult           sql.NullString `json:"game_result"`
	EachGameUniqueNumber int            `json:"each_game_unique_number"`
	CreatedAt            time.Time      `json:"created_at"`
	UpdatedAt            time.Time      `json:"updated_at"`
}

func (o *OneMinGameModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE one_min_game SET game_hash=?,game_type=?,game_result=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, o.GameHash, o.GameType, o.GameResult.String, currentTime, o.Id)
	return err
}
