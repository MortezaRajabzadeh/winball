package types

type UserGameStreak struct {
    WinStreak    int    `json:"win_streak"`
    LossStreak   int    `json:"loss_streak"`
    TotalWins    int    `json:"total_wins"`
    TotalLosses  int    `json:"total_losses"`
    LastResult   string `json:"last_result"`
}

type BetValidationRules struct {
    MaxColors int
    MaxNumbers int
}

var DefaultBetRules = BetValidationRules{
    MaxColors: 1,
    MaxNumbers: 5,
} 