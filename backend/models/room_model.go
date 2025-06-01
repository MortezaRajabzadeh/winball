package models

import (
	"sync"

	"github.com/gorilla/websocket"
)

type RoomModel struct {
	Users []UserRoom
	Mutex *sync.RWMutex
}
type UserRoom struct {
	Conn      *websocket.Conn
	UserModel *User
}

func (r *RoomModel) AddUserRoomToRoom(user UserRoom) {
	if _, exists := r.isUserRoomExistsIntoRoom(user); !exists {
		r.Mutex.Lock()
		defer r.Mutex.Unlock()
		r.Users = append(r.Users, user)
	}
}
func (r *RoomModel) RemoveUserRoomFromRoom(user UserRoom) {
	if i, exists := r.isUserRoomExistsIntoRoom(user); exists {
		r.Mutex.Lock()
		defer r.Mutex.Unlock()
		r.Users = append(r.Users[:i], r.Users[i+1:]...)
	}
}
func (r *RoomModel) isUserRoomExistsIntoRoom(user UserRoom) (int, bool) {
	for index, userRoom := range r.Users {
		if user.UserModel.Id == userRoom.UserModel.Id {
			return index, true
		}
	}
	return -1, false
}
func (r *RoomModel) BroadcastMessageToUsers(message []byte) (err error) {
	for _, u := range r.Users {
		err = u.Conn.WriteMessage(websocket.TextMessage, message)
	}
	return err
}
