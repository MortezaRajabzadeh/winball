package models

import "time"

type InvitationModel struct {
	Id             int       `json:"id"`
	InvitorId      int       `json:"invitor_id"`
	Invitor        User      `json:"invitor"`
	InvitedId      string    `json:"invited_id"`
	Invited        User      `json:"invited"`
	InvitationCode string    `json:"invitation_code"`
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}
