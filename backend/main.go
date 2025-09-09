package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/khodehamid/winball_go_back/database"
	"github.com/khodehamid/winball_go_back/jobs"
	"github.com/khodehamid/winball_go_back/routes"
)

func main() {
	ctx := context.Background()
	db, err := database.GetDatabase()
	if err != nil {
		panic(err)
	}
	defer db.Close()
	

	jobs.StartTransactionChecker()
	
	
	//! real code is here
	sm := &http.ServeMux{}
	server := &http.Server{Addr: ":8080", Handler: sm}
	go func(s *http.Server, sm *http.ServeMux) {
		routes.SetupRoutes(sm)
		log.Fatal(s.ListenAndServe())
	}(server, sm)
	sigChann := make(chan os.Signal, 1)
	signal.Notify(sigChann, syscall.SIGTERM)
	signal.Notify(sigChann, os.Interrupt)
	_, cancel := context.WithTimeout(ctx, time.Second*30)
	defer cancel()
	cause := <-sigChann
	fmt.Println("server was shutted down by cause ", cause)
	server.Shutdown(ctx)
}
