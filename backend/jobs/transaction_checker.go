package jobs

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/khodehamid/winball_go_back/configs"
	"github.com/khodehamid/winball_go_back/controllers"
	"github.com/khodehamid/winball_go_back/database"
	"github.com/xssnick/tonutils-go/ton/wallet"
)

// TransactionCheckerJob - job برای چک کردن خودکار تراکنش‌ها
func TransactionCheckerJob() {
	fmt.Println("🚀 Starting automatic transaction checker job...")
	
	ticker := time.NewTicker(30 * time.Second) // هر 30 ثانیه چک کند
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			checkAllTransactions()
		}
	}
}

func checkAllTransactions() {
	ctx := context.Background()
	db, err := database.GetDatabase()
	if err != nil {
		fmt.Printf("❌ Error getting database: %v\n", err)
		return
	}

	api := controllers.CreateApiWallet(false, ctx)
	words := strings.Split(configs.CasinoWallet, " ")
	w := controllers.GetWalletFromWords(api, wallet.ConfigV5R1Final{NetworkGlobalID: wallet.MainnetGlobalID}, words, ctx)
	block := controllers.GetBlockFromApi(api, ctx)

	fmt.Printf("🔍 Checking transactions at %s\n", time.Now().Format("15:04:05"))
	controllers.CheckTonTransactionsList(api, w, block, db, ctx)
}

// StartTransactionChecker - شروع job در background
func StartTransactionChecker() {
	go TransactionCheckerJob()
} 