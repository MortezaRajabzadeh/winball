package controllers

import (
	"database/sql"

	"github.com/khodehamid/winball_go_back/models"
)

func getHelpsWithConditions(query string, db *sql.DB, args ...any) ([]models.HelpModel, error) {
	var helps []models.HelpModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var help models.HelpModel
			if err = rows.Scan(&help.Id, &help.Title, &help.Subsection, &help.Description, &help.CreatorId, &help.CreatedAt, &help.UpdatedAt); err != nil {
				return helps, err
			}
			help.Creator, _ = GetUserWithId(help.CreatorId, db)
			helps = append(helps, help)
		}
	}
	return helps, err
}
func CreateHelp(title, subsection, description string, creatorId int, db *sql.DB) (models.HelpModel, error) {
	query := "INSERT INTO help (title,subsection,description,creator_id) VALUES (?,?,?,?)"
	result, err := db.Exec(query, title, subsection, description, creatorId)
	if err == nil {
		lastInsertedId, _ := result.LastInsertId()
		return GetHelpWithId(int(lastInsertedId), db)

	}
	return models.HelpModel{}, err
}
func GetHelps(db *sql.DB) ([]models.HelpModel, error) {
	query := "SELECT * FROM help"
	return getHelpsWithConditions(query, db)
}
func DeleteHelpWithId(helpId int, db *sql.DB) error {
	query := "DELETE FROM help WHERE id=?"
	_, err := db.Exec(query, helpId)
	return err
}
func GetHelpWithId(helpId int, db *sql.DB) (models.HelpModel, error) {
	query := "SELECT * FROM help WHERE id=?"
	helps, err := getHelpsWithConditions(query, db, helpId)
	if err == nil && len(helps) > 0 {
		return helps[0], err
	}
	return models.HelpModel{}, err
}
