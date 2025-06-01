package database

import (
	"database/sql"
	"fmt"
	"time"

	"github.com/go-sql-driver/mysql"
	_ "github.com/go-sql-driver/mysql"
)

var db *sql.DB

// 22 days
const (
	DATABASEUSERNAME = "root"
	DATABASEPASSWORD = "04031377"
	DATABASEPROTOCOL = "tcp"
	DATABASEADDRESS  = "127.0.0.1:3306"
	DATABASENAME     = "winball"
)

func GetDatabase() (*sql.DB, error) {
	var err error
	if db == nil {
		fmt.Println("creating database")
		cfg := mysql.Config{
			User:                 DATABASEUSERNAME,
			Passwd:               DATABASEPASSWORD,
			Net:                  DATABASEPROTOCOL,
			Addr:                 DATABASEADDRESS,
			DBName:               DATABASENAME,
			Loc:                  time.Local,
			AllowAllFiles:        true,
			AllowOldPasswords:    true,
			AllowNativePasswords: true,
			ParseTime:            true,
		}
		db, err = sql.Open("mysql", cfg.FormatDSN())
		if err == nil {
			err = db.Ping()
			if err == nil {
				fmt.Println("connected to database")
			}
		}
	}
	return db, err
}
