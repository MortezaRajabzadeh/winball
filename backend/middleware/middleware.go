package middleware

import (
	"fmt"
	"net/http"
	"time"

	"github.com/kataras/jwt"
	"github.com/khodehamid/winball_go_back/controllers"
	"github.com/khodehamid/winball_go_back/database"
	"github.com/khodehamid/winball_go_back/models"
)

var SUPER_SECRETE_KEY []byte = []byte("GO_FAST_VPN_SUPER_SECRETE_KEY")
var blockList *jwt.Blocklist = jwt.NewBlocklist(1 * time.Hour)

func CreateToken() (string, error) {
	token, err := jwt.Sign(jwt.HS256, SUPER_SECRETE_KEY, "", jwt.MaxAge(time.Hour*24*30))
	return string(token), err
}
func ValidateJWT(next func(w http.ResponseWriter, r *http.Request, user *models.User)) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authorization := r.Header.Get("Authorization")
		if authorization == "" {
			w.WriteHeader(http.StatusNotAcceptable)
			w.Write([]byte("Authorization is required"))
		} else {
			db, _ := database.GetDatabase()
			user, err := controllers.GetUserWithToken(authorization, db)
			if err == nil {
				if user.IsBlocked() {
					w.WriteHeader(http.StatusForbidden)
					w.Write([]byte("It seems you are blocked from our servers . please contact to admin to solve this problem"))
				} else {
					if user.Id > 0 {
						next(w, r, &user)
					} else {
						w.WriteHeader(http.StatusInternalServerError)
						w.Write([]byte(fmt.Sprint("token is invalid cause sent token is :", authorization)))
					}
				}
			} else {
				w.WriteHeader(http.StatusInternalServerError)
				w.Write([]byte(err.Error()))
			}
		}
	})
}
func Logout(token string) error {
	return blockList.InvalidateToken([]byte(token), jwt.Claims{})
}
