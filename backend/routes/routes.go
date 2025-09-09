package routes

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/gorilla/websocket"
	"github.com/khodehamid/winball_go_back/configs"
	"github.com/khodehamid/winball_go_back/controllers"
	"github.com/khodehamid/winball_go_back/database"
	"github.com/khodehamid/winball_go_back/middleware"
	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
	"github.com/xssnick/tonutils-go/ton/wallet"
)

var chatRoom = models.RoomModel{Users: []models.UserRoom{}, Mutex: &sync.RWMutex{}}

func SetupRoutes(sm *http.ServeMux) {
	// these are from activity controller
	sm.Handle("/create-activity", middleware.ValidateJWT(createActivity))
	sm.Handle("/edit-activity", middleware.ValidateJWT(editActivity))
	sm.Handle("/delete-activity-by-id", middleware.ValidateJWT(deleteActivityById))
	sm.Handle("/get-activities", middleware.ValidateJWT(getActivities))
	// these are from activity controller
	// these are from announcement controller
	sm.Handle("/craete-announcement", middleware.ValidateJWT(createAnnouncement))
	sm.Handle("/edit-announcement", middleware.ValidateJWT(editAnnouncementt))
	sm.Handle("/delete-announcement-by-id", middleware.ValidateJWT(deleteAnnouncementById))
	sm.Handle("/get-announcements", middleware.ValidateJWT(getAnnouncements))
	// these are from announcement controller
	// these are from deposit_controller
	// sm.Handle("/create-deposit", middleware.ValidateJWT(createDeposit))
	// sm.Handle("/get-deposits", middleware.ValidateJWT(getDepositsByUserId))
	// sm.Handle("/get-deposit-by-transaction-id", middleware.ValidateJWT(getDepositByTransactionId))
	// these are from deposit_controller
	// these are from help_controller
	sm.Handle("/create-help", middleware.ValidateJWT(createHelp))
	sm.Handle("/edit-help", middleware.ValidateJWT(editHelp))
	sm.Handle("/get-helps", middleware.ValidateJWT(getHelps))
	sm.Handle("/delete-help-with-id", middleware.ValidateJWT(deleteHelpWithId))
	// these are from help_controller
	// these are from invitation_controller
	sm.HandleFunc("/create-invitation", createInvitation)
	sm.Handle("/get-invitation-by-invitor-id", middleware.ValidateJWT(getInvitationByInvitorId))
	sm.Handle("/get-invited-users-count", middleware.ValidateJWT(getInvitedUsersCount))
	sm.Handle("/get-first-invitation-users", middleware.ValidateJWT(getFirstInvitationUsers))
	sm.Handle("/get-second-invitation-users", middleware.ValidateJWT(getSecondInvitationUsers))
	sm.Handle("/get-third-invitation-users", middleware.ValidateJWT(getThirdInvitationUsers))
	// sm.Handle("/get-invitations", middleware.ValidateJWT(getInvitations))
	// these are from invitation_controller
	// these are from level_controller
	sm.Handle("/create-level", middleware.ValidateJWT(createLevel))
	sm.Handle("/edit-level", middleware.ValidateJWT(editLevel))
	sm.Handle("/delete-level-by-id", middleware.ValidateJWT(deleteLevelById))
	sm.Handle("/get-levels", middleware.ValidateJWT(getLevels))
	// these are from level_controller
	// these are from one_min_game_controller
	sm.Handle("/get-last-one-min-game", middleware.ValidateJWT(getLastOneMinGame))
	sm.Handle("/get-game-with-game-hash", middleware.ValidateJWT(getGameWithGameHash))
	sm.Handle("/get-two-last-one-min-game", middleware.ValidateJWT(getTwoLastOneMinGame))
	sm.Handle("/get-two-last-one-min-game-by-game-type", middleware.ValidateJWT(getTwoLastOneMinGameByGameType))
	sm.Handle("/get-one-min-game-with-id", middleware.ValidateJWT(getOneMinGameWithId))
	sm.Handle("/get-old-one-min-games-per-page", middleware.ValidateJWT(getOldOneMinGamesByPage))
	sm.Handle("/get-old-one-min-games-by-game-type-and-page", middleware.ValidateJWT(getOldOneMinGamesByGameTypeAndPage))
	// Red Black Game specific endpoints
	sm.Handle("/get-last-red-black-30s", middleware.ValidateJWT(getLastRedBlack30s))
	sm.Handle("/get-red-black-game-history", middleware.ValidateJWT(getRedBlackGameHistory))
	// these are from one_min_game_controller
	// these are from site_settings_controller
	sm.Handle("/create-site-setting", middleware.ValidateJWT(createSiteSetting))
	sm.HandleFunc("/get-site-settings", getSiteSettings)
	// these are from site_settings_controller
	// these are from support_controller
	sm.Handle("/get-supports-by-room-id", middleware.ValidateJWT(getSupportsByRoomId))
	sm.Handle("/get-support-by-user-id", middleware.ValidateJWT(getSupportByUserId))
	sm.Handle("/create-support-message", middleware.ValidateJWT(createSupportMessage))
	// these are from support_controller
	// these are from transaction_controller
	sm.Handle("/get-transaction-by-creator-id", middleware.ValidateJWT(getTransactionsByCreatorId))
	sm.Handle("/get-transactions-by-user-id", middleware.ValidateJWT(getTransactionsByUserId))
	sm.Handle("/get-transaction-with-status", middleware.ValidateJWT(getTransactionsWithStatus))
	sm.Handle("/get-transactions-by-transaction-type-and-status-and-page", middleware.ValidateJWT(getTransactionsByTransactionTypeAndStatusAndPage))
	// sm.Handle("/get-transaction-with-transaction-id", middleware.ValidateJWT(getTransactionWithTransactionId))
	// these are from transaction_controller
	// these are from user_bet_controller
	sm.Handle("/create-user-bet", middleware.ValidateJWT(createUserBet))
	sm.Handle("/edit-user-bet", middleware.ValidateJWT(editUserBet))
	sm.Handle("/get-user-bets", middleware.ValidateJWT(getUserBets))
	sm.Handle("/get-user-bets-by-user-id", middleware.ValidateJWT(getUserBetsByUserId))
	sm.Handle("/get-user-bet-by-game-id", middleware.ValidateJWT(getUserBetsByGameId))
	sm.Handle("/get-two-last-user-bets", middleware.ValidateJWT(getTwoLastUserBets))
	sm.Handle("/get-user-bets-per-page", middleware.ValidateJWT(getUserBetsPerPage))
	sm.Handle("/get-user-bets-count", middleware.ValidateJWT(getUserBetsCount))
	sm.Handle("/get-user-total-wins", middleware.ValidateJWT(getUserTotalWins))
	// these are from user_bet_controller
	// these are from user_controller
	sm.HandleFunc("/register-entry", registerEntry)
	sm.HandleFunc("/login-entry", loginUser)
	sm.Handle("/get-user-team", middleware.ValidateJWT(getUserTeam))
	sm.Handle("/update-user", middleware.ValidateJWT(updateUser))
	sm.HandleFunc("/get-user-with-unique-identifier", getUserWithUniqueIdentifier)
	sm.Handle("/get-user-with-username", middleware.ValidateJWT(getUserWithUsername))
	sm.Handle("/get-team-report-model", middleware.ValidateJWT(getTeamReportModel))
	sm.Handle("/change-user-ton-amount", middleware.ValidateJWT(changeUserTonAmount))
	sm.Handle("/change-user-stars-amount", middleware.ValidateJWT(changeUserStarsAmount))
	sm.Handle("/change-user-type", middleware.ValidateJWT(changeUserType))
	sm.Handle("/change-user-demo-account", middleware.ValidateJWT(changeUserDemoAccount))
	sm.Handle("/get-all-users-per-page", middleware.ValidateJWT(getAllUsersPerPage))
	// these are from user_controller
	// these are from withdraw_controller
	sm.Handle("/create-withdraw", middleware.ValidateJWT(createWithdraw))
	sm.Handle("/get-withdraw-by-creator", middleware.ValidateJWT(getWithdrawByCreator))
	sm.Handle("/get-withdraw-by-transaction-id", middleware.ValidateJWT(getWithdrawByTransactionId))
	sm.Handle("/get-withdraws-by-status-and-page", middleware.ValidateJWT(getWithdrawsByStatusAndPage))
	sm.Handle("/change-withdraw-status", middleware.ValidateJWT(changeWithdrawStatus))
	sm.Handle("/get-withdrawable-amount", middleware.ValidateJWT(getWithdrawableAmount))
	// these are from withdraw_controller
	// these are from slider_controller
	sm.Handle("/create-slider", middleware.ValidateJWT(createSlider))
	sm.Handle("/get-slider", middleware.ValidateJWT(getSlider))
	sm.Handle("/delete-slider", middleware.ValidateJWT(deleteSlider))
	// these are from slider_controller
	//websocket game
	sm.HandleFunc("/telegram-bot-endpoint", telegramBotEndpoint)
	sm.HandleFunc("/ws", websocketConn)
	//statistics controllers.
	sm.Handle("/get-site-statistics", middleware.ValidateJWT(getSiteStatistics))
	sm.HandleFunc("/", rootWeb)
	sm.Handle("/upload-file", middleware.ValidateJWT(uploadFile))
	sm.HandleFunc("/serve-image", serveImage)

	//here is tonkeeper controller
	sm.Handle("/check-ton-transactions", middleware.ValidateJWT(checkTonTransactions))
	//here is tonkeeper controller
	//here is about coinmarketcap
	sm.HandleFunc("/get-coins", getCoins)
	//here is about coinmarketcap
	//here is from game timer
	db, _ := database.GetDatabase()
	go func(db *sql.DB) {
		for range time.Tick(time.Second) {
			lastOneMinGameModel, err := controllers.GetLastOneMinGame("one_min_game", db)
			if err == nil {
				if lastOneMinGameModel.Id == 0 {
					createdGame, err := controllers.CreateOneMinGame("one_min_game", db)
					if err == nil {
						var currentTime = time.Now()
						diff := currentTime.Sub(createdGame.UpdatedAt)
						seconds := int(diff.Seconds())
						var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: createdGame, GameSecondsRemains: utils.GetGameDiffByGameType("one_min_game") - seconds}
						bytes, _ := json.Marshal(websocketCommand)
						chatRoom.BroadcastMessageToUsers(bytes)
					}
				} else {
					var currentTime = time.Now()
					diff := currentTime.Sub(lastOneMinGameModel.UpdatedAt)
					seconds := int(diff.Seconds())
					if seconds > 60 {
						updatedGame := controllers.SetRandomResultToOneMinGame(lastOneMinGameModel.GameHash, db)
						controllers.CalculateUserBetEndGameResult(lastOneMinGameModel.GameHash, db)
						var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameUpdatedCommand, Value: updatedGame, GameSecondsRemains: utils.GetGameDiffByGameType("one_min_game") - seconds}
						bytes, _ := json.Marshal(websocketCommand)
						chatRoom.BroadcastMessageToUsers(bytes)
						createdGame, _ := controllers.CreateOneMinGame("one_min_game", db)
						websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: createdGame, GameSecondsRemains: utils.GetGameDiffByGameType("one_min_game") - seconds}
						bytes, _ = json.Marshal(websocketCommand)
						chatRoom.BroadcastMessageToUsers(bytes)
					}
				}
				lastThreeMinGameModel, err := controllers.GetLastThreeMinGame(db)
				if err == nil {
					if lastThreeMinGameModel.Id == 0 {
						createdGame, err := controllers.CreateOneMinGame("three_min_game", db)
						if err == nil {
							var currentTime = time.Now()
							diff := currentTime.Sub(createdGame.UpdatedAt)
							seconds := int(diff.Seconds())
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: createdGame, GameSecondsRemains: utils.GetGameDiffByGameType("three_min_game") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					} else {
						var currentTime = time.Now()
						diff := currentTime.Sub(lastThreeMinGameModel.UpdatedAt)
						seconds := int(diff.Seconds())
						if seconds > 180 {
							updatedGame := controllers.SetRandomResultToOneMinGame(lastThreeMinGameModel.GameHash, db)
							controllers.CalculateUserBetEndGameResult(lastThreeMinGameModel.GameHash, db)
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameUpdatedCommand, Value: updatedGame, GameSecondsRemains: utils.GetGameDiffByGameType("three_min_game") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
							createdGame, _ := controllers.CreateOneMinGame("three_min_game", db)
							websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: createdGame, GameSecondsRemains: utils.GetGameDiffByGameType("three_min_game") - seconds}
							bytes, _ = json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					}
				} else {
					fmt.Println(err.Error())
				}
				lastFiveMinGameModel, err := controllers.GetLastFiveMinGame(db)
				if err == nil {
					if lastFiveMinGameModel.Id == 0 {
						createdGame, err := controllers.CreateOneMinGame("five_min_game", db)
						if err == nil {
							var currentTime = time.Now()
							diff := currentTime.Sub(createdGame.UpdatedAt)
							seconds := int(diff.Seconds())
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: createdGame, GameSecondsRemains: utils.GetGameDiffByGameType("five_min_game") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					} else {
						var currentTime = time.Now()
						diff := currentTime.Sub(lastFiveMinGameModel.UpdatedAt)
						seconds := int(diff.Seconds())
						if seconds > 300 {
							updatedGame := controllers.SetRandomResultToOneMinGame(lastFiveMinGameModel.GameHash, db)
							controllers.CalculateUserBetEndGameResult(lastFiveMinGameModel.GameHash, db)
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameUpdatedCommand, Value: updatedGame, GameSecondsRemains: utils.GetGameDiffByGameType("five_min_game") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
							createdGame, _ := controllers.CreateOneMinGame("five_min_game", db)
							websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: createdGame, GameSecondsRemains: utils.GetGameDiffByGameType("five_min_game") - seconds}
							bytes, _ = json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					}
				} else {
					fmt.Println(err.Error())
				}
				// red_black 30s
				lastRB30, err := controllers.GetLastOneMinGame("red_black_30s", db)
				if err == nil {
					if lastRB30.Id == 0 {
						created, err := controllers.CreateOneMinGame("red_black_30s", db)
						if err == nil {
							var currentTime = time.Now()
							diff := currentTime.Sub(created.UpdatedAt)
							seconds := int(diff.Seconds())
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: created, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_30s") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					} else {
						var currentTime = time.Now()
						diff := currentTime.Sub(lastRB30.UpdatedAt)
						seconds := int(diff.Seconds())
						if seconds > 30 {
							updated := controllers.SetRandomResultToOneMinGame(lastRB30.GameHash, db)
							controllers.CalculateUserBetEndGameResult(lastRB30.GameHash, db)
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameUpdatedCommand, Value: updated, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_30s") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
							created, _ := controllers.CreateOneMinGame("red_black_30s", db)
							websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: created, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_30s") - seconds}
							bytes, _ = json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					}
				} else {
					fmt.Println(err.Error())
				}
				// red_black 3m
				lastRB3, err := controllers.GetLastOneMinGame("red_black_3m", db)
				if err == nil {
					if lastRB3.Id == 0 {
						created, err := controllers.CreateOneMinGame("red_black_3m", db)
						if err == nil {
							var currentTime = time.Now()
							diff := currentTime.Sub(created.UpdatedAt)
							seconds := int(diff.Seconds())
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: created, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_3m") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					} else {
						var currentTime = time.Now()
						diff := currentTime.Sub(lastRB3.UpdatedAt)
						seconds := int(diff.Seconds())
						if seconds > 180 {
							updated := controllers.SetRandomResultToOneMinGame(lastRB3.GameHash, db)
							controllers.CalculateUserBetEndGameResult(lastRB3.GameHash, db)
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameUpdatedCommand, Value: updated, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_3m") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
							created, _ := controllers.CreateOneMinGame("red_black_3m", db)
							websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: created, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_3m") - seconds}
							bytes, _ = json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					}
				} else {
					fmt.Println(err.Error())
				}
				// red_black 5m
				lastRB5, err := controllers.GetLastOneMinGame("red_black_5m", db)
				if err == nil {
					if lastRB5.Id == 0 {
						created, err := controllers.CreateOneMinGame("red_black_5m", db)
						if err == nil {
							var currentTime = time.Now()
							diff := currentTime.Sub(created.UpdatedAt)
							seconds := int(diff.Seconds())
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: created, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_5m") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					} else {
						var currentTime = time.Now()
						diff := currentTime.Sub(lastRB5.UpdatedAt)
						seconds := int(diff.Seconds())
						if seconds > 300 {
							updated := controllers.SetRandomResultToOneMinGame(lastRB5.GameHash, db)
							controllers.CalculateUserBetEndGameResult(lastRB5.GameHash, db)
							var websocketCommand = models.ServerWebsocketCommand{Command: configs.GameUpdatedCommand, Value: updated, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_5m") - seconds}
							bytes, _ := json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
							created, _ := controllers.CreateOneMinGame("red_black_5m", db)
							websocketCommand = models.ServerWebsocketCommand{Command: configs.GameCreatedCommand, Value: created, GameSecondsRemains: utils.GetGameDiffByGameType("red_black_5m") - seconds}
							bytes, _ = json.Marshal(websocketCommand)
							chatRoom.BroadcastMessageToUsers(bytes)
						}
					}
				} else {
					fmt.Println(err.Error())
				}
			} else {
				fmt.Println(err.Error())
			}
		}
	}(db)
}
func getFirstInvitationUsers(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			firstClass := controllers.GetFirstInvitationUsers(*user, db)
			encoder := json.NewEncoder(w)
			encoder.Encode(firstClass)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusNotAcceptable)
		}
	}
}

// Red Black 30s specific endpoints
func getLastRedBlack30s(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			game, err := controllers.GetLastOneMinGame("red_black_30s", db)
			if err == nil {
				var currentTime = time.Now()
				diff := currentTime.Sub(game.UpdatedAt)
				seconds := int(diff.Seconds())
				response := map[string]interface{}{
					"game": game,
					"seconds_remaining": utils.GetGameDiffByGameType("red_black_30s") - seconds,
				}
				encoder := json.NewEncoder(w)
				encoder.Encode(response)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

func getRedBlackGameHistory(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			var page = 1
			var err error
			pageString := r.URL.Query().Get("page")
			if pageString != "" {
				page, err = strconv.Atoi(pageString)
				if err != nil {
					page = 1
				}
			}

			db, _ := database.GetDatabase()
			games, err := controllers.GetOldOneMinGamesByGameTypeAndPage("red_black_30s", page, utils.ITEM_PER_PAGE, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(games)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getSecondInvitationUsers(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			secondClass := controllers.GetSecondInvitationUsers(*user, db)
			encoder := json.NewEncoder(w)
			encoder.Encode(secondClass)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusNotAcceptable)
		}
	}
}
func getThirdInvitationUsers(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			thirdClass := controllers.GetThirdInvitationUsers(*user, db)
			encoder := json.NewEncoder(w)
			encoder.Encode(thirdClass)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusNotAcceptable)
		}
	}
}
func getCoins(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		{
			request, err := http.NewRequest(http.MethodGet, configs.CoinValuesUrl, nil)
			if err == nil {
				request.Header.Set("Content-Type", "application/json")
				request.Header.Set("Accept", "application/json")
				request.Header.Set("X-CMC_PRO_API_KEY", configs.CoinMarketCapApi)
				client := http.Client{Timeout: time.Second * 30}
				response, err := client.Do(request)
				if err == nil {
					responseBody, err := io.ReadAll(response.Body)
					if err == nil {
						w.Write(responseBody)
						defer response.Body.Close()
					} else {
						fmt.Println(err.Error())
					}

				} else {
					fmt.Println(err.Error())
				}
			} else {
				fmt.Println(err.Error())
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func checkTonTransactions(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			ctx := context.Background()
			db, _ := database.GetDatabase()
			api := controllers.CreateApiWallet(false, ctx)
			words := strings.Split(configs.CasinoWallet, " ")
			wallet := controllers.GetWalletFromWords(api, wallet.ConfigV5R1Final{NetworkGlobalID: wallet.MainnetGlobalID}, words, ctx)
			block := controllers.GetBlockFromApi(api, ctx)

			// فقط چک کردن تراکنش‌های این کاربر خاص
			found := controllers.CheckUserSpecificTransactions(api, wallet, block, db, ctx, user.UserUniqueNumber)

			response := map[string]interface{}{
				"success": true,
				"message": "Transaction check completed",
				"found_new_transactions": found,
			}

			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(response)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func uploadFile(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string][]byte
			body, _ := io.ReadAll(r.Body)
			json.Unmarshal(body, &jsonOfInputs)
			fileBytes := jsonOfInputs["file"]
			fileType := jsonOfInputs["file_type"]
			fileExtension := jsonOfInputs["file_extension"]
			if fileBytes == nil || fileType == nil || fileExtension == nil {
				http.Error(w, "file and file_type and file_extension are required fields", http.StatusBadRequest)
			} else {
				path, err := controllers.UploadFile(fileBytes, user, string(fileType), string(fileExtension))
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(path)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func serveImage(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		{
			imagePath := r.URL.Query().Get("image_path")
			if imagePath == "" {
				http.Error(w, "image_path is required", http.StatusBadRequest)
			} else {
				imagePathFiltered := utils.FilterImageStringPath(imagePath)
				image, err := os.ReadFile(imagePathFiltered)
				if err != nil {
					http.Error(w, err.Error(), http.StatusInternalServerError)
				} else {
					w.Header().Set("Content-Type", "image/jpeg")
					w.Write(image)
					// io.Copy(w, image)
				}
			}
		}
	default:
		{
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getSiteStatistics(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			statistics, err := controllers.GetSiteStatistics(db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(statistics)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func telegramBotEndpoint(w http.ResponseWriter, r *http.Request) {
	controllers.StartTelegramBot()
}
func rootWeb(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hello"))
}
func getAllUsersPerPage(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, err := database.GetDatabase()
			if err == nil {
				pageString := r.URL.Query().Get("page")
				var page int = 1
				if pageString != "" {
					page, err = strconv.Atoi(pageString)
					if err != nil {
						page = 1
					}
				}
				users, err := controllers.GetAllUsersPerPage(page, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(users)
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func changeUserDemoAccount(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			userIdString, isDemoString := r.URL.Query().Get("user_id"), r.URL.Query().Get("is_demo")
			if userIdString == "" || isDemoString == "" {
				http.Error(w, "user_id and is_demo are required fields", http.StatusNotAcceptable)
			} else {
				userId, err := strconv.Atoi(userIdString)
				if err == nil {
					isDemo, err := strconv.Atoi(isDemoString)
					if err == nil {
						db, _ := database.GetDatabase()
						controllers.ChangeDemoAccount(userId, isDemo, db)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}

		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func changeUserType(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			userTypeString, userIdString := r.URL.Query().Get("user_type"), r.URL.Query().Get("user_id")
			if userTypeString == "" || userIdString == "" {
				http.Error(w, "user_type and user_id are required fields", http.StatusNotAcceptable)
			} else {
				userId, err := strconv.Atoi(userIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					err = controllers.ChangeUserType(userTypeString, userId, db)
					if err == nil {
						w.WriteHeader(http.StatusOK)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}

			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusNotAcceptable)
		}
	}
}
func changeUserStarsAmount(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			amountString := r.URL.Query().Get("amount")
			userIdString := r.URL.Query().Get("user_id")
			if amountString == "" || userIdString == "" {
				http.Error(w, "amount and user_id are required fields", http.StatusNotAcceptable)
				return
			}
			amount, err := strconv.Atoi(amountString)
			if err == nil {
				userId, err := strconv.Atoi(userIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					err := controllers.ChangeUserStarsAmount(amount, userId, db)
					if err == nil {
						w.WriteHeader(http.StatusOK)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func changeUserTonAmount(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			amountString := r.URL.Query().Get("amount")
			userIdString := r.URL.Query().Get("user_id")
			if amountString == "" || userIdString == "" {
				http.Error(w, "amount and user_id are required fields", http.StatusNotAcceptable)
				return
			}
			amount, err := strconv.ParseFloat(amountString, 64)
			if err == nil {
				userId, err := strconv.Atoi(userIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					otherUser, err := controllers.GetUserWithId(userId, db)
					if err == nil {
						otherUserTon, _ := strconv.ParseFloat(otherUser.TonInventory, 64)
						// err = controllers.ChangeUserTonAmount(amount, userId, db)
						transactionId := utils.GetRandomString(16)
						controllers.CreateTransaction("ton", "deposit", utils.ConvertAnyToString(utils.GetDifferenceBetweenUserAmountAndDepositAmount(amount, otherUserTon)), "success", transactionId, "Created Deposit With Admin Command", userId, db)
						w.WriteHeader(http.StatusOK)

					} else {
						fmt.Println(err.Error())
						w.WriteHeader(http.StatusInternalServerError)
						w.Write([]byte("user not found"))
					}
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getTeamReportModel(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			teamReportModel, err := controllers.GetTeamReportModel(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(teamReportModel)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserWithUsername(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			username := r.URL.Query().Get("username")
			db, _ := database.GetDatabase()
			user, err := controllers.GetUserWithUsername(username, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(user)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserWithUniqueIdentifier(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		{
			userUniqueIdentifier := r.URL.Query().Get("unique_identifier")
			if userUniqueIdentifier == "" {
				http.Error(w, "unique_identifier is required field", http.StatusNotAcceptable)
			} else {
				db, _ := database.GetDatabase()
				user, err := controllers.GetUserWithUniqueIdentifier(userUniqueIdentifier, db)
				if err == nil {
					if user.Id > 0 {
						user.Token.String, _ = middleware.CreateToken()
						user.Save(db)
						user, _ = controllers.GetUserWithUniqueIdentifier(userUniqueIdentifier, db)
						encoder := json.NewEncoder(w)
						encoder.Encode(user)
					} else {
						token, _ := middleware.CreateToken()
						_, err := controllers.RegisterEntry("", "", userUniqueIdentifier, userUniqueIdentifier, userUniqueIdentifier, token, db)
						if err == nil {
							user, err = controllers.GetUserWithUniqueIdentifier(userUniqueIdentifier, db)
							encoder := json.NewEncoder(w)
							encoder.Encode(user)
						} else {
							utils.HandleErrors(w, err)
						}
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func loginUser(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		{
			username, password := r.URL.Query().Get("username"), r.URL.Query().Get("password")
			if username == "" || password == "" {
				http.Error(w, "username and password are required fields", http.StatusNotAcceptable)
			} else {
				token, _ := middleware.CreateToken()
				db, _ := database.GetDatabase()
				user, err := controllers.GetUserWithUsernameAndPassword(username, password, token, db)
				if err == nil {
					if user.Id == 0 {
						http.Error(w, "User not found", http.StatusNotFound)
					} else {
						encoder := json.NewEncoder(w)
						encoder.Encode(user)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}

		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func registerEntry(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			err := json.Unmarshal(bytes, &jsonOfInputs)
			if err == nil {
				if jsonOfInputs["firstname"] == nil || jsonOfInputs["lastname"] == nil || jsonOfInputs["password"] == nil || jsonOfInputs["user_identifier"] == nil || jsonOfInputs["username"] == nil {
					http.Error(w, "firstname,lastname,password,user_identifier,username are required fields", http.StatusNotAcceptable)
				} else {
					firstname, lastname, userIdentifier, username, password := utils.ConvertAnyToString(jsonOfInputs["firstname"]), utils.ConvertAnyToString(jsonOfInputs["lastname"]), utils.ConvertAnyToString(jsonOfInputs["user_identifier"]), utils.ConvertAnyToString(jsonOfInputs["username"]), utils.ConvertAnyToString(jsonOfInputs["password"])
					db, _ := database.GetDatabase()
					token, _ := middleware.CreateToken()
					user, err := controllers.RegisterEntry(firstname, lastname, userIdentifier, username, password, token, db)
					if err == nil {
						if jsonOfInputs["invitation_code"] != nil && utils.ConvertAnyToString(jsonOfInputs["invitation_code"]) != "" {
							invitationCode := utils.ConvertAnyToString(jsonOfInputs["invitation_code"])
							invitor, err := controllers.GetUserWithInvitationCode(invitationCode, db)
							if err == nil && user.Id > 0 {
								controllers.CreateInvitation(userIdentifier, invitationCode, db)
								// check user level .
								invitations, err := controllers.GetInvitationByInvitorId(invitor.Id, db)
								if err == nil {
									var invitationsCount = len(invitations)
									levelId, err := controllers.GetLevelIdByInvitationsCount(invitationsCount, db)
									if err == nil {
										invitor.LevelId = levelId
										invitor.Save(db)
									}
								}
							} else {
								fmt.Println(err.Error())
							}
						}
						encoder := json.NewEncoder(w)
						encoder.Encode(user)
					} else {
						utils.HandleErrors(w, err)
					}
				}
			} else {
				http.Error(w, err.Error(), http.StatusInternalServerError)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

func createActivity(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["title"] == nil || jsonOfInputs["banner_url"] == nil || jsonOfInputs["details"] == nil {
				http.Error(w, "title,banner_url,details are required fields", http.StatusNotAcceptable)
			} else {
				title, bannerUrl, details, creatorId := utils.ConvertAnyToString(jsonOfInputs["title"]), utils.ConvertAnyToString(jsonOfInputs["banner_url"]), utils.ConvertAnyToString(jsonOfInputs["details"]), user.Id
				encoder := json.NewEncoder(w)
				db, _ := database.GetDatabase()
				activity, err := controllers.CreateActivity(title, bannerUrl, details, creatorId, db)
				if err == nil {
					encoder.Encode(activity)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func editActivity(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["title"] == nil || jsonOfInputs["banner_url"] == nil || jsonOfInputs["details"] == nil || jsonOfInputs["activity_id"] == nil {
				http.Error(w, "title,banner_url,details,activity_id are required fields", http.StatusNotAcceptable)
			} else {
				db, _ := database.GetDatabase()
				activityId, err := strconv.Atoi(utils.ConvertAnyToString(jsonOfInputs["activity_id"]))
				if err == nil {
					activity, err := controllers.GetActivityById(activityId, db)
					if err == nil {
						title, bannerUrl, details := utils.ConvertAnyToString(jsonOfInputs["title"]), utils.ConvertAnyToString(jsonOfInputs["banner_url"]), utils.ConvertAnyToString(jsonOfInputs["details"])
						activity.Title = title
						activity.BannerUrl = bannerUrl
						activity.Details = details
						err = activity.Save(db)
						encoder := json.NewEncoder(w)
						if err == nil {
							encoder.Encode(activity)
						} else {
							utils.HandleErrors(w, err)
						}
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func deleteActivityById(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			activityIdString := r.URL.Query().Get("activity_id")
			activityId, err := strconv.Atoi(activityIdString)
			if err == nil {
				db, _ := database.GetDatabase()
				err = controllers.DeleteActivityById(activityId, db)
				if err == nil {
					w.WriteHeader(http.StatusOK)
					w.Write([]byte("activity deleted successfully"))
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getActivities(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			activities, err := controllers.GetActivities(db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(activities)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func createAnnouncement(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["title"] == nil || jsonOfInputs["details"] == nil {
				http.Error(w, "title and details are required fields", http.StatusNotAcceptable)
			} else {
				title, details := utils.ConvertAnyToString(jsonOfInputs["title"]), utils.ConvertAnyToString(jsonOfInputs["details"])
				db, _ := database.GetDatabase()
				announce, err := controllers.CreateAnnouncement(title, details, user.Id, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(announce)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func editAnnouncementt(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["title"] == nil || jsonOfInputs["details"] == nil || jsonOfInputs["announce_id"] == nil {
				http.Error(w, "title ,details,announce_id are required fields", http.StatusNotAcceptable)
			} else {

				title, details, announceIdString := utils.ConvertAnyToString(jsonOfInputs["title"]), utils.ConvertAnyToString(jsonOfInputs["details"]), utils.ConvertAnyToString(jsonOfInputs["announce_id"])
				announceId, err := strconv.Atoi(announceIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					announcement, err := controllers.GetAnnouncementById(announceId, db)
					if err == nil && announcement.Id > 0 {
						announcement.Title = title
						announcement.Details = details
						err = announcement.Save(db)
						if err == nil {
							encoder := json.NewEncoder(w)
							encoder.Encode(announcement)
						} else {
							utils.HandleErrors(w, err)
						}
					} else if err != nil {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func deleteAnnouncementById(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			announcementIdString := r.URL.Query().Get("announcement_id")
			if announcementIdString == "" {
				http.Error(w, "announcement_id is required field", http.StatusNotAcceptable)
			} else {
				announcementId, err := strconv.Atoi(announcementIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					err = controllers.DeleteAnnouncementById(announcementId, db)
					if err == nil {
						w.WriteHeader(http.StatusOK)
						w.Write([]byte("announcement deleted successfully"))
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getAnnouncements(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			announcements, err := controllers.GetAnnouncements(db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(announcements)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

// func createDeposit(w http.ResponseWriter, r *http.Request, user *models.User) {
// 	switch r.Method {
// 	case http.MethodPost:
// 		{
// 			var jsonOfInputs map[string]any
// 			bytes, _ := io.ReadAll(r.Body)
// 			json.Unmarshal(bytes, &jsonOfInputs)
// 			if jsonOfInputs["amount"] == nil {
// 				http.Error(w, "amount is required field", http.StatusNotAcceptable)
// 			} else {
// 				amount, err := strconv.Atoi(utils.ConvertAnyToString(jsonOfInputs["amount"]))
// 				if err == nil {
// 					db, _ := database.GetDatabase()
// 					deposit, err := controllers.CrateDeposit(float32(amount), user.Id, db)
// 					if err != nil {
// 						utils.HandleErrors(w, err)
// 					} else {
// 						encoder := json.NewEncoder(w)
// 						encoder.Encode(deposit)
// 					}
// 				} else {
// 					utils.HandleErrors(w, err)
// 				}
// 			}
// 		}
// 	default:
// 		{
// 			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
// 		}
// 	}
// }

// func getDepositsByUserId(w http.ResponseWriter, r *http.Request, user *models.User) {
// 	switch r.Method {
// 	case http.MethodGet:
// 		{
// 			deposits, err := controllers.GetDepositsByUserId(user.Id, db)
// 		}
// 	default:
// 		{
// 			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
// 		}
// 	}
// }

//	func getDepositByTransactionId(w http.ResponseWriter, r *http.Request, user *models.User) {
//		switch r.Method {
//		case http.MethodGet:
//			{
//			}
//		default:
//			{
//				http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
//			}
//		}
//	}
func createHelp(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["title"] == nil || jsonOfInputs["subsection"] == nil || jsonOfInputs["description"] == nil {
				http.Error(w, "title and subsection and description are required fields", http.StatusNotAcceptable)
			} else {
				title, subsection, description := utils.ConvertAnyToString(jsonOfInputs["title"]), utils.ConvertAnyToString(jsonOfInputs["subsection"]), utils.ConvertAnyToString(jsonOfInputs["description"])
				db, _ := database.GetDatabase()
				help, err := controllers.CreateHelp(title, subsection, description, user.Id, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(help)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

func editHelp(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["title"] == nil || jsonOfInputs["subsection"] == nil || jsonOfInputs["description"] == nil || jsonOfInputs["help_id"] == nil {
				http.Error(w, "title and subsection and description,help_id are required fields", http.StatusNotAcceptable)
			} else {
				title, subsection, description, helpIdString := utils.ConvertAnyToString(jsonOfInputs["title"]), utils.ConvertAnyToString(jsonOfInputs["subsection"]), utils.ConvertAnyToString(jsonOfInputs["description"]), utils.ConvertAnyToString(jsonOfInputs["help_id"])
				helpId, err := strconv.Atoi(helpIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					help, err := controllers.GetHelpWithId(helpId, db)
					if err == nil {
						help.Title = title
						help.Subsection = subsection
						help.Description = description
						help.Save(db)
						encoder := json.NewEncoder(w)
						encoder.Encode(help)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

func getHelps(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			helps, err := controllers.GetHelps(db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(helps)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

func deleteHelpWithId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			helpIdString := r.URL.Query().Get("help_id")
			if helpIdString == "" {
				http.Error(w, "help_id is required field", http.StatusNotAcceptable)
			} else {
				helpId, err := strconv.Atoi(helpIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					help, err := controllers.GetHelpWithId(helpId, db)
					if err == nil {
						encoder := json.NewEncoder(w)
						encoder.Encode(help)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

func createInvitation(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["invited_id"] == nil || jsonOfInputs["invitation_code"] == nil {
				http.Error(w, "invitor_id ,invited_id,invitation_code are required fields", http.StatusNotAcceptable)
			} else {
				invitedIdString, invitationCode := utils.ConvertAnyToString(jsonOfInputs["invited_id"]), utils.ConvertAnyToString(jsonOfInputs["invitation_code"])
				db, _ := database.GetDatabase()
				err := controllers.CreateInvitation(invitedIdString, invitationCode, db)
				if err == nil {
					w.WriteHeader(http.StatusOK)
				} else {
					utils.HandleErrors(w, err)
				}

			}

		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

func getInvitationByInvitorId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			invitations, err := controllers.GetInvitationByInvitorId(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(invitations)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getInvitedUsersCount(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			count := controllers.GetInvitedUsersCount(user.Id, db)
			encoder := json.NewEncoder(w)
			encoder.Encode(count)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func createLevel(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["level_tag"] == nil || jsonOfInputs["exp_to_upgrade"] == nil {
				http.Error(w, "level_tag , exp_to_upgrade are required fields", http.StatusNotAcceptable)
			} else {
				levelTag, expToUpgrade := utils.ConvertAnyToString(jsonOfInputs["level_tag"]), utils.ConvertAnyToString(jsonOfInputs["exp_to_upgrade"])
				db, _ := database.GetDatabase()
				level, err := controllers.CreateLevel(levelTag, expToUpgrade, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(level)
				} else {
					utils.HandleErrors(w, err)

				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func editLevel(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["level_tag"] == nil || jsonOfInputs["exp_to_upgrade"] == nil || jsonOfInputs["level_id"] == nil {
				http.Error(w, "level_tag , exp_to_upgrade,level_id are required fields", http.StatusNotAcceptable)
			} else {
				levelTag, expToUpgradeString, levelIdString := utils.ConvertAnyToString(jsonOfInputs["level_tag"]), utils.ConvertAnyToString(jsonOfInputs["exp_to_upgrade"]), utils.ConvertAnyToString(jsonOfInputs["level_id"])
				levelId, err := strconv.Atoi(levelIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					expToUpgrade, err := strconv.ParseFloat(expToUpgradeString, 32)
					if err == nil {
						level, err := controllers.GetLevelById(levelId, db)
						if err == nil {
							level.LevelTag = levelTag
							level.ExpToUpgrade = expToUpgrade
							level.Save(db)
							encoder := json.NewEncoder(w)
							encoder.Encode(level)
						} else {
							utils.HandleErrors(w, err)
						}
					} else {
						utils.HandleErrors(w, err)
					}

				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func deleteLevelById(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			levelIdString := r.URL.Query().Get("level_id")
			levelId, err := strconv.Atoi(levelIdString)
			if err == nil {
				db, _ := database.GetDatabase()
				err = controllers.DeleteLevelById(levelId, db)
				if err == nil {
					w.WriteHeader(http.StatusOK)
					w.Write([]byte("level was deleted successfully"))
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getLevels(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			levels, err := controllers.GetLevels(db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(levels)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getLastOneMinGame(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			oneMinGame, err := controllers.GetLastOneMinGame("one_min_game", db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(oneMinGame)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getGameWithGameHash(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			gameHash := r.URL.Query().Get("game_hash")
			db, _ := database.GetDatabase()
			games, err := controllers.GetGameWithGameHash(gameHash, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(games)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getTwoLastOneMinGame(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			oneMinGames, err := controllers.GetTwoLastOneMinGame(db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(oneMinGames)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getTwoLastOneMinGameByGameType(w http.ResponseWriter, r *http.Request, _ *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			gameType := r.URL.Query().Get("game_type")
			if gameType == "" {
				http.Error(w, "game_type is required field", http.StatusNotAcceptable)
				return
			}
			db, _ := database.GetDatabase()
			oneMinGames, err := controllers.GetTwoLastOneMinGameByGameType(gameType, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(oneMinGames)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getOneMinGameWithId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			gameIdString := r.URL.Query().Get("game_id")
			gameId, err := strconv.Atoi(gameIdString)
			if err == nil {
				db, _ := database.GetDatabase()
				oneMinGame, err := controllers.GetOneMinGameWithId(gameId, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(oneMinGame)
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getOldOneMinGamesByPage(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			var page = 1
			var err error
			pageString := r.URL.Query().Get("page")
			if pageString != "" {
				page, err = strconv.Atoi(pageString)
				if err != nil {
					http.Error(w, "page must be convertable to an integer", http.StatusInternalServerError)
					return
				}
			}
			db, _ := database.GetDatabase()
			oneMinGames, err := controllers.GetOldOneMinGamesByPage(page, utils.ITEM_PER_PAGE, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(oneMinGames)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getOldOneMinGamesByGameTypeAndPage(w http.ResponseWriter, r *http.Request, _ *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			var page = 1
			var err error
			pageString := r.URL.Query().Get("page")
			if pageString != "" {
				page, err = strconv.Atoi(pageString)
				if err != nil {
					http.Error(w, "page must be convertable to an integer", http.StatusInternalServerError)
					return
				}
			}
			gameType := r.URL.Query().Get("game_type")
			if gameType == "" {
				http.Error(w, "game_type is required field", http.StatusNotAcceptable)
				return
			}
			db, _ := database.GetDatabase()
			oneMinGames, err := controllers.GetOldOneMinGamesByGameTypeAndPage(gameType, page, utils.ITEM_PER_PAGE, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(oneMinGames)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func createSiteSetting(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["loading_picture"] == nil || jsonOfInputs["min_withdraw_amount"] == nil || jsonOfInputs["min_deposit_amount"] == nil || jsonOfInputs["referal_percent"] == nil {
				http.Error(w, "loading_picture,min_withdraw_amount,min_deposit_amount,referal_percent are required fields", http.StatusNotAcceptable)
			} else {
				loadingPicture, minWithdrawAmountString, minDepositAmountString, referalPercentString := utils.ConvertAnyToString(jsonOfInputs["loading_picture"]), utils.ConvertAnyToString(jsonOfInputs["min_withdraw_amount"]), utils.ConvertAnyToString(jsonOfInputs["min_deposit_amount"]), utils.ConvertAnyToString(jsonOfInputs["referal_percent"])
				minWithdrawAmount, err := strconv.ParseFloat(minWithdrawAmountString, 32)
				if err == nil {
					minDepositAmount, err := strconv.ParseFloat(minDepositAmountString, 32)
					if err == nil {
						referalPercent, err := strconv.ParseFloat(referalPercentString, 32)
						if err == nil {
							db, _ := database.GetDatabase()
							siteSetting, err := controllers.CreateSiteSetting(loadingPicture, float32(minWithdrawAmount), float32(minDepositAmount), float32(referalPercent), user.Id, db)
							if err == nil {
								encoder := json.NewEncoder(w)
								encoder.Encode(siteSetting)
							} else {
								utils.HandleErrors(w, err)
							}
						} else {
							utils.HandleErrors(w, err)
						}
					} else {
						utils.HandleErrors(w, err)
					}

				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getSiteSettings(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			siteSettings, err := controllers.GetSiteSettings(db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(siteSettings)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getSupportsByRoomId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			roomId := r.URL.Query().Get("room_id")
			if roomId == "" {
				http.Error(w, "room_id is required field", http.StatusNotAcceptable)
			} else {
				db, _ := database.GetDatabase()
				messages, err := controllers.GetSupportsByRoomId(roomId, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(messages)
				} else {
					utils.HandleErrors(w, err)
				}
			}

		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getSupportByUserId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			supports, err := controllers.GetSupportByUserId(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(supports)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func createSupportMessage(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["message_value"] == nil || jsonOfInputs["message_type"] == nil {
				http.Error(w, "message_value , message_type are required fields", http.StatusNotAcceptable)
			} else {
				messageValue, messageType := utils.ConvertAnyToString(jsonOfInputs["message_value"]), utils.ConvertAnyToString(jsonOfInputs["message_type"])
				db, _ := database.GetDatabase()
				message, err := controllers.CreateSupportMessage(messageValue, messageType, user.Id, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(message)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getTransactionsByUserId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			creatorIdString := r.URL.Query().Get("user_id")
			if creatorIdString == "" {
				http.Error(w, "user_id is required field", http.StatusNotAcceptable)
				return
			}
			creatorId, err := strconv.Atoi(creatorIdString)
			if err == nil {
				db, _ := database.GetDatabase()
				transactionsList, err := controllers.GetTransactionsByCreatorId(creatorId, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(transactionsList)
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusNotAcceptable)
		}
	}
}
func getTransactionsByCreatorId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			transactions, err := controllers.GetTransactionsByCreatorId(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(transactions)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getTransactionsByTransactionTypeAndStatusAndPage(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			transactionType, transactionStatus, transactionPage := r.URL.Query().Get("transaction_type"), r.URL.Query().Get("status"), r.URL.Query().Get("page")
			if transactionType == "" || transactionStatus == "" {
				http.Error(w, "trnasaction_type and status are required fields", http.StatusNotAcceptable)
			} else {
				var page = 1
				if transactionPage != "" {
					page, _ = strconv.Atoi(transactionPage)
				}
				db, _ := database.GetDatabase()
				transactions, err := controllers.GetTransactionsByTransactionTypeAndStatusAndPage(transactionType, transactionStatus, page, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(transactions)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getTransactionsWithStatus(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			status := r.URL.Query().Get("status")
			if status == "" {
				http.Error(w, "status is required field", http.StatusNotAcceptable)
			} else {
				db, _ := database.GetDatabase()
				transactions, err := controllers.GetTransactionsWithStatus(status, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(transactions)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func createUserBet(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["game_id"] == nil || jsonOfInputs["user_choices"] == nil || jsonOfInputs["amount"] == nil || jsonOfInputs["coin_type"] == nil {
				http.Error(w, "game_id , user_choices,amount are required fields", http.StatusNotAcceptable)
			} else {
				userChoices, amountString, coinType := utils.ConvertAnyToString(jsonOfInputs["user_choices"]), utils.ConvertAnyToString(jsonOfInputs["amount"]), utils.ConvertAnyToString(jsonOfInputs["coin_type"])
				amount, err := strconv.ParseFloat(amountString, 64)
				if err == nil {
					isAmountValid := true
					switch coinType {
					case "ton":
						{
							userTonAmountFloat, _ := strconv.ParseFloat(user.TonInventory, 64)
							isAmountValid = amount <= userTonAmountFloat
						}
					case "stars":
						{
							userStarsAmount, _ := strconv.ParseFloat(user.StarsInventory, 64)
							isAmountValid = amount <= userStarsAmount
						}
					case "usdt":
						{
							userUsdtAmount, _ := strconv.ParseFloat(user.UsdtInventory, 64)
							isAmountValid = amount <= userUsdtAmount
						}
					case "cusd":
						{
							userCusdAmount, _ := strconv.ParseFloat(user.CusdInventory, 64)
							isAmountValid = amount <= userCusdAmount
						}
					case "btc":
						{
							userBtcAmount, _ := strconv.ParseFloat(user.BtcInventory, 64)
							isAmountValid = amount <= userBtcAmount
						}
					}
					if isAmountValid {
						gameId, err := strconv.Atoi(utils.ConvertAnyToString(jsonOfInputs["game_id"]))
						if err == nil {
							db, _ := database.GetDatabase()
							userBet, err := controllers.CreateUserBet(gameId, user.Id, userChoices, amountString, coinType, db)
							if err == nil {
								encoder := json.NewEncoder(w)
								encoder.Encode(userBet)
							} else {
								utils.HandleErrors(w, err)
							}
						} else {
							utils.HandleErrors(w, err)
						}
					} else {
						http.Error(w, "Amount must be less than your inventory", http.StatusNotAcceptable)
					}

				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

// this function is only for closing the user bets.
func editUserBet(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			var jsonOfInputs map[string]any
			bytes, _ := io.ReadAll(r.Body)
			json.Unmarshal(bytes, &jsonOfInputs)
			if jsonOfInputs["bet_status"] == nil || jsonOfInputs["user_bet_id"] == nil || jsonOfInputs["coin_type"] == nil {
				http.Error(w, "bet_status , user_bet_id ,coin_type are required fields", http.StatusNotAcceptable)
			} else {
				userBetId, err := strconv.Atoi(utils.ConvertAnyToString(jsonOfInputs["user_bet_id"]))
				betStatus, coinType := utils.ConvertAnyToString(jsonOfInputs["bet_status"]), utils.ConvertAnyToString(jsonOfInputs["coin_type"])

				if err == nil {
					db, _ := database.GetDatabase()
					userBet, err := controllers.GetUserBetById(userBetId, db)
					if err == nil {
						userBet.BetStatus = betStatus
						userBet.CoinType = coinType
						userBet.Save(db)
						userBet, _ = controllers.GetUserBetById(userBetId, db)
						encoder := json.NewEncoder(w)
						encoder.Encode(userBet)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserBets(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			userBets, err := controllers.GetUserBets(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(userBets)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserBetsByUserId(w http.ResponseWriter, r *http.Request, _ *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			userIdString := r.URL.Query().Get("user_id")
			if userIdString == "" {
				http.Error(w, "user_id is required field", http.StatusNotAcceptable)
				return
			}
			userId, err := strconv.Atoi(userIdString)
			if err == nil {
				db, _ := database.GetDatabase()
				userBets, err := controllers.GetUserBets(userId, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(userBets)
				} else {
					utils.HandleErrors(w, err)
				}
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserBetsByGameId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			gameIdString := r.URL.Query().Get("game_id")
			if gameIdString == "" {
				http.Error(w, "game_id is required fields", http.StatusNotAcceptable)
			} else {
				gameId, err := strconv.Atoi(gameIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					userBets, err := controllers.GetUserBetsByGameId(gameId, user.Id, db)
					if err == nil {
						encoder := json.NewEncoder(w)
						encoder.Encode(userBets)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getTwoLastUserBets(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			userBets, err := controllers.GetTwoLastUserBets(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(userBets)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserBetsCount(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			betCount := controllers.GetUserBetsCount(user.Id, db)
			encoder := json.NewEncoder(w)
			encoder.Encode(betCount)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserTotalWins(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			totalWins := controllers.GetUserTotalWins(user.Id, db)
			encoder := json.NewEncoder(w)
			encoder.Encode(totalWins)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getUserBetsPerPage(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			var page = 1
			var err error
			var pageString = r.URL.Query().Get("page")
			if pageString != "" {
				page, err = strconv.Atoi(pageString)
				if err != nil {
					utils.HandleErrors(w, err)
					return
				}
			}
			db, _ := database.GetDatabase()
			userBets, err := controllers.GetUserBetsPerPage(user.Id, page, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(userBets)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func createWithdraw(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodPost:
		{
			if !user.IsDemo() {
				var jsonOfInputs map[string]any
				bytes, _ := io.ReadAll(r.Body)
				json.Unmarshal(bytes, &jsonOfInputs)
				if jsonOfInputs["amount"] == nil || jsonOfInputs["address"] == nil || jsonOfInputs["coin_type"] == nil {
					http.Error(w, "amount,address,coinname are required field", http.StatusNotAcceptable)
				} else {
					amount, err := strconv.ParseFloat(utils.ConvertAnyToString(jsonOfInputs["amount"]), 32)
					if err == nil {
						address, coinType := utils.ConvertAnyToString(jsonOfInputs["address"]), utils.ConvertAnyToString(jsonOfInputs["coin_type"])
						db, _ := database.GetDatabase()
						userTonsString := user.TonInventory
						userStarsString := user.StarsInventory
						userTons, _ := strconv.ParseFloat(userTonsString, 64)
						userStars, _ := strconv.ParseFloat(userStarsString, 64)
						if (coinType == "ton" && userTons < amount) || (coinType == "not" && userStars < amount) {
							http.Error(w, "your balance is less than your withdraw amount !", http.StatusNotAcceptable)
							return
						}
						withdrawableAmount := controllers.GetWithdrawableAmount(coinType, user.Id, db)
						if withdrawableAmount > configs.WITHDRAWABLE_LESS_THAN {
							http.Error(w, "you must make unfinishedflow to zero then create withdraw request", http.StatusNotAcceptable)
							return
						}
						withdraw, err := controllers.CreateWithdraw(float32(amount), address, coinType, user.Id, db)
						newUserInventory := userTons - amount
						user.TonInventory = utils.ConvertAnyToString(newUserInventory)
						user.Save(db)
						if err == nil {
							encoder := json.NewEncoder(w)
							encoder.Encode(withdraw)
						} else {
							utils.HandleErrors(w, err)
						}
					} else {
						utils.HandleErrors(w, err)
					}
				}
			} else {
				http.Error(w, "You are in demo account mode if you think something went wrong please contact to admin", http.StatusNotAcceptable)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getWithdrawByCreator(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			withdraws, err := controllers.GetWithdrawByCreator(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(withdraws)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func changeWithdrawStatus(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			status, withdrawIdString := r.URL.Query().Get("status"), r.URL.Query().Get("withdraw_id")
			if status == "" || withdrawIdString == "" {
				http.Error(w, "status and withdraw_id are required fields", http.StatusNotAcceptable)
			} else {
				withdrawId, err := strconv.Atoi(withdrawIdString)
				if err == nil {
					db, _ := database.GetDatabase()
					withdraw, err := controllers.GetWithdrawById(withdrawId, db)
					if err == nil {
						transactions, err := controllers.GetTransactionWithTransactionId(withdraw.TransactionId, db)
						if status == "success" {
							user := withdraw.Creator
							switch withdraw.CoinType {
							case "ton":
								{
									userTonInventory, err := strconv.ParseFloat(user.TonInventory, 64)
									if err != nil {
										return
									}
									userTonInventory -= float64(withdraw.Amount)
									user.TonInventory = utils.ConvertAnyToString(userTonInventory)
									controllers.SendTonToWalletAddress(context.Background(), utils.ConvertAnyToString(withdraw.Amount/configs.TonBaseFactor), withdraw.WalletAddress)
									//TODO check the amount of the withdraw. (base on the amount *10^9) or something another else.
								}
							case "stars":
								{
									//TODO handle this section and exchange stars to tons base configs and transfer it to user account.
									userStarsInventory, err := strconv.ParseFloat(user.StarsInventory, 64)
									if err != nil {
										return
									}
									tonOfTheseStars := withdraw.Amount / configs.TonToStarsCount
									controllers.SendTonToWalletAddress(context.Background(), utils.ConvertAnyToString(tonOfTheseStars), withdraw.WalletAddress)
									userStarsInventory -= float64(withdraw.Amount)
									user.StarsInventory = utils.ConvertAnyToString(userStarsInventory)
								}
							}
							user.Save(db)
						} else {
							userTonInventory, err := strconv.ParseFloat(user.TonInventory, 64)
							if err == nil {
								userTonInventory = userTonInventory + float64(withdraw.Amount)
								user.TonInventory = utils.ConvertAnyToString(userTonInventory)
								user.Save(db)
							}
						}
						if err == nil && len(transactions) == 1 {
							transaction := transactions[0]
							transaction.Status = status
							transaction.Save(db)
						}
						withdraw.Status = status
						withdraw.Save(db)
						w.WriteHeader(http.StatusOK)
					} else {
						utils.HandleErrors(w, err)
					}
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getWithdrawableAmount(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			coinType := r.URL.Query().Get("coin_type")
			if coinType == "" {
				http.Error(w, "cion_type is required ", http.StatusNotAcceptable)
			} else {
				db, _ := database.GetDatabase()
				withdrawableAmount := controllers.GetWithdrawableAmount(coinType, user.Id, db)
				encoder := json.NewEncoder(w)
				encoder.Encode(withdrawableAmount)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getWithdrawsByStatusAndPage(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			var page = 1
			status := r.URL.Query().Get("status")
			if status == "" {
				http.Error(w, "status is required field", http.StatusNotAcceptable)
			} else {
				if pageString := r.URL.Query().Get("page"); pageString != "" {
					page, _ = strconv.Atoi(pageString)
				}
				db, _ := database.GetDatabase()
				withdraws, err := controllers.GetWithdrawsByStatusAndPage(status, page, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(withdraws)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func getWithdrawByTransactionId(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			transactionId := r.URL.Query().Get("transaction_id")
			if transactionId == "" {
				http.Error(w, "transaction_id is required field", http.StatusNotAcceptable)
			} else {
				db, _ := database.GetDatabase()
				withdraws, err := controllers.GetWithdrawByTransactionId(transactionId, db)
				if err == nil {
					encoder := json.NewEncoder(w)
					encoder.Encode(withdraws)
				} else {
					utils.HandleErrors(w, err)
				}
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func createSlider(w http.ResponseWriter, r *http.Request, user *models.User) {
	start := time.Now()
	log.Printf("🆕 درخواست ایجاد اسلایدر جدید از کاربر: %s (ID: %d)", user.Username, user.Id)

	switch r.Method {
	case http.MethodPost:
		{
			// Log request body
			bodyBytes, _ := io.ReadAll(r.Body)
			log.Printf("📥 بدنه درخواست: %s", string(bodyBytes))

			// Restore the request body for JSON unmarshalling
		r.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))

			var jsonOfInputs map[string]any
			if err := json.Unmarshal(bodyBytes, &jsonOfInputs); err != nil {
				log.Printf("❌ خطا در تجزیه JSON درخواست: %v", err)
				http.Error(w, "Invalid JSON format", http.StatusBadRequest)
				return
			}

			// Validate required fields
			if jsonOfInputs["image_path"] == nil {
				errMsg := "image_path is a required field"
				log.Printf("❌ %s", errMsg)
				http.Error(w, errMsg, http.StatusNotAcceptable)
				return
			}

			log.Printf("🔧 پارامترهای دریافتی - image_path: %v, button_title: %v, button_link: %v",
				jsonOfInputs["image_path"], jsonOfInputs["button_title"], jsonOfInputs["button_link"])

			db, err := database.GetDatabase()
			if err != nil {
				log.Printf("❌ خطا در اتصال به دیتابیس: %v", err)
				http.Error(w, "Database connection error", http.StatusInternalServerError)
				return
			}

			slider, err := controllers.CreateSlider(
				utils.ConvertAnyToString(jsonOfInputs["image_path"]),
				jsonOfInputs["button_title"],
				jsonOfInputs["button_link"],
				db,
			)

			if err != nil {
				log.Printf("❌ خطا در ایجاد اسلایدر: %v", err)
				utils.HandleErrors(w, err)
				return
			}

			log.Printf("✅ اسلایدر با موفقیت ایجاد شد - ID: %d (زمان اجرا: %v)", slider.Id, time.Since(start))

			// Set response headers
			w.Header().Set("Content-Type", "application/json")
			if err := json.NewEncoder(w).Encode(slider); err != nil {
				log.Printf("❌ خطا در ارسال پاسخ: %v", err)
			}
		}
	default:
		{
			errMsg := fmt.Sprintf("Method %s Not Allowed", r.Method)
			log.Printf("❌ %s", errMsg)
			http.Error(w, errMsg, http.StatusMethodNotAllowed)
		}
	}
}
func getSlider(w http.ResponseWriter, r *http.Request, user *models.User) {
	start := time.Now()
	log.Printf("📥 درخواست دریافت لیست اسلایدرها از کاربر: %s (ID: %d)", user.Username, user.Id)

	switch r.Method {
	case http.MethodGet:
		{
			// Log query parameters if any
			if len(r.URL.Query()) > 0 {
				log.Printf("🔍 پارامترهای کوئری: %v", r.URL.Query())
			}

			db, err := database.GetDatabase()
			if err != nil {
				log.Printf("❌ خطا در اتصال به دیتابیس: %v", err)
				http.Error(w, "Database connection error", http.StatusInternalServerError)
				return
			}

			sliders, err := controllers.GetSliders(db)
			if err != nil {
				log.Printf("❌ خطا در دریافت اسلایدرها: %v", err)
				utils.HandleErrors(w, err)
				return
			}

			log.Printf("✅ با موفقیت %d اسلایدر در مدت زمان %v دریافت شد", len(sliders), time.Since(start))

			// Set response headers
			w.Header().Set("Content-Type", "application/json")
			if err := json.NewEncoder(w).Encode(sliders); err != nil {
				log.Printf("❌ خطا در ارسال پاسخ: %v", err)
			}
		}
	default:
		{
			errMsg := fmt.Sprintf("Method %s Not Allowed", r.Method)
			log.Printf("❌ %s", errMsg)
			http.Error(w, errMsg, http.StatusMethodNotAllowed)
		}
	}
}
func deleteSlider(w http.ResponseWriter, r *http.Request, user *models.User) {
	start := time.Now()
	log.Printf("🗑️  درخواست حذف اسلایدر از کاربر: %s (ID: %d)", user.Username, user.Id)

	switch r.Method {
	case http.MethodDelete:
		{
			sliderIdString := r.URL.Query().Get("slider_id")
			if sliderIdString == "" {
				errMsg := "پارامتر اجباری slider_id ارسال نشده است"
				log.Printf("❌ %s", errMsg)
				http.Error(w, errMsg, http.StatusNotAcceptable)
				return
			}

			sliderId, err := strconv.Atoi(sliderIdString)
			if err != nil {
				errMsg := fmt.Sprintf("شناسه اسلایدر نامعتبر است: %s", sliderIdString)
				log.Printf("❌ %s - خطا: %v", errMsg, err)
				http.Error(w, "Invalid slider_id format", http.StatusBadRequest)
				return
			}

			log.Printf("🔍 در حال حذف اسلایدر با شناسه: %d", sliderId)

			db, err := database.GetDatabase()
			if err != nil {
				log.Printf("❌ خطا در اتصال به دیتابیس: %v", err)
				http.Error(w, "Database connection error", http.StatusInternalServerError)
				return
			}

			// First get the slider to log its details
			slider, err := controllers.GetSliderById(sliderId, db)
			if err != nil {
				log.Printf("❌ خطا در یافتن اسلایدر با شناسه %d: %v", sliderId, err)
				utils.HandleErrors(w, err)
				return
			}

			log.Printf("🔍 یافت شد - اسلایدر ID: %d, تصویر: %s", slider.Id, slider.ImagePath)

			err = controllers.DeleteSlider(sliderId, db)
			if err != nil {
				log.Printf("❌ خطا در حذف اسلایدر (ID: %d): %v", sliderId, err)
				utils.HandleErrors(w, err)
				return
			}

			log.Printf("✅ اسلایدر با موفقیت حذف شد - ID: %d, تصویر: %s (زمان اجرا: %v)",
				sliderId, slider.ImagePath, time.Since(start))

			w.WriteHeader(http.StatusOK)
			if _, err := w.Write([]byte("اسلایدر با موفقیت حذف شد")); err != nil {
				log.Printf("❌ خطا در ارسال پاسخ: %v", err)
			}
		}
	default:
		{
			errMsg := fmt.Sprintf("Method %s Not Allowed", r.Method)
			log.Printf("❌ %s", errMsg)
			http.Error(w, errMsg, http.StatusMethodNotAllowed)
		}
	}
}
func getUserTeam(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			db, _ := database.GetDatabase()
			users, err := controllers.GetUserTeam(user.Id, db)
			if err == nil {
				encoder := json.NewEncoder(w)
				encoder.Encode(users)
			} else {
				utils.HandleErrors(w, err)
			}
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}
func updateUser(w http.ResponseWriter, r *http.Request, user *models.User) {
	switch r.Method {
	case http.MethodGet:
		{
			encoder := json.NewEncoder(w)
			encoder.Encode(user)
		}
	default:
		{
			http.Error(w, "Method Not Allowed", http.StatusMethodNotAllowed)
		}
	}
}

var upgrader = websocket.Upgrader{ReadBufferSize: 1024, WriteBufferSize: 1024, CheckOrigin: func(r *http.Request) bool { return true }}

func websocketConn(w http.ResponseWriter, r *http.Request) {
	token := r.URL.Query().Get("token")
	gameType := r.URL.Query().Get("game_type")
	if gameType == "" {
		http.Error(w, "game_type is required field", http.StatusNotAcceptable)
		return
	}
	var user models.User
	db, _ := database.GetDatabase()
	if token == "" {
		http.Error(w, "token is required", http.StatusNotAcceptable)
		return
	}
	user, _ = controllers.GetUserWithToken(token, db)
	conn, err := upgrader.Upgrade(w, r, nil)
	if err == nil {
		var userRoom = models.UserRoom{Conn: conn, UserModel: &user}
		chatRoom.AddUserRoomToRoom(userRoom)
		defer func(conn *websocket.Conn, chatRoom models.RoomModel, userRoom models.UserRoom) {
			conn.Close()
			chatRoom.RemoveUserRoomFromRoom(userRoom)
		}(conn, chatRoom, userRoom)
		lastGame, err := controllers.GetLastOneMinGame(gameType, db)
		if err == nil {
			var currentTime = time.Now()
			diff := currentTime.Sub(lastGame.UpdatedAt)
			seconds := int(diff.Seconds())
			serverCommand := models.ServerWebsocketCommand{Command: configs.StartGameDtails, Value: lastGame, GameSecondsRemains: utils.GetGameDiffByGameType(gameType) - seconds}
			bytes, _ := json.Marshal(serverCommand)
			conn.WriteMessage(websocket.TextMessage, bytes)
		}
		readMessages(conn, userRoom)
	} else {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}

}
func readMessages(conn *websocket.Conn, user models.UserRoom) {
	var serverWebsocketCommand models.ServerWebsocketCommand
outer:
	for {
		_, message, err := conn.ReadMessage()
		json.Unmarshal(message, &serverWebsocketCommand)
		if err != nil {
			chatRoom.RemoveUserRoomFromRoom(user)
			if err == io.EOF {
				break outer
			}
			fmt.Println(err.Error())
			break outer
		} else {

		}
	}
}
