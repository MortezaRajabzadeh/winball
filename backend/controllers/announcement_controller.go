package controllers

import (
	"database/sql"

	"github.com/khodehamid/winball_go_back/models"
)

func getAnnouncementsByConditions(query string, db *sql.DB, args ...any) ([]models.AnnouncementModel, error) {
	var announcements []models.AnnouncementModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var announcement models.AnnouncementModel
			if err = rows.Scan(&announcement.Id, &announcement.Title, &announcement.Details, &announcement.CreatorId, &announcement.CreatedAt, &announcement.UpdatedAt); err != nil {
				return announcements, err
			}
			announcement.Creator, _ = GetUserWithId(announcement.CreatorId, db)
			announcements = append(announcements, announcement)
		}
	}
	return announcements, err
}
func CreateAnnouncement(title, details string, creatorId int, db *sql.DB) (models.AnnouncementModel, error) {
	query := "INSERT INTO announcements (title,details,creator_id) VALUES (?,?,?)"
	result, err := db.Exec(query, title, details, creatorId)
	if err == nil {
		lastInsertedId, _ := result.LastInsertId()
		return GetAnnouncementById(int(lastInsertedId), db)
	}
	return models.AnnouncementModel{}, err
}
func DeleteAnnouncementById(announcementId int, db *sql.DB) error {
	query := "DELETE FROM announcements WHERE id=?"
	_, err := db.Exec(query, announcementId)
	return err

}
func GetAnnouncements(db *sql.DB) ([]models.AnnouncementModel, error) {
	query := "SELECT * FROM announcements"
	return getAnnouncementsByConditions(query, db)
}
func GetAnnouncementById(announcementId int, db *sql.DB) (models.AnnouncementModel, error) {
	query := "SELECT * FROM announcements WHERE id=?"
	announcements, err := getAnnouncementsByConditions(query, db, announcementId)
	if err == nil && len(announcements) > 0 {
		return announcements[0], err
	}
	return models.AnnouncementModel{}, err
}
