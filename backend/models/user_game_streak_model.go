package models

import (
	"database/sql"
)

type UserGameStreak struct {
	ID          int
	UserID      int
	WinStreak   int
	LossStreak  int
	TotalWins   int
	TotalLosses int
	LastResult  string         // "win" or "loss"
	UpdatedAt   sql.NullTime
}

func (s *UserGameStreak) Save(db *sql.DB) error {
	query := `
		INSERT INTO user_game_streaks (user_id, win_streak, loss_streak, total_wins, total_losses, last_result, updated_at)
		VALUES (?, ?, ?, ?, ?, ?, NOW())
		ON DUPLICATE KEY UPDATE
			win_streak = VALUES(win_streak),
			loss_streak = VALUES(loss_streak),
			total_wins = VALUES(total_wins),
			total_losses = VALUES(total_losses),
			last_result = VALUES(last_result),
			updated_at = NOW()
	`
	_, err := db.Exec(query, s.UserID, s.WinStreak, s.LossStreak, s.TotalWins, s.TotalLosses, s.LastResult)
	return err
}

func GetUserGameStreak(userID int, db *sql.DB) (UserGameStreak, error) {
	query := "SELECT id, user_id, win_streak, loss_streak, total_wins, total_losses, last_result, updated_at FROM user_game_streaks WHERE user_id = ?"
	var s UserGameStreak
	err := db.QueryRow(query, userID).Scan(&s.ID, &s.UserID, &s.WinStreak, &s.LossStreak, &s.TotalWins, &s.TotalLosses, &s.LastResult, &s.UpdatedAt)
	if err != nil {
		// اگر رکوردی نبود، مقدار پیش‌فرض برگردون
		return UserGameStreak{UserID: userID}, nil
	}
	return s, nil
}
