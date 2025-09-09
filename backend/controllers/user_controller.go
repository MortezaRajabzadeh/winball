package controllers

import (
	"database/sql"
	"errors"
	"fmt"
	"math"
	"strconv"
	"time"

	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

func getUsersWithConditions(query string, db *sql.DB, args ...any) ([]models.User, error) {
	var users []models.User
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var user models.User
			if err = rows.Scan(&user.Id, &user.InvitationCode, &user.Username, &user.Password, &user.Firstname, &user.Lastname, &user.UserUniqueNumber, &user.IsDemoAccount, &user.TonInventory, &user.StarsInventory, &user.UsdtInventory, &user.BtcInventory, &user.CusdInventory, &user.UserProfile, &user.TotalWagered, &user.TotalBets, &user.TotalWins, &user.LevelId, &user.Experience, &user.UserType, &user.Token, &user.CreatedAt, &user.UpdatedAt); err != nil {
				return users, err
			}
			user.Level, _ = GetLevelById(user.LevelId, db)
			users = append(users, user)
		}
	}
	return users, err
}
func createUser(firstname, lastname, username, password, userUniqueNumber, token string, db *sql.DB) (models.User, error) {
	invitationCode := utils.GetRandomString(16)
	levels, err := GetLevels(db)
	levelId := 1
	if err == nil && len(levels) > 0 {
		levelId = levels[0].Id
	}
	user, err := GetUserWithInvitationCode(invitationCode, db)
	if err == nil && user.Id > 0 {
		for user.Id > 0 {
			invitationCode = utils.GetRandomString(16)
			user, _ = GetUserWithInvitationCode(invitationCode, db)
		}
	}
	query := "INSERT INTO users (invitation_code,firstname,lastname,username,password,user_unique_number,total_wagered,total_bets,total_wins,level_id,experience,user_type,token) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)"
	result, err := db.Exec(query, invitationCode, firstname, lastname, username, utils.HashToSha256(password), userUniqueNumber, "0", "0", "0", levelId, 0, "normal", token)
	if err == nil {
		lastInsertedId, _ := result.LastInsertId()
		return GetUserWithId(int(lastInsertedId), db)
	}
	return models.User{}, err
}
func RegisterEntry(firstname, lastname, userIdentifier, username, password, token string, db *sql.DB) (models.User, error) {
	user, err := GetUserWithUniqueIdentifier(userIdentifier, db)
	// if err == nil && user.Id > 0 {
	// 	user.Username.String = username
	// 	user.Token.String = token
	// 	user.Firstname.String = firstname
	// 	user.Lastname.String = lastname
	// 	err = user.Save(db)
	// 	return user, err
	// } else
	if err == nil && user.Id <= 0 {
		user, err = GetUserWithUsername(username, db)
		if user.Id == 0 {
			return createUser(firstname, lastname, username, password, userIdentifier, token, db)
		}
	}
	if user.Id > 0 {
		fmt.Println(user.Id)
		return models.User{}, errors.New("users exists")
	}

	return models.User{}, err
}
func GetUserWithUniqueIdentifier(uniqueIdentifier string, db *sql.DB) (models.User, error) {
	query := "SELECT * FROM users WHERE user_unique_number=?"
	users, err := getUsersWithConditions(query, db, uniqueIdentifier)
	if err == nil && len(users) > 0 {
		return users[0], err
	}
	return models.User{}, err
}
func GetUserWithId(userId int, db *sql.DB) (models.User, error) {
	query := "SELECT * FROM users WHERE id=?"
	users, err := getUsersWithConditions(query, db, userId)
	if err == nil && len(users) > 0 {
		return users[0], err
	}
	return models.User{}, err
}
func GetUserWithToken(token string, db *sql.DB) (models.User, error) {
	query := "SELECT * FROM users WHERE token=?"
	users, err := getUsersWithConditions(query, db, token)
	if err == nil && len(users) > 0 {
		return users[0], err
	}
	return models.User{}, err
}
func Logout(userId int, db *sql.DB) error {
	query := "UPDATE users SET token=? WHERE id=?"
	_, err := db.Exec(query, nil, userId)
	return err
}
func GetUserTeam(userId int, db *sql.DB) ([]models.User, error) {
	var users []models.User
	invitations, err := GetInvitationByInvitorId(userId, db)
	for _, invitation := range invitations {
		if _, exists := IsUserExistsIntoSlice(invitation.Invited, users); !exists {
			users = append(users, invitation.Invited)
		}
	}

	return users, err
}
func IsUserExistsIntoSlice(needle models.User, haystack []models.User) (int, bool) {
	for index, user := range haystack {
		if user.Id == needle.Id {
			return index, true
		}
	}
	return -1, false
}
func GetUserWithUsernameAndPassword(username, password, token string, db *sql.DB) (models.User, error) {
	hashedPassword := utils.HashToSha256(password)
	query := "SELECT * FROM users WHERE username=? AND password=?"
	users, err := getUsersWithConditions(query, db, username, hashedPassword)
	if err == nil && len(users) > 0 {
		user := users[0]
		user.Token.String = token
		user.Save(db)
		users, err = getUsersWithConditions(query, db, username, hashedPassword)
		return users[0], err
	}
	return models.User{}, err
}
func GetUsersCount(db *sql.DB) string {
	query := "SELECT COUNT(*) FROM users"
	var usersCount string
	rows, err := db.Query(query)
	if err == nil {
		for rows.Next() {
			if err = rows.Scan(&usersCount); err != nil {
				return "0"
			}
			return usersCount
		}
	}
	return usersCount
}
func GetUserWithInvitationCode(invitationCode string, db *sql.DB) (models.User, error) {
	query := "SELECT * FROM users WHERE invitation_code=?"
	users, err := getUsersWithConditions(query, db, invitationCode)
	if err == nil && len(users) > 0 {
		return users[0], err
	}
	return models.User{}, err
}
func GetUserWithUsername(username string, db *sql.DB) (models.User, error) {
	usernameSearchedQuery := fmt.Sprintf("%%%s%%", username)
	query := "SELECT * FROM users WHERE username LIKE ?"
	users, err := getUsersWithConditions(query, db, usernameSearchedQuery)
	if err == nil && len(users) > 0 {
		return users[0], err
	}
	return models.User{}, errors.New("user not found")
}
func AddAmountToUserInventoryByCoinType(amount, percent float64, user models.User, coinType string, db *sql.DB) {
	switch coinType {
	case "ton":
		{
			tonAmountPay := amount * percent
			userTonInventory, err := strconv.ParseFloat(user.TonInventory, 64)
			if err == nil {
				userTonInventory += tonAmountPay
				user.TonInventory = utils.ConvertAnyToString(userTonInventory)
				//here is from ton inventory
				userTotalWins, _ := strconv.ParseFloat(user.TotalWins, 64)
				userTotalWins += tonAmountPay
				user.TotalWins = utils.ConvertAnyToString(userTotalWins)
				user.Save(db)
				query := "INSERT INTO transactions (coin_type,transaction_type,amount,status,transaction_id,more_info,creator_id) VALUES (?,?,?,?,?,?,?)"
				db.Exec(query, coinType, "deposit", tonAmountPay, "success", utils.GetRandomString(16), fmt.Sprintf("the %v amount is added to your inventory cause of referal link", tonAmountPay), user.Id)
				// CreateTransaction("ton", "deposit", utils.ConvertAnyToString(tonAmountPay), "success", utils.GetRandomString(16), fmt.Sprintf("the %v amount is added to your inventory cause of referal link", tonAmountPay), user.Id, db)
			}
		}
	case "stars":
		{
			starsAmountPay := amount * percent
			userStarsInventory, err := strconv.ParseFloat(user.StarsInventory, 64)
			if err == nil {
				userStarsInventory += starsAmountPay
				userStarsInventory = math.Floor(userStarsInventory)
				//here is from stars inventory
				user.TotalBets += int(userStarsInventory)
				user.StarsInventory = utils.ConvertAnyToString(userStarsInventory)
				user.Save(db)
			}
		}
	}
}
func GetUserInventoryByCoinType(coinType string, user models.User) float32 {
	switch coinType {
	case "ton":
		{
			tonInventory, err := strconv.ParseFloat(user.TonInventory, 64)
			if err == nil {
				return float32(tonInventory)
			}
		}
	case "stars":
		{
			starsInventory, err := strconv.ParseFloat(user.StarsInventory, 64)
			if err == nil {
				return float32(starsInventory)
			}
		}
	}
	return 0
}
func GetTeamReportModel(userId int, db *sql.DB) (models.TeamReportModel, error) {
	var registerationCount int = 0
	var firstDepositTonUsers float64 = 0
	var firstDepositStarsUsers float64 = 0
	var depositsTonUsers float64 = 0
	var depositsStarsUsers float64 = 0
	var withdrawTonUsers float64 = 0
	var withdrawStarsUsers float64 = 0
	firstInvitations, err := GetFirstInvitations(userId, db)
	if err == nil && len(firstInvitations) > 0 {
		for _, i := range firstInvitations {
			invitedUser, _ := GetUserWithUniqueIdentifier(i.InvitedId, db)
			if d := time.Until(i.CreatedAt); d.Hours() < 24 {
				registerationCount++
				tonTransactions, err := GetFirstTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "ton", "success", invitedUser.Id, db)
				if err == nil && len(tonTransactions) > 0 {
					firstDepositTonUsers += GetSumOfTheTransactionsAmount(tonTransactions)
				}
				starsTransactions, err := GetFirstTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "stars", "success", invitedUser.Id, db)
				if err == nil && len(starsTransactions) > 0 {
					firstDepositStarsUsers += GetSumOfTheTransactionsAmount(starsTransactions)
				}
			}
			tonTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "ton", "success", invitedUser.Id, db)
			if err == nil && len(tonTransactions) > 0 {
				depositsTonUsers += GetSumOfTheTransactionsAmount(tonTransactions)
			}
			withdrawTonTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("withdraw", "ton", "success", invitedUser.Id, db)
			if err == nil && len(withdrawTonTransactions) > 0 {
				withdrawTonUsers += GetSumOfTheTransactionsAmount(withdrawTonTransactions)
			}
			withdrawStarsTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("withdraw", "stars", "success", invitedUser.Id, db)
			if err == nil && len(withdrawStarsTransactions) > 0 {
				withdrawStarsUsers += GetSumOfTheTransactionsAmount(withdrawTonTransactions)
			}
			starsTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "stars", "success", invitedUser.Id, db)
			if err == nil && len(starsTransactions) > 0 {
				depositsStarsUsers += GetSumOfTheTransactionsAmount(starsTransactions)
			}
		}
	}
	secondInvitations, err := GetSecondInvitations(userId, db)
	if err == nil && len(secondInvitations) > 0 {
		for _, i := range secondInvitations {
			invitedUser, _ := GetUserWithUniqueIdentifier(i.InvitedId, db)
			if d := time.Until(i.CreatedAt); d.Hours() < 24 {
				registerationCount++
				tonTransactions, err := GetFirstTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "ton", "success", invitedUser.Id, db)
				if err == nil && len(tonTransactions) > 0 {
					firstDepositTonUsers += GetSumOfTheTransactionsAmount(tonTransactions)
				}
				starsTransactions, err := GetFirstTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "stars", "success", invitedUser.Id, db)
				if err == nil && len(starsTransactions) > 0 {
					firstDepositStarsUsers += GetSumOfTheTransactionsAmount(starsTransactions)
				}
			}
			tonTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "ton", "success", invitedUser.Id, db)
			if err == nil && len(tonTransactions) > 0 {
				depositsTonUsers += GetSumOfTheTransactionsAmount(tonTransactions)
			}
			withdrawTonTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("withdraw", "ton", "success", invitedUser.Id, db)
			if err == nil && len(withdrawTonTransactions) > 0 {
				withdrawTonUsers += GetSumOfTheTransactionsAmount(withdrawTonTransactions)
			}
			withdrawStarsTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("withdraw", "stars", "success", invitedUser.Id, db)
			if err == nil && len(withdrawStarsTransactions) > 0 {
				withdrawStarsUsers += GetSumOfTheTransactionsAmount(withdrawTonTransactions)
			}
			starsTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "stars", "success", invitedUser.Id, db)
			if err == nil && len(starsTransactions) > 0 {
				depositsStarsUsers += GetSumOfTheTransactionsAmount(starsTransactions)
			}
		}
	}
	thirdInvitations, err := GetThirdInvitations(userId, db)
	if err == nil && len(thirdInvitations) > 0 {
		for _, i := range thirdInvitations {
			invitedUser, _ := GetUserWithUniqueIdentifier(i.InvitedId, db)
			if d := time.Until(i.CreatedAt); d.Hours() < 24 {
				registerationCount++
				tonTransactions, err := GetFirstTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "ton", "success", invitedUser.Id, db)
				if err == nil && len(tonTransactions) > 0 {
					firstDepositTonUsers += GetSumOfTheTransactionsAmount(tonTransactions)
				}
				starsTransactions, err := GetFirstTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "stars", "success", invitedUser.Id, db)
				if err == nil && len(starsTransactions) > 0 {
					firstDepositStarsUsers += GetSumOfTheTransactionsAmount(starsTransactions)
				}
			}
			tonTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "ton", "success", invitedUser.Id, db)
			if err == nil && len(tonTransactions) > 0 {
				depositsTonUsers += GetSumOfTheTransactionsAmount(tonTransactions)
			}
			withdrawTonTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("withdraw", "ton", "success", invitedUser.Id, db)
			if err == nil && len(withdrawTonTransactions) > 0 {
				withdrawTonUsers += GetSumOfTheTransactionsAmount(withdrawTonTransactions)
			}
			withdrawStarsTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("withdraw", "stars", "success", invitedUser.Id, db)
			if err == nil && len(withdrawStarsTransactions) > 0 {
				withdrawStarsUsers += GetSumOfTheTransactionsAmount(withdrawTonTransactions)
			}
			starsTransactions, err := GetTransactionsByCreatorIdTransactionTypeAndCoinTypeAndStatus("deposit", "stars", "success", invitedUser.Id, db)
			if err == nil && len(starsTransactions) > 0 {
				depositsStarsUsers += GetSumOfTheTransactionsAmount(starsTransactions)
			}
		}
	}
	return models.TeamReportModel{
		RegistrationUsers:      registerationCount,
		FirstDepositTonUsers:   firstDepositTonUsers,
		FirstDepositStarsUsers: firstDepositStarsUsers,
		DepositsTonUsers:       depositsTonUsers,
		DepositsStarsUsers:     depositsStarsUsers,
		WithdrawTonUsers:       withdrawTonUsers,
		WithdrawStarsUsers:     withdrawStarsUsers,
	}, err
}
func ChangeUserTonAmount(amount float64, userId int, db *sql.DB) error {
	user, err := GetUserWithId(userId, db)
	if err == nil {
		user.TonInventory = utils.ConvertAnyToString(amount)
		err = user.Save(db)
	}
	return err
}
func ChangeUserStarsAmount(amount, userId int, db *sql.DB) error {
	user, err := GetUserWithId(userId, db)
	if err == nil {
		user.StarsInventory = utils.ConvertAnyToString(amount)
		err = user.Save(db)
	}
	return err
}
func ChangeUserType(userType string, userId int, db *sql.DB) error {
	user, err := GetUserWithId(userId, db)
	if err == nil && user.Id > 0 {
		user.UserType = userType
		return user.Save(db)
	}
	return err
}
func ChangeDemoAccount(userId, isDemo int, db *sql.DB) error {
	user, err := GetUserWithId(userId, db)
	if err == nil && user.Id > 0 {
		user.IsDemoAccount = utils.ConvertAnyToString(isDemo)
		return user.Save(db)
	}
	return err
}
func GetAllUsersPerPage(page int, db *sql.DB) ([]models.User, error) {
	query := "SELECT * FROM users LIMIT ? OFFSET ?"
	return getUsersWithConditions(query, db, utils.ITEM_PER_PAGE, (page-1)*utils.ITEM_PER_PAGE)
}
