package controllers

import (
	"database/sql"

	"github.com/khodehamid/winball_go_back/models"
)

func getActivitiesByConditions(query string, db *sql.DB, args ...any) ([]models.ActivityModel, error) {
	var activities []models.ActivityModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var activity models.ActivityModel
			if err = rows.Scan(&activity.Id, &activity.Title, &activity.BannerUrl, &activity.Details, &activity.CreatorId, &activity.CreatedAt, &activity.UpdatedAt); err != nil {
				return activities, err
			}
			activity.Creator, _ = GetUserWithId(activity.CreatorId, db)
			activities = append(activities, activity)
		}
	}
	return activities, err
}
func CreateActivity(title, bannerUrl, details string, creatorId int, db *sql.DB) (models.ActivityModel, error) {
	query := "INSERT INTO activities (title,banner_url,details,creator_id) VALUES (?,?,?,?)"
	result, err := db.Exec(query, title, bannerUrl, details, creatorId)
	if err == nil {
		lastRowInsertedId, _ := result.LastInsertId()
		return GetActivityById(int(lastRowInsertedId), db)
	}
	return models.ActivityModel{}, err
}
func GetActivityById(activityId int, db *sql.DB) (models.ActivityModel, error) {
	query := "SELECT * FROM activities WHERE id=?"
	activities, err := getActivitiesByConditions(query, db, activityId)
	if err == nil && len(activities) > 0 {
		return activities[0], err
	}
	return models.ActivityModel{}, err
}
func DeleteActivityById(activityId int, db *sql.DB) error {
	query := "DELETE FROM activities WHERE id=?"
	_, err := db.Exec(query, activityId)
	return err
}
func GetActivities(db *sql.DB) ([]models.ActivityModel, error) {
	query := "SELECT * FROM activities"
	return getActivitiesByConditions(query, db)
}
