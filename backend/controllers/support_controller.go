package controllers

import (
	"database/sql"

	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

func getSupportsWithConditions(query string, db *sql.DB, args ...any) ([]models.SupportModel, error) {
	var supports []models.SupportModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var support models.SupportModel
			if err = rows.Scan(&support.Id, &support.MessageValue, &support.MessageType, &support.CreatorId, &support.RoomId, &support.CreatedAt, &support.UpdatedAt); err != nil {
				return supports, err
			}
			support.Creator, _ = GetUserWithId(support.CreatorId, db)
			supports = append(supports, support)
		}
	}
	return supports, err
}
func GetSupportsByRoomId(roomId string, db *sql.DB) ([]models.SupportModel, error) {
	query := "SELECT * FROM support WHERE room_id=?"
	return getSupportsWithConditions(query, db, roomId)
}
func GetSupportByUserId(userId int, db *sql.DB) ([]models.SupportModel, error) {
	query := "SELECT * FROM support WHERE creator_id=?"
	supports, err := getSupportsWithConditions(query, db, userId)
	if err == nil && len(supports) > 0 {
		roomId := supports[0].RoomId
		return GetSupportsByRoomId(roomId, db)
	}
	return supports, err
}
func GetSupportById(supportId int, db *sql.DB) (models.SupportModel, error) {
	query := "SELECT * FROM support WHERE id=?"
	supports, err := getSupportsWithConditions(query, db, supportId)
	if err == nil && len(supports) > 0 {
		return supports[0], err
	}
	return models.SupportModel{}, err
}

func CreateSupportMessage(messageValue, messageType string, creatorId int, db *sql.DB) (models.SupportModel, error) {
	var roomId = utils.GetRandomString(32)
	supports, err := GetSupportByUserId(creatorId, db)
	if err == nil && len(supports) > 0 {
		roomId = supports[0].RoomId
	} else if len(supports) == 0 {
		tempSupport, err := GetSupportsByRoomId(roomId, db)
		if err == nil {
			for len(tempSupport) > 0 {
				roomId = utils.GetRandomString(32)
				tempSupport, _ = GetSupportsByRoomId(roomId, db)
			}
		}
	}
	query := "INSERT INTO support (message_value,message_type,creator_id,room_id) VALUES (?,?,?,?)"
	result, err := db.Exec(query, messageValue, messageType, creatorId, roomId)
	if err == nil {
		lastInsertedId, _ := result.LastInsertId()
		return GetSupportById(int(lastInsertedId), db)
	}
	return models.SupportModel{}, err
}
