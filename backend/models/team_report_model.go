package models

type TeamReportModel struct {
	RegistrationUsers      int     `json:"registration_users"`
	FirstDepositTonUsers   float64 `json:"first_deposit_ton_users"`
	FirstDepositStarsUsers float64 `json:"first_deposit_stars_users"`
	DepositsTonUsers       float64 `json:"deposit_ton_users"`
	DepositsStarsUsers     float64 `json:"deposit_stars_users"`
	WithdrawTonUsers       float64 `json:"withdraw_ton_users"`
	WithdrawStarsUsers     float64 `json:"withdraw_stars_users"`
}
