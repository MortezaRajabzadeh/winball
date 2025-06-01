package controllers

import (
	"database/sql"
	"fmt"

	"github.com/khodehamid/winball_go_back/models"
)

func getSiteSettingsWithConditions(query string, db *sql.DB, args ...any) ([]models.SiteSettingModel, error) {
	var siteSettings []models.SiteSettingModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var siteSetting models.SiteSettingModel
			if err = rows.Scan(&siteSetting.Id, &siteSetting.LoadingPicture, &siteSetting.ReferalPercent, &siteSetting.MinWithdrawAmount, &siteSetting.MinDepositAmount, &siteSetting.CreatorId, &siteSetting.CreatedAt, &siteSetting.UpdatedAt); err != nil {
				return siteSettings, err
			}
			siteSetting.Creator, _ = GetUserWithId(siteSetting.CreatorId, db)
			siteSettings = append(siteSettings, siteSetting)
		}
	}
	return siteSettings, err
}
func CreateSiteSetting(loadingPicture string, minWithdrawAmount, minDepositAmount, referalPercent float32, creatorId int, db *sql.DB) (models.SiteSettingModel, error) {
	settings, err := GetSiteSettings(db)
	if err == nil {
		if len(settings) > 0 {
			setting := settings[0]
			if loadingPicture != "" {
				setting.LoadingPicture.String = loadingPicture
			}
			setting.ReferalPercent = referalPercent
			setting.MinWithdrawAmount = minWithdrawAmount
			setting.MinDepositAmount = minDepositAmount
			err = setting.Save(db)
			return setting, err
		} else {
			query := "INSERT INTO site_settings (loading_picture,referal_percent,min_withdraw_amount,min_deposit_amount,creator_id) VALUES (?,?,?,?,?)"
			result, err := db.Exec(query, loadingPicture, referalPercent, minWithdrawAmount, minDepositAmount, creatorId)
			if err == nil {
				lastInsertedId, _ := result.LastInsertId()
				return GetSiteSettingWithId(int(lastInsertedId), db)
			} else {
				fmt.Println(err.Error())
			}
		}
	}

	return models.SiteSettingModel{}, err
}
func GetSiteSettings(db *sql.DB) ([]models.SiteSettingModel, error) {
	query := "SELECT * FROM site_settings"
	return getSiteSettingsWithConditions(query, db)
}
func GetSiteSettingWithId(settingId int, db *sql.DB) (models.SiteSettingModel, error) {
	query := "SELECT * FROM site_settings WHERE id=?"
	settings, err := getSiteSettingsWithConditions(query, db, settingId)
	if err == nil && len(settings) > 0 {
		return settings[0], err
	}
	return models.SiteSettingModel{}, err
}
