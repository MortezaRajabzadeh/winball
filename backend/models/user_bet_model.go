package models

import (
	"database/sql"
	"time"
)

type UserBetModel struct {
	Id            int             `json:"id"`
	GameId        int             `json:"game_id"`
	Game          OneMinGameModel `json:"game"`
	UserChoices   string          `json:"user_choices"`
	EndGameResult sql.NullString  `json:"end_game_result"`
	BetStatus     string          `json:"bet_status"`
	CreatorId     int             `json:"creator_id"`
	Creator       User            `json:"creator"`
	Amount        float32         `json:"amount"`
	CoinType      string          `json:"coin_type"`
	CreatedAt     time.Time       `json:"created_at"`
	UpdatedAt     time.Time       `json:"updated_at"`
}

func (u *UserBetModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE user_bets SET user_choices=?,end_game_result=?,bet_status=?,amount=?,coin_type=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, u.UserChoices, u.EndGameResult.String, u.BetStatus, u.Amount, u.CoinType, currentTime, u.Id)
	return err
}
