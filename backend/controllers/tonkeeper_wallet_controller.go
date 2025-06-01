package controllers

import (
	"context"
	"database/sql"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/khodehamid/winball_go_back/configs"
	"github.com/khodehamid/winball_go_back/models"
	"github.com/khodehamid/winball_go_back/utils"
	"github.com/xssnick/tonutils-go/address"
	"github.com/xssnick/tonutils-go/liteclient"
	"github.com/xssnick/tonutils-go/tlb"
	"github.com/xssnick/tonutils-go/ton"
	"github.com/xssnick/tonutils-go/ton/wallet"
)

func CreateApiWallet(isTestNet bool, ctx context.Context) ton.APIClientWrapped {
	client := liteclient.NewConnectionPool()
	var configUrl string
	if isTestNet {
		configUrl = "https://ton-blockchain.github.io/testnet-global.config.json"
	} else {
		configUrl = "https://ton.org/global.config.json"
	}
	err := client.AddConnectionsFromConfigUrl(ctx, configUrl)
	if err != nil {
		fmt.Println(err.Error())
		CreateApiWallet(isTestNet, ctx)
	}
	api := ton.NewAPIClient(client).WithRetry()
	return api
}
func GetWalletFromWords(api ton.APIClientWrapped, networkGlobalID wallet.ConfigV5R1Final, words []string, ctx context.Context) *wallet.Wallet {

	w, err := wallet.FromSeed(api, words, wallet.ConfigV5R1Final{NetworkGlobalID: wallet.MainnetGlobalID})
	if err != nil {
		GetWalletFromWords(api, networkGlobalID, words, ctx)
	}
	return w

}
func GetBlockFromApi(api ton.APIClientWrapped, ctx context.Context) *ton.BlockIDExt {
	block, err := api.CurrentMasterchainInfo(ctx)
	if err != nil {
		GetBlockFromApi(api, ctx)
	}
	return block
}

// Blockchain Tracking Functions
func GetBlockchainTracking(walletAddress string, db *sql.DB) (models.BlockchainTrackingModel, error) {
	query := "SELECT * FROM blockchain_tracking WHERE wallet_address=?"
	var tracking models.BlockchainTrackingModel
	
	rows, err := db.Query(query, walletAddress)
	if err != nil {
		return tracking, err
	}
	defer rows.Close()
	
	if rows.Next() {
		err = rows.Scan(&tracking.Id, &tracking.WalletAddress, &tracking.LastProcessedLT, 
			&tracking.LastProcessedHash, &tracking.CreatedAt, &tracking.UpdatedAt)
	}
	
	return tracking, err
}

func CreateBlockchainTracking(walletAddress, lastProcessedLT, lastProcessedHash string, db *sql.DB) error {
	query := "INSERT INTO blockchain_tracking (wallet_address, last_processed_lt, last_processed_hash) VALUES (?, ?, ?)"
	_, err := db.Exec(query, walletAddress, lastProcessedLT, lastProcessedHash)
	return err
}

func UpdateBlockchainTracking(walletAddress, lastProcessedLT, lastProcessedHash string, db *sql.DB) error {
	query := "UPDATE blockchain_tracking SET last_processed_lt=?, last_processed_hash=?, updated_at=? WHERE wallet_address=?"
	_, err := db.Exec(query, lastProcessedLT, lastProcessedHash, time.Now(), walletAddress)
	return err
}

func CheckTonTransactionsList(api ton.APIClientWrapped, w *wallet.Wallet, block *ton.BlockIDExt, db *sql.DB, ctx context.Context) {
	account, err := api.GetAccount(ctx, block, w.Address())
	if err == nil {
		lastLt := account.LastTxLT
		lastHash := account.LastTxHash
		
		// دریافت آخرین LT پردازش شده از جدول blockchain_tracking
		walletAddress := w.Address().String()
		blockchainTracking, err := GetBlockchainTracking(walletAddress, db)
		var lastSavedLT uint64 = 0
		
		if err == nil && blockchainTracking.Id > 0 {
			lastSavedLT, _ = strconv.ParseUint(blockchainTracking.LastProcessedLT, 10, 64)
			fmt.Printf("DEBUG: Last processed LT from blockchain_tracking for wallet %s: %d\n", walletAddress, lastSavedLT)
		} else {
			// اگر رکورد وجود ندارد، آن را ایجاد می‌کنیم
			CreateBlockchainTracking(walletAddress, "0", "", db)
			fmt.Printf("DEBUG: Created new blockchain_tracking record for wallet: %s\n", walletAddress)
		}
		
		transactions, _ := api.ListTransactions(ctx, w.WalletAddress(), 150, lastLt, lastHash)
		if len(transactions) > 0 {
			var maxProcessedLT uint64 = lastSavedLT
			processedTransactions := 0
			
			for _, t := range transactions {
				if t.LT > lastSavedLT {
					if utils.ConvertAnyToString(t.IO.In.MsgType) == configs.DepositMessage {
						amount := t.IO.In.AsInternal().Amount
						comment := t.IO.In.AsInternal().Comment()
						userUniqueNumbers := strings.Split(comment, "-")
						if len(userUniqueNumbers) > 1 {
							userUniqueNumber := userUniqueNumbers[1]
							user, err := GetUserWithUniqueIdentifier(userUniqueNumber, db)
							if err == nil && user.Id > 0 {
								// بررسی که آیا این تراکنش قبلاً پردازش شده یا نه
								existingTransactions, _ := GetTransactionWithTransactionId(utils.ConvertAnyToString(t.LT), db)
								if len(existingTransactions) == 0 {
									_, createErr := CreateTransaction("ton", "deposit", amount.Nano().Text(10), "success", utils.ConvertAnyToString(t.LT), string(t.String()), user.Id, db)
									if createErr == nil {
										processedTransactions++
										fmt.Printf("DEBUG: Processed transaction LT: %d for user: %s, amount: %s\n", 
											t.LT, userUniqueNumber, amount.Nano().Text(10))
									} else {
										fmt.Printf("DEBUG: Error creating transaction for LT %d: %v\n", t.LT, createErr)
									}
								} else {
									fmt.Printf("DEBUG: Transaction LT %d already exists, skipping\n", t.LT)
								}
							}
						}
					}
					
					// به‌روزرسانی بیشترین LT پردازش شده
					if t.LT > maxProcessedLT {
						maxProcessedLT = t.LT
					}
				}
			}
			
			// به‌روزرسانی blockchain_tracking با آخرین LT پردازش شده
			if maxProcessedLT > lastSavedLT {
				err = UpdateBlockchainTracking(walletAddress, utils.ConvertAnyToString(maxProcessedLT), utils.ConvertAnyToString(lastHash), db)
				if err == nil {
					fmt.Printf("DEBUG: Updated blockchain_tracking for wallet %s with LT: %d, processed %d new transactions\n", 
						walletAddress, maxProcessedLT, processedTransactions)
				} else {
					fmt.Printf("DEBUG: Error updating blockchain_tracking for wallet %s: %v\n", walletAddress, err)
				}
			}
		}
	} else {
		fmt.Printf("DEBUG: Error getting account: %v\n", err)
	}
}
func SendTonToWalletAddress(ctx context.Context, amount string, destinationWalletAddress string) bool {
	api := CreateApiWallet(false, ctx)
	
	// لاگ کردن اطلاعات قبل از ارسال
	logMessage := fmt.Sprintf("درحال تلاش برای ارسال %s TON به آدرس %s", amount, destinationWalletAddress)
	fmt.Println(logMessage)
	
	// بررسی ولید بودن کلمات کیف پول کازینو
	if len(configs.CasinoWallet) == 0 {
		errorMessage := "خطا: کلمات کیف پول کازینو تنظیم نشده است"
		fmt.Println(errorMessage)
		return false
	}
	
	words := strings.Split(configs.CasinoWallet, " ")
	if len(words) < 12 {
		errorMessage := fmt.Sprintf("خطا: تعداد کلمات کیف پول کازینو کافی نیست (تعداد: %d)", len(words))
		fmt.Println(errorMessage)
		return false
	}
	
	// بررسی معتبر بودن آدرس مقصد
	if len(destinationWalletAddress) < 10 {
		errorMessage := fmt.Sprintf("خطا: آدرس کیف پول مقصد نامعتبر است: %s", destinationWalletAddress)
		fmt.Println(errorMessage)
		return false
	}
	
	// تلاش برای ارسال با مدیریت خطای پنیک
	defer func() {
		if r := recover(); r != nil {
			errorMessage := fmt.Sprintf("پنیک در هنگام ارسال: %v", r)
			fmt.Println(errorMessage)
		}
	}()
	
	// ایجاد کیف پول و ارسال تراکنش
	w := GetWalletFromWords(api, wallet.ConfigV5R1Final{NetworkGlobalID: wallet.MainnetGlobalID}, words, ctx)
	
	// بررسی کیف پول
	if w == nil {
		errorMessage := "خطا: کیف پول ایجاد نشد"
		fmt.Println(errorMessage)
		return false
	}
	
	// fmt.Println(fmt.Sprintf("آدرس کیف پول کازینو: %s", w.Address().String()))

	// بررسی موجودی کیف پول کازینو
	block := GetBlockFromApi(api, ctx)
	if block == nil {
		errorMessage := "خطا در دریافت اطلاعات بلاک"
		fmt.Println(errorMessage)
		return false
	}
	
	balance, err := w.GetBalance(ctx, block)
	if err != nil {
		errorMessage := fmt.Sprintf("خطا در دریافت موجودی کیف پول: %s", err.Error())
		fmt.Println(errorMessage)
		return false
	}
	
	// تبدیل مقدار ارسالی به عدد و محاسبه کارمزد
	amountFloat, err := strconv.ParseFloat(amount, 64)
	if err != nil {
		errorMessage := fmt.Sprintf("خطا در تبدیل مقدار ارسالی: %s", err.Error())
		fmt.Println(errorMessage)
		return false
	}
	
	// اضافه کردن 0.05 TON برای کارمزد
	amountWithFee := amountFloat + 0.05
	amountNano := tlb.MustFromTON(fmt.Sprintf("%.9f", amountWithFee)).Nano().Uint64()
	
	// بررسی کافی بودن موجودی با در نظر گرفتن کارمزد
	if balance.Nano().Uint64() < amountNano {
		errorMessage := fmt.Sprintf("خطا: موجودی کیف پول کازینو ناکافی است.\nموجودی: %s TON\nمقدار درخواستی + کارمزد: %.9f TON", 
			balance.TON(), amountWithFee)
		fmt.Println(errorMessage)
		return false
	}
	
	// گزارش موجودی
	balanceInfo := fmt.Sprintf("موجودی کیف پول کازینو: %s TON\nمقدار درخواستی + کارمزد: %.9f TON", 
		balance.TON(), amountWithFee)
	fmt.Println(balanceInfo)
	
	// اگر مقدار ارسالی کوچکتر یا مساوی صفر باشد
	if amountFloat <= 0 {
		errorMessage := fmt.Sprintf("خطا: مبلغ ارسالی نامعتبر است: %s", amount)
		fmt.Println(errorMessage)
		return false
	}
	
	// بررسی آدرس کیف پول مقصد
	var to *address.Address
	
	// مدیریت خطا در پارس کردن آدرس
	func() {
		defer func() {
			if r := recover(); r != nil {
				errorMessage := fmt.Sprintf("خطا در پارس کردن آدرس مقصد: %v", r)
				fmt.Println(errorMessage)
			}
		}()
		to = address.MustParseAddr(destinationWalletAddress)
	}()
	
	// لاگ کردن جزئیات تراکنش قبل از ارسال
	transactionDetails := fmt.Sprintf("جزئیات تراکنش:\nاز: %s\nبه: %s\nمبلغ: %s TON\nبا کارمزد: %.9f TON", 
		w.Address().String(), destinationWalletAddress, amount, amountWithFee)
	fmt.Println(transactionDetails)
	
	// ارسال تراکنش
	comment := "withdraw status success from winball telegram bot!"
	tonAmount := utils.ConvertAnyToString(amount)
	
	// تلاش مجدد برای ارسال در صورت خطا (حداکثر 3 بار)
	maxRetries := 3
	var lastError error
	
	for i := 0; i < maxRetries; i++ {
		// بررسی مجدد موجودی قبل از هر تلاش
		currentBalance, err := w.GetBalance(ctx, block)
		if err != nil || currentBalance.Nano().Uint64() < amountNano {
			errorMessage := fmt.Sprintf("خطا: موجودی ناکافی در تلاش %d از %d", i+1, maxRetries)
			fmt.Println(errorMessage)
			continue
		}
		
		err = w.Transfer(ctx, to, tlb.MustFromTON(tonAmount), comment)
		if err == nil {
			// تایید تراکنش
			time.Sleep(5 * time.Second) // صبر برای تایید تراکنش
			newBalance, err := w.GetBalance(ctx, block)
			if err == nil && newBalance.Nano().Uint64() < balance.Nano().Uint64() {
				successMessage := fmt.Sprintf("✅ %s TON با موفقیت به آدرس %s ارسال شد\nموجودی جدید: %s TON", 
					amount, destinationWalletAddress, newBalance.TON())
				fmt.Println(successMessage)
				return true
			}
			lastError = fmt.Errorf("تراکنش تایید نشد")
			continue
		}
		
		lastError = err
		retryMessage := fmt.Sprintf("خطا در تلاش %d از %d: %s", i+1, maxRetries, err.Error())
		fmt.Println(retryMessage)
		
		time.Sleep(2 * time.Second)
	}
	
	// گزارش خطای نهایی
	if lastError != nil {
		errorMessage := fmt.Sprintf("خطا در ارسال TON پس از %d تلاش:\n%s\nمقدار: %s\nآدرس: %s", 
			maxRetries, lastError.Error(), amount, destinationWalletAddress)
		fmt.Println(errorMessage)
	}
	
	return false
}

func CheckUserSpecificTransactions(api ton.APIClientWrapped, w *wallet.Wallet, block *ton.BlockIDExt, db *sql.DB, ctx context.Context, userUniqueNumber string) bool {
	account, err := api.GetAccount(ctx, block, w.Address())
	if err != nil {
		fmt.Printf("DEBUG: Error getting account: %v\n", err)
		return false
	}

	// دریافت کاربر
	user, err := GetUserWithUniqueIdentifier(userUniqueNumber, db)
	if err != nil || user.Id == 0 {
		fmt.Printf("DEBUG: User %s not found\n", userUniqueNumber)
		return false
	}

	// دریافت آخرین LT پردازش شده
	walletAddress := w.Address().String()
	blockchainTracking, err := GetBlockchainTracking(walletAddress, db)
	var lastSavedLT uint64 = 0
	
	if err == nil && blockchainTracking.Id > 0 {
		lastSavedLT, _ = strconv.ParseUint(blockchainTracking.LastProcessedLT, 10, 64)
	}

	transactions, _ := api.ListTransactions(ctx, w.WalletAddress(), 50, account.LastTxLT, account.LastTxHash) // فقط 50 تراکنش آخر
	userTransactionFound := false

	for _, t := range transactions {
		if t.LT > lastSavedLT {
			if utils.ConvertAnyToString(t.IO.In.MsgType) == configs.DepositMessage {
				comment := t.IO.In.AsInternal().Comment()
				userUniqueNumbers := strings.Split(comment, "-")
				
				// فقط چک کردن تراکنش‌های مربوط به همین کاربر
				if len(userUniqueNumbers) > 1 && userUniqueNumbers[1] == userUniqueNumber {
					// بررسی که آیا قبلاً پردازش شده یا نه
					existingTransactions, _ := GetTransactionWithTransactionId(utils.ConvertAnyToString(t.LT), db)
					if len(existingTransactions) == 0 {
						amount := t.IO.In.AsInternal().Amount
						_, createErr := CreateTransaction("ton", "deposit", amount.Nano().Text(10), "success", utils.ConvertAnyToString(t.LT), string(t.String()), user.Id, db)
						if createErr == nil {
							userTransactionFound = true
							fmt.Printf("✅ Found and processed transaction for user %s: %s TON\n", 
								userUniqueNumber, amount.TON())
						} else {
							fmt.Printf("❌ Error creating transaction for user %s: %v\n", userUniqueNumber, createErr)
						}
					} else {
						fmt.Printf("ℹ️ Transaction already exists for user %s\n", userUniqueNumber)
						userTransactionFound = true
					}
				}
			}
		}
	}

	if !userTransactionFound {
		fmt.Printf("ℹ️ No new transactions found for user %s\n", userUniqueNumber)
	}

	return userTransactionFound
}
