package models

import "time"

type SupportModel struct {
	Id           int       `json:"id"`
	MessageValue string    `json:"message_value"`
	MessageType  string    `json:"message_type"`
	CreatorId    int       `json:"creator_id"`
	Creator      User      `json:"creator"`
	RoomId       string    `json:"room_id"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}
