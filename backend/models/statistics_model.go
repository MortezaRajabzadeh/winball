package models

type StatisticsModel struct {
	UsersCount                  int     `json:"users_count"`
	OutgoingTonAmountPerDay     float64 `json:"outgoing_ton_amount_per_day"`
	IncomeTonAmountPerDay       float64 `json:"income_ton_amount_per_day"`
	OutgoingTonAmountPerMonth   float64 `json:"outgoing_ton_amount_per_month"`
	IncomeTonAmountPerMonth     float64 `json:"income_ton_amount_per_month"`
	OutgoingTonAmountPerYear    float64 `json:"outgoing_ton_amount_per_year"`
	IncomeTonAmountPerYear      float64 `json:"income_ton_amount_per_year"`
	OutgoingStarsAmountPerDay   float64 `json:"outgoing_stars_amount_per_day"`
	IncomeStarsAmountPerDay     float64 `json:"income_stars_amount_per_day"`
	OutgoingStarsAmountPerMonth float64 `json:"outgoing_stars_amount_per_month"`
	IncomeStarsAmountPerMonth   float64 `json:"income_stars_amount_per_month"`
	OutgoingStarsAmountPerYear  float64 `json:"outgoing_stars_amount_per_year"`
	IncomeStarsAmountPerYear    float64 `json:"income_stars_amount_per_year"`
	WinnerCount                 int     `json:"winner_count"`
	LosersCount                 int     `json:"losers_count"`
}
