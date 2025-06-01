package models

import (
	"database/sql"
	"time"
)

type Slider struct {
	Id          int            `json:"id"`
	ImagePath   string         `json:"image_path"`
	ButtonTitle sql.NullString `json:"button_title"`
	ButtonLink  sql.NullString `json:"button_link"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`
}

func (s *Slider) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE slider SET image_path=?,button_title=?,button_link=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, s.ImagePath, s.ButtonTitle.String, s.ButtonLink.String, currentTime, s.Id)
	return err
}
