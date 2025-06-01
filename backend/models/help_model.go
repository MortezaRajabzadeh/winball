package models

import (
	"database/sql"
	"time"
)

type HelpModel struct {
	Id          int       `json:"id"`
	Title       string    `json:"title"`
	Subsection  string    `json:"subsection"`
	Description string    `json:"description"`
	CreatorId   int       `json:"creator_id"`
	Creator     User      `json:"creator"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

func (h *HelpModel) Save(db *sql.DB) error {
	var currentTime = time.Now()
	query := "UPDATE help SET title=?,subsection=?,description=?,updated_at=? WHERE id=?"
	_, err := db.Exec(query, h.Title, h.Subsection, h.Description, currentTime, h.Id)
	return err
}
