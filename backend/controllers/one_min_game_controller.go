package controllers

import (
	"database/sql"
	"fmt"

	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
)

func getOneMinGameWithConditions(query string, db *sql.DB, args ...any) ([]models.OneMinGameModel, error) {
	var games []models.OneMinGameModel
	rows, err := db.Query(query, args...)
	if err == nil {
		for rows.Next() {
			var game models.OneMinGameModel
			if err = rows.Scan(&game.Id, &game.GameType, &game.GameHash, &game.GameResult, &game.EachGameUniqueNumber, &game.CreatedAt, &game.UpdatedAt); err != nil {
				return games, err
			}
			games = append(games, game)
		}
	}
	return games, err
}
func CreateOneMinGame(gameType string, db *sql.DB) (models.OneMinGameModel, error) {
	gameHash := utils.GetRandomString(128)
	games, err := GetGameWithGameHash(gameHash, db)
	if err == nil {
		for len(games) > 0 {
			gameHash = utils.GetRandomString(128)
			games, err = GetGameWithGameHash(gameHash, db)
		}
		lastOneMinGame, err := GetLastOneMinGame(gameType, db)
		if err == nil {
			openBets, err := GetOpenUserBetsByGameId(lastOneMinGame.Id, db)
			if err == nil && len(openBets) > 0 {
				for _, bet := range openBets {
					bet.BetStatus = "closed"
					bet.EndGameResult.String = "0"
					bet.Save(db)
				}
			}
			eachGameUniqueNumber := 1
			if err == nil && lastOneMinGame.EachGameUniqueNumber > 0 {
				eachGameUniqueNumber = lastOneMinGame.EachGameUniqueNumber + 1
			}
			query := "INSERT INTO one_min_game (game_hash,game_type,each_game_unique_number) VALUES (?,?,?)"
			result, err := db.Exec(query, gameHash, gameType, eachGameUniqueNumber)
			if err == nil {
				lastInsertedId, _ := result.LastInsertId()
				return GetOneMinGameWithId(int(lastInsertedId), db)
			}
		}
	}
	return models.OneMinGameModel{}, err
}
func GetLastOneMinGame(gameType string, db *sql.DB) (models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE game_type=? ORDER BY created_at DESC LIMIT 1"
	games, err := getOneMinGameWithConditions(query, db, gameType)
	if err == nil && len(games) > 0 {
		return games[0], err
	}
	return models.OneMinGameModel{}, err
}
func GetLastFiveMinGame(db *sql.DB) (models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE game_type=? ORDER BY created_at DESC LIMIT 1"
	games, err := getOneMinGameWithConditions(query, db, "five_min_game")
	if err == nil && len(games) > 0 {
		return games[0], err
	}
	return models.OneMinGameModel{}, err
}
func GetLastThreeMinGame(db *sql.DB) (models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE game_type=? ORDER BY created_at DESC LIMIT 1"
	games, err := getOneMinGameWithConditions(query, db, "three_min_game")
	if err == nil && len(games) > 0 {
		return games[0], err
	}
	return models.OneMinGameModel{}, err
}
func GetGameWithGameHash(gameHash string, db *sql.DB) ([]models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE game_hash=?"
	return getOneMinGameWithConditions(query, db, gameHash)
}
func GetOneMinGameWithId(gameId int, db *sql.DB) (models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE id=?"
	games, err := getOneMinGameWithConditions(query, db, gameId)
	if err == nil && len(games) > 0 {
		return games[0], err
	}
	return models.OneMinGameModel{}, err
}
func GetTwoLastOneMinGame(db *sql.DB) (models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game ORDER BY created_at DESC LIMIT 2"
	oneMinGames, err := getOneMinGameWithConditions(query, db)
	if err == nil && len(oneMinGames) > 0 {
		return oneMinGames[1], err
	}
	return models.OneMinGameModel{}, err
}
func GetTwoLastOneMinGameByGameType(gameType string, db *sql.DB) (models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE game_type=? ORDER BY created_at DESC LIMIT 2"
	oneMinGames, err := getOneMinGameWithConditions(query, db, gameType)
	if err == nil && len(oneMinGames) > 0 {
		return oneMinGames[1], err
	}
	return models.OneMinGameModel{}, err
}
func SetRandomResultToOneMinGame(gameHash string, db *sql.DB) models.OneMinGameModel {
	games, err := GetGameWithGameHash(gameHash, db)
	if err == nil && len(games) > 0 {
		game := games[0]
		gameBets, err := GetOpenUserBetsByGameId(game.Id, db)
		if err == nil {
			// Get the result before saving
			result := utils.GetOneMinModelBaseGameBets(gameBets)
			game.GameResult.String = result
			err = game.Save(db)
			for err != nil {
				game.GameResult.String = utils.GetOneMinModelBaseGameBets(gameBets)
				err = game.Save(db)
			}
		}
	}
	
	updatedGames, err := GetGameWithGameHash(gameHash, db)
	if err == nil && len(updatedGames) > 0 {
		return updatedGames[0]
	}
	
	return models.OneMinGameModel{}
}
func GetOldOneMinGamesByPage(page int, db *sql.DB) ([]models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE game_result IS NOT NULL ORDER BY created_at DESC LIMIT ? OFFSET ?"
	return getOneMinGameWithConditions(query, db, utils.ITEM_PER_PAGE, (page-1)*utils.ITEM_PER_PAGE)
}
func GetOldOneMinGamesByGameTypeAndPage(gameType string, page int, db *sql.DB) ([]models.OneMinGameModel, error) {
	query := "SELECT * FROM one_min_game WHERE game_type=? AND game_result IS NOT NULL ORDER BY created_at DESC LIMIT ? OFFSET ?"
	return getOneMinGameWithConditions(query, db, gameType, utils.ITEM_PER_PAGE, (page-1)*utils.ITEM_PER_PAGE)
}
