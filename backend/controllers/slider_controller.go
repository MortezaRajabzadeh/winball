package controllers

import (
	"database/sql"

	"github.com/khodehamid/winball_go_back/models"
)

func getSliderWithConditions(query string, db *sql.DB, args ...any) ([]models.Slider, error) {
	var slider []models.Slider
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var slide models.Slider
			if err = rows.Scan(&slide.Id, &slide.ImagePath, &slide.ButtonTitle, &slide.ButtonLink, &slide.CreatedAt, &slide.UpdatedAt); err != nil {
				return slider, err
			}
			slider = append(slider, slide)
		}
	}
	return slider, err
}

// Moved this function up
func getSliderWithId(sliderId int, db *sql.DB) (models.Slider, error) {
	query := "SELECT * FROM slider WHERE id=?"
	slider, err := getSliderWithConditions(query, db, sliderId)
	if err == nil && len(slider) > 0 {
		return slider[0], err
	}
	return models.Slider{}, err
}

func CreateSlider(imagePath string, buttonTitle, buttonLink any, db *sql.DB) (models.Slider, error) {
	query := "INSERT INTO slider (image_path,button_title,button_link) VALUES (?,?,?)"
	result, err := db.Exec(query, imagePath, buttonTitle, buttonLink)
	if err == nil {
		lastInsertedId, _ := result.LastInsertId()
		return getSliderWithId(int(lastInsertedId), db)
	}
	return models.Slider{}, err
}

func GetSliders(db *sql.DB) ([]models.Slider, error) {
	query := "SELECT * FROM slider"
	return getSliderWithConditions(query, db)
}

// TODO remove file
func DeleteSlider(sliderId int, db *sql.DB) error {
	query := "DELETE FROM slider WHERE id=?"
	_, err := db.Exec(query, sliderId)
	return err
}

// Renamed from getSliderWithId to make it public
func GetSliderById(sliderId int, db *sql.DB) (models.Slider, error) {
	query := "SELECT * FROM slider WHERE id=?"
	slider, err := getSliderWithConditions(query, db, sliderId)
	if err == nil && len(slider) > 0 {
		return slider[0], err
	}
	return models.Slider{}, err
}
