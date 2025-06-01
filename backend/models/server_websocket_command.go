package models

type ServerWebsocketCommand struct {
	Command            string `json:"command"`
	Value              any    `json:"value"`
	GameSecondsRemains int    `json:"game_seconds_remains"`
}
