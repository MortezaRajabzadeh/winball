package controllers

import (
	"database/sql"

	"github.com/khodehamid/winball_go_back/models"
)

func getLevelsByConditions(query string, db *sql.DB, args ...any) ([]models.LevelModel, error) {
	var levels []models.LevelModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var level models.LevelModel
			if err = rows.Scan(&level.Id, &level.LevelTag, &level.ExpToUpgrade, &level.CreatedAt, &level.UpdatedAt); err != nil {
				return levels, err
			}
			levels = append(levels, level)
		}
	}
	return levels, err
}
func CreateLevel(levelTag, expToUpgrade string, db *sql.DB) (models.LevelModel, error) {
	query := "INSERT INTO levels (level_tag,exp_to_upgrade) VALUES (?,?)"
	result, err := db.Exec(query, levelTag, expToUpgrade)
	if err == nil {
		lastInsertedId, _ := result.LastInsertId()
		return GetLevelById(int(lastInsertedId), db)
	}
	return models.LevelModel{}, err
}
func DeleteLevelById(levelId int, db *sql.DB) error {
	query := "DELETE FROM levels WHERE id=?"
	_, err := db.Exec(query, levelId)
	return err
}
func GetLevels(db *sql.DB) ([]models.LevelModel, error) {
	query := "SELECT * FROM levels"
	return getLevelsByConditions(query, db)
}
func GetLevelById(levelId int, db *sql.DB) (models.LevelModel, error) {
	query := "SELECT * FROM levels WHERE id=?"
	levels, err := getLevelsByConditions(query, db, levelId)
	if err == nil && len(levels) > 0 {
		return levels[0], err
	}
	return models.LevelModel{}, err
}
func GetLevelIdByInvitationsCount(invitationCount int, db *sql.DB) (int, error) {
	query := "SELECT * FROM levels WHERE exp_to_upgrade<=? ORDER BY created_at DESC LIMIT 1"
	levels, err := getLevelsByConditions(query, db, invitationCount)
	if err == nil && len(levels) > 0 {
		return levels[0].Id, err
	}
	return 1, err
}
