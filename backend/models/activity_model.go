package models

import (
	"database/sql"
	"time"
)

type ActivityModel struct {
	Id        int       `json:"id"`
	Title     string    `json:"title"`
	BannerUrl string    `json:"banner_url"`
	Details   string    `json:"details"`
	CreatorId int       `json:"creator_id"`
	Creator   User      `json:"creator"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

func (a *ActivityModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE activities SET title=?,details=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, a.Title, a.Details, currentTime, a.Id)
	return err
}
