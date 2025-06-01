package models

import (
	"database/sql"
	"time"
)

type User struct {
	Id               int            `json:"id"`
	InvitationCode   string         `json:"invitation_code"`
	Username         sql.NullString `json:"username"`
	Password         string         `json:"-"`
	Firstname        sql.NullString `json:"firstname"`
	Lastname         sql.NullString `json:"lastname"`
	UserUniqueNumber string         `json:"user_unique_number"`
	IsDemoAccount    string         `json:"is_demo_account"`
	TonInventory     string         `json:"ton_inventory"`
	StarsInventory   string         `json:"stars_inventory"`
	UsdtInventory    string         `json:"usdt_inventory"`
	BtcInventory     string         `json:"btc_inventory"`
	CusdInventory    string         `json:"cusd_inventory"`
	UserProfile      sql.NullString `json:"user_profile"`
	TotalWagered     float32        `json:"total_wagered"`
	TotalBets        int            `json:"total_bets"`
	TotalWins        string         `json:"total_wins"`
	LevelId          int            `json:"level_id"`
	Level            LevelModel     `json:"level"`
	Experience       string         `json:"experience"`
	UserType         string         `json:"user_type"`
	Token            sql.NullString `json:"token"`
	CreatedAt        time.Time      `json:"created_at"`
	UpdatedAt        time.Time      `json:"updated_at"`
}

func (u *User) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE users SET username=?,password=?,firstname=?,lastname=?,is_demo_account=?,ton_inventory=?,stars_inventory=?,usdt_inventory=?,btc_inventory=?,cusd_inventory=?,user_profile=?,total_wagered=?,total_bets=?,total_wins=?,level_id=?,experience=?,user_type=?,token=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, u.Username.String, u.Password, u.Firstname.String, u.Lastname.String, u.IsDemoAccount, u.TonInventory, u.StarsInventory, u.UsdtInventory, u.BtcInventory, u.CusdInventory, u.UserProfile.String, u.TotalWagered, u.TotalBets, u.TotalWins, u.LevelId, u.Experience, u.UserType, u.Token.String, currentTime, u.Id)
	return err
}
func (u *User) IsAdmin() bool {
	return u.UserType == "admin"
}
func (u *User) IsSupport() bool {
	return u.UserType == "support"
}
func (u *User) IsBlocked() bool {
	return u.UserType == "blocked"
}
func (u *User) IsDemo() bool {
	return u.IsDemoAccount == "1"
}
