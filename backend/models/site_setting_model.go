package models

import (
	"database/sql"
	"time"
)

type SiteSettingModel struct {
	Id                int            `json:"id"`
	LoadingPicture    sql.NullString `json:"loading_picture"`
	ReferalPercent    float32        `json:"referal_percent"`
	MinWithdrawAmount float32        `json:"min_withdraw_amount"`
	MinDepositAmount  float32        `json:"min_deposit_amount"`
	CreatorId         int            `json:"creator_id"`
	Creator           User           `json:"creator"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
}

func (s *SiteSettingModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE site_settings SET loading_picture=?,referal_percent=?,min_withdraw_amount=?,min_deposit_amount=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, s.LoadingPicture.String, s.ReferalPercent, s.MinWithdrawAmount, s.MinDepositAmount, currentTime, s.Id)
	return err
}
