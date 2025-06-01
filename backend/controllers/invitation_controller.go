package controllers

import (
	"database/sql"
	"fmt"

	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

func getInvitationByConditions(query string, db *sql.DB, args ...any) ([]models.InvitationModel, error) {
	var invitations []models.InvitationModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var invitation models.InvitationModel
			if err = rows.Scan(&invitation.Id, &invitation.InvitorId, &invitation.InvitedId, &invitation.InvitationCode, &invitation.CreatedAt, &invitation.UpdatedAt); err != nil {
				return invitations, err
			}
			invitation.Invitor, _ = GetUserWithId(invitation.InvitorId, db)
			invitation.Invited, _ = GetUserWithUniqueIdentifier(utils.ConvertAnyToString(invitation.InvitedId), db)
			invitations = append(invitations, invitation)
		}
	}
	return invitations, err
}

func GetInvitationByInvitationCode(invitationCode string, db *sql.DB) ([]models.InvitationModel, error) {
	query := "SELECT * FROM invitations WHERE invitation_code=?"
	return getInvitationByConditions(query, db, invitationCode)

}
func CreateInvitation(invitedId, invitationCode string, db *sql.DB) error {
	invitations, err := GetInvitationByInvitedId(invitedId, db)
	if err == nil && len(invitations) == 0 {
		fmt.Println("length of invitations", len(invitations))
		fmt.Println("invitation code", invitationCode)
		user, err := GetUserWithInvitationCode(invitationCode, db)
		if err == nil {
			fmt.Println("invitor user id", user.Id)
			// invitedUser, err := GetUserWithId(invitedId, db)
			invitedUser, err := GetUserWithUniqueIdentifier(invitedId, db)
			fmt.Println("invited user id ", invitedUser.Id)
			if invitedUser.Id == 0 {
				if err == nil {
					query := "INSERT INTO invitations (invitor_id,invited_id,invitation_code) VALUES (?,?,?)"
					_, err := db.Exec(query, user.Id, invitedId, invitationCode)
					return err
				}
			} else {
				fmt.Println("user exists")
			}
		}
	}
	return err
}
func DeleteInvitationById(invitationId int, db *sql.DB) error {
	query := "DELETE FROM invitations WHERE id=?"
	_, err := db.Exec(query, invitationId)
	return err
}
func GetInvitations(db *sql.DB) ([]models.InvitationModel, error) {
	query := "SELECT * FROM invitations"
	return getInvitationByConditions(query, db)
}
func getInvitationById(invitationId int, db *sql.DB) (models.InvitationModel, error) {
	query := "SELECT * FROM invitations WHERE id=?"
	invitations, err := getInvitationByConditions(query, db, invitationId)
	if err == nil && len(invitations) > 0 {
		return invitations[0], err
	}
	return models.InvitationModel{}, err
}
func GetInvitationByInvitorId(invitorId int, db *sql.DB) ([]models.InvitationModel, error) {
	query := "SELECT * FROM invitations WHERE invitor_id=?"
	return getInvitationByConditions(query, db, invitorId)
}
func GetInvitationByInvitedId(invitedId string, db *sql.DB) ([]models.InvitationModel, error) {
	query := "SELECT * FROM invitations WHERE invited_id=?"
	return getInvitationByConditions(query, db, invitedId)
}
func GetInvitedUsersCount(userId int, db *sql.DB) int {
	var invitationsCount int = 0
	query := "SELECT COUNT(*) FROM invitations WHERE invitor_id=?"
	rows, err := db.Query(query, userId)
	if err == nil {
		for rows.Next() {
			if err = rows.Scan(&invitationsCount); err != nil {
				return invitationsCount
			}
			return invitationsCount
		}
	}
	return invitationsCount
}
func GetFirstInvitations(userId int, db *sql.DB) ([]models.InvitationModel, error) {
	return GetInvitationByInvitorId(userId, db)
}
func IsInvitationExistsIntoSliceOfInvitations(invitationModel models.InvitationModel, invitations []models.InvitationModel) (int, bool) {
	for index, invite := range invitations {
		if invitationModel.Id == invite.Id {
			return index, true
		}
	}
	return -1, false
}
func GetSecondInvitations(userId int, db *sql.DB) ([]models.InvitationModel, error) {
	var secondInvitations []models.InvitationModel
	invitations, err := GetInvitationByInvitorId(userId, db)
	if len(invitations) > 0 && err == nil {
		for _, invitation := range invitations {
			u, err := GetUserWithUniqueIdentifier(invitation.InvitedId, db)
			if err == nil && u.Id > 0 {
				secondInvite, err := GetFirstInvitations(u.Id, db)
				if err == nil && len(secondInvite) > 0 {
					for _, in := range secondInvite {
						if _, exists := IsInvitationExistsIntoSliceOfInvitations(in, secondInvitations); !exists {
							secondInvitations = append(secondInvitations, in)
						}
					}
				}
			}
		}
	}
	return secondInvitations, err
}
func GetThirdInvitations(userId int, db *sql.DB) ([]models.InvitationModel, error) {
	var thirdInvitations []models.InvitationModel
	invitations, err := GetInvitationByInvitorId(userId, db)
	if len(invitations) > 0 && err == nil {
		for _, invitation := range invitations {
			secondUser, err := GetUserWithUniqueIdentifier(invitation.InvitedId, db)
			if err == nil && secondUser.Id > 0 {
				level2Invitations, err := GetFirstInvitations(secondUser.Id, db)
				if err == nil && len(level2Invitations) > 0 {
					for _, i := range level2Invitations {
						u, err := GetUserWithUniqueIdentifier(i.InvitedId, db)
						if err == nil && u.Id > 0 {
							thirdInvite, err := GetFirstInvitations(u.Id, db)
							if err == nil && len(thirdInvite) > 0 {
								for _, in := range thirdInvite {
									if _, exists := IsInvitationExistsIntoSliceOfInvitations(in, thirdInvitations); !exists {
										thirdInvitations = append(thirdInvitations, in)
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return thirdInvitations, err
}
func GetFirstInvitationUsers(payer models.User, db *sql.DB) int {
	invitations, _ := GetInvitationByInvitorId(payer.Id, db)
	return len(invitations)
}
func GetSecondInvitationUsers(payer models.User, db *sql.DB) int {
	invitations, err := GetSecondInvitations(payer.Id, db)
	if err == nil {
		return len(invitations)
	}
	return 0
}
func GetThirdInvitationUsers(payer models.User, db *sql.DB) int {
	invitations, err := GetThirdInvitations(payer.Id, db)
	if err == nil {
		return len(invitations)
	}
	return 0
}
func GetInvitationsByInvitedId(invitedId string, db *sql.DB) ([]models.InvitationModel, error) {
	query := "SELECT * FROM invitations WHERE invited_id=?"
	return getInvitationByConditions(query, db, invitedId)

}
